from pathlib import Path
import gzip,hashlib,importlib.util,json,sys
ROOT=Path('/workspace/formal-proofs/bendvy');STAGE=Path('/workspace/formal-proofs/bendvy-worktrees/events53-family-reader-authority');REL=Path('experiments/public-owned-events/family-readers-v1/retirement-loss-control-v1');BASE=Path(sys.argv[1]);OUT=Path('/tmp/bendvy53-retirement-loss-actual01')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
freeze=STAGE/REL/'SOURCE-FREEZE.json';f=json.loads(freeze.read_text());assert all(sha(p)==h for p,h in f['sourceInventory'].items());sourcepins={x['path']:x['sha256'] for x in f['sources']};assert all(sha(p)==h for p,h in sourcepins.items())
import re
reached=set()
def visit(p):
 p=Path(p).resolve();
 if str(p) in reached:return
 assert str(p) in f['sourceInventory'];reached.add(str(p))
 for target in re.findall(r'^import\s+(\S+)',p.read_text(),re.MULTILINE):
  if target!='Base':visit(p.parent/target)
visit(f['entrypoint']);f['sourceInventory']={p:f['sourceInventory'][p] for p in sorted(reached)}
collector=ROOT/'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/development.py';guardpath=ROOT/'experiments/public-inspect/development-plan-guard-v1/plan_guard.py';config=ROOT/'experiments/public-simulation/delivery-v1/installed-config.py';runnerpath=ROOT/'scripts/task_runner.py';cfg=load('config',config);runner=load('runner',runnerpath);guard=load('guard',guardpath)
tools={'bend':'/home/node/.bend/bin/bend-2.0.35','node':'/home/node/.local/share/mise/installs/node/24.20.0/bin/node','python':'/usr/bin/python3.11','taskset':'/usr/bin/taskset','clangWrapper':'/tmp/bendvy-clang19-diagnostic/clang19','clangBinary':'/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'}
closure_validator=load('closure_validator',collector);assert closure_validator.validate_imports(f['entrypoint'],f['sourceInventory'])==sorted(f['sourceInventory'])
NORMAL=BASE.parents[1]/'oracle-successor-v2'
FORMAT=BASE.parents[1]/'oracle'/'format.py'
pins=dict(sourcepins)
for p in [*sorted(p for p in NORMAL.iterdir() if p.is_file()),FORMAT]:pins[str(p)]=sha(p)
for p in [collector,guardpath,config,runnerpath,freeze,ROOT/'scripts/evidence_boundary.py',Path(__file__),*map(Path,tools.values()),*sorted(p for p in BASE.iterdir() if p.is_file()),*sorted(p for p in (STAGE/REL).iterdir() if p.is_file()),*sorted(p for p in (STAGE/REL/'checks').rglob('*') if p.is_file())]:pins[str(p)]=sha(p)
# Base/effect bodies and installed native headers/libraries are covered by exact resources.
resources=runner.Inputs(directories=cfg.RESOURCE_ROOTS).expected
OUT.mkdir(exist_ok=False)
for case in ['mutant']:
 entry=Path(f['entrypoint']);inv=f['sourceInventory'];oracle=BASE/'expected.stdout.gz';raw=gzip.decompress(oracle.read_bytes());assert raw==(BASE/'expected.stdout').read_bytes();assert len(raw)==90719;assert hashlib.sha256(raw).hexdigest()=='ac8fb3f9415a3c4b29e7eace6fb9bf6f802de67bf9f943da9dc2ca19e79e900e'
 for role in ['js','native']:
  out=OUT/case/role;out.mkdir(parents=True);generated=out/('scenario.js' if role=='js' else 'scenario.c');native=out/'scenario.native';prefix=[tools['taskset'],'-c','3'];commands=[{'label':'emit','argv':prefix+[tools['bend'],str(entry),'-o',str(generated)],'capSeconds':30}]
  if role=='native':commands += [{'label':'build','argv':prefix+[tools['clangWrapper'],'-O3',str(generated),'-o',str(native),'-pthread','-lm'],'capSeconds':120},{'label':'consumer','argv':prefix+[str(native),'--threads','1','--gpu','off'],'capSeconds':5}]
  else:commands += [{'label':'consumer','argv':prefix+[tools['node'],str(generated)],'capSeconds':5}]
  plan={'scope':'Reached retirement-loss mutant: frame receipts omitted, all runtime state retained. Ordinary #53 three-family owned readers: independent same-family readers and unlike payload readers, full Host and runtime state, failure/retry, skip, frame/lag, foreign refusal, typed retirement receipts, shutdown and disposal without fabricated reader owners','role':role,'subject':'mutant','entrypoint':str(entry),'stage':str(entry.parent),'cwd':str(entry.parent),'sourceInventory':inv,'importClosure':sorted(inv),'pins':pins,'resourceRoots':resources,'environment':cfg.environment(),'tools':tools,'commands':commands,'oracle':str(oracle),'oracleBytes':len(raw),'oracleSHA256':hashlib.sha256(raw).hexdigest(),'normalOracle':str(NORMAL/'expected.stdout.gz'),'normalOracleBytes':90973,'normalOracleSHA256':'98107a0f330aeae49e55ac96403f8bb2462791206b61d3b9afb60c8884049e30','generated':str(generated),'native':str(native),'postConsumer':'Whole independent complete owned-event trace equality; no normalization; empty runtime stderr'}
  guard.validate(plan,output_dir=out);p=out/'plan.json';p.write_text(json.dumps(plan,indent=2)+'\n');print(case,role,str(p),sha(p))
