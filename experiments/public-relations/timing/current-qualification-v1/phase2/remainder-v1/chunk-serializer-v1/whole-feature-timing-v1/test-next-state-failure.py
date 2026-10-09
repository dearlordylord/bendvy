"""Actual successor orchestration failure seam: zero actual children."""
from pathlib import Path
from unittest.mock import patch
import hashlib,importlib.util,json,sys,tempfile
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[7]
def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
M=load('entry',HERE/'next-state-execution.py');T=load('runner',ROOT/'scripts/task_runner.py');L=load('logs',ROOT/'scripts/receipt-logs.py');B=load('boundary',ROOT/'scripts/evidence_boundary.py')
with tempfile.TemporaryDirectory(prefix='bendvy42-nextstate-nochild-') as temporary:
 directory=Path(temporary);out=directory/'out';artifact=out/'trace.c';python=str(Path(sys.executable).resolve(strict=True));paths=[HERE/'next-state-execution.py',Path(python),Path('/usr/bin/false'),ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'scripts/evidence_boundary.py']
 p={'subject':'serializer-next-state','stage':'emit','scope':'NO_CHILD_CONTROL','cwd':str(ROOT),'executionPython':python,'pins':{str(p):sha(p) for p in paths},'resourceRoots':{},'output':str(out),'generated':[str(artifact)],'environment':{},'lock':str(directory/'isolated-control-lock'),'commands':[{'label':'emit','argv':['/usr/bin/taskset','-c','5','/usr/bin/false'],'seconds':30}]}
 plan=directory/'plan.json';plan.write_text(json.dumps(p))
 def failed_child(*args,**kwargs):
  with artifact.open('xb') as f:f.write(b'controlled partial, no compiler')
  return {'exit':None,'failure':'child deadline','stdout':b'','stderr':b'controlled\n','capture':'split','runnerSHA256':sha(ROOT/'scripts/task_runner.py')}
 modules={'runner':T,'logs':L,'boundary':B}
 with patch.object(M,'load',side_effect=lambda name,path:modules[name]),patch.object(T,'execute_result',side_effect=failed_child) as child:
  try:M.main(plan,sha(plan))
  except TimeoutError as error:assert str(error)=='child deadline'
  else:raise AssertionError('deadline must propagate')
  assert child.call_count==1
 receipt=json.loads((out/'receipt.json').read_text())
 assert receipt['status']=='INCOMPLETE' and receipt['commands'][0]['failure']=='child deadline'
 assert receipt['guardFailures']==[] and [g['label'] for g in receipt['guards']]==['pre','acquired-emit','post-emit','final']
 assert receipt['generated'][str(artifact)]['sha256']==sha(artifact)
 print(json.dumps({'actualExecutionEntryFailureControl':'PASS','partialCapturedBeforePost':True,'namedPostAndFinal':True,'unconditionalFailureReceipt':True,'actualChildren':0}))
