#!/usr/bin/env python3
"""Read-only exact catalogue reconciliation, deliberately not validate_gates acceptance."""
import argparse,pathlib,json,hashlib,re,subprocess
p=argparse.ArgumentParser();p.add_argument('--root',type=pathlib.Path,required=True);p.add_argument('--source',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();sha=lambda b:hashlib.sha256(b).hexdigest();catalogue=a.root/'experiments/s-prep/fivehour-connected-gates/checks.py';text=catalogue.read_text();expected={'materialize-controls':'PASS_DERIVED_CONTROL_SOURCE_MAP','host12':'PASS','access':'ACTUAL_ACCESS_9_PASS','e11':'BOUNDED_JOINED_PASS','owned-storage':'ACTUAL_FINAL_STORAGE_FIELDS_OWNERSHIP_MUTANTS_PASS','staging':'PASS_BOUNDED_STAGING_TYPE_BOUNDARY','tx-baseline':'FINITE_ACTUAL_TX_CACHE_FIELDS_PASS',**{'tx-'+v:'DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE' for v in ['stale-head','torn-tail','lost-mark','inverse-order']}};assert all(repr(n) in text for n in list(expected)[:7]);assert "('stale-head','torn-tail','lost-mark','inverse-order')" in text
m=json.loads((a.source/'overlay.json').read_text());pins=m['sources'];digest=sha(json.dumps(pins,sort_keys=True,separators=(',',':')).encode());assert len(pins)==29 and digest=='4baad4960575cda216576e8b90593fbd7ed7dcd44cfa86836b8d87dd5af71f5c';assert all(sha((a.source/n).read_bytes())==h for n,h in pins.items());cache=json.loads((a.source/'cache-specialization.json').read_text());assert cache==m['cacheSpecialization'] and all(cache[k]==pins and cache[k+'SHA256']==digest for k in ['runtimeClosure','specializedClosure'])
r={'status':'DIAGNOSTIC_GATE_MAP_CANONICAL_AGGREGATE_OPEN','sourceClosureSHA256':digest,'sourcePins29':pins,'masterAtReview':subprocess.check_output(['git','-C',str(a.root),'rev-parse','HEAD'],text=True).strip(),'catalogueSHA256':sha(catalogue.read_bytes()),'expectedIDsPerRole':list(expected),'roles':['JS','Native'],'gates':[]}
paths={
'host12':['/tmp/bendvy-slot-host-motion-original-v1/evidence.json','/tmp/bendvy-slot-host-health-original-v1/evidence.json',str(a.root/'experiments/s-prep/source-slot-host-controls/host12-evidence.json')],
'access':['/tmp/bendvy-slot-host-access-v3/evidence.json'],
'e11':['/tmp/bendvy-slot-host-retention-original-v2/evidence.json','/tmp/bendvy-slot-host-retention-mutants-v1/evidence.json'],
'owned-storage':['/tmp/bendvy-slot-host-owned-generic-v1/wrapper.json','/tmp/bendvy-slot-host-owned-generic-v1/actual/evidence.json'],
'staging':[str(a.root/'experiments/s-prep/source-slot-staging/summary.json')],
 'tx-baseline':['/tmp/bendvy-slot-host-tx-controls-v2/evidence.json']}
for n in expected:
 ps=paths.get(n,[])
 if n.startswith('tx-') and n!='tx-baseline':ps=['/tmp/bendvy-slot-host-tx-mutants-v3/evidence.json']
 receipts=[]
 for s in ps:
  path=pathlib.Path(s);b=path.read_bytes();x=json.loads(b);receipts.append({'path':str(path),'SHA256':sha(b),'observedStatus':x.get('status'),'sourceBinding':x.get('sourceClosureSHA256',x.get('sourceClosure'))})
 coverage='STRUCTURAL_MAP_OPEN' if n=='materialize-controls' else 'PARTIAL_9_STATIC8_WORLD16_OPEN' if n=='access' else 'FRESH_BOTH_BACKEND_FINITE_COVERAGE'
 route='original private persistent Slot Host, ordinary generic query/Tx/barrier' if n in ['host12','e11'] else 'opaque private Slot A/B and frozen public query access' if n=='access' else 'original generic Rows with arbitrary affine Type components; private supplements separate' if n=='owned-storage' else 'actual Slot command ingress/factory two-world queue preservation' if n=='staging' else 'supplied namespace/IDs into typed row wrapper + FlatPair Tx; not cursor enumeration' if n.startswith('tx-') else 'route-aware fixture/provider/observer source cohort materialization not completed'
 r['gates'].append({'id':n,'canonicalExpectedStatus':expected[n],'coverage':{'JS':coverage,'Native':coverage},'route':route,'receipts':receipts,'canonicalAggregateAccepted':False})
assert len(r['gates'])==11;r['remainingExactIDs']=['materialize-controls','access'];r['caveat']='Finite coverage map only; no canonical full22, source route transfer, performance/adoption or universal refinement approval';a.output.write_text(json.dumps(r,indent=2)+'\n')
