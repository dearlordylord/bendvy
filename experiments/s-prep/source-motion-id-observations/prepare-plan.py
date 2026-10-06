#!/usr/bin/env python3
"""Pin a fresh, scoped Motion split-ID diagnostic; no canonical admission."""
import argparse,hashlib,json
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy');HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True)
p.add_argument('--source',type=Path,required=True);p.add_argument('--closure',required=True)
p.add_argument('--build',type=Path,required=True);p.add_argument('--freeze',type=Path,required=True)
p.add_argument('--admission',type=Path,required=True);p.add_argument('--full65',type=Path,action='append',required=True)
a=p.parse_args();assert not a.output.exists();pins={}
sha=lambda path:hashlib.sha256(Path(path).read_bytes()).hexdigest()
def pin(path,expected=None):
 path=Path(path).resolve();assert path.is_file(),path;h=sha(path)
 if expected is not None:assert h==expected,('drift',str(path))
 if str(path) in pins:assert pins[str(path)]==h
 pins[str(path)]=h;return h
basepath=Path('/tmp/bendvy-concrete-owner-cohort-plan-r2.json')
assert sha(basepath)=='c91aa83b291440cb3e7cf7edc048458e96dc5241c4fcc164d6e8f33971d7049b'
base=json.loads(basepath.read_text());pin(basepath)
# Freshly enroll comparator/tool/support paths; old source audit was subsequently
# extended, so do not pretend the old complete pin map is current.
for path in base['pins']:pin(path)
for path in [__file__,HERE/'observe.py',HERE/'summarize.py',HERE/'launch.py',a.freeze,a.admission,a.build/'build.json']:pin(path)
b=json.loads((a.build/'build.json').read_text());f=json.loads(a.freeze.read_text())
assert b['status']=='BUILD_PASS' and b['schema']=='Motion'
assert b['sourceRoot']==str(a.source.resolve()) and b['sourceClosure']==a.closure
assert b['toolBytesStableBeforeAfter'] and b['cIncludeBytesStableBeforeAfter']
assert f['status']=='FROZEN_DIRECT_MOTION_DENSE1024_GUARDED_JS_FINITE_GATES_PASS'
assert f['sourceRoot']==str(a.source.resolve()) and f['sourceClosure']==a.closure
assert len(b['sourcePins'])==29 and b['sourcePins']==f['sourcePins']
for rel,h in b['sourcePins'].items():pin(a.source/rel,h)
manifest=json.loads((a.source/'overlay.json').read_text());cache=json.loads((a.source/'cache-specialization.json').read_text())
assert manifest['cacheSpecialization']==cache
assert cache['runtimeClosure']==cache['specializedClosure']==b['sourcePins']
assert cache['runtimeClosureSHA256']==cache['specializedClosureSHA256']==a.closure
pin(a.source/'overlay.json');pin(a.source/'cache-specialization.json')
for key in ['inputManifestPins','builderInputPins','cIncludePinsBeforeClang']:
 for path,h in b[key].items():pin(path,h)
assert b['toolPinsBefore']['pins']==b['toolPinsAfter']['pins']
assert b['toolPinsBefore']['environment']==b['toolPinsAfter']['environment']
for path,h in b['toolPinsBefore']['pins'].items():pin(path,h)
for rel,h in b['artifacts'].items():pin(a.build/rel,h)
for key in ['normalConsumedFiles','currentReceipts']:
 assert f[key]
 for path,h in f[key].items():pin(path,h)
js=Path(f['schemaPrograms']['motion']);assert str(js.resolve()) in pins
assert len(a.full65)==2
backends=set()
for path in a.full65:
 pin(path);r=json.loads(path.read_text());assert r['status']=='PASS_FULL65'
 assert r['worlds']==65 and r['allFullFieldsEqual']
 assert r['sourceClosureSHA256']==a.closure and r['source29']==b['sourcePins']
 program=a.build/('batch.js' if r['kind']=='js' else 'batch-native');pin(program,r['programSHA256']);backends.add(r['kind'])
assert backends=={'js','native'}
# Preserve the original driver and fresh-world body: source-path change only.
old=Path('/tmp/bendvy-concrete-owner-motion-dense1024-build')
assert (old/'batch.bend').read_text().replace('/tmp/bendvy-slot-host-concrete-owner-v3/',str(a.source.resolve())+'/')==(a.build/'batch.bend').read_text()
assert (old/'measurement-bend.bend').read_text().replace('/tmp/bendvy-slot-host-concrete-owner-v3/',str(a.source.resolve())+'/')==(a.build/'measurement-bend.bend').read_text()
ad=json.loads(a.admission.read_text());assert ad['scope']=='FRESH_MOTION_SPLIT_ID_RAW_ADMISSION'
assert ad['sourceClosure']==a.closure and ad['status']=='PASS_SCOPED_FINITE_GATES'
assert set(ad['groups'])=={'source-audit','generic-access','actual-lifecycle','js-guarded','allocation-attribution'}
for paths in ad['groups'].values():
 assert paths
 for path in paths:pin(path)
oldroles=base['schemas']['Motion']['roles']
roles=[{'name':'baseline-JS','argv':next(r['argv'] for r in oldroles if r['name']=='handoff-JS')},
 {'name':'baseline-Native','argv':next(r['argv'] for r in oldroles if r['name']=='handoff-Native')},
 {'name':'handoff-JS','argv':['node',str(js)]},
 {'name':'handoff-Native','argv':[str(a.build/'batch-native'),'--threads','1','--gpu','off']}]
for role in roles:assert (role['argv'][1] if role['argv'][0]=='node' else role['argv'][0]) in pins
plan={'scope':'RAW_MOTION_SPLIT_ID_DENSE1024_DIAGNOSTIC','count':1024,'iterations':64,'batch':64,
 'observerSHA256':sha(HERE/'observe.py'),'pins':dict(sorted(pins.items())),
 'sourceClosure':a.closure,'baselineSourceClosure':base['sourceClosure'],
 'schemas':{'Motion':{'roles':roles,'baselineMeaning':'exact concrete-v3 Motion Dense1024 guarded JS/Native',
 'candidateMeaning':'new Motion split-ID exact source/build and guarded JS','candidateBuildReceipt':str(a.build/'build.json')}},
 'freshAdmission':str(a.admission.resolve()),'order':'Ten fixed attempts; five shifted orders and five reversed shifts',
 'claimLimit':'Raw diagnostic ratios of medians; no qualification, canonical packet/reset/keep, full22, common forcing or full5x3 acceptance'}
a.output.write_text(json.dumps(plan,indent=2)+'\n');print(json.dumps({'planSHA256':sha(a.output),'pins':len(pins),'scope':plan['scope']}))
