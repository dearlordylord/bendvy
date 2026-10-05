#!/usr/bin/env python3
"""Original/CPS sparse retained high-water comparison with Node's default stack."""
import argparse, hashlib, json, os, re, sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parents[2]/'experiments/s-prep/fivehour-connected-gates'))
import supervisor
p=argparse.ArgumentParser();p.add_argument('--original',type=Path,required=True);p.add_argument('--candidate',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--cpu',type=int,default=9);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{a.cpu})
r={'status':'INCOMPLETE','cpu':a.cpu,'highWater':65538,'capacity':131072,'scope':'Default-stack JS trampoline, aligned all-dead columns; finite original/candidate comparison','commands':[],'cases':[]}
try:
 for role,overlay in [('original',a.original),('candidate',a.candidate)]:
  pins=json.loads((overlay/'overlay.json').read_text())['sources'];assert len(pins)==29 and all(hashlib.sha256((overlay/n).read_bytes()).hexdigest()==h for n,h in pins.items())
  core=overlay/'experiments/s-integrate';source=re.sub(r'^import (\./\S+\.bend)',lambda m:'import '+str((core/m[1]).resolve()),(HERE/'sparse-high.bend').read_text(),flags=re.M);driver=a.output/(role+'.bend');driver.write_text(source);generated=a.output/(role+'.js')
  for argv,cap in [(['bend',str(driver),'--check-only'],15),(['bend',str(driver),'-o',str(generated)],30),(['node',str(generated)],5)]:
   rec={'role':role,'argv':argv,'cap':cap};r['commands'].append(rec)
   try:code,text=supervisor.execute(argv,cap);rec.update(exit=code,output=text[-2000:]);assert code==0
   except Exception as error:rec['error']=repr(error);raise
  assert text.strip()=='SPARSE-HIGH-PASS';(a.output/(role+'.observed.txt')).write_text(text);r['cases'].append({'role':role,'status':'PASS','generatedSHA256':hashlib.sha256(generated.read_bytes()).hexdigest()})
 r['status']='ORIGINAL_AND_CPS_DEFAULT_STACK_SPARSE65538_PASS'
except Exception as error:r.update(status='FAILED',error=repr(error))
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(r));sys.exit(0 if r['status']=='ORIGINAL_AND_CPS_DEFAULT_STACK_SPARSE65538_PASS' else 1)
