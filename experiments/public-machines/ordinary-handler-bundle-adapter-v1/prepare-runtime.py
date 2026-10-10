"""Prepare exact existing detached-v2 collector plans; no child execution."""
from pathlib import Path
import gzip, hashlib, importlib.util, json, sys
ROOT=Path('/workspace/formal-proofs/bendvy'); HERE=Path(__file__).resolve().parent
COLLECTOR=ROOT/'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/development.py'
GUARD=ROOT/'experiments/public-inspect/development-plan-guard-v1/plan_guard.py'
CONFIG=ROOT/'experiments/public-simulation/delivery-v1/installed-config.py'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(name,p):
 spec=importlib.util.spec_from_file_location(name,p); module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module); return module
def main():
 role,case,capture,attempt=sys.argv[1:]; assert role in ('js','native'); assert case == 'A'
 out=HERE/attempt;source=HERE/capture;closure=json.loads((source/'CLOSURE.json').read_text());inventory=closure['sourceInventory'];entry=Path(closure['entrypoint'])
 result=json.loads((source/'result.json').read_text());pins=json.loads((source/'SOURCE.json').read_text())['pins']
 assert result['exit']==0 and result['failure'] is None and json.loads((source/'post.json').read_text())['unchanged']
 assert all(pins.get(n)==h and sha(n)==h for n,h in inventory.items())
 tools={'bend':'/home/node/.bend/bin/bend-2.0.35','node':'/home/node/.local/share/mise/installs/node/24.20.0/bin/node','python':str(Path(sys.executable).resolve()),'taskset':'/usr/bin/taskset','clangWrapper':'/tmp/bendvy-clang19-diagnostic/clang19','clangBinary':'/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'}
 config=load('handler_authority_configuration',CONFIG);helper=load('handler_authority_inputs',ROOT/'scripts/task_runner.py')
 oracle=HERE/(case+'-expected.stdout.gz');normal=HERE/'A-expected.stdout.gz';raw=gzip.decompress(oracle.read_bytes());normal_raw=gzip.decompress(normal.read_bytes());extra=[COLLECTOR,GUARD,CONFIG,HERE/'model.py',HERE/'ORACLES.json',HERE/'FREEZE.json',HERE/'independent-minimal-model-review.json',HERE/'independent-source-interface-review.md',Path(__file__),oracle,normal,source/'SOURCE.json',source/'CLOSURE.json',source/'result.json',source/'post.json',source/'stdout',source/'stderr',ROOT/'scripts/task_runner.py',ROOT/'scripts/evidence_boundary.py',*map(Path,tools.values())]
 pins=inventory|{str(p.resolve(strict=True)):sha(p) for p in extra};resources=helper.Inputs(directories=config.RESOURCE_ROOTS).expected
 generated=out/('scenario.js' if role=='js' else 'scenario.c');native=out/'scenario.native';prefix=[tools['taskset'],'-c','5']
 commands=[dict(label='emit',argv=prefix+[tools['bend'],str(entry),'-o',str(generated)],capSeconds=30)]
 if role=='native':commands += [dict(label='build',argv=prefix+[tools['clangWrapper'],'-O3',str(generated),'-o',str(native),'-pthread','-lm'],capSeconds=120),dict(label='consumer',argv=prefix+[str(native),'--threads','1','--gpu','off'],capSeconds=5)]
 else:commands += [dict(label='consumer',argv=prefix+[tools['node'],str(generated)],capSeconds=5)]
 plan=dict(scope='#48/#49 generic ordinary Bundle adapter first complete consumer; existing failure/retry semantics only',role=role,subject=('normal' if case=='A' else 'mutant'),entrypoint=str(entry),stage=str(HERE),sourceInventory=inventory,importClosure=sorted(inventory),pins=pins,resourceRoots=resources,environment=config.environment(),cwd=str(HERE),tools=tools,commands=commands,oracle=str(oracle),oracleSHA256=hashlib.sha256(raw).hexdigest(),oracleBytes=len(raw),normalOracle=str(normal),normalOracleSHA256=hashlib.sha256(normal_raw).hexdigest(),normalOracleBytes=len(normal_raw),generated=str(generated),native=str(native),postConsumer='Three full failure/retry lanes with actual Bundle/World/handler owners and complete physical observation; independent source-only whole oracle')
 out.mkdir(exist_ok=False);(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(sha(out/'plan.json'))
if __name__=='__main__':main()
