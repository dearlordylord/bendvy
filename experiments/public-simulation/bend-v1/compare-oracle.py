from pathlib import Path
from source_evidence import validate_sources
import json,os,re,hashlib
p=Path('experiments/public-simulation/bend-v1');out=p/'development/full-js-v1';oracle=p/'independent-expected.json';assert hashlib.sha256(oracle.read_bytes()).hexdigest()=='f821c68264eb25c33a674841d0f2abcf466a9d6372e888cfc40b7ae691ae071a'
pins=json.loads((out/'sources.json').read_text());validate_sources(pins)
expected=json.loads(oracle.read_text());actual=json.loads((out/'parsed.json').read_text());labels=set()
def collect(x):
 if isinstance(x,list):
  for y in x:collect(y)
 elif isinstance(x,dict):
  if 'constructor' in x:labels.add(x['constructor'])
  for y in x.values():collect(y)
collect(expected)
files=list(Path('/workspace/formal-proofs/bendvy/src/ecs').glob('*.bend'))+list(Path('experiments/public-simulation/readers-v1').glob('*.bend'))+list(p.glob('*.bend'))
# Explicit disjoint source namespaces; never choose an events.bend by order.
local_sources={f.name:f for f in p.glob('*.bend')}
reader_sources={name:Path('experiments/public-simulation/readers-v1')/name for name in ('pair.bend','readers.bend')}
core_sources={name:Path('/workspace/formal-proofs/bendvy/src/ecs')/name for name in ('world.bend','transaction.bend','event-runtime.bend')}
assert not (set(local_sources)&set(reader_sources) or set(local_sources)&set(core_sources) or set(reader_sources)&set(core_sources))
lookup={**local_sources,**reader_sources,**core_sources};mapping={}
for label in sorted(labels):
 file,name=label.split('::')
 if file=='Base':source=Path('/home/node/.bend/bend2/base.bend');literal=name
 else:
  source=lookup[file];literal=name if file=='main.bend' else os.path.relpath(source.resolve().with_suffix(''),p.resolve())+'.'+name
 declared=set(); in_type=False
 for line in source.read_text().splitlines():
  if line.startswith('type '):
   in_type=True; tail=line.partition(' is ')[2].partition(':')[2].strip()
  elif line and not line[0].isspace() and not line.startswith('#'):
   in_type=False; tail=''
  else: tail=line.strip() if in_type else ''
  constructor=re.match(r'([A-Za-z_][A-Za-z0-9_]*)\s*\{',tail)
  if constructor: declared.add(constructor.group(1))
 assert name in declared,(label,source,'constructor is not declared')
 mapping[label]={'literal':literal,'source':str(source.resolve()),'sha256':hashlib.sha256(source.read_bytes()).hexdigest()}
def join(x):
 if isinstance(x,list):return [join(y) for y in x]
 if isinstance(x,dict):return {k:(mapping[v]['literal'] if k=='constructor' else join(v)) for k,v in x.items()}
 return x
joined=join(expected);(out/'expected-literal.json').write_text(json.dumps(joined,indent=2)+'\n');(out/'constructor-source-join.json').write_text(json.dumps(mapping,indent=2)+'\n')
diffs=[]
def compare(a,b,path='$'):
 if type(a)!=type(b):diffs.append([path,a,b]);return
 if isinstance(a,dict):
  if set(a)!=set(b):diffs.append([path,sorted(a),sorted(b)]);return
  for k in a:compare(a[k],b[k],path+'.'+k)
 elif isinstance(a,list):
  if len(a)!=len(b):diffs.append([path+'.length',len(a),len(b)])
  for i,(x,y) in enumerate(zip(a,b)):compare(x,y,path+f'[{i}]')
 elif a!=b:diffs.append([path,a,b])
compare(joined,actual)
record={'scope':'Complete two-schema fourteen-phase structural development comparison; no Native/negative/mutation/regression qualification.','oracleSha256':hashlib.sha256(oracle.read_bytes()).hexdigest(),'actualStdoutSha256':hashlib.sha256((out/'run.stdout').read_bytes()).hexdigest(),'constructorJoins':len(mapping),'differences':diffs,'completeMatch':not diffs};(out/'oracle-comparison.json').write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record,indent=2)[:4500])
