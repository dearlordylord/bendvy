from pathlib import Path
import sys,hashlib,json,gzip,re,importlib.util
root=Path('/workspace/formal-proofs/bendvy')
wt=Path('/workspace/formal-proofs/bendvy-worktrees/readers43-reader-parameter')
entry=wt/'experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/capacity-v1/array-transport-v1/matched-feature-v1/ordinary-io-disposal-consumer.bend'
evidence=wt/'experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/capacity-v1/array-transport-v1/matched-feature-v1/io-disposal-evidence-v1'
source_oracle=Path(sys.argv[1]).resolve(strict=True)
expected_sha=sys.argv[2]
expected=source_oracle.read_bytes()
assert hashlib.sha256(expected).hexdigest()==expected_sha,'Independent oracle changed'
out=evidence/'execution-v1';out.mkdir(exist_ok=False)
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(name,p):
 s=importlib.util.spec_from_file_location(name,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
config=root/'experiments/public-simulation/delivery-v1/installed-config.py';configuration=load('configuration',config)
runner=load('runner',root/'scripts/task_runner.py')
collector=root/'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/development.py'
guard=root/'experiments/public-inspect/development-plan-guard-v1/plan_guard.py'
oracle=out/'expected.stdout.gz';oracle.write_bytes(gzip.compress(expected,mtime=0))
inventory={}
def visit(p):
 p=p.resolve(strict=True)
 if str(p) in inventory:return
 inventory[str(p)]=sha(p)
 for target in re.findall(r'^import\s+(\S+)',p.read_text(),re.M):
  if target!='Base':visit(p.parent/target)
visit(entry)
tools={'bend':'/home/node/.bend/bin/bend-2.0.35','node':'/home/node/.local/share/mise/installs/node/24.20.0/bin/node','python':str(Path(sys.executable).resolve()),'taskset':'/usr/bin/taskset','clangWrapper':'/tmp/bendvy-clang19-diagnostic/clang19','clangBinary':'/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'}
extra=[config,collector,guard,root/'scripts/task_runner.py',root/'scripts/evidence_boundary.py',root/'scripts/bend-check',root/'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/development.py',Path(__file__),oracle,*map(Path,tools.values())]
extra.extend(p for p in source_oracle.parent.iterdir() if p.is_file())
extra.extend([evidence/'ORACLE-REBIND.json',evidence/'CANDIDATE-SOURCE.json',evidence/'source-pins-original.json',evidence/'source-check/result.json',evidence/'source-check/stdout',evidence/'source-check/stderr',root/'src/ecs/world-namespace.c',root/'src/ecs/world-namespace.js'])
pins=inventory|{str(p.resolve()):sha(p) for p in extra}
resources=runner.Inputs(directories=configuration.RESOURCE_ROOTS).expected
for role in ['js','native']:
 d=out/role;d.mkdir();generated=d/('scenario.js' if role=='js' else 'scenario.c');native=d/'scenario.native';prefix=[tools['taskset'],'-c','5']
 commands=[{'label':'emit','argv':prefix+[tools['bend'],str(entry),'-o',str(generated)],'capSeconds':30}]
 if role=='native':commands.extend([{'label':'build','argv':prefix+[tools['clangWrapper'],'-O3',str(generated),'-o',str(native),'-pthread','-lm'],'capSeconds':120},{'label':'consumer','argv':prefix+[str(native),'--threads','1','--gpu','off'],'capSeconds':5}])
 else:commands.append({'label':'consumer','argv':prefix+[tools['node'],str(generated)],'capSeconds':5})
 plan={'scope':'IO-origin ordinary provider disposal: two sequential WorldIO-created same-schema worlds; foreign-context refusal preserves complete Context and Provider; subsequent owning-context disposal succeeds. Finite bounded consumer, not full #43 acceptance.','role':role,'subject':'normal','entrypoint':str(entry),'stage':str(entry.parent),'sourceInventory':inventory,'importClosure':sorted(inventory),'pins':pins,'resourceRoots':resources,'environment':configuration.environment(),'cwd':str(entry.parent),'tools':tools,'commands':commands,'oracle':str(oracle),'oracleSHA256':expected_sha,'oracleBytes':len(expected),'normalOracle':str(oracle),'normalOracleSHA256':expected_sha,'normalOracleBytes':len(expected),'generated':str(generated),'native':str(native),'postConsumer':'Entire independent source-derived JSON+LF equality for actual WorldIO host allocation and provider disposal; empty runtime stderr'}
 target=d/'plan.json';target.write_text(json.dumps(plan,indent=2)+'\n');load('guard_'+role,guard).validate(plan,output_dir=d)
 print(role,sha(target),len(inventory),len(expected))
