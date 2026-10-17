from pathlib import Path
import gzip, hashlib, json

PACKET = Path(__file__).resolve().parent
manifest = json.loads((PACKET / 'RETENTION.json').read_text())
rows = {row['path']: row for row in manifest['members']}
assert len(rows) == len(manifest['members']), 'duplicate retained member paths'
sha = lambda raw: hashlib.sha256(raw).hexdigest()

def read(path):
    key = str(path)
    row = rows[key]
    if 'object' in row:
        compressed = (PACKET / row['object']).read_bytes()
        assert sha(compressed) == row['objectSHA256']
        raw = gzip.decompress(compressed)
    else:
        raw = Path(key).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], key
    return raw

def js(path):
    return json.loads(read(path))

for key, row in rows.items():
    raw = read(key)
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
    if 'object' in row:
        compressed = (PACKET / row['object']).read_bytes()
        assert sha(compressed) == row['objectSHA256']
used_objects = {row['object'] for row in rows.values() if 'object' in row}
actual_objects = {str(path.relative_to(PACKET)) for path in (PACKET / 'objects').glob('*.gz')}
assert actual_objects == used_objects, 'unreferenced or missing content objects'

assert manifest['priorDiagnosticProfilesIncluded'] is False
assert len(manifest['roles']) == 8
assert {row['role'] for row in manifest['roles']} == {
    'motion64-js', 'motion64-native', 'motion256-js', 'motion256-native',
    'motion1024-js', 'motion1024-native', 'affine-owner-js', 'affine-owner-native',
}
for role in manifest['roles']:
    plan = js(role['plan'])
    receipt = js(role['receipt'])
    comparison = js(role['comparison'])
    assert receipt['status'] == role['status']
    assert len(receipt['commands']) == len(plan['commands'])
    assert sha(read(role['plan'])) == receipt['planSHA256'] == role['planSHA256']
    assert sha(read(role['receipt'])) == role['receiptSHA256']
    assert sha(read(role['comparison'])) == role['comparisonSHA256']
    for path, expected in plan['pins'].items():
        assert sha(read(path)) == expected, path
    for path, expected in plan.get('sourceInventory', {}).items():
        assert sha(read(path)) == expected, path
    for base, files in plan.get('resourceRoots', {}).items():
        for name, expected in files.items():
            assert sha(read(Path(base) / name)) == expected, (base, name)
    for path in plan.get('tools', {}).values():
        if str(path) in rows:
            read(path)
    for guard_record in receipt.get('guards', []):
        assert sha(read(guard_record['path'])) == guard_record['sha256']
        guard = js(guard_record['path'])
        assert guard['unchanged']
        for path, expected in guard.get('actualPins', {}).items():
            assert sha(read(path)) == expected, path
    for actual_command, planned_command in zip(receipt['commands'], plan['commands']):
        for field in ('label', 'argv', 'capSeconds'):
            assert actual_command[field] == planned_command[field]
        for stream in ('stdout', 'stderr'):
            item = actual_command[stream]
            raw = read(item['path'])
            assert len(raw) == item['bytes'] and sha(raw) == item['sha256']
        assert actual_command['stderr']['bytes'] == 0
    oracle = gzip.decompress(read(plan['oracle']))
    assert len(oracle) == role['oracleRawBytes']
    assert len(oracle) == plan['oracleBytes']
    assert sha(oracle) == role['oracleRawSHA256'] == plan['oracleSHA256']
    actual = read(Path(role['actualDirectory']) / 'consumer.stdout')
    stderr = read(Path(role['actualDirectory']) / 'consumer.stderr')
    assert Path(role['actualDirectory']) / 'consumer.stdout' == Path(receipt['commands'][-1]['stdout']['path'])
    assert Path(role['actualDirectory']) / 'consumer.stderr' == Path(receipt['commands'][-1]['stderr']['path'])
    assert len(actual) == role['actualBytes'] and sha(actual) == role['actualSHA256']
    assert stderr == b''
    equal = comparison.get('fullOracleEquality', comparison.get('fullEqual'))
    prefix_equal = comparison.get('prefixEqual', comparison.get('prefixMatches'))
    if role['status'] == 'COMPLETE_CONSUMER_DEVELOPMENT_PASS':
        assert role['result'] == 'FULL_ORACLE_EQUALITY' and equal is True and actual == oracle
        assert all(command['exit'] == 0 and command['failure'] is None for command in receipt['commands'])
    else:
        assert role['status'] == 'INCOMPLETE' and role['result'] == 'INCOMPLETE_CORRECT_PREFIX_ONLY'
        assert equal is False and prefix_equal is True and actual == oracle[:len(actual)]
        assert not receipt.get('guardFailures', [])
        assert all(command['exit'] is None and command['failure'] == 'child deadline' and command['capSeconds'] == 5 for command in receipt['commands'])
    if role['producer']:
        for field in ('generated', 'native'):
            path = role['producer'].get(field)
            expected = role['producer'].get(field + 'SHA256')
            if path and expected:
                assert sha(read(path)) == expected
    for artifact in role['artifactBindings']:
        assert sha(read(artifact['path'])) == artifact['sha256']
    if role['basis']:
        basis = js(role['basis'])
        assert role['basisSHA256'] == sha(read(role['basis']))
        for ref in role['basisReferences']:
            assert sha(read(ref['path'])) == ref['sha256']

for attempt in manifest['failedPreparationAttempts']:
    for key, value in attempt.items():
        if key.endswith('s') and isinstance(value, list):
            for path in value:
                read(path)
        elif isinstance(value, str) and value.startswith('/tmp/'):
            path = Path(value)
            if path.is_file():
                read(path)

first_attempt, second_attempt = manifest['failedPreparationAttempts']
assert first_attempt['status'] == 'JS_PREFLIGHT_REJECTED_NO_CHILD'
assert '/usr/bin/python3.11' in first_attempt['reason']
for path in first_attempt['receiptAbsence']:
    assert not Path(path).exists(), path
first_plans = [js(path) for path in first_attempt['plans']]
assert all('/usr/bin/python3.11' not in plan.get('pins', {}) for plan in first_plans)
assert second_attempt['status'] == 'COLLECTOR_INCOMPLETE_AFTER_CHILD_SUCCESS'
second_plan = js(second_attempt['jsPlan'])
second_receipt = js(second_attempt['jsReceipt'])
second_comparison = js(second_attempt['jsComparison'])
assert second_receipt['status'] == 'INCOMPLETE'
assert 'BadGzipFile' in second_receipt.get('error', '')
assert all(command['exit'] == 0 and command['failure'] is None for command in second_receipt['commands'])
assert all(command['stderr']['bytes'] == 0 for command in second_receipt['commands'])
assert len(second_receipt['commands']) == len(second_plan['commands'])
for actual_command, planned_command in zip(second_receipt['commands'], second_plan['commands']):
    for field in ('label', 'argv', 'capSeconds'):
        assert actual_command[field] == planned_command[field]
    for stream in ('stdout', 'stderr'):
        item = actual_command[stream]
        raw = read(item['path'])
        assert len(raw) == item['bytes'] and sha(raw) == item['sha256']
for guard_record in second_receipt.get('guards', []):
    guard = js(guard_record['path'])
    assert guard['unchanged']
    for path, expected in guard.get('actualPins', {}).items():
        assert sha(read(path)) == expected, path
second_actual = read(second_receipt['commands'][-1]['stdout']['path'])
second_plain_expected = read(second_plan['oracle'])
assert second_plain_expected.startswith(b'indexed=') and second_plain_expected.endswith(b'\n')
assert not second_plain_expected.startswith(b'\x1f\x8b')
assert second_actual == second_plain_expected
assert second_comparison['fullEqual'] is True
assert second_attempt['nativePlanUnexecuted'] and not Path(second_attempt['nativeReceiptAbsent']).exists()

print(json.dumps({
    'status': 'PASS',
    'roles': len(manifest['roles']),
    'members': manifest['memberCount'],
    'uniqueObjects': manifest['uniqueObjectCount'],
    'completeOracleMatches': sum(row['result'] == 'FULL_ORACLE_EQUALITY' for row in manifest['roles']),
    'incompleteCorrectPrefixes': sum(row['result'] == 'INCOMPLETE_CORRECT_PREFIX_ONLY' for row in manifest['roles']),
    'failedPreparationsPreserved': len(manifest['failedPreparationAttempts']),
    'priorDiagnosticProfilesIncluded': manifest['priorDiagnosticProfilesIncluded'],
}, indent=2))
