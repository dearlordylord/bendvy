#!/usr/bin/env python3
"""Prospectively freeze one raw concrete-owner Dense1024 comparison."""
import argparse, hashlib, json, shutil, sys
from pathlib import Path

ROOT=Path('/workspace/formal-proofs/bendvy')
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser()
p.add_argument('--output',type=Path,required=True)
p.add_argument('--admission',type=Path,required=True,help='Reviewed fresh gate receipt list; no acceptance transfer')
a=p.parse_args();assert not a.output.exists()
sha=lambda path:hashlib.sha256(Path(path).read_bytes()).hexdigest()
pins={}
def pin(path, expected=None):
    path=Path(path).resolve();assert path.is_file(),path
    actual=sha(path)
    if expected is not None:assert actual==expected,('pin drift',str(path))
    if str(path) in pins:assert pins[str(path)]==actual
    pins[str(path)]=actual
    return actual
def tree(root):
    root=Path(root);assert root.is_dir(),root
    for path in sorted(root.rglob('*')):
        if path.is_file() and '__pycache__' not in path.parts:pin(path)

# Prior baseline enrollment is a source-bound input, not current correctness evidence.
parent=Path('/tmp/bendvy-handoff-v8-dense-sizes-plan-r2.json')
baseline=json.loads(parent.read_text())
assert sha(parent)=='2a8dc7024ae354a3a68b7b186999cb70c9c728d0b60f468827545c126236193d'
for path, expected in baseline['pins'].items():pin(path,expected)
pin(parent)
admission=json.loads(a.admission.read_text())
assert admission['scope']=='FRESH_CONCRETE_OWNER_V3_RAW_ADMISSION'
assert admission['sourceClosure']=='a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55'
assert set(admission['groups'])=={'source-audit','generic-access','actual-lifecycle','js-guarded'}
assert all(admission['groups'].values())
for paths in admission['groups'].values():
    for path in paths:pin(path)
pin(a.admission)
for path in [HERE/'observe.py',Path(__file__),HERE/'summarize.py',
             ROOT/'experiments/s-prep/source-handoff-observations/child-rss.py',
             ROOT/'experiments/s-prep/source-handoff-dense-sizes/prepare-ts.py']:
    pin(path)
for executable in ['node','git']:
    pin(Path(shutil.which(executable)).resolve())
pin(Path(sys.executable).resolve())
tree(ROOT/'experiments/s-prep/source-concrete-owner-handoff')
tree(ROOT/'experiments/s-prep/js-profile-followup/source-concrete-owner')
freeze=json.loads((ROOT/'experiments/s-prep/js-profile-followup/source-concrete-owner/freeze.json').read_text())
assert freeze['status']=='FROZEN_CONCRETE_V3_DENSE1024_GUARDED_JS_FINITE_GATES_PASS'
assert freeze['sourceClosure']==admission['sourceClosure']
for group in ['normalConsumedFiles','currentReceipts']:
    for path,expected in freeze[group].items():pin(path,expected)
generated=Path('/tmp/bendvy-concrete-owner-generated-v3')
tree(generated)
pipeline=json.loads((generated/'evidence.json').read_text())
assert pipeline['status']=='FROZEN_TWO_EXACT_HANDOFF_CHAIN_PROGRAMS_PASS'
candidate=Path('/tmp/bendvy-slot-host-concrete-owner-v3')
overlay=json.loads((candidate/'overlay.json').read_text())
cache=json.loads((candidate/'cache-specialization.json').read_text())
source_pins=overlay['sources'];assert len(source_pins)==29
closure=hashlib.sha256(json.dumps(source_pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
assert closure==admission['sourceClosure']
assert freeze['sourcePins']==source_pins and freeze['sourceRoot']==str(candidate)
assert freeze['schemaPrograms']=={schema:str(generated/(schema+'-tuple.js')) for schema in ['motion','health']}
assert overlay['cacheSpecialization']==cache
assert cache['runtimeClosure']==source_pins and cache['specializedClosure']==source_pins
assert cache['runtimeClosureSHA256']==closure and cache['specializedClosureSHA256']==closure
for name, expected in source_pins.items():pin(candidate/name,expected)
pin(candidate/'overlay.json');pin(candidate/'cache-specialization.json')
schemas={}
for schema in ['Motion','Health']:
    low=schema.lower();build=Path('/tmp/bendvy-concrete-owner-'+low+'-dense1024-build')
    receipt=json.loads((build/'build.json').read_text());pin(build/'build.json')
    assert receipt['status']=='BUILD_PASS' and receipt['sourceClosure']==closure
    assert receipt['sourcePins']==source_pins and receipt['countAdaptation']['count']==1024
    assert receipt['countAdaptation']['batch']==64 and receipt['countAdaptation']['ticks']==64
    for name, expected in receipt['artifacts'].items():pin(build/name,expected)
    for name in ['builderInputPins','inputManifestPins','cIncludePinsBeforeClang']:
        for path,expected in receipt[name].items():pin(path,expected)
    for path,expected in receipt['toolPinsBefore']['pins'].items():pin(path,expected)
    assert receipt['toolPinsBefore']['pins']==receipt['toolPinsAfter']['pins']
    for command in receipt['commands']:
        assert command['exit']==0 and not command['timeout']
    assert receipt['recipeSHA256']==pin(ROOT/'experiments/s-prep/source-concrete-owner-handoff/build.py')
    # The original driver body is equal after path normalization and main count specialization.
    original=Path('/tmp/bendvy-handoff-v8-'+low+'-dense1024-build-r2/batch.bend').read_text()
    derived=(build/'batch.bend').read_text()
    assert original.replace('/tmp/bendvy-slot-host-handoff-v8-coherent/',str(candidate)+'/')==derived
    for backend in ['native','js']:
        validation=Path('/tmp/bendvy-concrete-owner-'+low+'-'+backend+'-full65/evidence.json')
        pin(validation)
        record=json.loads(validation.read_text());assert record['status']=='PASS_FULL65'
        assert record['allFullFieldsEqual'] and record['worlds']==65
        program=build/('batch-native' if backend=='native' else 'batch.js')
        assert record['programSHA256']==sha(program)
    old=baseline['schemas'][schema]['1024']['roles']
    old_js=next(role['argv'] for role in old if role['name']=='JS')
    old_native=next(role['argv'] for role in old if role['name']=='Native')
    roles=[{'name':'baseline-JS','argv':old_js},
           {'name':'baseline-Native','argv':old_native},
           {'name':'handoff-JS','argv':['node',str(generated/(low+'-tuple.js'))]},
           {'name':'handoff-Native','argv':[str(build/'batch-native'),'--threads','1','--gpu','off']}]
    for role in roles:
        program=role['argv'][1] if role['argv'][0]=='node' else role['argv'][0]
        assert program in pins
    schemas[schema]={'roles':roles,'baselineMeaning':'exact coherent v8 source, current count-only1024 specialization',
                     'candidateMeaning':'concrete owner v3, exact guarded row/pool/Tuple JS and fresh Native',
                     'candidateBuildReceipt':str(build/'build.json')}
plan={'scope':'RAW_CONCRETE_OWNER_DENSE1024_DIAGNOSTIC','count':1024,'iterations':64,'batch':64,
      'observerSHA256':sha(HERE/'observe.py'),'pins':dict(sorted(pins.items())),
      'sourceClosure':closure,'baselineSourceClosure':'4eb71a36304194a1c2764c7301ed59afa9b4d0a4ee7336b8b6c7f8175095f235',
      'schemas':schemas,'freshAdmission':str(a.admission.resolve()),
      'order':'Twenty fixed attempts, ten rotations per schema; five roles shifted0..4 then reversed shifted0..4',
      'claimLimit':'Ratios of raw medians only; no canonical packet/budget reset, noise qualification, keep, complete forcing or full5x3 acceptance'}
a.output.write_text(json.dumps(plan,indent=2)+'\n')
print(json.dumps({'planSHA256':sha(a.output),'pins':len(pins),'scope':plan['scope']}))
