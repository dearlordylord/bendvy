import fcntl,hashlib,importlib.util,json,os,shutil,sys
from pathlib import Path
root=Path('/workspace/formal-proofs/bendvy'); here=Path('/workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1')
sys.path.insert(0,str(root/'scripts'))
import task_runner
from evidence_boundary import ReceiptBoundary,GuardBoundary
spec=importlib.util.spec_from_file_location('stage',here.parent/'generated-js-stage.py'); stage=importlib.util.module_from_spec(spec);spec.loader.exec_module(stage)
out=here/'src-consumer-v1/development/family-js-v1';out.mkdir(exist_ok=False)
entry=here/'src-consumer-v1/family-consumer.bend';sources,edges=stage.consumed(entry)
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
oracle=here/'core-promotion-v1/oracle-review-v1/expected-family.json';assert sha(oracle)=='724b69f4df2620d00d71d7668d0fd630f3e9177b322b6c99a089b98f9505aa46'
frozen=stage.stage(entry,out/'sources',{str(p):h for p,h in sources.items()})
tools={name:str(Path(shutil.which(name)).resolve()) for name in ('bend','node','taskset')}
pins={str(p):h for p,h in sources.items()};pins.update({str(out/'sources'/n):h for n,h in frozen['inventory'].items()})
for p in [oracle,here/'core-promotion-v1/oracle-review-v1/expected-family.py',here/'core-promotion-v1/oracle-review-v1/REVIEW.md',here.parent/'retained-codec-v1/independent-oracle-v2.json',Path(sys.executable).resolve(),Path(__file__),Path(stage.__file__),Path(task_runner.__file__),root/'scripts/evidence_boundary.py',Path.home()/'.bend/bend2/base.bend',*map(Path,tools.values())]:pins[str(p)]=sha(p)
env={k:os.environ[k] for k in ('HOME','PATH','LANG','LC_ALL','TZ') if k in os.environ};env['BEND_NO_TELEMETRY']='1'
generated=out/'consumer.js'
assert not generated.exists()
commands=[('emit',[tools['taskset'],'-c','5',tools['bend'],frozen['entry'],'-o',str(generated)],30),('consumer',[tools['taskset'],'-c','5',tools['node'],str(generated)],5)]
record={'scope':'direct development; NOT complete tool/resolver/frozen delivery qualification','sourceStage':frozen,'pins':pins.copy(),'environment':env,'plannedCommands':commands,'commands':[]}
(out/'plan.json').write_text(json.dumps(record,indent=2)+'\n')
def guard():
 assert {p:sha(p) for p in pins}==pins
 assert stage.consumed(entry)==(sources,edges)
 assert stage.inventory(out/'sources')==frozen['inventory']
def compare(a,b):
 assert type(a) is type(b)
 if isinstance(a,dict):
  assert a.keys()==b.keys()
  for k in a:compare(a[k],b[k])
 elif isinstance(a,list):
  assert len(a)==len(b)
  for x,y in zip(a,b):compare(x,y)
 else:assert a==b,(a,b)
with ReceiptBoundary(record,out/'receipt.json',[('source/oracle/tool binary pins',guard)]):
 for label,argv,cap in commands:
  guard()
  with GuardBoundary([('source/oracle/tool binary pins',guard)]):
   with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
    fcntl.flock(lock,fcntl.LOCK_EX)
    try:
     guard()
     if label=='emit':assert not generated.exists()
     result=task_runner.execute_result(argv,cap,env,str(here),'split')
    finally:fcntl.flock(lock,fcntl.LOCK_UN)
   row={'label':label,'argv':argv,'capSeconds':cap}
   for k,v in result.items():
    if isinstance(v,bytes):
     path=out/(label+'.'+k);path.write_bytes(v);row[k]={'path':str(path),'sha256':sha(path),'bytes':len(v)}
    else:row[k]=v
   record['commands'].append(row)
   assert result['exit']==0 and result['failure'] is None,row
   if label=='emit':
    assert generated.is_file();pins[str(generated)]=sha(generated);record['generatedSHA256']=sha(generated)
   else:
    assert result['stderr']==b''
    compare(json.loads(result['stdout']),json.loads(oracle.read_bytes()))
    record['completeOracleSHA256']=sha(oracle)
 record['status']='DEVELOPMENT_PASS'
print(record['status'])
