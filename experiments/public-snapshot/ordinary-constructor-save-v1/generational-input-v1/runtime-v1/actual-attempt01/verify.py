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
    assert len(reached) == 50
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
    namespace = {'__file__': oracle_parent + '/model.py', '__name__': 'retained_oracle'}
    saved = sys.modules.get('base_model')
    base = types.ModuleType('base_model')
    base.__file__ = oracle_parent + '/base_model.py'
    sys.modules['base_model'] = base
    try:
        exec(compile(retained[base.__file__], '<retained base model>', 'exec'), base.__dict__)
        exec(compile(retained[oracle_parent + '/model.py'], '<retained Context model>', 'exec'), namespace)
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
    assert retained_hash(oracle_parent + '/base_model.py') == basis['oldBasis']['sha256']
    assert retained_hash(basis['oldBasis']['path']) == basis['oldBasis']['sha256']
source_check_path = next(name for name in retained if name.endswith('/generational-input-v1/checks/SOURCE-CHECK.json'))
checks = load(source_check_path)['checks']
source_check_joins = 0
assert len(checks) == 4
for check in checks:
    assert check['pinsUnchanged'] and check['prePins'] == check['postPins']
    assert len(check['prePins']) == 121
    for pins in (check['prePins'], check['postPins']):
        for path, digest in pins.items():
            assert retained_hash(path) == digest
            source_check_joins += 1
    assert check['capSeconds'] == 5 and check['cpu'] == 8
    assert check['exit'] == (1 if check['expectedForeignRefusalOnly'] else 0)
    for stream in ('stdout', 'stderr'):
        path = str(Path(source_check_path).parent / check[stream])
        assert retained_hash(path) == check[stream + 'SHA256']
result = {'sourceChecks': len(checks), 'sourceCheckPrePostPinJoins': source_check_joins, 'status': 'PASS', 'bindings': len(manifest['members']), 'objects': len({row['object'] for row in manifest['members'] if 'object' in row}), 'externalInstalledELFIdentities': len(external), 'literalModulesPerRole': 50, 'evolvingGuardPinJoins': pin_joins, 'completeBytes': len(rendered), 'completeSHA256': sha(rendered), 'backendReplay': False, 'limitation': 'Installed ELF bodies remain external identities. Source check raws, exact tools and original pre/post inventories are retained in plan pins; this verifier checks their retained byte identities. Both stock roles completed.'}
print(json.dumps(result, indent=2))
