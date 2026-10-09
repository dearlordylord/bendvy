"""Prepare-only bindings to the existing reviewed declaration collector; no child."""
import hashlib,json,re,types,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
RUNNER=ROOT/'experiments/public-owned-events/declaration-read-v1/development-run.py'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(path):
 p=types.ModuleType('retention_preparation');p.__file__=str(path);exec(compile(path.read_bytes(),str(path),'exec'),p.__dict__);return p

def closure(entry):
 reached=set()
 def visit(p):
  p=p.resolve()
  if p in reached:return
  reached.add(p)
  for name in re.findall(r'^import\s+(\S+)',p.read_text(),re.M):
   visit(Path('/home/node/.bend/bend2/base.bend')if name=='Base'else p.parent/name)
 visit(entry);return {str(p):sha(p)for p in sorted(reached)}
def prepare(base):
 base.mkdir(exist_ok=False)
 runner=load(RUNNER);rows=[]
 for name in ('normal','retainer'):
  transport=HERE/('transport.py'if name=='normal'else 'transport-retainer.py')
  oracle=HERE/('expected.json'if name=='normal'else 'expected-retainer.json')
  raw=HERE/('expected.stdout'if name=='normal'else 'expected-retainer.stdout')
  expected=(load(transport).render('generic',json.loads(oracle.read_bytes()))+'\n').encode()
  if raw.exists():assert not raw.is_symlink()and raw.read_bytes()==expected, 'frozen raw oracle differs'
  else:
   with raw.open('xb')as stream:stream.write(expected)
  entry=HERE/('main.bend'if name=='normal'else 'mutant-retainer/main.bend')
  pin=lambda p:{'path':str(p),'sha256':sha(p)}
  binding={'role':'generic','entry':pin(entry),'sourcePins':closure(entry),'oracles':[pin(raw),pin(oracle)],'oracleCommit':'a7c358e56afcf0e03c393ff576a2676dc7631647 + independent9752741d','transport':pin(transport),'transportInputs':[pin(HERE/'transport.py'),pin(ROOT/'experiments/public-owned-events/registered-read-v1/transport.py')],'tools':{k:pin(Path(p))for k,p in {'bend':'/home/node/.bend/bin/bend-2.0.35','node':'/home/node/.local/share/mise/installs/node/24.20.0/bin/node','taskset':'/usr/bin/taskset'}.items()}}
  bindingPath=base/(name+'-binding.json');bindingPath.write_text(json.dumps(binding,indent=2)+'\n');digest=sha(bindingPath)
  for native in (False,True):
   out=base/(name+('-native'if native else '-js'));runner.main(out,native=native,role='generic',binding_path=bindingPath,binding_digest=digest)
   plan=out/'plan.json';rows.append({'name':name,'native':native,'plan':str(plan),'planSha256':sha(plan),'binding':str(bindingPath),'bindingSha256':digest,'commands':json.loads(plan.read_bytes())['commands']})
 index=HERE/('PREPARED.json'if not(HERE/'PREPARED.json').exists()else base.name+'-INDEX.json')
 with index.open('x')as stream:stream.write(json.dumps({'scope':'Current13-step retention models, stock installed2.0.35 first; no runtime/adoption/performance claim','collector':str(RUNNER),'collectorSha256':sha(RUNNER),'plans':rows},indent=2)+'\n')
 if __name__=='__main__':print('Prepared four complete plans; no child')
if __name__=='__main__':prepare(Path(sys.argv[1]).resolve())
