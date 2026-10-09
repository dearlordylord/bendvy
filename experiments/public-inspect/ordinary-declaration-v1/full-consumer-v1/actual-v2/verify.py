"""Archive-only additive comparison; never executes compiler or runtime."""
from pathlib import Path
import gzip
import hashlib
import json
import runpy

HERE = Path(__file__).resolve().parent
old = HERE.parent / 'actual-v1'
runpy.run_path(str(old / 'verify.py'))
manifest = json.loads((HERE / 'manifest.json').read_text())
objects = {}
for digest, row in manifest['members'].items():
    raw = gzip.decompress((HERE / row['member']).read_bytes())
    assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == digest
    objects[digest] = raw
files = manifest['nativeFiles']
plan_path = '/tmp/bendvy-ordinary-inspector-normal-native02/plan.json'
plan = json.loads(objects[files[plan_path]])
receipt = json.loads(objects[files[str(Path(plan_path).with_name('receipt.json'))]])
assert receipt['planSHA256'] == files[plan_path]
assert receipt['status'] == 'INCOMPLETE' and receipt['guardFailures'] == []
assert receipt['error'] == 'ValueError: Owned child failed: emit'
assert len(receipt['commands']) == 1
command = receipt['commands'][0]
assert command['label'] == 'emit' and command['failure'] == 'child deadline' and command['exit'] is None
assert command['capSeconds'] == 30 and command['argv'] == plan['commands'][0]['argv']
assert plan['generated'] not in files and plan['native'] not in files
pins = dict(plan['pins']); pins[plan_path] = files[plan_path]
for path, digest in plan['pins'].items():
    assert manifest['sourceObjects'].get(path, manifest['externalPins'].get(path)) == digest
labels = []
for guard in receipt['guards']:
    assert files[guard['path']] == guard['sha256']
    body = json.loads(objects[guard['sha256']]); labels.append(body['label'])
    if body['label'] == 'emit-post':
        for stream in ('stdout', 'stderr'):
            row = command[stream]
            assert row['published'] and row['bytes'] == 0
            assert files[row['path']] == row['sha256'] and objects[row['sha256']] == b''
            pins[row['path']] = row['sha256']
    assert body['unchanged'] and body['actualPins'] == pins
assert labels == ['emit-pre', 'emit-acquired', 'emit-post', 'final']
previous = json.loads((old / 'manifest.json').read_text())
reader = next(row for row in previous['subjects'] if row['subject'] == 'reader')
reader_plan_path = '/tmp/bendvy-ordinary-inspector-reader-js02/plan.json'
def old_object(digest):
    return gzip.decompress((old / previous['members'][digest]['member']).read_bytes())
reader_plan = json.loads(old_object(reader['files'][reader_plan_path]))
model_root = Path('/workspace/formal-proofs/bendvy-worktrees/review-46-native22-launch/experiments/public-inspect/ordinary-declaration-v1/full-consumer-v1/reader-oracle-v1/successor-v2')
basis = json.loads(objects[manifest['modelFiles'][str(model_root / 'SOURCE-BASIS.json')]])
closures = plan['sourceInventory'] | reader_plan['sourceInventory']
closures['/home/node/.bend/bend2/base.bend'] = plan['resourceRoots']['/home/node/.bend/bend2']['base.bend']
assert basis['consumingClosurePins'] == closures
expected = gzip.decompress(objects[manifest['modelFiles'][str(model_root / 'expected.txt.gz')]])
actual = old_object(reader['files'][str(Path(reader_plan_path).with_name('consumer.stdout'))])
assert actual == expected and len(actual) == 5057139
assert hashlib.sha256(actual).hexdigest() == basis['expectedSHA256'] == 'ea9857a0afe61387ecf5948fb11e1f6f7f099263057b963b06ca105ed1640a5b'
normal = gzip.decompress(objects[manifest['sourceObjects'][plan['normalOracle']]])
assert actual != normal and hashlib.sha256(normal).hexdigest() == plan['normalOracleSHA256']
print('PASS', len(objects), 'members; four Native failure guards; complete retained reader equality and normal rejection; original failure untouched')
