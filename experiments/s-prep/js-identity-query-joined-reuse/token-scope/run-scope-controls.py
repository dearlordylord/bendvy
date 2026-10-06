#!/usr/bin/env python3
import argparse,json,os,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9});here=Path(__file__).resolve().parent;receipts=[]
for name in ['retained','fields','type','write','escape','identity','arguments','capture']:
 source=here/(name+'-control.js');output=a.output/(name+'.js');cmd=['node','--expose-internals',str(here/'rewrite.cjs'),str(source),str(output)];made=subprocess.run(cmd,capture_output=True,timeout=5);r={'control':name,'argv':cmd,'limitSeconds':5,'rewriteExit':made.returncode,'diagnostic':made.stderr.decode()}
 if name=='retained':
  assert made.returncode==0,made.stderr;old=subprocess.run(['node',str(source)],capture_output=True,check=True,timeout=5).stdout;new=subprocess.run(['node',str(output)],capture_output=True,check=True,timeout=5).stdout;assert old==new;assert json.loads(new)=={'reads':['types.PositionToken','types.PositionToken','types.VitalsToken','types.MotionLedgerToken','types.HealthLedgerToken'],'sameTag':True,'oppositeTag':False};r.update(status='EXPECTED_READS_EQUAL',stdout=new.decode(),recipe=json.loads(Path(str(output)+'.recipe.json').read_text()))
  frozen=subprocess.run(['node','-e',output.read_text()+'\nconsole.log([__pool_token_0,__pool_token_1,__pool_token_2,__pool_token_3].every(Object.isFrozen));'],capture_output=True,check=True,timeout=5);assert frozen.stdout.endswith(b'true\n');r['allFourPooledObjectsFrozen']=True
 else:assert made.returncode!=0 and not output.exists();r['status']='REFUSED_NO_OUTPUT'
 receipts.append(r)
(a.output/'scope-controls.json').write_text(json.dumps(receipts,indent=2)+'\n');print([(x['control'],x['status'])for x in receipts])
