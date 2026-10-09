"""Exact four existing finite consuming cohorts; preparation only, no children."""
from pathlib import Path
import importlib.util,json,hashlib,sys,gzip
P=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('development',P/'native-development.py');M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
h=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main(out):
 out=Path(out).resolve();out.mkdir(exist_ok=False)
 M.prepare(out/'normal-native')
 original=json.loads((out/'normal-native/plan.json').read_text())
 supplementary=[Path(__file__),P/'test_backend_controls.py',P/'backend-controls.stdout',P/'backend-controls.stderr',P/'source-stage.tar.gz',*sorted((P/'oracle-review-v1').glob('*'))]
 for path in supplementary:
  if path.is_file():original['pins'][str(path.resolve())]=h(path)
 original['case']='normal';original['backend']='native'
 node=Path('/home/node/.local/share/mise/installs/node/24.20.0/bin/node').resolve(strict=True)
 original['pins'][str(node)]=h(node);original['tools']['node']=str(node)
 originals={}
 for backend in ['js','native']:
  plan=json.loads(json.dumps(original));target=out/('normal-'+backend)
  if backend=='js':target.mkdir()
  plan['backend']=backend
  if backend=='js':
   plan['generated']=str(target/'scenario.js');plan['native']=str(target/'unused.native')
   plan['commands']=[{'label':'emit','argv':['/usr/bin/taskset','-c','5',plan['tools']['bend'],plan['entrypoint'],'-o',plan['generated']],'capSeconds':30},{'label':'consumer','argv':['/usr/bin/taskset','-c','5',str(node),plan['generated']],'capSeconds':5}]
  path=target/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');originals[backend]=plan;print(str(path),h(path))
 # Mutant plans are prepared after independent counterfactual binding is frozen.
 if not(P/'oracle-review-v1/absence-omission-expected.stdout').exists():return
 for backend in ['js','native']:
  plan=json.loads(json.dumps(originals[backend]));target=out/('absent-slot-omission-'+backend);target.mkdir();mutant=P/'controls/absent-slot-omission';inventory=json.loads((mutant/'source-inventory.json').read_text());plan['case']='absent-slot-omission';oldstage=plan['stage'];plan['stage']=str(mutant/'stage');plan['sourceInventory']=inventory;plan['entrypoint']=str(Path(plan['stage'])/Path(plan['entrypoint']).relative_to(oldstage));plan['importClosure']=M.validate_imports(plan['stage'],inventory)
  plan['pins']={name:value for name,value in plan['pins'].items()if not name.startswith(oldstage+'/')};plan['pins'].update({str((mutant/'stage'/name).resolve()):value for name,value in inventory.items()})
  for path in mutant.glob('*'):
   if path.is_file():plan['pins'][str(path.resolve())]=h(path)
  for path in (P/'oracle-review-v1').glob('*'):
   if path.is_file():plan['pins'][str(path.resolve())]=h(path)
  plan['oracle']=str(P/'oracle-review-v1/absence-omission-expected.txt.gz');raw=gzip.decompress(Path(plan['oracle']).read_bytes());plan['oracleBytes']=len(raw);plan['oracleSHA256']=hashlib.sha256(raw).hexdigest();plan['normalOracle']=str(P/'oracle-review-v1/expected.stdout');plan['normalOracleSHA256']=h(plan['normalOracle']);plan['expectedWitnessCount']=20
  plan['generated']=str(target/('scenario.js'if backend=='js'else'scenario.c'));plan['native']=str(target/'scenario.native')
  for c in plan['commands']:
   c['argv']=[str(target/Path(a).name)if a.startswith(str(out/('normal-'+backend))+'/')else plan['entrypoint']if a==originals[backend]['entrypoint']else a for a in c['argv']]
  path=target/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');print(str(path),h(path))
if __name__=='__main__':main(sys.argv[1])
