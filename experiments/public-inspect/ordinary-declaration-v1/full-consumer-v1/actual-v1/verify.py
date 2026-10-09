"""Archive-only verification of original two JS outcomes; never runs children."""
from pathlib import Path
import gzip
import hashlib
import json

HERE = Path(__file__).resolve().parent
manifest = json.loads((HERE / 'manifest.json').read_text())
objects = {}
for key, row in manifest['members'].items():
    raw = gzip.decompress((HERE / row['member']).read_bytes())
    assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == key == row['sha256']
    objects[key] = raw
for subject in manifest['subjects']:
    files = subject['files']
    plan_path = next(path for path in files if Path(path).name == 'plan.json')
    receipt_path = str(Path(plan_path).with_name('receipt.json'))
    plan = json.loads(objects[files[plan_path]])
    receipt = json.loads(objects[files[receipt_path]])
    assert receipt['planSHA256'] == files[plan_path]
    for path, digest in plan['pins'].items():
        assert subject['sourceObjects'].get(path, subject['externalPins'].get(path)) == digest
    assert len(plan['sourceInventory']) == 49
    assert receipt.get('guardFailures', []) == []
    pins = dict(plan['pins'])
    pins[plan_path] = files[plan_path]
    labels = []
    for guard in receipt['guards']:
        assert files[guard['path']] == guard['sha256']
        body = json.loads(objects[guard['sha256']])
        label = body['label']; labels.append(label)
        if label == 'emit-post':
            pins[str(Path(plan_path).with_name('emit.stdout'))] = files[str(Path(plan_path).with_name('emit.stdout'))]
            pins[str(Path(plan_path).with_name('emit.stderr'))] = files[str(Path(plan_path).with_name('emit.stderr'))]
            pins[plan['generated']] = files[plan['generated']]
        if label == 'consumer-post':
            for stream in ['stdout','stderr']:
                path = str(Path(plan_path).with_name('consumer.' + stream))
                pins[path] = files[path]
        assert body['unchanged'] and body['actualPins'] == pins
    assert labels == ['emit-pre','emit-acquired','emit-post','consumer-pre','consumer-acquired','consumer-post','final']
    assert [row['label'] for row in receipt['commands']] == ['emit','consumer']
    for row in receipt['commands']:
        assert row['exit'] == 0 and row['failure'] is None
        for stream in ['stdout','stderr']:
            raw = row[stream]
            assert raw['published'] and files[raw['path']] == raw['sha256']
            assert len(objects[raw['sha256']]) == raw['bytes']
    actual = objects[files[str(Path(plan_path).with_name('consumer.stdout'))]]
    expected = gzip.decompress(objects[subject['sourceObjects'][plan['oracle']]])
    assert len(expected) == plan['oracleBytes'] and hashlib.sha256(expected).hexdigest() == plan['oracleSHA256']
    assert objects[files[str(Path(plan_path).with_name('consumer.stderr'))]] == b''
    if subject['subject'] == 'normal':
        assert subject['terminalExit'] == 0 and actual == expected
        assert receipt['status'] == 'COMPLETE_CONSUMER_DEVELOPMENT_PASS'
    else:
        assert subject['terminalExit'] == 1 and actual != expected
        assert receipt['status'] == 'INCOMPLETE' and 'byte output differs' in receipt['error']
        assert len(actual) == 5057139 and hashlib.sha256(actual).hexdigest() == 'ea9857a0afe61387ecf5948fb11e1f6f7f099263057b963b06ca105ed1640a5b'
print('PASS', len(objects), 'members; exact fourteen guards; original normal success/reader failure')
