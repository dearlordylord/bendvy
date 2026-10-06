#!/usr/bin/env python3
"""Read-only exact producer/layer join verification, no acceptance or timing."""
import pathlib,json,hashlib,gzip
H=pathlib.Path(__file__).resolve().parent;P=H/'pipeline';S=pathlib.Path('/tmp/bendvy-slot-host-handoff-v8-coherent');O=pathlib.Path('/tmp/bendvy-source-handoff-generated-v8');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();load=lambda p:json.loads(p.read_text())
o=load(S/'overlay.json');cache=load(S/'cache-specialization.json');pins=o['sources'];assert len(pins)==29 and o['cacheSpecialization']==cache
closure=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert closure=='4eb71a36304194a1c2764c7301ed59afa9b4d0a4ee7336b8b6c7f8175095f235'
assert cache['runtimeClosure']==pins==cache['specializedClosure'];assert cache['runtimeClosureSHA256']==closure==cache['specializedClosureSHA256']
for n,h in pins.items():assert sha(S/n)==h,n
facts=load(P/'token-pool/source-facts.json');assert facts['sourceRoot']==str(S) and facts['runtimeSourcePins']==pins and facts['typesSHA256']==pins['experiments/s-integrate/types.bend'];assert hashlib.sha256(gzip.decompress((P/'token-pool/types-source.bend.gz').read_bytes())).hexdigest()==facts['typesSHA256']
for schema in ['motion','health']:
 b=pathlib.Path('/tmp/bendvy-source-handoff-'+schema+'-build-v8');m=load(b/'build.json');assert m['status']=='BUILD_PASS' and m['sourceClosure']==closure and m['sourcePins']==pins
 assert m['toolBytesStableBeforeAfter'] and m['cIncludeBytesStableBeforeAfter'] and m['toolPinsBefore']['pins']==m['toolPinsAfter']['pins']
 for n,h in {**m['toolPinsBefore']['pins'],**m['cIncludePinsBeforeClang'],**m['builderInputPins'],**m['inputManifestPins']}.items():assert sha(pathlib.Path(n))==h,n
 assert m['recipeSHA256']==sha(H/'build.py') and m['toolPinRecipeSHA256']==sha(H/'tool-pins.py')
 for n,h in m['artifacts'].items():assert sha(b/n)==h,n
 assert m['sourceOutputSHA256']==sha(b/'batch.bend') and m['measurementOutputSHA256']==sha(b/'measurement-bend.bend')
 previous=b/'batch.js'
 for stage,recipe,catalog in [('row',P/'row-rewrite.cjs',P/'row-input-pins.json'),('pool',P/'token-pool/rewrite.cjs',P/'token-pool/input-pins.json'),('tuple',P/'rewrite.cjs',P/'input-pins.json')]:
  f=O/(schema+'-'+stage+'.js');r=load(pathlib.Path(str(f)+'.recipe.json'));cat=load(catalog);pin=cat[sha(previous)]
  assert pin['inputPath']==str(previous) and pin['sourceRoot']==str(S) and pin['sourcePins']==pins
  assert r['inputSHA256']==sha(previous) and r['outputSHA256']==sha(f) and r['sourceRoot']==str(S) and r['sourcePins']==pins and r['recipeSHA256']==sha(recipe) and r['catalogSHA256']==sha(catalog)
  for n,h in pin.get('provenancePins',{}).items():assert sha(pathlib.Path(n))==h,n
  if stage=='pool':assert r['sourceFactsSHA256']==sha(P/'token-pool/source-facts.json')
  if stage=='tuple':assert r['analysisSHA256']==sha(P/'analyze.cjs')
  previous=f
 for role,program in [('js65',b/'batch.js'),('native65',b/'batch-native'),('transformed65',previous)]:
  r=load(pathlib.Path('/tmp/bendvy-source-handoff-'+schema+'-'+role+'-v8/evidence.json'));assert r['status']=='PASS_FULL65' and r['worlds']==65 and r['allFullFieldsEqual'] and r['programSHA256']==sha(program)
print(json.dumps({'status':'EXACT_V8_NORMAL_PRODUCER_AND_THREE_LAYER_JOINS_PASS','sourceClosure':closure,'schemas':2,'scope':'Exact pinned finite source/build/layer/full65 joins; broader source gates, performance and universal refinement are separate'}))
