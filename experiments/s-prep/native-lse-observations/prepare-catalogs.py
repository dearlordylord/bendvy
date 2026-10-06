#!/usr/bin/env python3
"""Build pending immutable byte catalogs; no execution or approval invention."""
import argparse,hashlib,json
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy');HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--motion-admission',type=Path,required=True);p.add_argument('--health-admission',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False)
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
base=json.loads(Path('/tmp/bendvy-concrete-owner-cohort-plan-r2.json').read_text())
path=Path('/tmp/bendvy-native-lse-build-v1/evidence.json');l=json.loads(path.read_text());inspector=Path('/tmp/bendvy-native-lse-build-v1/fresh-elf-inspection.json');i=json.loads(inspector.read_text())
assert l['status']=='BOTH_UNCHANGED_C_LSE_BUILD_AND_ELF_INSPECTION_PASS' and i['allPinnedBytesStableBeforeAfter']
for schema in ['Motion','Health']:
 s=l['subjects'][schema];source=Path(s['sourceRoot']);build=Path(s['inputC']).parent
 fpath=ROOT/'experiments/s-prep/js-profile-followup'/('source-motion-id-buffer' if schema=='Motion' else 'source-concrete-owner')/'freeze.json';f=json.loads(fpath.read_text())
 admission=a.motion_admission if schema=='Motion' else a.health_admission
 tools=l['toolPinsBefore']['pins'];headers=s['includePinsBefore'];hardware=l['hostBefore']['headerPins']
 libraries={k:v for k,v in {**tools,**i['pinsBefore']}.items() if '.so' in k}
 pins={}
 def pin(path,expected=None):
  path=Path(path).resolve();h=sha(path)
  if expected is not None:assert h==expected,('drift',str(path))
  assert str(path) not in pins or pins[str(path)]==h;pins[str(path)]=h
 for name in base['pins']:pin(name)
 for name,h in {**tools,**headers,**hardware,**i['pinsBefore'],**l['extraToolPins']}.items():pin(name,h)
 for name,h in {**f['normalConsumedFiles'],**f['currentReceipts']}.items():pin(name,h)
 for name,h in s['source29'].items():pin(source/name,h)
 for name in [path,inspector,path.with_name('exact-flag-join.json'),fpath,admission,build/'build.json',build/'batch.c',build/'batch-native',source/'overlay.json',source/'cache-specialization.json',s['native'],f['schemaPrograms'][schema.lower()],__file__,HERE/'observe.py',HERE/'summarize.py',HERE/'cohort.py',HERE/'prepare-plan.py']:pin(name)
 full={}
 for name in [f'/tmp/bendvy-native-lse-{schema.lower()}-full65-v1/evidence.json',f'/tmp/bendvy-'+('motion-id-buffer-direct-v1-native-full65' if schema=='Motion' else 'concrete-owner-health-native-full65')+'/evidence.json']:
  pin(name);full[name]=sha(name)
 c={'scope':'SAME_C_LSE_DENSE1024_ENROLLMENT','status':'PENDING_INDEPENDENT_REVIEW_AND_SOURCE_ADMISSION','schema':schema,'count':1024,'iterations':64,'batch':64,'defaultFlags':['-O3'],'lseFlags':['-O3','-march=armv8-a+lse'],'hwcapAtomics':l['hostBefore']['HWCAP_ATOMICS'],'sourceRoot':str(source),'sourceClosure':s['sourceClosure'],'defaultBuild':str(build/'build.json'),'lseBuild':str(path),'hardwareReceipt':str(path),'jsFreeze':str(fpath),'admission':str(admission.resolve()),'jsProgram':f['schemaPrograms'][schema.lower()],'defaultNative':s['baselineNative'],'lseNative':s['native'],'defaultC':s['inputC'],'lseC':s['inputC'],'cSHA256':s['inputCSHA256'],'actualFull65Receipts':full,'toolPins':tools,'headerPins':headers,'libraryPins':libraries,'hardwarePins':hardware,'pins':dict(sorted(pins.items()))}
 (a.output/(schema.lower()+'.json')).write_text(json.dumps(c,indent=2)+'\n')
print('PENDING_CATALOGS_PREPARED_NO_EXECUTION')
