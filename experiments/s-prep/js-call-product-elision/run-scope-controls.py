#!/usr/bin/env python3
import argparse,hashlib,json,os,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9});here=Path(__file__).resolve().parent;r=[]
for name in ['order','escape','write','nested','shadow','callee-write']:
 source=here/(name+'-control.js');output=a.output/(name+'.js');argv=['node','--expose-internals',str(here/'rewrite.cjs'),str(source),str(output)];made=subprocess.run(argv,capture_output=True,timeout=5);receipt={'control':name,'argv':argv,'limitSeconds':5,'rewriteExit':made.returncode,'diagnostic':made.stderr.decode()}
 if name=='order':
  assert made.returncode==0,made.stderr
  original=subprocess.run(['node',str(source)],check=True,capture_output=True,timeout=5).stdout;changed=subprocess.run(['node',str(output)],check=True,capture_output=True,timeout=5).stdout;assert original==changed
  lines=[json.loads(x) for x in original.splitlines()];assert lines==[{'kind':'retained-fields','result':{'tag':'tag','old':11,'now':12,'rest':[12,13,14]},'retained':[11,12,13,14],'events':['prefix','read','receiver','write','read']},{'kind':'prefix-throw','error':'prefix-failure','events':['prefix']},{'kind':'read-throw','error':'read-failure','events':['prefix','read']}]
  receipt.update(status='EXPECTED_FULL_OUTPUT_EQUAL',stdout=original.decode(),recipe=json.loads(Path(str(output)+'.recipe.json').read_text()))
 else:assert made.returncode!=0 and not output.exists();receipt['status']='REFUSED_NO_OUTPUT'
 r.append(receipt)
(a.output/'scope-controls.json').write_text(json.dumps(r,indent=2)+'\n');print([(x['control'],x['status'])for x in r])
