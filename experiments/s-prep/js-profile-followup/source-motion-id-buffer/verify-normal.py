#!/usr/bin/env python3
"""Read-only exact producer/layer join verification, no acceptance or timing."""
import pathlib,json,hashlib,gzip
H=pathlib.Path(__file__).resolve().parent;P=H/'direct-v1-pipeline';S=pathlib.Path('/tmp/bendvy-slot-host-motion-id-buffer-direct-v1');O=pathlib.Path('/tmp/bendvy-motion-id-buffer-direct-generated-v1');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();load=lambda p:json.loads(p.read_text())
o=load(S/'overlay.json');cache=load(S/'cache-specialization.json');pins=o['sources'];assert len(pins)==29 and o['cacheSpecialization']==cache
closure=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert closure=='84b808cee2c1a657569888229241dd95ae59f314025512c20159d951f4a1db2c'
assert cache['runtimeClosure']==pins==cache['specializedClosure'];assert cache['runtimeClosureSHA256']==closure==cache['specializedClosureSHA256']
for n,h in pins.items():assert sha(S/n)==h,n
facts=load(P/'token-pool/source-facts.json');assert facts['sourceRoot']==str(S) and facts['runtimeSourcePins']==pins and facts['typesSHA256']==pins['experiments/s-integrate/types.bend'];assert hashlib.sha256(gzip.decompress((P/'token-pool/types-source.bend.gz').read_bytes())).hexdigest()==facts['typesSHA256']
for schema in ['motion']:
 b=pathlib.Path('/tmp/bendvy-motion-id-buffer-direct-dense1024-build-v1');m=load(b/'build.json');assert m['status']=='BUILD_PASS' and m['sourceClosure']==closure and m['sourcePins']==pins
 assert m['toolBytesStableBeforeAfter'] and m['cIncludeBytesStableBeforeAfter'] and m['toolPinsBefore']['pins']==m['toolPinsAfter']['pins']
 for n,h in {**m['toolPinsBefore']['pins'],**m['cIncludePinsBeforeClang'],**m['builderInputPins'],**m['inputManifestPins']}.items():assert sha(pathlib.Path(n))==h,n
 assert m['recipeSHA256']==sha(pathlib.Path('/tmp/bendvy-slot-staging/experiments/s-prep/source-motion-id-buffer/direct-drain/build.py')) and m['toolPinRecipeSHA256']==sha(pathlib.Path('/tmp/bendvy-slot-staging/experiments/s-prep/source-motion-id-buffer/direct-drain/tool-pins.py'))
 for n,h in m['artifacts'].items():assert sha(b/n)==h,n
 assert m['sourceOutputSHA256']==sha(b/'batch.bend') and m['measurementOutputSHA256']==sha(b/'measurement-bend.bend')
 d=m['countAdaptation'];assert d['count']==1024 and d['batch']==64 and d['ticks']==64
 assert d['originalDriverSHA256']==sha(pathlib.Path(d['parentEntry'])) and d['derivedDriverSHA256']==sha(b/'batch.bend')
 old=pathlib.Path(d['parentEntry']).read_text();actual=(b/'batch.bend').read_text();anchor=schema+'_batch'
 anchor=anchor.lower()+'(256,64)'
 prefix='/tmp/bendvy-slot-host-handoff-v8-coherent/';assert old.count(prefix)==4
 driver=old.replace(prefix,str(S)+'/');assert driver.count(anchor)==1 and actual==driver.replace(anchor,anchor.replace('256','1024'),1)
 frame=driver.replace(anchor,schema.lower()+'_batch(COUNT,64)',1);assert hashlib.sha256(frame.encode()).hexdigest()==d['bodyFrameSHA256']
 previous=b/'batch.js'
 for stage,recipe,catalog in [('row',P/'row-rewrite.cjs',P/'row-input-pins.json'),('pool',P/'token-pool/rewrite.cjs',P/'token-pool/input-pins.json'),('tuple',P/'rewrite.cjs',P/'input-pins.json')]:
  f=O/(schema+'-'+stage+'.js');r=load(pathlib.Path(str(f)+'.recipe.json'));cat=load(catalog);pin=cat[sha(previous)]
  assert pin['inputPath']==str(previous) and pin['sourceRoot']==str(S) and pin['sourcePins']==pins
  assert r['inputSHA256']==sha(previous) and r['outputSHA256']==sha(f) and r['sourceRoot']==str(S) and r['sourcePins']==pins and r['recipeSHA256']==sha(recipe) and r['catalogSHA256']==sha(catalog)
  for n,h in pin.get('provenancePins',{}).items():assert sha(pathlib.Path(n))==h,n
  if stage=='pool':assert r['sourceFactsSHA256']==sha(P/'token-pool/source-facts.json')
  if stage=='tuple':assert r['analysisSHA256']==sha(P/'analyze.cjs')
  previous=f

print(json.dumps({'status':'EXACT_DIRECT_MOTION_DENSE1024_PRODUCER_THREE_LAYER_JOINS_PASS','sourceClosure':closure,'schemas':1}))
