from pathlib import Path
import hashlib,json,gzip,re,sys,importlib.util
ROOT=Path('/workspace/formal-proofs/bendvy');HERE=Path('/workspace/formal-proofs/bendvy-worktrees/70-resource-confinement/experiments/public-resource-fields');OUT=Path('/tmp/bendvy70-remaining-runtime01')
RUNNER=ROOT/'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/development.py'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(name,p):
 s=importlib.util.spec_from_file_location(name,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
configuration=load('cfg',ROOT/'experiments/public-simulation/delivery-v1/installed-config.py');helper=load('runner',ROOT/'scripts/task_runner.py')
collector=load('collector',RUNNER)
# No child launches: this script prepares exact guarded plans only.
cat=json.loads((HERE/'runtime-v1/ORACLES-REMAINING.json').read_text());sequence=[]
profiles=[('wrong-field','js'),('incomplete-inverse','js'),('b-write','js'),('a-read','js'),('b-read','js'),('a-write','native'),('b-write','native'),('a-read','native'),('b-read','native')]
for case,role in profiles:
  subject='mutant' if case in ('wrong-field','incomplete-inverse') else 'normal'
  entries={'a-write':'consumer.bend','b-write':'consumer-b.bend','a-read':'consumer-read.bend','b-read':'consumer-b-read.bend','wrong-field':'mutants/wrong-field/consumer.bend','incomplete-inverse':'mutants/incomplete-inverse/consumer.bend'}
  entry=HERE/entries[case];inventory={}
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
  extra=[RUNNER,ROOT/'scripts/task_runner.py',ROOT/'scripts/evidence_boundary.py',ROOT/'experiments/public-simulation/delivery-v1/installed-config.py',HERE/'runtime-v1/ORACLES-REMAINING.json',HERE/'SOURCE.json',HERE/'README.md',Path(__file__),HERE/'runtime-v1/parent-prepare.py.source',oracle,baseline,*map(Path,tools.values()),*map(Path,selection['basisInputs'])]
  if subject=='mutant':
   check=HERE/'checks'/('mutant-'+case+'-source01')
   result=json.loads((check/'result.json').read_text());source=json.loads((check/'SOURCE.json').read_text())['pins']
   assert result['exit']==0 and result['failure'] is None and json.loads((check/'post.json').read_text())['unchanged']
   assert all(source.get(p)==h for p,h in inventory.items())
   extra += [check/n for n in ('result.json','SOURCE.json','post.json','stdout','stderr','environment.json')]
   extra += list((check/'sources').glob('*'))
  else:
   check=HERE/'checks/current-source01';result=json.loads((check/'results.json').read_text());source=json.loads((check/'pre-source.json').read_text());post=json.loads((check/'post-source.json').read_text())
   assert result['developmentOnly'] and result['prePostEqual'] and source==post
   names={'a-write':'consumer','b-write':'consumer-b','a-read':'consumer-read','b-read':'consumer-b-read'}
   actual=[row for row in result['checks'] if row['name']==names[case]];assert len(actual)==1 and actual[0]['exit']==0
   assert all(source.get(str(Path(p).relative_to(HERE.parent.parent)))==h for p,h in inventory.items())
   extra += [check/n for n in ('results.json','pre-source.json','post-source.json','snapshot-index.json',names[case]+'.stdout',names[case]+'.stderr')]
   extra += [check/row['snapshot'] for row in json.loads((check/'snapshot-index.json').read_text())]
  # Actual admitted normal-A JS is a frozen prerequisite and mutation baseline.
  previous=HERE/'runtime-v1/actual-normal-a-js01';facts=json.loads((previous/'ACTUAL.json').read_text())
  assert facts['collectorTerminalExit']==0 and facts['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS' and facts['wholeOracleSHA256']==cat['a-write']['sha256']
  actual_stdout=Path('/tmp/bendvy70-normal-a-js01/normal-js/consumer.stdout');assert sha(actual_stdout)==cat['a-write']['sha256']
  extra += [previous/'ACTUAL.json',previous/'manifest.json',actual_stdout,Path('/tmp/bendvy70-normal-a-js01/normal-js/receipt.json')]
  pins=inventory|{str(p.resolve(strict=True)):sha(p) for p in extra};generated=out/('scenario.c' if role=='native' else 'scenario.js');native=out/'scenario.native'
  commands=[{'label':'emit','argv':[tools['taskset'],'-c','11',tools['bend'],str(entry),'-o',str(generated)],'capSeconds':30}]
  if role=='native':commands += [{'label':'build','argv':[tools['taskset'],'-c','11',tools['clangWrapper'],'-O3',str(generated),'-o',str(native),'-pthread','-lm'],'capSeconds':120},{'label':'consumer','argv':[tools['taskset'],'-c','11',str(native),'--threads','1','--gpu','off'],'capSeconds':5}]
  else:commands += [{'label':'consumer','argv':[tools['taskset'],'-c','11',tools['node'],str(generated)],'capSeconds':5}]
  plan={'scope':'Private declaration-bound resource-field '+case+' '+subject+' '+role+' complete finite empty-component/event/queue World'+'; affine resource/output, success/failure rollback/retry; no automatic App/schedule/proof/full56/performance acceptance','role':role,'subject':subject,'entrypoint':str(entry),'stage':str(entry.parent),'sourceInventory':inventory,'importClosure':closure,'pins':pins,'resourceRoots':helper.Inputs(directories=configuration.RESOURCE_ROOTS).expected,'environment':configuration.environment(),'cwd':str(HERE),'tools':tools,'commands':commands,'oracle':str(oracle),'oracleSHA256':selection['sha256'],'oracleBytes':selection['bytes'],'normalOracle':str(baseline),'normalOracleSHA256':selection['baselineSHA256'],'normalOracleBytes':selection['baselineBytes'],'generated':str(generated),'native':str(native),'postConsumer':'Whole independent complete term byte equality; mutant rejects namespace-matched normal term; empty runtime stderr'}
  path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');sequence.append({'role':role,'subject':subject,'case':case,'path':str(path),'sha256':sha(path),'sources':len(inventory),'command':[tools['python'],str(RUNNER),'run',str(path),sha(path)]})
proposal={'runner':str(RUNNER),'runnerSHA256':sha(RUNNER),'plans':sequence,'sequence':'Wrong-field JS -> incomplete-inverse JS (both reject actual normal-A baseline) -> Bwrite/Aread/Bread JS -> Awrite/Bwrite/Aread/Bread Native; stop any failure/deadline/guard failure; no retry; reuse passed normalA JS','sourcePrerequisite':'Exact current four normal source5 positives plus captured source5 PASS for both compiling mutations; development capture only; no portable source-verdict claim','scope':'Remaining finite resource-field development cohort union; no public promotion/nontrivialWorld/universal/proof/performance/full #70 acceptance'}
(HERE/'runtime-v1/BATCH-REMAINING.json').write_text(json.dumps(proposal,indent=2)+'\n')
for row in sequence:
 target=HERE/'runtime-v1/prepared-remaining-v1'/ (row['case']+'-'+row['role']);target.mkdir(parents=True);(target/'plan.json').write_bytes(Path(row['path']).read_bytes())
print(json.dumps(proposal,indent=2))
