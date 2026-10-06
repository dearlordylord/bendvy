#!/usr/bin/env python3
"""Supervise unchanged existing Owned storage runner; generic route only."""
import argparse,hashlib,json,os,pathlib,signal,subprocess,time
H=pathlib.Path(__file__).resolve().parent;ROOT=H.parents[2]
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False)
verifier=ROOT/'experiments/s-prep/source-slot-host/verify.py';subprocess.run(['python3',str(verifier),str(a.overlay)],check=True)
runner=ROOT/'experiments/s-prep/fivehour-connected-gates/owned-storage-run.py';assert hashlib.sha256(runner.read_bytes()).hexdigest()=='fcc1b1166fcd1fbe1cbabbccaeedfb79085183d020aae4cb3208ead4386ec69e';env=os.environ.copy();env.update(BENDVY_FINAL_OVERLAY=str(a.overlay),BENDVY_OWNED_ARTIFACT=str(a.output/'actual'),BENDVY_CPU='10',BENDVY_CHECKER_SECONDS='15')
cmd=['python3',str(runner)];start=time.monotonic();ch=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True,env=env)
r={'status':'INCOMPLETE','route':'original generic affine Type Rows; not private Slot/Host dispatch','runner':str(runner),'runnerSHA256':hashlib.sha256(runner.read_bytes()).hexdigest(),'command':cmd,'explicitEnvironment':{k:env[k] for k in ['BENDVY_FINAL_OVERLAY','BENDVY_OWNED_ARTIFACT','BENDVY_CPU','BENDVY_CHECKER_SECONDS']},'checkerDiagnosticSeconds':15,'defaultProofCheckerSeconds':5}
try:
 out,err=ch.communicate(timeout=1200);r.update(returncode=ch.returncode,elapsedSeconds=time.monotonic()-start,status='PASS' if ch.returncode==0 else 'FAIL')
except subprocess.TimeoutExpired:
 os.killpg(ch.pid,signal.SIGKILL);out,err=ch.communicate();r.update(status='OUTER_TIMEOUT',elapsedSeconds=time.monotonic()-start)
(a.output/'stdout.txt').write_text(out);(a.output/'stderr.txt').write_text(err);(a.output/'wrapper.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2));raise SystemExit(0 if r['status']=='PASS' else 1)
