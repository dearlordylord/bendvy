"""Archive-only check of original printer-domain refusal."""
from pathlib import Path
import gzip
import hashlib
import json

HERE = Path(__file__).resolve().parent
m = json.loads((HERE / 'manifest.json').read_text())
objects = {}
for digest, row in m['members'].items():
    raw = gzip.decompress((HERE / row['member']).read_bytes())
    assert hashlib.sha256(raw).hexdigest() == digest and len(raw) == row['bytes']
    objects[digest] = raw
plan_path = '/tmp/bendvy-ordinary-inspector-canonical-normal-js01/plan.json'
plan = json.loads(objects[m['files'][plan_path]])
r = json.loads(objects[m['files'][str(Path(plan_path).with_name('receipt.json'))]])
assert r['planSHA256'] == m['files'][plan_path]
assert r['status'] == 'INCOMPLETE' and r['guardFailures'] == []
assert len(r['commands']) == 1
c = r['commands'][0]
assert c['label'] == 'emit' and c['exit'] == 1 and c['failure'] is None
assert c['argv'] == plan['commands'][0]['argv'] and c['capSeconds'] == 30
assert objects[c['stdout']['sha256']] == b''
assert objects[c['stderr']['sha256']] == b"Error: main's type Report cannot be printed (a function, a Type, an erased or dependent field)\n"
assert plan['generated'] not in m['files'] and plan['native'] not in m['files']
pins = dict(plan['pins']); pins[plan_path] = m['files'][plan_path]
for path, digest in plan['pins'].items():
    assert m['sourceObjects'].get(path, m['externalPins'].get(path)) == digest
labels = []
for guard in r['guards']:
    assert m['files'][guard['path']] == guard['sha256']
    body = json.loads(objects[guard['sha256']]); labels.append(body['label'])
    if body['label'] == 'emit-post':
        for stream in ('stdout', 'stderr'):
            row = c[stream]
            assert row['published'] and m['files'][row['path']] == row['sha256']
            assert len(objects[row['sha256']]) == row['bytes']
            pins[row['path']] = row['sha256']
    assert body['unchanged'] and body['actualPins'] == pins
assert labels == ['emit-pre', 'emit-acquired', 'emit-post', 'final']
print('PASS', len(objects), 'lossless members; exact four guards; original emit refusal/no runtime')
