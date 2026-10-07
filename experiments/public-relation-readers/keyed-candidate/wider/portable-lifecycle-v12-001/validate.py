"""Stdlib retained-byte reconciliation only; executes no child or backend."""
import hashlib
import json
from pathlib import Path, PurePosixPath
import tarfile

ROOT = Path(__file__).resolve().parent

def digest(data):
    return hashlib.sha256(data).hexdigest()

def main():
    manifest = json.loads((ROOT / 'manifest.json').read_text())
    assert manifest['developmentOnly'] and not manifest['acceptance'] and not manifest['completeIssue43']
    actual = {str(p.relative_to(ROOT)) for p in ROOT.rglob('*') if p.is_file()}
    assert actual == set(manifest['files']) | {'manifest.json'}
    for name, expected in manifest['files'].items():
        assert digest((ROOT / name).read_bytes()) == expected, name
    objects = {}
    with tarfile.open(ROOT / 'objects.tar.gz', 'r:gz') as archive:
        for member in archive.getmembers():
            name = member.name
            path = PurePosixPath(name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert str(path) == name and name not in objects
            objects[name] = archive.extractfile(member).read()
    assert set(objects) == set(manifest['objects'])
    for name, expected in manifest['objects'].items():
        assert digest(objects[name]) == expected, name
    receipt = json.loads(objects['execution/receipt.json'])
    plan = json.loads(objects['execution-plan.json'])
    assert digest(objects['execution/receipt.json']) == manifest['terminalReceiptSHA256']
    assert digest(objects['execution-plan.json']) == manifest['planSHA256'] == receipt['planSHA256']
    assert receipt['status'] == 'LIFECYCLE_DEVELOPMENT_PASS'
    assert len(plan['commands']) == 7 and len(receipt['toolProbeReceiptPins']) == 70
    for name, expected in receipt['rawPins'].items():
        assert digest(objects['execution/' + name]) == expected
    for name, expected in receipt['toolProbeRawPins'].items():
        assert digest(objects['execution/tool-probes/' + name]) == expected
    for name, expected in receipt['generatedPins'].items():
        if name in manifest['excludedGenerated']:
            assert manifest['excludedGenerated'][name] == expected
        else:
            assert digest(objects['execution/' + Path(name).name]) == expected
    for row in plan['commands']:
        command = json.loads(objects['execution/' + row['label'] + '.json'])
        assert command['exit'] == 0 and command['failure'] is None
        assert command['command'] == row['argv'] and command['timeout'] == row['limit']
    probes = [name for name in objects if (name.startswith('prepare-probes/') or
        name.startswith('execution/tool-probes/')) and name.endswith('.json')]
    assert len(probes) == 75
    for name in probes:
        command = json.loads(objects[name])
        assert command['exit'] == 0 and command['failure'] is None and command['timeout'] == 5
    js = json.loads(objects['execution/consume-js.stdout'])['observed']
    native = json.loads(objects['execution/consume-native.stdout'])['observed']
    assert js == native and len(js) == 2
    assert js[0] == js[1]
    for root in js:
        assert root['neverActivatedSkip']['observations'] == [{'$': 'Skipped', 'id': 1}]
        assert root['activatedSkip']['observations'] == [{'$': 'Skipped', 'id': 1}]
        assert root['neverActivatedSkip']['final']['positions'] == []
        assert root['activatedSkip']['final']['positions'][-1]['cursor'] == 8
        assert root['successfulDisposal']['domains'][0]['readers'] == [3]
        assert [p['id'] for p in root['successfulDisposal']['positions']] == [3, 2]
    failure = json.loads(objects['failed-v11/terminal-failure.json'])
    assert failure['status'] == 'FAIL' and failure['sourceCheckExit'] == 0
    assert failure['unreached'] == ['emit-js', 'consume-js', 'emit-c', 'compile', 'native', 'consume-native']
    print(json.dumps({'retainedBytesReconciled': True, 'childrenExecuted': 0,
        'retainedMainCommands': 7, 'retainedToolProbes': 75,
        'completeTwoSchemaJSNativeEquality': True, 'developmentOnly': True,
        'acceptance': False, 'completeIssue43': False}))

if __name__ == '__main__':
    main()
