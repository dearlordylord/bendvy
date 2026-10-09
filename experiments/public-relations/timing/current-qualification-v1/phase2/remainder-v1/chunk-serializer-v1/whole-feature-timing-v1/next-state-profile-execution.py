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
 for path,digest in p['pins'].items():
  if sha(path)!=digest:raise ValueError('pre-import file pin drift')
 actual_python=str(Path(sys.executable).resolve(strict=True))
 if actual_python!=p['executionPython'] or sha(actual_python)!=p['pins'].get(actual_python):raise ValueError('approved actual interpreter drift')
 if p['subject']!='serializer-next-state' or p['stage'] not in ('cpu-profile','allocation-profile'):raise ValueError('exact next-state stage required')
 if len(p['commands'])!=1:raise ValueError('one complete matched profile subject')
 T=load('runner',root/'scripts/task_runner.py');L=load('logs',root/'scripts/receipt-logs.py');B=load('boundary',root/'scripts/evidence_boundary.py')
 inputs=T.Inputs(files=[plan_path,*p['pins']],directories=p['resourceRoots'])
 if inputs.expected!={str(plan_path):admitted,**p['pins'],**p['resourceRoots']}:raise ValueError('initial pin/resource drift')
 if str(Path(__file__).resolve()) not in p['pins']:raise ValueError('orchestration source must be pinned')
 output=Path(p['output'])
 if output.exists() or output.is_symlink():raise ValueError('output starts absent')
 output.mkdir();commands=p['commands']
 for c in commands:
  if c['argv'][:3]!=['/usr/bin/taskset','-c','5'] or c['seconds']!={'cpu-profile':5,'allocation-profile':5}[p['stage']]:raise ValueError('unchanged CPU/cap recipe')
  executable=Path(c['argv'][3]).resolve(strict=True)
  if str(executable) not in p['pins'] or sha(executable)!=p['pins'][str(executable)]:raise ValueError('actual reached executable pin required')
 logs=L.CommandLogs(output,[c['label'] for c in commands]);runner=T.Runner(logs,inputs=inputs,env=p['environment'],cwd=p['cwd'],capture='split')
 record={'scope':p['scope'],'planSHA256':admitted,'stage':p['stage'],'commands':[],'guards':[]}
 def capture():
  record['logs']=dict(logs.hashes)
  for path in p.get('generated',[]):
   artifact=Path(path)
   if artifact.is_symlink():raise ValueError('generated symlink refusal')
   if artifact.exists():
    if not artifact.is_file():raise ValueError('generated regular file required')
    state={'bytes':artifact.stat().st_size,'sha256':sha(artifact)}
    previous=record.get('generated',{}).get(path)
    if previous is not None and previous!=state:raise ValueError('captured generated artifact changed')
    record.setdefault('generated',{})[path]=state
   else:record.setdefault('generated',{})[path]={'absent':True}
 def guard(label):
  inputs.guard();logs.guard()
  for path,state in record.get('generated',{}).items():
   artifact=Path(path)
   if state.get('absent'):
    if artifact.exists() or artifact.is_symlink():raise ValueError('absent generated path changed')
   elif sha(artifact)!=state['sha256']:raise ValueError('generated artifact changed')
  record['guards'].append({'label':label,'unchanged':True})
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
      if p['stage'] in ('emit','build'):
       if result['stdout'] or result['stderr']:raise ValueError('exact empty successful stage raw logs required')
       capture()
       if any(v.get('absent') for v in record.get('generated',{}).values()):raise ValueError('successful stage artifact missing')
       row['artifactPass']=True
      elif p['stage']=='fuel-runtime':
       expected=Path(command['oracle']).read_bytes()
       if result['stdout']!=expected or result['stderr']:raise ValueError('whole focused fuel stdout/stderr gate')
       row['completeFuelOraclePass']=True
      else:
       expected=gzip.decompress(Path(command['oracle']).read_bytes())
       if result['stdout']!=expected:raise ValueError('complete unchanged oracle mismatch')
       value=json.loads(expected)
       if sum(len(w['records']) for w in value['roots'])!=30:raise ValueError('all30 records required')
       markers=[json.loads(line) for line in result['stderr'].splitlines()]
       if len(markers)!=2 or markers[0]!={'boundary':'begin'}:raise ValueError('exact Begin/Complete chronology')
       stop=dict(markers[1]);duration=stop.pop('elapsedNs')
       if type(duration)is not str or not duration.isascii() or not duration.isdecimal():raise ValueError('literal nonnegative duration diagnostic')
       if any(type(stop[k])is not int for k in ('nodes','characters','sum')):raise ValueError('actual primitive walk controls')
       if stop!={'boundary':'complete-trace-forced',**command['walk'],'region':'whole-feature-setup-operations-full-trace'}:raise ValueError('complete normal walk mismatch')
       row.update(completeOraclePass=True,markerStatGatePass=True,stdoutBytes=len(expected))
       profile_path=Path(command['profile']);data=json.loads(profile_path.read_text())
       if data.get('zeroExits')!=1 or data.get('invocations')!=1 or data.get('mode')!=command['mode']:raise ValueError('matched one completed invocation audit')
       profile=data['profile']
       if command['mode']=='cpu':
        nodes=profile['nodes'];ids=[n['id'] for n in nodes]
        if not ids or len(ids)!=len(set(ids)) or any(type(x)is not int for x in ids):raise ValueError('CPU unique node IDs')
        samples=profile['samples'];deltas=profile['timeDeltas']
        if not samples or len(samples)!=len(deltas) or any(type(x)is not int or x not in ids for x in samples):raise ValueError('CPU sample references')
        if any(type(x)is not int for x in deltas):raise ValueError('signed exact integer deltas')
        row['negativeDeltaCount']=sum(x<0 for x in deltas)
       else:
        pending=[profile['head']];ids=set()
        while pending:
         node=pending.pop();identifier=node['id'];weight=node['selfSize']
         if type(identifier)is not int or identifier in ids or type(weight)not in (int,float) or weight<0:raise ValueError('heap tree IDs/weights')
         ids.add(identifier);pending.extend(node['children'])
        if not profile['samples'] or any(type(x['nodeId'])is not int or x['nodeId'] not in ids for x in profile['samples']):raise ValueError('heap sample references')
       row['profileSHA256']=sha(profile_path)
     finally:capture()
  record['status']='NEXT_STATE_'+p['stage'].upper()+'_PASS_NO_TIMING'
 print(json.dumps(record))
if __name__=='__main__':main(sys.argv[1],sys.argv[2])
