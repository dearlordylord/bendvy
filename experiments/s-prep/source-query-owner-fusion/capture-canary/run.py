#!/usr/bin/env python3
"""Reached affine Array frozen capture canary; no general safety claim."""
import pathlib,argparse,subprocess,json,hashlib,os,signal,time,shutil
HERE=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{8});os.environ['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';r={'status':'INCOMPLETE','scope':'Finite reached captured affine Array; separate from closed named query continuation and ECS gates','cases':[]}
def run(args,limit):
 t=time.monotonic();c=subprocess.Popen(list(map(str,args)),stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try:out,err=c.communicate(timeout=limit);return {'argv':list(map(str,args)),'limitSeconds':limit,'exit':c.returncode,'seconds':time.monotonic()-t,'out':out,'err':err}
 except subprocess.TimeoutExpired:os.killpg(c.pid,signal.SIGKILL);out,err=c.communicate();return {'argv':list(map(str,args)),'limitSeconds':limit,'status':'TIMEOUT','out':out,'err':err}
try:
 for name in ['generic-open','generic-open-repeated','plain-duplicate','one-use','repeated','closed-positive']:
  folder=a.output/name;folder.mkdir();source=folder/(name+'.bend');shutil.copyfile(HERE/(name+'.bend'),source);case={'subject':name,'sourceSHA256':hashlib.sha256(source.read_bytes()).hexdigest(),'commands':[]};r['cases'].append(case)
  check=run(['bend',source,'--check-only'],15);case['commands'].append(check)
  if check.get('exit')!=0:case['status']='CHECKER_REJECTED' if check.get('exit')==1 else 'CHECKER_FAILURE';continue
  assert 'ALL PROOFS CHECK' in check['out']+check['err'];case['status']='CHECKER_ACCEPTED'
  if name=='plain-duplicate' or name.startswith('generic-open'):continue
  c=folder/'subject.c';js=folder/'subject.js';native=folder/'subject.native'
  for backend,steps in [('Native',[(['bend',source,'-o',c],30),(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',c,'-o',native,'-lm','-pthread'],120),([native,'--threads','1','--gpu','off'],5)]),('JS',[(['bend',source,'-o',js],30),(['node',js],5)])]:
   for command,limit in steps:
    result=run(command,limit);case['commands'].append(result)
    if result.get('exit')!=0:case.setdefault('backend',{})[backend]={'status':'FAILED','phase':str(command[0]),'result':result};break
   else:case.setdefault('backend',{})[backend]={'status':'EXECUTED','output':result['out'].strip()}
 r['status']='CAPTURE_CANARY_OBSERVED_NOT_UNIVERSAL_GATE'
except Exception as e:r.update(status='FAILED',error=repr(e));raise
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps({'status':r['status'],'cases':[{'subject':c['subject'],'status':c['status'],'backend':c.get('backend')} for c in r['cases']]}))
