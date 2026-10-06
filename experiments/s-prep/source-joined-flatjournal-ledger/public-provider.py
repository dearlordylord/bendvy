#!/usr/bin/env python3
"""Fresh unchanged public Held two-positive/six-negative boundary controls."""
import argparse,pathlib,json,hashlib,os,sys,importlib.util,subprocess,signal,time,shutil
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{10});ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');BASE=ROOT/'experiments/s-prep/fivehour-connected-gates';HERE=pathlib.Path(__file__).resolve().parent;sys.path.insert(0,str(BASE));import static_provider_boundary as SPB
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest();pins=json.loads((a.overlay/'overlay.json').read_text())['sources'];assert len(pins)==29 and all(sha(a.overlay/n)==v for n,v in pins.items())
s=importlib.util.spec_from_file_location('local_pc',HERE/'local-provider-controls.py');pc=importlib.util.module_from_spec(s);s.loader.exec_module(pc);SPB.PC.static_registration=pc.static_registration
r={'status':'INCOMPLETE','scope':'Original public Held boundary registration, distinct from private new row owner boundary16; finite only','CPU':10,'sourcePins':pins,'protectedRunnerSHA256':sha(BASE/'static_provider_boundary.py'),'localRegistrationSHA256':sha(HERE/'local-provider-controls.py'),'checkerDiagnosticSeconds':15,'proofDefaultSeconds':5,'commands':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def checker(source):
 target=a.output/source.name;shutil.copyfile(source,target);start=time.monotonic();c=subprocess.Popen(['bend',str(target),'--check-only'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True);timed=False
 try:out=c.communicate(timeout=15)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(c.pid,signal.SIGKILL);out=c.communicate()[0]
 result={'argv':['bend',str(target),'--check-only'],'limitSeconds':15,'exit':c.returncode,'timeout':timed,'seconds':time.monotonic()-start,'output':out};r['commands'].append(result);save();assert not timed,result;return result
try:r['result']=SPB.run(a.overlay/'experiments/s-integrate',checker);assert r['result'] is not None;r['status']='PUBLIC_HELD_TWO_POSITIVE_SIX_NEGATIVE_EXACT_DIAGNOSTICS_PASS'
except Exception as e:r.update(status='FAIL',error=repr(e));raise
finally:save()
