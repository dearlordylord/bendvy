#!/usr/bin/env python3
"""Build pending immutable byte catalogs; no execution or approval invention."""
import argparse,hashlib,json
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy');HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--motion-admission',type=Path,required=True);p.add_argument('--build',type=Path,required=True);p.add_argument('--features',type=Path,required=True);p.add_argument('--health-tune65',type=Path,required=True);p.add_argument('--motion-default65',type=Path,required=True);p.add_argument('--motion-tune65',type=Path,required=True);p.add_argument('--health-admission',type=Path,required=True);p.add_argument('--health-default65',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False)
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
base=json.loads(Path('/tmp/bendvy-concrete-owner-cohort-plan-r2.json').read_text())
path=a.build.resolve();l=json.loads(path.read_text());inspector=path.with_name('fresh-elf-inspection.json');i=json.loads(inspector.read_text())
assert l['status']=='BOTH_CONCRETE_UNCHANGED_C_TUNE_BUILD_AND_ELF_INSPECTION_PASS' and i['allPinnedBytesStableBeforeAfter']
for schema in ['Motion','Health']:
 subject_receipt=path
 current_l=json.loads(subject_receipt.read_text())
 current_inspector=subject_receipt.with_name('fresh-elf-inspection.json');current_i=json.loads(current_inspector.read_text());assert current_i['allPinnedBytesStableBeforeAfter']
 s=current_l['subjects'][schema];source=Path(s['sourceRoot']);build=Path(s['inputC']).parent
 fpath=ROOT/'experiments/s-prep/js-profile-followup'/'source-concrete-owner'/'freeze.json';f=json.loads(fpath.read_text())
 admission=a.motion_admission if schema=='Motion' else a.health_admission
 tools=current_l['toolPinsBefore']['pins'];headers=s['includePinsBefore'];hardware=current_l['hostBefore']['headerPins']
 libraries={k:v for k,v in {**tools,**i['pinsBefore'],**current_i['pinsBefore']}.items() if '.so' in k}
 pins={}
 def pin(path,expected=None):
  path=Path(path).resolve();h=sha(path)
  if expected is not None:assert h==expected,('drift',str(path))
  assert str(path) not in pins or pins[str(path)]==h;pins[str(path)]=h
 for name in base['pins']:pin(name)
 for name,h in {**tools,**headers,**hardware,**i['pinsBefore'],**current_i['pinsBefore'],**current_l['extraToolPins']}.items():pin(name,h)
 for name,h in {**f['normalConsumedFiles'],**f['currentReceipts']}.items():pin(name,h)
 for name,h in s['source29'].items():pin(source/name,h)
 for name in [path,a.features,subject_receipt,inspector,current_inspector,subject_receipt.with_name('exact-flag-join.json'),fpath,admission,build/'build.json',build/'batch.c',build/'batch-native',source/'overlay.json',source/'cache-specialization.json',s['native'],f['schemaPrograms'][schema.lower()],__file__,HERE/'observe.py',HERE/'summarize.py',HERE/'cohort.py',HERE/'prepare-plan.py']:pin(name)
 full={}
 for name in [str(a.motion_tune65.resolve()) if schema=='Motion' else str(a.health_tune65.resolve()),str(a.motion_default65.resolve()) if schema=='Motion' else str(a.health_default65.resolve())]:
  pin(name);full[name]=sha(name)
 c={'scope':'SAME_C_TUNE_DENSE1024_ENROLLMENT','status':'PENDING_INDEPENDENT_REVIEW_AND_SOURCE_ADMISSION','schema':schema,'count':1024,'iterations':64,'batch':64,'defaultFlags':['-O3'],'tuneFlags':['-O3','-mtune=apple-m1'],'hwcapAtomics':current_l['hostBefore']['HWCAP_ATOMICS'],'sourceRoot':str(source),'sourceClosure':s['sourceClosure'],'defaultBuild':str(build/'build.json'),'tuneBuild':str(subject_receipt.resolve()),'hardwareReceipt':str(subject_receipt.resolve()),'isaFeatureReceipt':str(a.features.resolve()),'jsFreeze':str(fpath),'admission':str(admission.resolve()),'jsProgram':f['schemaPrograms'][schema.lower()],'defaultNative':s['baselineNative'],'tuneNative':s['native'],'defaultC':s['inputC'],'tuneC':s['inputC'],'cSHA256':s['inputCSHA256'],'actualFull65Receipts':full,'toolPins':tools,'headerPins':headers,'libraryPins':libraries,'hardwarePins':hardware,'pins':dict(sorted(pins.items()))}
 (a.output/(schema.lower()+'.json')).write_text(json.dumps(c,indent=2)+'\n')
print('PENDING_CATALOGS_PREPARED_NO_EXECUTION')
