#!/usr/bin/env python3
"""Receipt guard controls only: no compiler, runtime or semantic acceptance."""
import hashlib,importlib.util,json,subprocess,tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('checks',HERE/'checks.py');C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
def main():
 import argparse
 p=argparse.ArgumentParser();p.add_argument('--js-overlay',type=Path,required=True);p.add_argument('--native-overlay',type=Path,required=True);p.add_argument('--evidence',type=Path,required=True);a=p.parse_args();result={'status':'INCOMPLETE','scope':'Synthetic negative receipt guards; no actual gate acceptance','cases':[]}
 try:
  binding=C.dependency_binding();roles={role:{'status':'PASS','binding':C.source_binding(overlay),'gates':[{}]*11,'controlSources':{}} for role,overlay in [('JS',a.js_overlay),('Native',a.native_overlay)]}
  for case in ['incomplete','canonical-digest','dependencies','runtime-source']:
   prior={'status':'FRESH_TWO_ROLE_CONNECTED_GATES_PASS','dependencyBinding':binding,'roles':roles};prior=json.loads(json.dumps(prior))
   if case=='incomplete':prior['status']='INCOMPLETE'
   elif case=='dependencies':prior['dependencyBinding']['limits']['checker']=6
   elif case=='runtime-source':prior['roles']['JS']['binding']['runtimeSources']['experiments/s-integrate/cache.bend']='0'*64
   with tempfile.TemporaryDirectory(prefix='reuse-negative-') as folder:
    folder=Path(folder);receipt=folder/'receipt.json';receipt.write_text(json.dumps(prior));digest=hashlib.sha256(receipt.read_bytes()).hexdigest();output=folder/'out'
    if case=='canonical-digest':digest='0'*64
    command=['python3',str(HERE/'checks.py'),'--js-overlay',str(a.js_overlay),'--native-overlay',str(a.native_overlay),'--output',str(output),'--reuse-receipt',str(receipt),'--reuse-receipt-sha256',digest]
    process=subprocess.run(command,capture_output=True,text=True,timeout=30);observed=json.loads((output/'evidence.json').read_text());assert process.returncode!=0 and observed['status']=='FAIL',(case,'unexpected acceptance');expected={'incomplete':'Only complete fresh receipt','canonical-digest':'Canonical receipt digest','dependencies':'Gate/tool/reference dependencies changed','runtime-source':'Runtime candidate source changed'}[case];assert expected in observed['error'],(case,observed['error']);result['cases'].append({'name':case,'exit':process.returncode,'status':observed['status'],'error':observed['error']})
  result['status']='NEGATIVE_RECEIPT_GUARDS_PASS'
 except Exception as error:result.update(status='FAIL',error=repr(error));raise
 finally:a.evidence.write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
