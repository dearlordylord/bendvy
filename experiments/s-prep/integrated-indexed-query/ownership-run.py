#!/usr/bin/env python3
"""Reject duplicating the actual query's affine state; not a refinement proof."""
import argparse, hashlib, importlib.util, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('bounded',ROOT/'experiments/t05/run.py');B=importlib.util.module_from_spec(spec);spec.loader.exec_module(B)
def main():
 p=argparse.ArgumentParser();p.add_argument('--overlay',required=True,type=Path);p.add_argument('--evidence',required=True,type=Path);a=p.parse_args();result={'candidateQuerySHA256':hashlib.sha256((a.overlay/'experiments/s-integrate/query.bend').read_bytes()).hexdigest(),'status':'INCOMPLETE','checkerLimitSeconds':5,'controls':[]}
 try:
  for name,expected in [('positive',0),('negative',1)]:
   source=a.overlay/'experiments/s-integrate'/('indexed-owner-'+name+'.bend');source.write_bytes((HERE/('ownership-'+name+'.bend')).read_bytes())
   out=B.command([B.CHECK,source,'--check-only'],expected=expected)
   if expected:assert 'state (consumed more than once)' in out,out
   else:assert 'ALL PROOFS CHECK' in out,out
   result['controls'].append({'name':name,'sourceSHA256':hashlib.sha256(source.read_bytes()).hexdigest(),'expectedExit':expected,'output':out})
  result['status']='ACTUAL_INDEXED_STATE_AFFINE_REJECTION_PASS'
 except Exception as e:result.update(status='FAIL',error=str(e))
 a.evidence.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2));return int(result['status']=='FAIL')
if __name__=='__main__':raise SystemExit(main())
