"""Actual Runner + collector row/guard + ReceiptBoundary under failed raw publication; no child."""
import ast,hashlib,importlib.util,json,tempfile
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy')
HERE=Path(__file__).resolve().parent
COLLECTORS=HERE.parents[1]/'adoption-v1/qualification-v1/spine-report-v1'
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);module=importlib.util.module_from_spec(spec)
 exec(compile(path.read_bytes(),str(path),'exec'),module.__dict__);return module
runner=load('actual_runner',ROOT/'scripts/task_runner.py')
logs_module=load('actual_logs',ROOT/'scripts/receipt-logs.py')
boundary=load('actual_boundary',ROOT/'scripts/evidence_boundary.py')
class Guard:
 def guard(self):pass
result={'command':['no-child-sentinel'],'timeout':5,'capture':'split','exit':17,'failure':{'kind':'returned-failure-sentinel'},'stdout':b'completed stdout\n','stderr':b'completed stderr\n'}
runner.execute_result=lambda *args,**kwargs:result
checks=[]
for filename in ('development-run.py','native-from-c.py'):
 path=COLLECTORS/filename;collector=load(filename.replace('.','_'),path)
 tree=ast.parse(path.read_text());guard_node=next(n for n in ast.walk(tree) if isinstance(n,ast.FunctionDef) and n.name=='guard')
 with tempfile.TemporaryDirectory() as temporary:
  home=Path(temporary);raw=home/'raw';raw.mkdir();generated=home/'generated';generated.mkdir()
  logs=logs_module.CommandLogs(raw,['sentinel']);record={'status':'INCOMPLETE','commands':[],'logs':{},'generated':{}}
  ns={'record':record,'logs':logs,'admitted_plan':lambda *args:{},'plan_path':home/'plan.json','plan_digest':'sentinel','admitted':{},'frozen':Guard(),'generated':generated,'hashlib':hashlib}
  exec(compile(ast.fix_missing_locations(ast.Module(body=[guard_node],type_ignores=[])),str(path),'exec'),ns)
  actual_guard=ns['guard'];original_open=Path.open
  def partial_open(subject,*args,**kwargs):
   if subject==raw/'sentinel.stderr' and args==('xb',):
    with original_open(subject,'xb') as stream:stream.write(b'partial stderr')
    raise OSError('PARTIAL_PUBLICATION_SENTINEL')
   return original_open(subject,*args,**kwargs)
  row={'label':'sentinel','argv':['no-child-sentinel'],'capSeconds':5};record['commands'].append(row)
  Path.open=partial_open
  try:
   try:
    with boundary.ReceiptBoundary(record,home/'receipt.json',[('actual collector guard',actual_guard)]):
     collector.run_recorded(row,runner.Runner(logs,inputs=Guard()),row)
   except OSError as error:
    assert str(error)=='PARTIAL_PUBLICATION_SENTINEL' and error.result is result
   else:raise AssertionError('failure disappeared')
  finally:Path.open=original_open
  receipt=json.loads((home/'receipt.json').read_text())
  assert receipt['status']=='INCOMPLETE' and receipt['commands'][0]['exit']==17 and receipt['commands'][0]['failure']==result['failure']
  assert receipt['commands'][0]['error']=='OSError: PARTIAL_PUBLICATION_SENTINEL'
  assert receipt['logs']=={'sentinel.stdout':hashlib.sha256(result['stdout']).hexdigest()}
  assert (raw/'sentinel.stdout').read_bytes()==result['stdout'] and (raw/'sentinel.stderr').read_bytes()==b'partial stderr'
  assert any('command log membership or bytes changed' in x['error'] for x in receipt['guardFailures'])
  checks.append({'collector':filename,'exactReturnedExitAndFailureRetained':True,'stdoutJoinRetainedBeforeFailedGuard':True,'partialStderrNotClaimedComplete':True,'receiptStatus':'INCOMPLETE'})
print(json.dumps({'status':'PASS','checks':checks,'backendChildren':0}))
