#!/usr/bin/env python3
from pathlib import Path
import json,hashlib
H=Path(__file__).resolve().parent;sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();load=lambda p:json.loads(p.read_text());files={};receipts={}
def add(p):p=Path(p);assert p.is_file();files[str(p)]=sha(p)
source=Path('/tmp/bendvy-slot-host-concrete-owner-v3');overlay=load(source/'overlay.json');pins=overlay['sources'];assert len(pins)==29
for n in pins:add(source/n)
for n in ['overlay.json','cache-specialization.json']:add(source/n)
for p in (H/'pipeline').rglob('*'):
 if p.is_file():add(p)
for lane in ['motion','health']:
 build=Path('/tmp/bendvy-concrete-owner-'+lane+'-dense1024-build');add(build/'build.json');m=load(build/'build.json');assert m['status']=='BUILD_PASS' and m['sourcePins']==pins
 for n in m['artifacts']:add(build/n)
 for stage in ['row','pool','tuple']:
  p=Path('/tmp/bendvy-concrete-owner-generated-v3')/(lane+'-'+stage+'.js');add(p);add(str(p)+'.recipe.json')
 for role in ['js','native']:
  p=Path('/tmp/bendvy-concrete-owner-'+lane+'-'+role+'-full65/evidence.json');assert load(p)['status']=='PASS_FULL65';add(p);receipts[str(p)]=sha(p)
 for role in ['transformed65','route65','count']:
  p=Path('/tmp/bendvy-concrete-owner-'+lane+'-'+role+'-v3/evidence.json');d=load(p);assert d['status'] in ['PASS_FULL65','FRESH_EXACT_SOURCE_NINE_WORLDS_PAIR_PASS'];add(p);receipts[str(p)]=sha(p)
for base in ['fixture-generated','fixture-route','fixture-mutants','packed-witness']:
 p=Path('/tmp/bendvy-concrete-owner-'+base+'-v3/evidence.json');d=load(p);assert 'FAILED'!=d['status'] and 'INCOMPLETE'!=d['status'];add(p);receipts[str(p)]=sha(p)
for p in ['/tmp/bendvy-concrete-owner-normal-verify-v3.json','/tmp/bendvy-concrete-owner-js-inspection.json','/tmp/bendvy-concrete-owner-row-guards-v3.json','/tmp/bendvy-concrete-owner-tuple-guards-v3.json']:add(p);receipts[p]=files[p]
for p in [Path('/workspace/formal-proofs/bendvy/experiments/s-prep/source-concrete-owner-handoff')/n for n in ['build.py','tool-pins.py','prepare-ts1024.py','validate-full65.py']]:add(p)
freeze={'status':'FROZEN_CONCRETE_V3_DENSE1024_GUARDED_JS_FINITE_GATES_PASS','sourceRoot':str(source),'sourceClosure':'a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55','sourcePins':pins,'normalConsumedFiles':files,'currentReceipts':receipts,'schemaPrograms':{lane:'/tmp/bendvy-concrete-owner-generated-v3/'+lane+'-tuple.js' for lane in ['motion','health']},'scope':'Exact fresh29/build/driver/layer and finite functional provenance; no child comparative time, gate transfer, canonical reset or adoption'}
(H/'freeze.json').write_text(json.dumps(freeze,indent=2)+'\n');(H/'status.json').write_text(json.dumps({k:v for k,v in freeze.items() if k!='normalConsumedFiles'},indent=2)+'\n');print(json.dumps({'status':freeze['status'],'files':len(files)}))
