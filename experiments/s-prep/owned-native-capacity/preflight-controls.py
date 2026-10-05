#!/usr/bin/env python3
"""Preflight-only controls; execute no evaluator, compiler or Node process."""
import argparse,hashlib,json,tempfile
from pathlib import Path
import preflight
H=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--evidence',type=Path,required=True);a=p.parse_args()
r={'scope':'Preflight-only: no artifact build, Node, construction or timing rerun','controls':[]}
r['positive']={'base':preflight.base(Path('/tmp/bendvy-held-integrated-overlay-v2')),'prepared':preflight.prepared(Path('/tmp/bendvy-owned-native-capacity-v2')),'evaluatorRoot':preflight.evaluator_root(preflight.PROJECT)}
with tempfile.TemporaryDirectory(prefix='capacity-wrong-root-') as wrongroot:
 try:preflight.evaluator_root(Path(wrongroot));raise RuntimeError('Mismatched import root accepted')
 except AssertionError as e:r['controls'].append({'name':'mismatched-evaluator-root','status':'REJECTED_BEFORE_IMPORT','diagnostic':str(e)})
originalH=preflight.H
with tempfile.TemporaryDirectory(prefix='capacity-repin-control-') as tmp:
 tmp=Path(tmp);ledger=json.loads((H/'source-bindings.json').read_text());ledger['rawReceiptSHA256']=hashlib.sha256(b'proposed altered receipt').hexdigest();(tmp/'source-bindings.json').write_text(json.dumps(ledger))
 preflight.H=tmp
 try:
  # Missing recipe path proves the frozen ledger is rejected before any recipe read.
  preflight.prepared(tmp/'nonexistent-derived-input');raise RuntimeError('Repinned ledger accepted')
 except AssertionError as e:r['controls'].append({'name':'repinned-source-ledger','status':'REJECTED_BEFORE_RECIPE_READ','diagnostic':str(e)})
 finally:preflight.H=originalH
r['status']='PREFLIGHT_POSITIVE_AND_NEGATIVES_PASS'
r['runnerSHA256']=hashlib.sha256(Path(__file__).read_bytes()).hexdigest();
with a.evidence.open('x') as output:output.write(json.dumps(r,indent=2)+'\n')
print(r['status'])
