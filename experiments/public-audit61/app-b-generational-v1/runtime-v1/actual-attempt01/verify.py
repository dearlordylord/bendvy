"""Verify retained source/receipt/guard/output joins without running a backend."""
from pathlib import Path
import gzip
import hashlib
import json
import re

HERE = Path(__file__).resolve().parent
sha = lambda data: hashlib.sha256(data).hexdigest()
manifest = json.loads((HERE / 'manifest.json').read_text())
retained = {}
external = []
for row in manifest['members']:
    if 'object' not in row:
        external.append(row['path'])
        continue
    packed = (HERE / row['object']).read_bytes()
    assert sha(packed) == row['compressedSHA256']
    raw = gzip.decompress(packed)
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
    retained[row['path']] = raw

def load(path):
    return json.loads(retained[path])

def retained_hash(path):
    if path in retained:
        return sha(retained[path])
    row = next(row for row in manifest['members'] if row['path'] == path)
    assert row['retention'] == 'external installed ELF identity only'
    return row['sha256']

pin_joins = 0
for role in manifest['roles']:
    plan = load(role['plan'])
    receipt = load(role['receipt'])
    assert sha(retained[role['plan']]) == role['planSHA256'] == receipt['planSHA256']
    assert sha(retained[role['receipt']]) == role['receiptSHA256']
    assert receipt['status'] == 'COMPLETE_CONSUMER_DEVELOPMENT_PASS'
    for path, digest in plan['pins'].items():
        assert retained_hash(path) == digest
    for root, entries in plan['resourceRoots'].items():
        for path, digest in entries.items():
            assert retained_hash(str(Path(root) / path)) == digest
    reached = set()
    def walk(path):
        if path in reached:
            return
        reached.add(path)
        assert sha(retained[path]) == plan['sourceInventory'][path]
        for child in re.findall(r'^import\s+(\S+)', retained[path].decode(), re.M):
            if child == 'Base':
                continue
            target = str((Path(path).parent / child).resolve())
            walk(target)
    walk(plan['entrypoint'])
    assert reached == set(plan['sourceInventory']) == set(plan['importClosure'])
    assert len(reached) == 80
    for guard in receipt['guards']:
        assert sha(retained[guard['path']]) == guard['sha256']
        value = load(guard['path'])
        assert value['unchanged']
        for path, digest in value['actualPins'].items():
            assert retained_hash(path) == digest
            pin_joins += 1
    for command in receipt['commands']:
        assert command['exit'] == 0 and command['failure'] is None
        for stream in ('stdout', 'stderr'):
            item = command[stream]
            assert len(retained[item['path']]) == item['bytes']
            assert sha(retained[item['path']]) == item['sha256']
        if command['label'] == 'consumer':
            assert retained[command['stdout']['path']] == (gzip.decompress(retained[plan['oracle']]) if retained[plan['oracle']].startswith(b'\x1f\x8b') else retained[plan['oracle']])
            assert retained[command['stderr']['path']] == b''
    oracle_parent = str(Path(plan['oracle']).parent)
    namespace = {'__file__': oracle_parent + '/model.py.source', '__name__': 'retained_oracle'}
    exec(compile(retained[oracle_parent + '/model.py.source'], '<retained scope model>', 'exec'), namespace)
    namespace['selftest']()
    rendered = namespace['render']()
    assert rendered == (gzip.decompress(retained[plan['oracle']]) if retained[plan['oracle']].startswith(b'\x1f\x8b') else retained[plan['oracle']])
    assert gzip.decompress(retained[oracle_parent + '/expected.stdout.gz']) == rendered
    basis = load(oracle_parent + '/SOURCE-BASIS.json')
    assert sha(retained[basis['freeze']['path']]) == basis['freeze']['sha256']
    for path, digest in basis['sourcePins'].items():
        assert retained_hash(path) == digest
    for path, digest in basis['sourceInventory'].items():
        assert retained_hash(path) == digest
    assert retained_hash(basis['priorModel']['path']) == basis['priorModel']['sha256']
result = {'status': 'PASS', 'bindings': len(manifest['members']), 'objects': len({row['object'] for row in manifest['members'] if 'object' in row}), 'externalInstalledELFIdentities': len(external), 'literalModulesPerRole': 80, 'evolvingGuardPinJoins': pin_joins, 'completeBytes': len(rendered), 'completeSHA256': sha(rendered), 'backendReplay': False, 'limitation': 'Installed ELF bodies remain external identities. Source check raws and exact entry/tool bindings are retained; no source-check pre/post inventory snapshots were created.'}
print(json.dumps(result, indent=2))
