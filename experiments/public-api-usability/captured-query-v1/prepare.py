"""Freeze one source-bound JS/Native pair using the unchanged development runner."""
from pathlib import Path
import copy,gzip,hashlib,importlib.util,json,sys
W=Path(__file__).resolve().parents[3];D=Path(__file__).parent;R=Path('/workspace/formal-proofs/bendvy');sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
sys.path.insert(0,str(W/'scripts'))
from task_runner import run
base=Path('/tmp/bendvy21-current-dispatch-acceptance-actual02/normal/js/plan.json');old=json.loads(base.read_text());basis=D/'SOURCE-BASIS02.json';b=json.loads(basis.read_text());entry=D/'main.bend';inv=b['sourceInventory'];foreign=b['foreign'];collector=R/'experiments/public-inspect/ordinary-declaration-v1/canonical-full-consumer-v1/development-v2.py'
spec=importlib.util.spec_from_file_location('collector',collector);c=importlib.util.module_from_spec(spec);spec.loader.exec_module(c);closure=c.validate_imports(entry.parent,inv,[str(entry)])
output=Path('/tmp/bendvy73-captured-query-workshop-actual01');assert not output.exists();output.mkdir();oracle=output/'expected.stdout.gz';oracle.write_bytes(gzip.compress((D/'oracle/workshop.stdout').read_bytes(),mtime=0))
helper_paths=[collector,R/'experiments/public-inspect/development-plan-guard-v1/plan_guard.py',R/'experiments/public-simulation/delivery-v1/installed-config.py',R/'scripts/task_runner.py',R/'scripts/evidence_boundary.py']
pins={str(p):old['pins'][str(p)]for p in helper_paths}
for p in old['tools'].values():pins[p]=sha(p)
for p in old['pins']:
 if p.startswith('/usr/lib/')or p.startswith('/lib/'):pins[p]=old['pins'][p]
pins.update(inv);pins.update(foreign)
for f in [Path(__file__),base,basis,oracle,*[p for p in D.rglob('*')if p.is_file()and'__pycache__'not in p.parts]]:pins[str(f)]=sha(f)
commit=run(['git','rev-parse','HEAD'],cwd=W,text=True,capture_output=True,timeout=15,check=True).stdout.strip()
for role in ['js','native']:
 q=output/'normal'/role;q.mkdir(parents=True);p=copy.deepcopy(old);rolepins=dict(pins);generated=q/('scenario.js'if role=='js'else'scenario.c');native=q/'scenario.native';prefix=[p['tools']['taskset'],'-c','11']
 for key in ['metricArtifact','modelSourceCheckpoint','moduleInterpretation','producer','loweringPrecondition']:p.pop(key,None)
 if role=='js':
  package=q/'package.json';package.write_text('{"type":"commonjs"}\n');rolepins[str(package)]=sha(package);p['moduleInterpretation']={'path':str(package),'sha256':sha(package),'type':'commonjs','scope':'Output-local pinned module interpretation'}
 commands=[{'label':'emit','argv':prefix+[p['tools']['bend'],str(entry),'-o',str(generated)],'capSeconds':60}]
 if role=='native':commands.append({'label':'build','argv':prefix+[p['tools']['clangWrapper'],'-O3',str(generated),'-o',str(native),'-pthread','-lm'],'capSeconds':120})
 commands.append({'label':'consumer','argv':prefix+([p['tools']['node'],str(generated),'workshop']if role=='js'else[str(native),'workshop','--threads','1','--gpu','off']),'capSeconds':180})
 p.update(scope='Public executable ordinary App captured-query helper Workshop; heterogeneous component audit plus typed-error/full-output/affine-owner/cursor failure-retry, full independent oracle; no performance claim',role=role,subject='normal',runtimeArguments=['workshop'],entrypoint=str(entry),stage=str(entry.parent),cwd=str(entry.parent),sourceInventory=inv,sourceEntries=[str(entry)],importClosure=closure,pins=rolepins,generated=str(generated),native=str(native),commands=commands,oracle=str(oracle),oracleBytes=b['oracles']['workshop']['bytes'],oracleSHA256=b['oracles']['workshop']['sha256'],normalOracle=str(oracle),normalOracleBytes=b['oracles']['workshop']['bytes'],normalOracleSHA256=b['oracles']['workshop']['sha256'],postConsumer='Full independent4468-byte equality and empty consumer stderr; no timing qualification.',sourceCommit=commit,modelCommit=commit,sourceFreeze={'path':str(basis),'sha256':sha(basis)},foreignConsumption={'sidecars':foreign})
 for f,h in rolepins.items():assert sha(f)==h,f
 for root,files in p['resourceRoots'].items():
  for rel,h in files.items():assert sha(Path(root)/rel)==h
 plan=q/'plan.json';plan.write_text(json.dumps(p,indent=2)+'\n');print(role,plan,sha(plan),'pins',len(rolepins),'imports',len(inv),flush=True)
