#!/usr/bin/env python3
"""Separate Native-only private helper recipe; does not edit common sources."""
import argparse,hashlib,json,pathlib,re,shutil
HERE=pathlib.Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()

def split_args(text):
 out=[];depth=0;angles=0;start=0
 for i,c in enumerate(text):
  if c in '([{':depth+=1
  elif c in ')]}':depth-=1
  elif c=='<':angles+=1
  elif c=='>' and i and text[i-1]!='-' and angles:angles-=1
  elif c==',' and depth==0 and angles==0:out.append(text[start:i].strip());start=i+1
 out.append(text[start:].strip());return out

def replace_calls(text,names,transform):
 # Innermost-first, preserves all argument bytes except explicit additions.
 for name in names:
  pattern=re.compile(r'(?<![A-Za-z0-9_.])'+re.escape(name)+r'\(')
  matches=list(pattern.finditer(text))
  for match in reversed(matches):
   start=match.end();depth=1;end=start
   while depth:
    if text[end]=='(':depth+=1
    elif text[end]==')':depth-=1
    end+=1
   text=text[:match.start()]+transform(name,split_args(text[start:end-1]))+text[end:]
 return text

def copy_capacity(body,param=False):
 lines=[]
 for line in body.splitlines():
  if line.lstrip().startswith('case ') and ':' in line:
   a,b=line.split(':',1);a=re.sub(r'(?<![A-Za-z_+])capacity\b','+capacity',a);a=re.sub(r'(?<![A-Za-z_+])c\b','+c',a) if 'Rows{' in a else a;line=a+':'+b
  lines.append(line)
 if param:
  copied=[]
  for line in lines:
   if line.lstrip().startswith('case ') and ':' in line:
    prefix,expression=line.split(':',1);indent=len(line)-len(line.lstrip())+2;copied.append(prefix+':');copied.append(' '*indent+'+capacity = capacity')
    if expression.strip():copied.append(' '*indent+expression.strip())
   else:copied.append(line)
  lines=copied
 return '\n'.join(lines)+'\n'

def blocks(text):return list(re.finditer(r'^def ([A-Za-z0-9_]+)[\s\S]*?(?=^(?:def|type|import) |\Z)',text,re.M))
def header_body(block):
 depth=0;angles=0
 for i,c in enumerate(block):
  if c in '([{':depth+=1
  elif c in ')]}':depth-=1
  elif c=='<':angles+=1
  elif c=='>' and i and block[i-1]!='-' and angles:angles-=1
  elif c==':' and not depth and not angles:return block[:i+1],block[i+2:]
 raise ValueError('header boundary')

def main():
 p=argparse.ArgumentParser();p.add_argument('--base',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args()
 frozen=json.loads((HERE/'source-bindings.json').read_text())
 assert all(sha(a.base/'experiments/s-integrate'/n)==v for n,v in frozen['baseline'].items())
 assert a.base.is_absolute() and a.base.resolve()==a.base and a.output.is_absolute() and a.output.resolve()==a.output and not a.output.exists();core=a.base/'experiments/s-integrate';a.output.mkdir();shutil.copytree(a.base/'experiments',a.output/'experiments');target=a.output/'experiments/s-integrate'
 original={n:(core/n).read_text() for n in ['storage.bend','query.bend','held-adapter.bend']}
 helper=(HERE/'column-native.bend').read_text().replace('import Base\n','')
 for name in ['left','right','swap_go','get_go','get','swap','set_done','set']:
  helper=re.sub(r'(?<![A-Za-z0-9_.])'+name+r'(?=\()', 'native_column_'+name,helper)
 storage=original['storage.bend'];storage=storage.replace('def slots_empty',helper+'\ndef slots_empty',1)
 take=(HERE/'cached-take.bend.txt').read_text().replace('S.','').replace('NC.get(', 'native_column_get(').replace('NC.swap(', 'native_column_swap(')
 take=re.sub(r'\bcached_', 'native_',take)
 storage+='\n'+take
 (target/'storage.bend').write_text(storage)
 query=original['query.bend'];names=['struct_idx_return','struct_idx_aux','struct_idx_main','struct_idx_selected','struct_idx_metadata','struct_idx_advance','struct_idx_finish','struct_idx_go'];clones=[]
 for match in blocks(query):
  if match[1] not in names:continue
  h,body=header_body(match[0]);name=match[1];h=h.replace('def '+name+'(', 'def native_'+name+'(',1);h=re.sub(r'-([MAFO]):',r'~\1:',h)
  has_capacity='capacity: U32' in h
  if not has_capacity:
   at=h.rfind(') ->');assert at>=0;h=h[:at]+',+capacity: U32'+h[at:]
  def thread(callee,args):return 'native_'+callee+'('+','.join(args+([] if callee in ['struct_idx_go','struct_idx_finish'] else ['capacity']))+')'
  body=replace_calls(body,names,thread)
  body=replace_calls(body,['Array.get','Array.set','Array.swap'],lambda op,args:'S.native_column_'+op.split('.')[1]+'('+','.join(args[:2]+['capacity']+args[2:])+')')
  clones.append(h+'\n'+body)
 # Define in original dependency order, before the public read_rows entry.
 at=query.index('def read_rows(');query=query[:at]+'\n'.join(clones)+'\n'+query[at:]
 matches=[m for m in blocks(query) if m[1]=='read_rows'];match=matches[0];h,body=header_body(match[0]);body=body.replace('struct_idx_go(', 'native_struct_idx_go(');query=query[:match.start()]+h+'\n'+body+query[match.end():];(target/'query.bend').write_text(query)
 adapter=original['held-adapter.bend'];adapter=replace_calls(adapter,['Array.set'],lambda op,args:'S.native_column_set('+','.join(args[:2]+['cap']+args[2:])+')')
 adapter=adapter.replace('S.take_rows(', 'S.native_take_rows(')
 adapter=re.sub(r'(S.Rows\{columns,aux,meta,)cap,',r'\1+cap,',adapter);(target/'held-adapter.bend').write_text(adapter)
 changed={n:sha(target/n) for n in original};receipt={'scope':'Native-only private column recipe; no accepted measurement','inputCore':str(core),'baseline':{n:sha(core/n) for n in original},'variant':changed,'priorColumnHelperSha256':sha(HERE/'column-native.bend'),'newImportAdded':False,'providerHeadersMustRemainExact':True,'JS':'original final JS recipe untouched','domain':'committed balanced equal-depth Main/Aux/metadata arrays; exact cached nonzero power-of-two capacity; guarded IDs before subtraction/descent; no forged shape claim'}
 (a.output/'native-columns-recipe.json').write_text(json.dumps(receipt,indent=2)+'\n');print('PREPARED_PRIVATE_NATIVE_COLUMN_VARIANT')
if __name__=='__main__':main()
