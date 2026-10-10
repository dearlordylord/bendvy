from pathlib import Path
import hashlib,json,gzip,re,sys,importlib.util
ROOT=Path('/workspace/formal-proofs/bendvy');HERE=Path('/workspace/formal-proofs/bendvy-worktrees/resource-field-integration/experiments/public-resource-fields/core-adoption-v1');OUT=Path('/tmp/bendvy70-core-runtime01')
RUNNER=ROOT/'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/development.py'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(name,p):
 s=importlib.util.spec_from_file_location(name,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
configuration=load('cfg',ROOT/'experiments/public-simulation/delivery-v1/installed-config.py');helper=load('runner',ROOT/'scripts/task_runner.py')
collector=load('collector',RUNNER)
# No child launches: this script prepares exact guarded plans only.
cat=json.loads((HERE/'runtime-v1/ORACLES.json').read_text());sequence=[]
for role in ('js','native'):
 for case in ('seeded-a','seeded-b','provision'):
  subject='normal'
  entry=HERE/({'seeded-a':'seeded-v1/consumer-a.bend','seeded-b':'seeded-v1/consumer-b.bend','provision':'provisioning-v1/consumer-a.bend'}[case]);inventory={}
  def visit(p):
   p=p.resolve(strict=True)
   if str(p) in inventory:return
   inventory[str(p)]=sha(p)
   for target in re.findall(r'^import\s+(\S+)',p.read_text(),re.M):
    if target!='Base':visit(p.parent/target)
  visit(entry);closure=collector.validate_imports(entry,inventory)
  selection=cat[case];oracle=Path(selection['path']);baseline=Path(selection['baselinePath'])
  expected=gzip.decompress(oracle.read_bytes());normal=gzip.decompress(baseline.read_bytes())
  assert len(expected)==selection['bytes'] and hashlib.sha256(expected).hexdigest()==selection['sha256']
  assert len(normal)==selection['baselineBytes'] and hashlib.sha256(normal).hexdigest()==selection['baselineSHA256']
  if subject=='mutant':assert expected!=normal
  out=OUT/(case+'-'+role);out.mkdir(parents=True,exist_ok=False)
  tools={'bend':'/home/node/.bend/bin/bend-2.0.35','node':'/home/node/.local/share/mise/installs/node/24.20.0/bin/node','python':str(Path(sys.executable).resolve()),'taskset':'/usr/bin/taskset','clangWrapper':'/tmp/bendvy-clang19-diagnostic/clang19','clangBinary':'/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'}
  extra=[RUNNER,ROOT/'scripts/task_runner.py',ROOT/'scripts/evidence_boundary.py',ROOT/'experiments/public-simulation/delivery-v1/installed-config.py',HERE/'runtime-v1/ORACLES.json',HERE/'SUCCESSOR-SOURCE.json',HERE/'SUCCESSOR-RELOCATION.json',HERE/'runtime-v1/README.md',HERE/'SOURCE-PLAN.json',HERE/'SOURCE-RESULT.json',Path(__file__),HERE/'runtime-v1/parent-prepare.py.source',oracle,baseline,*map(Path,tools.values()),*map(Path,selection['basisInputs'])]
  check=HERE/'successor-checks'/({'seeded-a':'seeded-a-source01','seeded-b':'seeded-b-source01','provision':'provision-source01'}[case])
  result=json.loads((check/'result.json').read_text());post=json.loads((check/'post.json').read_text());source=json.loads((check/'SOURCE.json').read_text())['pins']
  assert result['exit']==0 and result['failure'] is None and post['unchanged']
  assert all(source.get(p)==h for p,h in inventory.items())
  extra += [p for p in check.rglob('*') if p.is_file()]
  pins=inventory|{str(p.resolve(strict=True)):sha(p) for p in extra};generated=out/('scenario.c' if role=='native' else 'scenario.js');native=out/'scenario.native'
  commands=[{'label':'emit','argv':[tools['taskset'],'-c','11',tools['bend'],str(entry),'-o',str(generated)],'capSeconds':30}]
  if role=='native':commands += [{'label':'build','argv':[tools['taskset'],'-c','11',tools['clangWrapper'],'-O3',str(generated),'-o',str(native),'-pthread','-lm'],'capSeconds':120},{'label':'consumer','argv':[tools['taskset'],'-c','11',str(native),'--threads','1','--gpu','off'],'capSeconds':5}]
  else:commands += [{'label':'consumer','argv':[tools['taskset'],'-c','11',tools['node'],str(generated)],'capSeconds':5}]
  plan={'scope':'Core declaration-bound resource fields seeded A/B writer or existing provisioning boundary complete finite World '+subject+' '+role+'; affine resource/output, success/failure rollback/retry; no automatic App/schedule/proof/full56/performance acceptance','role':role,'subject':subject,'entrypoint':str(entry),'stage':str(entry.parent),'sourceInventory':inventory,'importClosure':closure,'pins':pins,'resourceRoots':helper.Inputs(directories=configuration.RESOURCE_ROOTS).expected,'environment':configuration.environment(),'cwd':str(HERE),'tools':tools,'commands':commands,'oracle':str(oracle),'oracleSHA256':selection['sha256'],'oracleBytes':selection['bytes'],'normalOracle':str(baseline),'normalOracleSHA256':selection['baselineSHA256'],'normalOracleBytes':selection['baselineBytes'],'generated':str(generated),'native':str(native),'postConsumer':'Whole independent complete term byte equality; mutant rejects namespace-matched normal term; empty runtime stderr'}
  path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');sequence.append({'role':role,'subject':subject,'case':case,'path':str(path),'sha256':sha(path),'sources':len(inventory),'command':[tools['python'],str(RUNNER),'run',str(path),sha(path)]})
proposal={'runner':str(RUNNER),'runnerSHA256':sha(RUNNER),'plans':sequence,'sequence':'seededA JS -> seededB JS -> provisioning JS -> seededA Native -> seededB Native -> provisioning Native; stop any failure/deadline/guard failure; no retry; Native only after all three whole JS PASS','sourcePrerequisite':'Current core seededA/seededB/provision source5 actual PASS original35558; development capture with broad pre/post sources; no portable source-verdict claim','scope':'Core resource-field seeded World preservation and existing declaration rejection development; no automatic App/full70/universal/performance acceptance'}
(HERE/'runtime-v1/BATCH.json').write_text(json.dumps(proposal,indent=2)+'\n')
for row in sequence:
 target=HERE/'runtime-v1/prepared-attempt01'/ (row['case']+'-'+row['role']);target.mkdir(parents=True);(target/'plan.json').write_bytes(Path(row['path']).read_bytes())
print(json.dumps(proposal,indent=2))
