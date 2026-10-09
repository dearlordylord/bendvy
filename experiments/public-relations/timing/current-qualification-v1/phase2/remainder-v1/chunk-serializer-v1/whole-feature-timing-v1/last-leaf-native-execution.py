"""Exact one-cohort orchestration over the existing Runner, not a new runner family."""
from pathlib import Path
import fcntl,gzip,hashlib,importlib.util,json,sys
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent

def sha(path):
 path=Path(path)
 if path.is_symlink() or not path.is_file():raise ValueError('regular nonsymlink file required')
 return hashlib.sha256(path.read_bytes()).hexdigest()
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);return module

def main(plan_path,admitted):
 plan_path=Path(plan_path).resolve(strict=True)
 if sha(plan_path)!=admitted:raise ValueError('exact plan digest required')
 p=json.loads(plan_path.read_text());root=Path(p['cwd'])
 if len(p['commands'])!=9 or p['mutation']!='last-leaf':raise ValueError('only complete Native lastleaf9 cohort')
 T=load('runner',root/'scripts/task_runner.py');L=load('logs',root/'scripts/receipt-logs.py');B=load('boundary',root/'scripts/evidence_boundary.py')
 inputs=T.Inputs(files=[plan_path,*p['pins']],directories=p['resourceRoots'])
 if inputs.expected!={str(plan_path):admitted,**p['pins'],**p['resourceRoots']}:raise ValueError('initial pin/resource drift')
 if str(Path(__file__).resolve()) not in p['pins']:raise ValueError('orchestration source must be pinned')
 output=Path(p['output'])
 if output.exists() or output.is_symlink():raise ValueError('output starts absent')
 output.mkdir();commands=p['commands'];binary=Path(commands[0]['argv'][3])
 if sha(binary)!=p['binarySHA256']:raise ValueError('actual existing binary drift')
 for c in commands:
  if c['argv'][:3]!=['/usr/bin/taskset','-c','5'] or c['argv'][3]!=str(binary) or c['argv'][4:8]!=['--threads','1','--gpu','off'] or c['seconds']!=5:raise ValueError('exact admitted Native recipe required')
 logs=L.CommandLogs(output,[c['label'] for c in commands]);runner=T.Runner(logs,inputs=inputs,env=p['environment'],cwd=p['cwd'],capture='split')
 record={'scope':p['scope'],'planSHA256':admitted,'binarySHA256':p['binarySHA256'],'commands':[],'guards':[]}
 def capture():
  record['logs']=dict(logs.hashes)
  if sha(binary)!=p['binarySHA256']:raise ValueError('binary changed after child')
 def guard(label):
  inputs.guard();logs.guard();record['guards'].append({'label':label,'unchanged':True})
 with B.ReceiptBoundary(record,output/'receipt.json',[('final',lambda:guard('final'))]):
  guard('pre')
  for command in commands:
   with open(p['lock'],'a+b') as lock:
    fcntl.flock(lock,fcntl.LOCK_EX);guard('acquired-'+command['label'])
    with B.GuardBoundary([('post',lambda:guard('post-'+command['label']))]):
     try:
      try:result=runner.run(command['label'],command['argv'],command['seconds'],expected=None)
      except BaseException as error:
       if hasattr(error,'result'):record['commands'].append({'label':command['label'],**{k:v for k,v in error.result.items() if k not in ('stdout','stderr')}})
       raise
      row={'label':command['label'],**{k:v for k,v in result.items() if k not in ('stdout','stderr')}};record['commands'].append(row)
      if result['exit']!=0 or result['failure'] is not None:raise ValueError('actual command failure')
      positive=gzip.decompress(Path(command['positiveOracle']).read_bytes());counter=gzip.decompress(Path(command['counterOracle']).read_bytes())
      if result['stdout']!=counter or result['stdout']==positive:raise ValueError('complete counteroracle or positive rejection failed')
      value=json.loads(counter);original=json.loads(positive)
      if sum(len(w['records']) for w in value['roots'])!=30:raise ValueError('all30 records required')
      if original['roots'][-1]['records'][-1]['systemResult'] is not None:raise ValueError('positive lastleaf basis changed')
      original['roots'][-1]['records'][-1]['systemResult']=1
      if value!=original:raise ValueError('only exact final Other lastleaf mutation permitted')
      markers=[json.loads(line) for line in result['stderr'].splitlines()]
      if len(markers)!=2 or markers[0]!={'boundary':'begin'}:raise ValueError('exact Begin/Complete chronology required')
      stop=dict(markers[1]);duration=stop.pop('elapsedNs')
      if type(duration)is not str or not duration.isascii() or not duration.isdecimal():raise ValueError('literal nonnegative duration diagnostic required')
      if any(type(stop[k])is not int for k in ('nodes','characters','sum')):raise ValueError('actual primitive walk controls required')
      if stop!={'boundary':'complete-trace-forced',**command['counterWalk'],'region':'whole-feature-setup-operations-full-trace'}:raise ValueError('full counterwalk mismatch')
      row.update(completeCounterOraclePass=True,markerStatGatePass=True,positiveGateRejected=True,witness='Other final systemResult null->1',stdoutBytes=len(counter))
     finally:capture()
  record['status']='NATIVE_FULL9_LASTLEAF_GATE_PASS_NO_TIMING'
 print(json.dumps(record))
if __name__=='__main__':main(sys.argv[1],sys.argv[2])
