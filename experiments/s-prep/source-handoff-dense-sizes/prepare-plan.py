#!/usr/bin/env python3
"""Prospective enrollment of unchanged-body Dense64/1024 raw diagnostics."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
p = argparse.ArgumentParser()
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
assert not a.output.exists()
parent = Path('/tmp/bendvy-source-handoff-v8-cohort-plan-rss-v1.json')
d = json.loads(parent.read_text())
assert sha(parent) == '2acbe3b5ae83c4feeb8018c6cc961efed039fd868cdb31f04237690e55d6758c'
pins = dict(d['pins'])

def pin(path, expected=None):
    path = str(Path(path).resolve())
    value = sha(path)
    assert expected is None or value == expected, path
    assert path not in pins or pins[path] == value, path
    pins[path] = value

def provenance(value):
    if isinstance(value, dict):
        for key, item in value.items():
            if key.startswith('/') and isinstance(item, str) and len(item) == 64:
                pin(key, item)
            elif isinstance(item, (dict, list)):
                provenance(item)
    elif isinstance(value, list):
        for item in value:
            provenance(item)

for path, expected in list(pins.items()):
    pin(path, expected)
pin(parent)
old_ts = ROOT / 'experiments/s-prep/fivehour-measurement/prepare-ts.py'
expected_ts = old_ts.read_text().replace(";a=p.parse_args()", ";p.add_argument('--count',type=int,choices=[64,1024],required=True);a=p.parse_args()")
expected_ts = expected_ts.replace("workload='dense',count=256,batch={a.batch}", "workload='dense',count={a.count},batch={a.batch}")
assert (HERE / 'prepare-ts.py').read_text() == expected_ts
for file in ['prepare-plan.py', 'prepare-ts.py', 'specialize-js.cjs', 'observe.py']:
    pin(HERE / file)
schemas = {}
closure = '4eb71a36304194a1c2764c7301ed59afa9b4d0a4ee7336b8b6c7f8175095f235'
for schema in ['Motion', 'Health']:
    lane = schema.lower()
    schemas[schema] = {}
    for count in [64, 1024]:
        js = Path('/tmp/bendvy-handoff-v8-dense-sizes-js-r1') / f'{lane}-{count}.js'
        receipt_path = Path(str(js) + '.specialization.json')
        receipt = json.loads(receipt_path.read_text())
        assert receipt['status'] == 'EXACT_MAIN_ENTITY_LITERAL_SPECIALIZATION'
        assert (receipt['schema'], receipt['count'], receipt['batch'], receipt['ticks']) == (lane, count, 64, 64)
        original = Path(receipt['parentPath'])
        pin(original, receipt['parentSHA256'])
        pin(str(original) + '.recipe.json', receipt['parentReceiptSHA256'])
        pin(js, receipt['outputSHA256'])
        pin(HERE / 'specialize-js.cjs', receipt['recipeSHA256'])
        literal = receipt['literal']
        before = original.read_text()
        after = js.read_text()
        assert before[literal['start']:literal['end']] == '256'
        expected = before[:literal['start']] + str(count) + before[literal['end']:]
        assert after == expected
        frame = before[:literal['start']] + '<ENTITY_COUNT>' + before[literal['end']:]
        assert hashlib.sha256(frame.encode()).hexdigest() == receipt['frameSHA256']
        pin(receipt_path)
        build = Path(f'/tmp/bendvy-handoff-v8-{lane}-dense{count}-build-r2')
        build_path = build / 'build.json'
        b = json.loads(build_path.read_text())
        assert b['status'] == 'BUILD_PASS' and b['schema'] == schema and b['sourceClosure'] == closure
        assert b['defaultProofSeconds'] == 5 and b['toolBytesStableBeforeAfter'] and b['cIncludeBytesStableBeforeAfter']
        assert all(c['exit'] == 0 and not c['timeout'] for c in b['commands'])
        native_recipe = Path('/tmp/bendvy-slot-host-work/experiments/s-prep/source-handoff-dense-sizes/native/build.py')
        pin(native_recipe, b['recipeSHA256'])
        pin(native_recipe.parent / 'tool-pins.py', b['toolPinRecipeSHA256'])
        cert = b['countAdaptation']
        assert (cert['count'], cert['batch'], cert['ticks']) == (count, 64, 64)
        parent_bend = Path(cert['parentEntry'])
        original_bend = parent_bend.read_text()
        needle = f'  {lane}_batch(256,64)'
        assert original_bend.count(needle) == 1
        expected_bend = original_bend.replace(needle, f'  {lane}_batch({count},64)', 1)
        assert (build / 'batch.bend').read_text() == expected_bend
        pin(parent_bend, cert['originalDriverSHA256'])
        pin(build_path)
        for name, expected in b['artifacts'].items():
            pin(build / name, expected)
        pin(build / 'measurement-bend.bend', b['measurementOutputSHA256'])
        provenance(b)
        schemas[schema][str(count)] = {'sourceClosure': closure, 'roles': [
            {'name': 'JS', 'argv': ['node', str(js)]},
            {'name': 'Native', 'argv': [str(build / 'batch-native'), '--threads', '1', '--gpu', 'off']}]}
a.output.write_text(json.dumps({'scope': 'RAW_SOURCE_HANDOFF_DENSE_SIZES_DIAGNOSTIC',
                               'counts': [64,1024], 'iterations': 64, 'batch': 64,
                               'observerSHA256': sha(HERE / 'observe.py'), 'pins': pins,
                               'schemas': schemas, 'order': 'Seven fixed three-role rotations per schema and size; seventh repeats TS-first',
                               'claimLimit': 'Raw only; whole-child RSS, count64 integer-clock quantization, no qualification/keep/full-matrix acceptance'}, indent=2) + '\n')
print(json.dumps({'status': 'PROSPECTIVE_SIZE_PLAN_WRITTEN_NOT_EXECUTED', 'pins': len(pins), 'SHA256': sha(a.output)}))
