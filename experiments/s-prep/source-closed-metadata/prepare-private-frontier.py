#!/usr/bin/env python3
"""Bounded diagnostic constructor-preserving private closed-source family."""
import hashlib,json,pathlib,re,shutil,argparse
HERE=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args()
assert not a.output.exists();assert not a.output.absolute().is_relative_to(a.input.resolve());assert not any(x.is_symlink() for x in a.input.rglob('*'));pins={str(x.relative_to(a.input)):hashlib.sha256(x.read_bytes()).hexdigest() for x in a.input.rglob('*.bend')};assert pins==json.loads((HERE/'input-pins.json').read_text());assert len(pins)==29
input_overlay=json.loads((a.input/'overlay.json').read_text());input_cache=json.loads((a.input/'cache-specialization.json').read_text());assert input_cache==input_overlay['cacheSpecialization'];assert input_overlay['sources']==input_cache['runtimeClosure']==input_cache['specializedClosure']==pins;assert input_cache['runtimeClosureSHA256']==hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
source=a.input/'experiments/s-integrate';defs={};aliases={};texts={}
for f in source.glob('*.bend'):
 s=f.read_text();mod=f.stem;texts[mod]=s;aliases[mod]={alias:pathlib.Path(name).stem for name,alias in re.findall(r'^import \./([^ ]+) as (\w+)',s,re.M)}
 for m in re.finditer(r'^def (\w+)\(',s,re.M):
  tail=s[m.start():];n=re.search(r'\n(?:def |type |import )',tail);b=tail[:n.start()+1] if n else tail;defs[(mod,m.group(1))]=b.rstrip()
edges={}
for k,b in defs.items():
 body=b[b.find('\n  '):];body=re.sub(r'#.*','',body);body=re.sub(r'"[^"\n]*"','""',body);edges[k]=set()
 for alias,name in re.findall(r'\b(?:(\w+)\.)?(\w+)\(',body):
  target=(aliases[k[0]].get(alias,alias) if alias else k[0],name)
  if target in defs:edges[k].add(target)
todo=[('storage','rows_empty'),('host','barrier'),('host','barrier_applied')];seen=set()
while todo:
 k=todo.pop()
 if k in seen:continue
 seen.add(k);todo.extend(x for x in edges[k] if x[0] in ('storage','commands'))
selected={k for k in seen if re.search(r'-\w+:\s*(?:Data|Type)',defs[k].split('\n  ')[0])}
params={k:re.findall(r'-(\w+):\s*(?:Data|Type)',defs[k].split('\n  ')[0]) for k in selected}
prefix='prototype_closed_'
def rewrite_calls(mod,b):
 for target in sorted(selected,key=lambda k:len(k[1]),reverse=True):
  spellings=[]
  if target[0]==mod:spellings.append(target[1])
  spellings += [alias+'.'+target[1] for alias,m in aliases[mod].items() if m==target[0]]
  for spelling in spellings:
   pat=r'(?<![\w.])'+re.escape(spelling)+r'\('
   def replace(m):
    tail=b[m.end():];names=params[target]
    if target==('storage','grow'):
     g=re.match(r'([^,]+),M,A,F,',tail);assert g,(spelling,tail[:100]);return spelling.replace(target[1],prefix+target[1])+'(~M,~A,~F,'+g.group(1)+','
    return spelling.replace(target[1],prefix+target[1])+'('+','.join('~'+x for x in names)+(',' if names else '')
   # Match and consume original erased leading argument identifiers exactly.
   if target==('storage','grow'):
    b=re.sub(pat+r'([^,]+),M,A,F,',lambda m:spelling.replace(target[1],prefix+target[1])+'(~M,~A,~F,'+m.group(1)+',',b)
   else:
    head=','.join(params[target]);b=re.sub(pat+re.escape(head)+r'(?=[,)])',lambda m:spelling.replace(target[1],prefix+target[1])+'('+','.join('~'+x for x in params[target]),b)
 return b
shutil.copytree(a.input,a.output)
receipt={}
for mod in ('storage','commands','host'):
 clones=[]
 for key in defs:
  if key not in selected or key[0]!=mod:continue
  b=defs[key];b=rewrite_calls(mod,b)
  b=b.replace('def '+key[1]+'(','def '+prefix+key[1]+'(',1)
  # rewrite_calls skips declaration because argument declarations differ.
  b=re.sub(r'-(\w+):\s*(Data|Type)',r'~\1: \2',b)
  if key==('storage','grow'):b=b.replace('fuel: Nat,~M: Type,~A: Type,~F: Data,','~M: Type,~A: Type,~F: Data,fuel: Nat,')
  clones.append(b)
 receipt[mod]=sorted(name for mm,name in selected if mm==mod)
 if clones:
  insertion='\n# Bounded closed private lifecycle hypothesis; originals retained.\n'+'\n\n'.join(clones)+'\n'
  final=texts[mod].replace('def motion_barrier(',insertion+'\ndef motion_barrier(',1) if mod=='host' else texts[mod]+insertion
  (a.output/'experiments/s-integrate'/f'{mod}.bend').write_text(final)
# Hook only frozen read/init boundaries and the two concrete schema barrier wrappers.
for mod,names in {'identity':['create_checked'],'query':['read_rows_advance','lookup_rows'],'observations':['rows_advance'],'host':['motion_barrier','health_barrier'],'measurement-bend':['motion_barrier','health_barrier']}.items():
 f=a.output/'experiments/s-integrate'/f'{mod}.bend';s=f.read_text()
 for name in names:
  old=defs[(mod,name)];new=rewrite_calls(mod,old)
  if mod in ('host','measurement-bend'):
   # Concrete wrappers have literal closed type arguments, not binder names.
   new=re.sub(r'(?<![\w.])(?:H\.)?barrier\((T\.\w+Schema),(CC\.Cache<T\.\w+,T\.\w+View>),(T\.\w+),(T\.\w+),(CC\.Cache<T\.\w+Ledger,T\.LedgerView>),(T\.\w+Mode),(T\.\w+Ping),(T\.\w+View),(T\.\w+View),(T\.LedgerView),',lambda m:('H.' if mod=='measurement-bend' else '')+prefix+'barrier('+','.join('~'+x for x in m.groups())+',',old)
  assert new!=old,(mod,name,'no hook');s=s.replace(old,new,1)
 f.write_text(s)
for mod,old in texts.items():
 new=(a.output/'experiments/s-integrate'/f'{mod}.bend').read_text()
 assert all(line in new.splitlines() for line in old.splitlines() if line.startswith(('def ','type '))),('public header',mod)
 if mod in ('storage','commands'):assert old in new,('public bodies changed',mod)
newpins={str(x.relative_to(a.output)):hashlib.sha256(x.read_bytes()).hexdigest() for x in a.output.rglob('*.bend')};overlay=json.loads((a.output/'overlay.json').read_text());cache=json.loads((a.output/'cache-specialization.json').read_text());assert cache==overlay['cacheSpecialization'];cache['runtimeClosure']=newpins;cache['specializedClosure']=newpins.copy();cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(newpins,sort_keys=True,separators=(',',':')).encode()).hexdigest();overlay['sources']=newpins;overlay['cacheSpecialization']=cache
for name,value in [('overlay.json',overlay),('cache-specialization.json',cache),('private-frontier.json',{'scope':'UNVERIFIED_PRIVATE_SOURCE_HYPOTHESIS','clones':receipt,'changedModules':[k for k in pins if pins[k]!=newpins[k]],'inputPins':pins,'outputPins':newpins})]:(a.output/name).write_text(json.dumps(value,indent=2)+'\n')
print(json.dumps(receipt))
