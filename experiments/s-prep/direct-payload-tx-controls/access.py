#!/usr/bin/env python3
"""Fresh unchanged-source authority lineage; no emitted-JS alias theorem."""
import argparse,hashlib,json,os,pathlib,signal,subprocess,time
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{10});os.environ['BENDVY_CHECKER_SECONDS']='15';ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');BASE=ROOT/'experiments/s-prep/fivehour-connected-gates';OVERLAY=pathlib.Path('/tmp/bendvy-live-first-native');sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest();manifest=json.loads((OVERLAY/'overlay.json').read_text());assert len(manifest['sources'])==29 and all(sha(OVERLAY/n)==v for n,v in manifest['sources'].items());r={'status':'INCOMPLETE','scope':'Fresh actual direct source access/provider/factory lineage only; does not prove generic emitted-JS alias legality','CPU':10,'actualCheckerOptInSeconds':15,'defaultProofCheckerSeconds':5,'runtimeSeconds':5,'sourcePins':manifest['sources'],'commands':[],'runnerPins':{str(p):sha(p) for p in [BASE/'materialize-controls.py',BASE/'access-run.py',BASE/'static_provider_boundary.py',BASE/'static-world-run.py']}}
def save():(a.output/'lineage.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,limit):
 start=time.monotonic();child=subprocess.Popen(list(map(str,argv)),stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True);timed=False
 try:out=child.communicate(timeout=limit)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(child.pid,signal.SIGKILL);out=child.communicate()[0]
 r['commands'].append({'argv':list(map(str,argv)),'orchestrationLimitSeconds':limit,'exit':child.returncode,'timeout':timed,'seconds':time.monotonic()-start,'output':out});save();assert child.returncode==0,r['commands'][-1]
try:
 run(['python3',BASE/'materialize-controls.py','--overlay',OVERLAY,'--output',a.output/'control-overlay','--raw-snapshots','--slice-host-fixtures'],30)
 run(['python3',BASE/'access-run.py',a.output/'control-overlay','--evidence',a.output/'access.json','--cpu','10'],300)
 x=json.loads((a.output/'access.json').read_text());assert len(x['cases'])==9;assert x['staticWorldBoundary']['status']=='FINITE_ACTUAL_STATIC_FOREIGN_WORLD_FIELDS_PASS';r.update(status='NINE_ACCESS_PROVIDER_BOUNDARY_AND_SIXTEEN_FACTORY_LINEAGE_PASS',accessSHA256=sha(a.output/'access.json'),legacyAccessCheckerMetadata=x['checker_limit_seconds']);save()
finally:assert all(sha(OVERLAY/n)==v for n,v in manifest['sources'].items());assert all(sha(p)==v for p,v in r['runnerPins'].items());save()
