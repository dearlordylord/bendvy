#!/usr/bin/env python3
"""Paired opaque-owner/token controls at the new trusted adapter seam."""
import argparse,hashlib,importlib.util,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent
sp=importlib.util.spec_from_file_location('bounded',ROOT/'experiments/t05/run.py');B=importlib.util.module_from_spec(sp);sp.loader.exec_module(B)
def main():
 p=argparse.ArgumentParser();p.add_argument('--overlay',required=True,type=Path);p.add_argument('--evidence',required=True,type=Path);a=p.parse_args();r={'status':'INCOMPLETE','checkerLimitSeconds':5,'scope':'Finite closed polymorphic provider controls; not universal authority/refinement','controls':[]}
 try:
  for name,expected,markers in [('positive-read',0,['ALL PROOFS CHECK']),('negative-schema',1,['T.PositionToken','T.VitalsToken']),('negative-read-write',1,['held.Held','Owner']),('negative-duplicate',1,['owner (consumed more than once)']),('negative-reconstruct',1,['Owner','T.Position'])]:
   target=a.overlay/'experiments/s-integrate'/(name+'.bend');target.write_bytes((HERE/(name+'.bend')).read_bytes());out=B.command([B.CHECK,target,'--check-only'],expected=expected);assert all(m in out for m in markers),(name,out);r['controls'].append({'name':name,'expectedExit':expected,'sourceSHA256':hashlib.sha256(target.read_bytes()).hexdigest(),'output':out})
  r['status']='FINITE_HELD_ADAPTER_ACCESS_NEGATIVES_PASS'
 except Exception as e:r.update(status='FAIL',error=str(e))
 a.evidence.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2));return int(r['status']=='FAIL')
if __name__=='__main__':raise SystemExit(main())
