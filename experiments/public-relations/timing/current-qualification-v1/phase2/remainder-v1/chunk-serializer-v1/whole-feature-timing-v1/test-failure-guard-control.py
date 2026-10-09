"""Metadata-only actual Runner failure seam: no compiler or actual child."""
from pathlib import Path
import hashlib,importlib.util,json,sys,tempfile
from unittest.mock import patch
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[8]
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);return module
T=load('runner',ROOT/'scripts/task_runner.py');L=load('logs',ROOT/'scripts/receipt-logs.py');B=load('boundary',ROOT/'scripts/evidence_boundary.py')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
with tempfile.TemporaryDirectory(prefix='bendvy42-no-child-postguard-') as temporary:
 out=Path(temporary);source=out/'source';source.write_bytes(b'unchanged metadata');artifact=out/'partial.c';inputs=T.Inputs(files=[source]);logs=L.CommandLogs(out,['emit']);runner=T.Runner(logs,inputs=inputs);record={'commands':[],'guards':[]};generated={}
 def guard(label):
  inputs.guard();logs.guard()
  for path,digest in generated.items():assert sha(path)==digest
  record['guards'].append(label)
 def capture():
  assert artifact.is_file() and not artifact.is_symlink();generated[str(artifact)]=sha(artifact)
 def failed_child(*args,**kwargs):
  artifact.write_bytes(b'controlled partial artifact, no compiler');return {'exit':None,'failure':'child deadline','stdout':b'','stderr':b'controlled failure\n','capture':'split','runnerSHA256':sha(ROOT/'scripts/task_runner.py')}
 try:
  with B.ReceiptBoundary(record,out/'receipt.json',[('final',lambda:guard('final'))]):
   guard('pre')
   with B.GuardBoundary([('post',lambda:guard('post'))]):
    guard('acquired-stub-no-lock-child')
    try:
     with patch.object(T,'execute_result',failed_child):runner.run('emit',['stub-no-child'],5,expected=None)
    except BaseException as error:
     record['commands'].append({k:v for k,v in error.result.items() if k not in ('stdout','stderr')});raise
    finally:capture()
 except TimeoutError as error:assert str(error)=='child deadline'
 else:raise AssertionError('failure must propagate')
 assert record['guards']==['pre','acquired-stub-no-lock-child','post','final']
 actual=json.loads((out/'receipt.json').read_text());assert actual['status']=='INCOMPLETE' and actual['commands'][0]['failure']=='child deadline';assert actual['guardFailures']==[]
 assert len(generated)==1 and logs.hashes['emit.stderr']==sha(out/'emit.stderr')
 print(json.dumps({'status':'CONTROLLED_NO_CHILD_FAILURE_POST_FINAL_PASS','guards':record['guards'],'partialCapturedBeforePost':True,'unconditionalReceipt':'INCOMPLETE','originalMovedNativeReceipt':'Untouched missing namedpost gap; no replay or success reinterpretation'}))
