"""Verify retained source/receipt/guard/output joins without running a backend."""
from pathlib import Path
import gzip
import hashlib
import json
import re
import sys
import types

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
    assert len(reached) == 143
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
    saved = sys.modules.get('base_model')
    base = types.ModuleType('base_model')
    base.__file__ = oracle_parent + '/base_model.py'
    sys.modules['base_model'] = base
    try:
        exec(compile(retained[base.__file__], '<retained base model>', 'exec'), base.__dict__)
        exec(compile(retained[oracle_parent + '/model.py.source'], '<retained Context model>', 'exec'), namespace)
        namespace['selftest']()
        rendered = namespace['render']()
    finally:
        if saved is None:
            del sys.modules['base_model']
        else:
            sys.modules['base_model'] = saved
    assert rendered == (gzip.decompress(retained[plan['oracle']]) if retained[plan['oracle']].startswith(b'\x1f\x8b') else retained[plan['oracle']])
    assert gzip.decompress(retained[oracle_parent + '/expected.stdout.gz']) == rendered
    basis = load(oracle_parent + '/SOURCE-BASIS.json')
    assert sha(retained[basis['freeze']['path']]) == basis['freeze']['sha256']
    for path, digest in basis['sourcePins'].items():
        assert retained_hash(path) == digest
    for path, digest in basis['sourceInventory'].items():
        assert retained_hash(path) == digest
    for name, digest in basis['models'].items():
        assert retained_hash(oracle_parent + '/' + name) == digest
    for path, digest in basis['priorIndependentModels'].items():
        assert retained_hash(path) == digest
source_freeze = load(basis['freeze']['path'])
pure_check = load(source_freeze['sourceCheck'])
host_check = load(source_freeze['hostSourceCheck'])
assert pure_check['exit'] == 0 and pure_check['argv'][-1].endswith('/main.bend')
assert host_check['exit'] == -9 and host_check['argv'][-1].endswith('/host.bend')
assert pure_check['argv'][1:3] == host_check['argv'][1:3] == ['-c', '6']
for stream in ('stdout', 'stderr'):
    path = str(Path(source_freeze['hostSourceCheck']).with_suffix('.' + stream))
    assert retained[path] == b''
result = {'status': 'PASS', 'bindings': len(manifest['members']), 'objects': len({row['object'] for row in manifest['members'] if 'object' in row}), 'externalInstalledELFIdentities': len(external), 'literalModulesPerRole': 143, 'evolvingGuardPinJoins': pin_joins, 'completeBytes': len(rendered), 'completeSHA256': sha(rendered), 'backendReplay': False, 'limitation': 'Installed ELF bodies remain external identities. Pure gameplay check passed at default5; host source check hit its default5 deadline. Both actual backend roles completed. No host source-check PASS or fabricated pre/post inventories are claimed.'}
print(json.dumps(result, indent=2))
