from pathlib import Path
import hashlib,json,re,subprocess,os
ROOT=Path('/workspace/formal-proofs/bendvy');OUT=Path(__file__).resolve().parent.parent;BASE='1fafe385e';SUB=Path('experiments/s-perf/canonical-api-v1/dense-runtime-v1/diagnostics/tx-peaks-v1/subject');files={};pins={}
def read(p):return subprocess.check_output(['git','show',BASE+':'+str(p)],cwd=ROOT)
def visit(p):
 p=Path(os.path.normpath(p));key=str(p)
 if key in files:return
 raw=read(p);pins[key]=hashlib.sha256(raw).hexdigest()
 if key.startswith('src/ecs/') and key!='src/ecs/query-contract.bend':return
 files[key]=raw
 if p.suffix=='.bend':
  for name in re.findall(r'^import\s+(\S+)',raw.decode(),re.M):
   if name!='Base':visit(p.parent/name)
  for name in re.findall(r'^\s+import "([^"]+)"',raw.decode(),re.M):visit(p.parent/name)
visit(Path('experiments/s-perf/canonical-api-v1/lifecycle-runtime-v1/motion-main.bend'))
def dest(p):
 p=Path(p)
 if str(p).startswith('src/ecs/') and str(p)!='src/ecs/query-contract.bend':return ROOT/'experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private'/p
 return OUT/'private'/p
for p,raw in files.items():
 target=dest(p);target.parent.mkdir(parents=True,exist_ok=True)
 if p.endswith('.bend'):
  text=raw.decode()
  def imp(m):
   name=m[1]
   if name=='Base':return m[0]
   resolved=Path(os.path.normpath(Path(p).parent/name));return 'import '+os.path.relpath(dest(resolved),target.parent)
  text=re.sub(r'^import\s+(\S+)',imp,text,flags=re.M)
  def ffi(m):return '  import "'+os.path.relpath(dest(Path(os.path.normpath(Path(p).parent/m[1]))),target.parent)+'"'
  text=re.sub(r'^  import "([^"]+)"',ffi,text,flags=re.M);target.write_text(text)
 else:target.write_bytes(raw)
# Preserve original declaration/body/import closure; only private transaction structure adapts.
def split(s):
 stack=[];start=0;out=[];quote=False;escape=False
 for i,c in enumerate(s):
  if quote:
   if escape:escape=False
   elif c=='\\':escape=True
   elif c=='"':quote=False
  elif c=='"':quote=True
  elif c in '({[<':stack.append(c)
  elif c in ')}]' or (c=='>' and stack and stack[-1]=='<' and (i==0 or s[i-1]!='-')):stack.pop()
  elif c==',' and not stack:out.append(s[start:i]);start=i+1
 out.append(s[start:]);return out

def end(text,start):
 stack=[text[start]];quote=False;escape=False
 for i in range(start+1,len(text)):
  c=text[i]
  if quote:
   if escape:escape=False
   elif c=='\\':escape=True
   elif c=='"':quote=False
  elif c=='"':quote=True
  elif c in '({[':stack.append(c)
  elif c in ')}]':
   stack.pop()
   if not stack:return i
 raise ValueError('unbalanced')
# Functions accepting the decomposed actual Tx must thread the added field.
texts={p:p.read_text() for p in (OUT/'private').rglob('*.bend')};targets={}
for p,t in texts.items():
 for m in re.finditer(r'^def (\w+)\(',t,re.M):
  e=end(t,m.end()-1);params=split(t[m.end():e]);joined=','.join(params)
  if (re.search(r'\bundo\s*:',joined) or re.search(r'\bcommands\s*:',joined)) and re.search(r'\bevents\s*:',joined) and re.search(r'\btrace\s*:',joined):
   at=next(i for i,v in enumerate(params) if re.match(r'\s*\+?trace\s*:',v));targets[p.resolve(),m[1]]=at
changes=[]
for p,t in texts.items():
 aliases={m[2]:(p.parent/m[1]).resolve() for m in re.finditer(r'^import\s+(\S+)\s+as\s+(\w+)',t,re.M)}
 edits=[]
 for m in re.finditer(r'(?<![\w.])(?:(\w+)\.)?(\w+)\(',t):
  key=(aliases.get(m[1],''),m[2]) if m[1] else (p.resolve(),m[2])
  if key not in targets:continue
  a=m.end()-1;e=end(t,a);args=split(t[a+1:e]);at=targets[key]
  defining=bool(re.search(r'def\s+$',t[max(0,m.start()-5):m.start()]))
  if defining:args.insert(at+1,'meter:Meter.State')
  else:args.insert(at+1,'meter')
  edits.append((a+1,e,','.join(args)))
 for a,e,r in reversed(edits):t=t[:a]+r+t[e:]
 # Sixth field for every private Tx pattern, constructor and declaration.
 edits=[]
 for m in re.finditer(r'\bTx\{',t):
  a=m.end()-1;e=end(t,a);fields=split(t[a+1:e]);assert len(fields)==5,(p,m.start(),fields)
  line=t[t.rfind('\n',0,m.start())+1:m.start()]
  pattern='case ' in line and ':' not in line[line.index('case '):]
  if 'world:' in fields[0]:meter='meter:Meter.State'
  elif pattern:meter='_' if all(x.strip()=='_' for x in fields[1:]) else 'meter'
  elif fields[1].strip()=='[]' and fields[2].strip()=='[]' and fields[3].strip()=='[]':meter='Meter.empty(Unit{})'
  else:
   meter='meter';delta=[int('<>' in fields[i]) for i in [1,2,3]]
   if any(delta):
    prefix=t[:m.start()];fn=list(re.finditer(r'^def (\w+)\(',prefix,re.M))[-1][1];site=p.stem+'.'+fn;meter='Meter.append(meter,"'+site+'",'+','.join(str(n)+'n' for n in delta)+')';changes.append({'file':p.name,'function':fn,'delta':delta})
   elif fields[2].strip()=='[]':meter='Meter.transfer_commands(meter,"'+p.stem+'.stage")'
  fields.append(meter);edits.append((a+1,e,','.join(fields)))
 for a,e,r in reversed(edits):t=t[:a]+r+t[e:]
 if t!=texts[p]:
  meterpath=os.path.relpath(ROOT/'experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/meter.bend',p.parent);t='import '+meterpath+' as Meter\n'+t
 p.write_text(t)
(OUT/'COPY-BASIS.json').write_text(json.dumps({'baseline':BASE,'sourcePins':pins,'privateAppendSites':changes,'scope':'Actual imported closure private-rebased; sixth Data meter, original TraceFacts module unchanged; trusted constructor/raw-helper propagation only.'},indent=2)+'\n')
print('closure',len(files),'append sites',len(changes),'raw helpers',len(targets))
