#!/usr/bin/env python3
"""Enroll the exact v7 diagnostic against the previous current-source baseline."""
import argparse
import hashlib
import json
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
SOURCE = Path('/tmp/bendvy-slot-host-handoff-v7')
CLOSURE = 'a9a2fa20913658b9561056e660803e3afd74870f321ff3a30c839e62fa44a56b'
PIPELINE = Path('/tmp/bendvy-js-profile-followup/experiments/s-prep/js-profile-followup/source-handoff/pipeline')


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    assert not args.output.exists()
    pins = {}

    def pin(path, expected=None):
        path = str(Path(path).resolve())
        value = sha(path)
        assert expected is None or value == expected, path
        assert path not in pins or pins[path] == value, path
        pins[path] = value

    def mapped(data):
        for path, value in data.items():
            pin(path, value)

    def provenance(data):
        # Receipts contain maps at several nested layers. Only actual absolute
        # file-key/SHA pairs are admitted, never inferred from a prose claim.
        if isinstance(data, dict):
            for key, value in data.items():
                if key.startswith('/') and isinstance(value, str) and len(value) == 64:
                    pin(key, value)
                elif isinstance(value, (dict, list)):
                    provenance(value)
        elif isinstance(data, list):
            for value in data:
                provenance(value)

    source_manifest = json.loads((SOURCE / 'overlay.json').read_text())
    source_pins = source_manifest['sources']
    cache = json.loads((SOURCE / 'cache-specialization.json').read_text())
    assert source_manifest['cacheSpecialization'] == cache
    assert cache['runtimeClosure'] == cache['specializedClosure'] == source_pins
    assert cache['runtimeClosureSHA256'] == cache['specializedClosureSHA256'] == CLOSURE
    assert len(source_pins) == 29
    assert hashlib.sha256(json.dumps(source_pins, sort_keys=True, separators=(',', ':')).encode()).hexdigest() == CLOSURE
    mapped({str(SOURCE / name): value for name, value in source_pins.items()})
    for name in ['overlay.json', 'cache-specialization.json', 'handoff-source-pins.json']:
        pin(SOURCE / name)
    review = ROOT / 'experiments/s-prep/source-cursor-row-handoff-review'
    source_receipt = json.loads((SOURCE / 'handoff-source-pins.json').read_text())
    pin(review / 'reproduce-v7/derive.py', source_receipt['recipeSHA256'])
    pin(review / 'reproduce-v7/input-pins.json')
    static = json.loads((review / 'v7-static.json').read_text())
    assert static['closure'] == CLOSURE and static['sourcePins'] == source_pins
    for name in ['v7-static.json', 'v7-build-review.json', 'array-canary/archive.json']:
        pin(review / name)

    schemas = {}
    for schema in ['Motion', 'Health']:
        lane = schema.lower()
        build = Path('/tmp/bendvy-source-handoff-' + lane + '-build-v7')
        receipt_path = build / 'build.json'
        receipt = json.loads(receipt_path.read_text())
        assert receipt['status'] == 'BUILD_PASS' and receipt['schema'] == schema
        assert receipt['sourcePins'] == source_pins and receipt['sourceClosure'] == CLOSURE
        producer = PIPELINE.parent
        pin(producer / 'build.py', receipt['recipeSHA256'])
        pin(producer / 'tool-pins.py', receipt['toolPinRecipeSHA256'])
        assert receipt['toolBytesStableBeforeAfter'] and receipt['cIncludeBytesStableBeforeAfter']
        assert receipt['toolPinsBefore']['pins'] == receipt['toolPinsAfter']['pins']
        assert receipt['toolPinsBefore']['environment'] == receipt['toolPinsAfter']['environment']
        libraries = lambda data: {key: re.sub(r'\(0x[0-9a-fA-F]+\)', '(address)', value)
                                  for key, value in data['resolvedLibraries'].items()}
        assert libraries(receipt['toolPinsBefore']) == libraries(receipt['toolPinsAfter'])
        assert all(command['exit'] == 0 and not command['timeout'] for command in receipt['commands'])
        assert receipt['defaultProofSeconds'] == 5
        pin(receipt_path)
        mapped({str(build / name): value for name, value in receipt['artifacts'].items()})
        pin(build / 'measurement-bend.bend', receipt['measurementOutputSHA256'])
        provenance(receipt)

        previous = build / 'batch.js'
        for stage, recipe, catalog, status in [
            ('row', PIPELINE / 'row-rewrite.cjs', PIPELINE / 'row-input-pins.json', 'EXACT_PACKED_ROW_IDENTITY_REUSE_DERIVED'),
            ('pool', PIPELINE / 'token-pool/rewrite.cjs', PIPELINE / 'token-pool/input-pins.json', None),
            ('tuple', PIPELINE / 'rewrite.cjs', PIPELINE / 'input-pins.json', 'PINNED_DIRECT_TUPLE_SCALAR_RECEIVERS_DERIVED'),
        ]:
            program = Path('/tmp/bendvy-source-handoff-generated-v7') / (lane + '-' + stage + '.js')
            layer_path = Path(str(program) + '.recipe.json')
            layer = json.loads(layer_path.read_text())
            assert layer['inputSHA256'] == sha(previous) and layer['outputSHA256'] == sha(program)
            assert layer['recipeSHA256'] == sha(recipe) and layer['catalogSHA256'] == sha(catalog)
            assert layer['sourceRoot'] == str(SOURCE) and layer['sourcePins'] == source_pins
            assert status is None or layer['status'] == status
            catalog_entry = json.loads(catalog.read_text())[layer['inputSHA256']]
            assert catalog_entry['inputPath'] == str(previous)
            for file in [program, layer_path, recipe, catalog]:
                pin(file)
            provenance(layer)
            provenance(catalog_entry)
            previous = program
        candidate = previous
        for kind in ['js65', 'native65', 'transformed65']:
            evidence_path = Path('/tmp/bendvy-source-handoff-' + lane + '-' + kind + '-v7/evidence.json')
            evidence = json.loads(evidence_path.read_text())
            assert evidence['status'] == 'PASS_FULL65' and evidence['worlds'] == 65 and evidence['allFullFieldsEqual']
            program = candidate if kind == 'transformed65' else build / ('batch.js' if kind == 'js65' else 'batch-native')
            assert evidence['programSHA256'] == sha(program)
            pin(evidence_path)

        baseline = Path('/tmp/bendvy-slot-host-swap-selective-frozen-v1') / (lane + '.js')
        baseline_build = Path('/tmp/bendvy-slot-host-' + lane + '-dense-build-v1')
        baseline_receipt = json.loads((baseline_build / 'build.json').read_text())
        assert baseline_receipt['status'] == 'BUILD_PASS' and baseline_receipt['schema'] == schema
        baseline_pins = baseline_receipt['sourcePins']
        assert hashlib.sha256(json.dumps(baseline_pins, sort_keys=True, separators=(',', ':')).encode()).hexdigest() == '4baad4960575cda216576e8b90593fbd7ed7dcd44cfa86836b8d87dd5af71f5c'
        mapped({str(Path('/tmp/bendvy-slot-host-v1') / name): value for name, value in baseline_pins.items()})
        baseline_source = Path('/tmp/bendvy-slot-host-v1')
        old_manifest = json.loads((baseline_source / 'overlay.json').read_text())
        old_cache = json.loads((baseline_source / 'cache-specialization.json').read_text())
        assert old_manifest['sources'] == baseline_pins and old_manifest['cacheSpecialization'] == old_cache
        assert old_cache['runtimeClosure'] == old_cache['specializedClosure'] == baseline_pins
        for name in ['overlay.json', 'cache-specialization.json']:
            pin(baseline_source / name)
        pin(baseline_build / 'build.json')
        mapped({str(baseline_build / name): value for name, value in baseline_receipt['artifacts'].items()})
        pin(baseline_build / 'measurement-bend.bend', baseline_receipt['measurementOutputSHA256'])
        baseline_freeze_path = Path('/tmp/bendvy-slot-host-swap-selective-root-freeze-v1') / (lane + '.json')
        baseline_freeze = json.loads(baseline_freeze_path.read_text())
        mapped(baseline_freeze['paths'])
        pin(baseline_freeze_path)
        for path in baseline_freeze['paths']:
            if path.endswith('.recipe.json'):
                provenance(json.loads(Path(path).read_text()))
        schemas[schema] = {'sourceClosure': CLOSURE, 'baseline': 'current4baa selective+swap',
                           'candidate': 'v7 handoff row+pool+Tuple; selective+swap rejected', 'roles': [
            {'name': 'baseline-JS', 'argv': ['node', str(baseline)]},
            {'name': 'baseline-Native', 'argv': [str(baseline_build / 'batch-native'), '--threads', '1', '--gpu', 'off']},
            {'name': 'handoff-JS', 'argv': ['node', str(candidate)]},
            {'name': 'handoff-Native', 'argv': [str(build / 'batch-native'), '--threads', '1', '--gpu', 'off']},
        ]}

    for path in [Path(__file__), HERE / 'observe.py',
                 ROOT / 'experiments/s-prep/fivehour-measurement/prepare-ts.py',
                 ROOT / 'experiments/s-integrate/measurement-samples-reference.mjs',
                 ROOT / 'experiments/s-integrate/measurement-bend-run.py',
                 ROOT / 'experiments/s-prep/fivehour-connected-gates/supervisor.py',
                 ROOT / '.references/sources.json',
                 Path(shutil.which('node')).resolve(), Path(shutil.which('git')).resolve(), Path(sys.executable).resolve()]:
        pin(path)
    for path in (ROOT / '.references/bevy-ts/packages/core/src').rglob('*'):
        if path.is_file():
            pin(path)
    args.output.write_text(json.dumps({'scope': 'RAW_SOURCE_HANDOFF_DENSE_DIAGNOSTIC',
                                      'count': 256, 'iterations': 64, 'batch': 64,
                                      'observerSHA256': sha(HERE / 'observe.py'), 'pins': pins,
                                      'schemas': schemas, 'order': 'round-major Motion then Health, five positions forward/reverse',
                                      'claimLimit': 'Raw diagnosis only; no keep, qualification or full-matrix acceptance'}, indent=2) + '\n')
    print(json.dumps({'status': 'PROSPECTIVE_PLAN_WRITTEN_NOT_EXECUTED', 'files': len(pins), 'planSHA256': sha(args.output)}))


if __name__ == '__main__':
    main()
