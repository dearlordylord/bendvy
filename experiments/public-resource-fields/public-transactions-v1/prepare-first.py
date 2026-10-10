"""Two first public Read plans; existing collector/guards/tools, no children."""
from pathlib import Path
import hashlib,json,gzip,importlib.util,sys
ROOT=Path('/workspace/formal-proofs/bendvy');HERE=Path(__file__).resolve().parent
COLLECTOR=ROOT/'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/development.py'
GUARD=ROOT/'experiments/public-inspect/development-plan-guard-v1/plan_guard.py'
ORACLE=Path('/workspace/formal-proofs/bendvy-worktrees/observable-query-boundaries/experiments/public-inspect/debug-study-v1/production-adoption-v1/canonical-observable-api-v1/resource-fields-public-reference-join-v1')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(name,p):
 s=importlib.util.spec_from_file_location(name,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def main():
 runtime=HERE/'runtime-v1';runtime.mkdir(exist_ok=True);cat=json.loads((ORACLE/'ORACLES.json').read_text());selection=cat['a-read'];basis=json.loads((HERE/'SOURCE-PREPARATION.json').read_text());row=next(x for x in basis['cases'] if x['case']=='a-read');inventory=row['sources'];entry=Path(row['entrypoint']);assert str(entry)==selection['entrypoint']
 c=load('public_transaction_collector',COLLECTOR);g=load('public_transaction_plan_guard',GUARD);runner=load('public_transaction_runner',ROOT/'scripts/task_runner.py');cfg=load('public_transaction_configuration',ROOT/'experiments/public-simulation/delivery-v1/installed-config.py')
 check=HERE/'checks/a-read-source01';result=json.loads((check/'result.json').read_text());pinsource=json.loads((check/'SOURCE.json').read_text())['pins'];assert result['exit']==0 and result.get('failure') is None and json.loads((check/'post.json').read_text())['unchanged'];assert all(pinsource[k]==v and sha(k)==v for k,v in inventory.items())
 expected=Path(selection['path']);raw=gzip.decompress(expected.read_bytes());assert len(raw)==selection['bytes'] and hashlib.sha256(raw).hexdigest()==selection['sha256'];sequence=[]
 for role in ['js','native']:
  out=Path('/tmp/bendvy70-public-transactions-first01')/('a-read-'+role);out.mkdir(parents=True,exist_ok=False)
  tools={'bend':'/home/node/.bend/bin/bend-2.0.35','node':'/home/node/.local/share/mise/installs/node/24.20.0/bin/node','python':str(Path(sys.executable).resolve()),'taskset':'/usr/bin/taskset','clangWrapper':'/tmp/bendvy-clang19-diagnostic/clang19','clangBinary':'/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'}
  extra=[COLLECTOR,GUARD,ROOT/'scripts/task_runner.py',ROOT/'scripts/evidence_boundary.py',ROOT/'experiments/public-simulation/delivery-v1/installed-config.py',Path(__file__),HERE/'README.md',HERE/'SOURCE-PREPARATION.json',HERE/'check-source.py',ORACLE/'ORACLES.json',ORACLE/'SOURCE-JOIN.json',expected,*map(Path,selection['basisInputs']),*map(Path,tools.values()),*sorted(x for x in check.rglob('*') if x.is_file())]
  pins=inventory|{str(x.resolve(strict=True)):sha(x) for x in extra};generated=out/('scenario.js' if role=='js' else 'scenario.c');native=out/'scenario.native';prefix=[tools['taskset'],'-c','11']
  commands=[{'label':'emit','argv':prefix+[tools['bend'],str(entry),'-o',str(generated)],'capSeconds':30}]
  if role=='js':commands.append({'label':'consumer','argv':prefix+[tools['node'],str(generated)],'capSeconds':5})
  else:commands.extend([{'label':'build','argv':prefix+[tools['clangWrapper'],'-O3',str(generated),'-o',str(native),'-pthread','-lm'],'capSeconds':120},{'label':'consumer','argv':prefix+[str(native),'--threads','1','--gpu','off'],'capSeconds':5}])
  plan={'scope':'Issue70 complete public registered schema-A Read transaction consumer; whole owner/World/arrays/commit/failure-input/retry trace, exact independent2015B oracle. Public3modules unchanged.','role':role,'subject':'normal','entrypoint':str(entry),'stage':str(entry.parent),'sourceInventory':inventory,'importClosure':c.validate_imports(entry,inventory),'pins':pins,'resourceRoots':runner.Inputs(directories=cfg.RESOURCE_ROOTS).expected,'environment':cfg.environment(),'cwd':str(HERE),'tools':tools,'commands':commands,'oracle':str(expected),'oracleSHA256':selection['sha256'],'oracleBytes':selection['bytes'],'normalOracle':str(expected),'normalOracleSHA256':selection['sha256'],'normalOracleBytes':selection['bytes'],'generated':str(generated),'native':str(native),'postConsumer':'Complete independent2015B trace equality, empty runtime stderr; no partial observation'}
  assert {k:c.sha(k) for k in pins}==pins;g.validate(plan,output_dir=out);raw=(json.dumps(plan,indent=2)+'\n').encode();file=out/'plan.json';file.write_bytes(raw);target=runtime/'prepared-first01'/('a-read-'+role);target.mkdir(parents=True);(target/'plan.json').write_bytes(raw);digest=sha(file);sequence.append({'case':'a-read','role':role,'path':str(file),'sha256':digest,'pins':len(pins),'sources':len(inventory),'command':[tools['python'],str(COLLECTOR),'run',str(file),digest]})
 (runtime/'FIRST.json').write_text(json.dumps({'sequence':sequence,'conditions':'Execute once JS wholePASS then Native; stop any failure; no retry. Existing collector internal lock, no outerlock.','oracle':'Independent source-only exact public join, model bytes unchanged; no historical backend acceptance transfer'},indent=2)+'\n');print(json.dumps(sequence))
if __name__=='__main__':main()
