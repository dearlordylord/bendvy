#!/usr/bin/env python3
"""Fresh unchanged protected static-provider fixtures on actual source29."""
import argparse,hashlib,json,pathlib,subprocess,sys,time
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'))
import static_provider_boundary as SPB
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();assert not a.output.exists()
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
pins=json.loads((a.overlay/'overlay.json').read_text())['sources'];assert len(pins)==29 and all(sha(a.overlay/n)==v for n,v in pins.items())
r={'status':'INCOMPLETE','sourcePins':pins,'protectedRunnerSHA256':sha(SPB.__file__),'checkerDiagnosticLimitSeconds':15,'proofDefaultLimitSeconds':5}
def check(path):
 start=time.monotonic();v=subprocess.run(['taskset','-c','8','bend',str(path),'--check-only'],capture_output=True,text=True,timeout=15)
 return {'exit':v.returncode,'output':v.stdout+v.stderr,'seconds':time.monotonic()-start}
try:
 r['controls']=SPB.run(a.overlay/'experiments/s-integrate',check);assert r['controls'] is not None;r['status']='FRESH_SOURCE29_STATIC_PROVIDER_TWO_POSITIVE_SIX_NEGATIVE_PASS'
except Exception as e:r.update(status='FAILED',error=repr(e));raise
finally:a.output.write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])
