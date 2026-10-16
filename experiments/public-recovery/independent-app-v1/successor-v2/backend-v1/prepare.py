from pathlib import Path
import gzip,hashlib,importlib.util,json,sys
ROOT=Path('/workspace/formal-proofs/bendvy');STAGE=Path('/workspace/formal-proofs/bendvy-worktrees/recovery52-independent-application');REL=Path('experiments/public-recovery/independent-app-v1/successor-v2');BASE=Path(sys.argv[1]);OUT=Path('/tmp/bendvy52-independent-app-actual02')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
freeze=STAGE/REL/'SOURCE-FREEZE.json';original=json.loads(freeze.read_text());assert all(sha(STAGE/x['path'])==x['sha256'] for x in original['closure'])
f={'entrypoint':str(STAGE/original['entry']),'sourceInventory':{str(STAGE/x['path']):x['sha256'] for x in original['closure'] if x['path'].endswith('.bend')},'sourcePins':{str(STAGE/x['path']):x['sha256'] for x in original['closure']}}
collector=ROOT/'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/development.py';guardpath=ROOT/'experiments/public-inspect/development-plan-guard-v1/plan_guard.py';config=ROOT/'experiments/public-simulation/delivery-v1/installed-config.py';runnerpath=ROOT/'scripts/task_runner.py';cfg=load('config',config);runner=load('runner',runnerpath);guard=load('guard',guardpath)
tools={'bend':'/home/node/.bend/bin/bend-2.0.35','node':'/home/node/.local/share/mise/installs/node/24.20.0/bin/node','python':'/usr/bin/python3.11','taskset':'/usr/bin/taskset','clangWrapper':'/tmp/bendvy-clang19-diagnostic/clang19','clangBinary':'/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'}
pins=dict(f['sourcePins'])
for p in [collector,guardpath,config,runnerpath,freeze,ROOT/'scripts/evidence_boundary.py',Path(__file__),*map(Path,tools.values()),*sorted(p for p in BASE.iterdir() if p.is_file()),*sorted(p for p in (STAGE/REL).iterdir() if p.is_file())]:pins[str(p)]=sha(p)
# Base/effect bodies and installed native headers/libraries are covered by exact resources.
resources=runner.Inputs(directories=cfg.RESOURCE_ROOTS).expected
OUT.mkdir(exist_ok=False)
for case in ['normal']:
 entry=Path(f['entrypoint']);inv=f['sourceInventory'];oracle=BASE/'oracle.txt.gz';raw=gzip.decompress(oracle.read_bytes());assert raw==(BASE/'oracle.txt').read_bytes()
 for role in ['js','native']:
  out=OUT/case/role;out.mkdir(parents=True);generated=out/('scenario.js' if role=='js' else 'scenario.c');native=out/'scenario.native';prefix=[tools['taskset'],'-c','3'];commands=[{'label':'emit','argv':prefix+[tools['bend'],str(entry),'-o',str(generated)],'capSeconds':30}]
  if role=='native':commands += [{'label':'build','argv':prefix+[tools['clangWrapper'],'-O3',str(generated),'-o',str(native),'-pthread','-lm'],'capSeconds':120},{'label':'consumer','argv':prefix+[str(native),'--threads','1','--gpu','off'],'capSeconds':5}]
  else:commands += [{'label':'consumer','argv':prefix+[tools['node'],str(generated)],'capSeconds':5}]
  plan={'scope':'Independent ordinary #52 application: exact frozen c120b7a20fbf82567c085c573190781c2205d118 source and full independent oracle; no production/tool changes','role':role,'subject':'normal','entrypoint':str(entry),'stage':str(entry.parent),'cwd':str(entry.parent),'sourceInventory':inv,'importClosure':sorted(inv),'pins':pins,'resourceRoots':resources,'environment':cfg.environment(),'tools':tools,'commands':commands,'oracle':str(oracle),'oracleBytes':len(raw),'oracleSHA256':hashlib.sha256(raw).hexdigest(),'normalOracle':str(oracle),'normalOracleBytes':len(raw),'normalOracleSHA256':hashlib.sha256(raw).hexdigest(),'generated':str(generated),'native':str(native),'postConsumer':'Whole independent complete capture trace equality; no normalization; empty runtime stderr'}
  guard.validate(plan,output_dir=out);p=out/'plan.json';p.write_text(json.dumps(plan,indent=2)+'\n');print(case,role,str(p),sha(p))
