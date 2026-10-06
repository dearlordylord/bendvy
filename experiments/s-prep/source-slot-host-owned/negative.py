#!/usr/bin/env python3
import argparse,json,pathlib,shutil,subprocess,hashlib,time
from pins import verify
H=pathlib.Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();files,pins,closure=verify(a.overlay);a.output.mkdir(exist_ok=False);receipts=[]
for schema,ty in [('motion','PrototypeMotionMainSlot'),('health','PrototypeHealthMainSlot')]:
 stage=a.output/schema;stage.mkdir()
 for n,b in files.items():(stage/n).write_bytes(b)
 f=stage/'negative.bend';f.write_text('import Base\nimport ./cached-payload.bend as CP\nimport ./host.bend as H\ndef bad(+owner:CP.'+ty+') -> CP.'+ty+' & CP.'+ty+':\n  (owner,owner)\n')
 cmd=['taskset','-c','10','timeout','-k','1s','15s','bend',str(f),'--check-only'];st=time.monotonic();r=subprocess.run(cmd,capture_output=True,text=True,timeout=17);text=r.stdout+r.stderr;(stage/'diagnostic.txt').write_text(text);good=r.returncode==1 and all(x in text for x in ['SOME PROOFS FAIL','Location: bad','expected : Data','observed : Type']);receipts.append({'schema':schema,'command':cmd,'elapsedSeconds':time.monotonic()-st,'returncode':r.returncode,'status':'INTENDED_TYPE_REJECTION' if good else 'FAIL','fixtureSHA256':hashlib.sha256(f.read_bytes()).hexdigest()})
(a.output/'evidence.json').write_text(json.dumps({'status':'PASS' if all(x['status']=='INTENDED_TYPE_REJECTION' for x in receipts) else 'FAIL','closure':closure,'source29':pins,'cases':receipts,'route':'Actual nominal affine Slot cannot be annotated as duplicable Data'},indent=2)+'\n');assert all(x['status']=='INTENDED_TYPE_REJECTION' for x in receipts)
