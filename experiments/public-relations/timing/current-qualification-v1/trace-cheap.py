"""Frozen complete public-trace anchor; no timing, tool cohort or verdict."""
from pathlib import Path
import hashlib,json,os,re,shutil,sys,time,runpy
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'scripts'));import task_runner
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def closure(p,files):
 p=p.resolve()
 if p in files:return
 files.add(p)
 for n in re.findall(r'^import\s+(\S+)',p.read_text(),re.M):
  if n!='Base':closure(p.parent/n,files)
def force(value):
 pending=[value];nodes=characters=total=0
 while pending:
  value=pending.pop();nodes+=1
  if value is None:total+=1
  elif isinstance(value,bool):total+=5 if value else 4
  elif isinstance(value,int):total+=2+value
  elif isinstance(value,str):total+=3+sum(map(ord,value));characters+=len(value)
  elif isinstance(value,list):total+=6;pending.extend(reversed(value))
  else:
   total+=7
   for key,item in reversed(list(value.items())):pending.extend([item,key])
 return dict(nodes=nodes&0xffffffff,characters=characters&0xffffffff,sum=total&0xffffffff)
def main():
 out=ROOT/'.artifacts'/('relations-public-trace-anchor-'+str(time.time_ns()));out.mkdir();files=set();closure(HERE/'trace-emitted.bend',files)
 files.update([HERE/'trace-boundary.js',HERE/'trace-boundary.c']);files.update([Path(__file__).resolve(),HERE/'trace-reference.mjs',ROOT/'experiments/public-relations/promotion-stage/application/next-version/v1/expected.json',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py']);files.update(Path(shutil.which(n)).resolve() for n in ['bend','node','taskset'])
 directories=[Path('/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src'),Path('/home/node/.bend/bend2')];env=dict(os.environ,BEND_NO_TELEMETRY='1');inputs=task_runner.Inputs(files=files,directories=directories);js=out/'trace.js';commands=[('check',['taskset','-c','5','bend',str(HERE/'trace-application.bend'),'--check-only'],5),('ts',['taskset','-c','5','node',str(HERE/'trace-reference.mjs')],5),('emit',['taskset','-c','5','bend',str(HERE/'trace-emitted.bend'),'-o',str(js)],30),('js',['taskset','-c','5','node',str(js)],5)];expected=json.loads((ROOT/'experiments/public-relations/promotion-stage/application/next-version/v1/expected.json').read_text());summary=force(expected);plan={'files':list(map(str,sorted(files))),'directories':list(map(str,directories)),'inputs':inputs.expected,'commands':commands,'environmentSHA256':hashlib.sha256(json.dumps(env,sort_keys=True).encode()).hexdigest(),'scope':'Matched registered operations and complete30 public snapshots, whole trace forced after Begin; no timing acceptance.'};(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');logs=runpy.run_path(str(ROOT/'scripts/receipt-logs.py'))['CommandLogs'](out,[x[0] for x in commands]);runner=task_runner.Runner(logs,inputs=inputs,env=env,cwd=ROOT);receipt={'status':'INCOMPLETE','planSHA256':sha(out/'plan.json'),'commands':[]}
 try:
  for label,argv,seconds in commands:
   x=runner.run(label,argv,seconds);receipt['commands'].append({'label':label,'exit':x['exit'],'failure':x['failure']});assert x['exit']==0 and x['failure'] is None
   if label=='check':assert b'ALL PROOFS CHECK' in x['stdout'] and b'SOME PROOFS FAIL' not in x['stdout']
   if label=='emit':runner.inputs=task_runner.Inputs(files=[*files,js],directories=directories);receipt['generatedSHA256']=sha(js)
   if label in ('ts','js'):
    boundaries=[json.loads(line) for line in x['stderr'].splitlines()];assert boundaries==[dict(boundary='begin'),dict(boundary='complete-trace-forced',**summary)];actual=json.loads(x['stdout']);assert actual==expected,(label,'complete public trace mismatch');receipt[label+'Records']=sum(len(x['records']) for x in actual)
   runner.inputs.guard();logs.guard()
  receipt['status']='COMPLETE_PUBLIC_TRACE_ANCHOR_PASS_NOT_FAIR_TIMING_QUALIFIED'
 except BaseException as e:receipt['error']=str(e);raise
 finally:receipt['logs']=dict(logs.hashes);(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out)
if __name__=='__main__':main()
