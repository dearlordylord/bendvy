from pathlib import Path
import gzip, hashlib, json

WT = Path('/tmp/bendvy-readers-reverse-history')
LEAF = WT / 'experiments/s-perf/canonical-api-v1/readers-runtime-v1'
PACKET = LEAF / 'runtime-v1/indexed-optional-selected/actual-attempt01'
OBJECTS = PACKET / 'objects'
OBJECTS.mkdir(parents=True, exist_ok=True)
sha = lambda b: hashlib.sha256(b).hexdigest()
roles = [
    ('motion64-js', Path('/tmp/bendvy21-readers-indexed-optional-motion64-v1/normal/js')),
    ('motion64-native', Path('/tmp/bendvy21-readers-indexed-optional-motion64-v1/normal/native')),
    ('motion256-js', Path('/tmp/bendvy21-readers-indexed-optional-motion256-reuse-v1/normal/js')),
    ('motion256-native', Path('/tmp/bendvy21-readers-indexed-optional-motion256-reuse-v1/normal/native')),
    ('motion1024-js', Path('/tmp/bendvy21-readers-indexed-optional-motion1024-reuse-v1/normal/js')),
    ('motion1024-native', Path('/tmp/bendvy21-readers-indexed-optional-motion1024-reuse-v1/normal/native')),
    ('affine-owner-js', Path('/tmp/bendvy21-readers-indexed-optional-affine-control-attempt03/normal/js')),
    ('affine-owner-native', Path('/tmp/bendvy21-readers-indexed-optional-affine-control-attempt03/normal/native')),
]
paths = {}
tool_only = set()
raw_oracles = {}
role_rows = []

def add_path(path, expected=None, tool=False):
    p = Path(path)
    raw = p.read_bytes()
    h = sha(raw)
    if expected is not None:
        assert h == expected, (str(p), h, expected)
    key = str(p)
    row = {
        'path': key,
        'realpath': str(p.resolve()),
        'bytes': len(raw),
        'sha256': h,
        'mode': oct(p.lstat().st_mode & 0o7777),
        'symlinkTarget': str(p.readlink()) if p.is_symlink() else None,
    }
    if key in paths:
        assert paths[key]['sha256'] == h
    else:
        paths[key] = row
    if tool:
        tool_only.add(key)
    return raw, h

def add_json(path, expected=None):
    raw, h = add_path(path, expected)
    return json.loads(raw), h

def basis_refs(value):
    found = []
    if isinstance(value, dict):
        if isinstance(value.get('path'), str) and isinstance(value.get('sha256'), str) and len(value['sha256']) == 64:
            found.append((value['path'], value['sha256']))
        for key, item in value.items():
            if key in ('sourceInventory', 'modelPins') and isinstance(item, dict):
                found.extend((p, h) for p, h in item.items() if isinstance(p, str) and isinstance(h, str) and len(h) == 64)
            found.extend(basis_refs(item))
    elif isinstance(value, list):
        for item in value:
            found.extend(basis_refs(item))
    return found

for label, directory in roles:
    plan_path = directory / 'plan.json'
    receipt_path = directory / 'receipt.json'
    comparison_path = directory / 'ROOT-FULL-ORACLE-COMPARISON.json'
    plan, plan_hash = add_json(plan_path)
    receipt, receipt_hash = add_json(receipt_path)
    comparison, comparison_hash = add_json(comparison_path)
    assert receipt['planSHA256'] == plan_hash, label
    if 'planSHA256' in comparison:
        assert comparison['planSHA256'] == plan_hash, label
    if 'receiptSHA256' in comparison:
        assert comparison['receiptSHA256'] == receipt_hash, label

    if label.startswith('motion64-'):
        assert plan['runtimeArguments'] == ['64', '64']
    elif label.startswith('motion256-'):
        assert plan['runtimeArguments'] == ['256', '64']
    elif label.startswith('motion1024-'):
        assert plan['runtimeArguments'] == ['1024', '64']
    else:
        assert plan['runtimeArguments'] == []

    for path, expected in plan['pins'].items():
        add_path(path, expected)
    for path, expected in plan.get('sourceInventory', {}).items():
        add_path(path, expected)
    for base, files in plan.get('resourceRoots', {}).items():
        for name, expected in files.items():
            add_path(Path(base) / name, expected, tool=True)
    for path in plan.get('tools', {}).values():
        if isinstance(path, str) and Path(path).is_file():
            add_path(path, tool=True)

    producer = plan.get('producer')
    artifact_bindings = []
    if producer:
        for field in ('generated', 'native'):
            path = producer.get(field)
            expected = producer.get(field + 'SHA256')
            if path and expected:
                add_path(path, expected)
                artifact_bindings.append({'kind': 'producer-' + field, 'path': path, 'sha256': expected})
    generated = plan.get('generated')
    if generated and Path(generated).is_file():
        raw, generated_hash = add_path(generated)
        artifact_bindings.append({'kind': 'selected-generated', 'path': generated, 'sha256': generated_hash})

    oracle_path = Path(plan['oracle'])
    oracle_gz, oracle_gz_hash = add_path(oracle_path)
    oracle = gzip.decompress(oracle_gz)
    oracle_hash = sha(oracle)
    assert oracle_hash == plan['oracleSHA256'], label
    assert len(oracle) == plan['oracleBytes'], label
    raw_oracles[oracle_hash] = oracle

    basis = oracle_path.parent / 'SOURCE-BASIS.json'
    basis_rows = []
    basis_hash = None
    if basis.is_file():
        basis_value, basis_hash = add_json(basis)
        for path, expected in basis_refs(basis_value):
            if Path(path).is_file():
                add_path(path, expected)
                basis_rows.append({'path': path, 'sha256': expected})
    for candidate in (oracle_path.parent / 'MODEL-CHECKS.json', oracle_path.parent.parent / 'MODEL-CHECKS.json'):
        if candidate.is_file():
            add_path(candidate)

    guard_rows = []
    for guard_record in receipt.get('guards', []):
        guard, guard_hash = add_json(guard_record['path'], guard_record['sha256'])
        assert guard['unchanged'], (label, guard_record['path'])
        for path, expected in guard.get('actualPins', {}).items():
            add_path(path, expected)
        guard_rows.append({'path': guard_record['path'], 'sha256': guard_hash})

    command_rows = []
    for actual_command, expected_command in zip(receipt['commands'], plan['commands']):
        for field in ('label', 'argv', 'capSeconds'):
            assert actual_command[field] == expected_command[field], (label, field)
        streams = {}
        for stream in ('stdout', 'stderr'):
            item = actual_command[stream]
            data, data_hash = add_path(item['path'], item['sha256'])
            assert len(data) == item['bytes']
            streams[stream] = {'path': item['path'], 'bytes': len(data), 'sha256': data_hash}
        command_rows.append({
            'label': actual_command['label'], 'exit': actual_command['exit'],
            'failure': actual_command['failure'], 'capSeconds': actual_command['capSeconds'],
            'streams': streams,
        })

    stdout_path = directory / 'consumer.stdout'
    stderr_path = directory / 'consumer.stderr'
    actual = stdout_path.read_bytes()
    stderr = stderr_path.read_bytes()
    assert stderr == b'', label
    assert actual == Path(receipt['commands'][-1]['stdout']['path']).read_bytes(), label
    if receipt['status'] == 'COMPLETE_CONSUMER_DEVELOPMENT_PASS':
        full_equal = comparison.get('fullOracleEquality', comparison.get('fullEqual'))
        assert full_equal is True and actual == oracle, label
        assert all(command['exit'] == 0 and command['failure'] is None for command in receipt['commands']), label
        result = 'FULL_ORACLE_EQUALITY'
    elif receipt['status'] == 'INCOMPLETE':
        full_equal = comparison.get('fullOracleEquality', comparison.get('fullEqual'))
        prefix_equal = comparison.get('prefixEqual', comparison.get('prefixMatches'))
        assert full_equal is False and prefix_equal is True and actual == oracle[:len(actual)], label
        assert all(command['exit'] is None and command['failure'] == 'child deadline' and command['capSeconds'] == 5 for command in receipt['commands']), label
        assert not receipt.get('guardFailures', []), label
        result = 'INCOMPLETE_CORRECT_PREFIX_ONLY'
    else:
        raise AssertionError((label, receipt['status']))

    role_rows.append({
        'role': label, 'actualDirectory': str(directory),
        'plan': str(plan_path), 'planSHA256': plan_hash,
        'receipt': str(receipt_path), 'receiptSHA256': receipt_hash,
        'comparison': str(comparison_path), 'comparisonSHA256': comparison_hash,
        'status': receipt['status'], 'result': result, 'runtimeArguments': plan['runtimeArguments'],
        'oracle': str(oracle_path), 'oracleGzipSHA256': oracle_gz_hash,
        'oracleRawBytes': len(oracle), 'oracleRawSHA256': oracle_hash,
        'actualBytes': len(actual), 'actualSHA256': sha(actual),
        'commands': command_rows, 'guards': guard_rows, 'producer': producer,
        'artifactBindings': artifact_bindings,
        'basis': str(basis) if basis.is_file() else None, 'basisSHA256': basis_hash,
        'basisReferences': basis_rows,
    })

failure_attempts = [
    {
        'id': 'affine-attempt01-missing-python-pin',
        'status': 'JS_PREFLIGHT_REJECTED_NO_CHILD',
        'reason': 'The JS runner preflight rejected before emit/consumer because /usr/bin/python3.11 was missing from tool pins. The Native plan was not launched. No child ran and no receipt was produced.',
        'plans': [
            '/tmp/bendvy21-readers-indexed-optional-affine-control-v1/normal/js/plan.json',
            '/tmp/bendvy21-readers-indexed-optional-affine-control-v1/normal/native/plan.json',
        ],
        'receiptAbsence': [
            '/tmp/bendvy21-readers-indexed-optional-affine-control-v1/normal/js/receipt.json',
            '/tmp/bendvy21-readers-indexed-optional-affine-control-v1/normal/native/receipt.json',
        ],
    },
    {
        'id': 'affine-attempt02-plain-oracle-gzip-mismatch',
        'status': 'COLLECTOR_INCOMPLETE_AFTER_CHILD_SUCCESS',
        'reason': 'JS emit and consumer exited 0 with empty stderr and produced 135 bytes matching the plain source-derived expected output. The collector then reported BadGzipFile because the plan pointed its gzip reader at a plain-text oracle; this is retained as INCOMPLETE, not a PASS. Native was prepared but not launched.',
        'jsPlan': '/tmp/bendvy21-readers-indexed-optional-affine-control-attempt02/normal/js/plan.json',
        'jsReceipt': '/tmp/bendvy21-readers-indexed-optional-affine-control-attempt02/normal/js/receipt.json',
        'jsComparison': '/tmp/bendvy21-readers-indexed-optional-affine-control-attempt02/normal/js/ROOT-FULL-ORACLE-COMPARISON.json',
        'nativePlanUnexecuted': '/tmp/bendvy21-readers-indexed-optional-affine-control-attempt02/normal/native/plan.json',
        'nativeReceiptAbsent': '/tmp/bendvy21-readers-indexed-optional-affine-control-attempt02/normal/native/receipt.json',
    },
]
for attempt in failure_attempts:
    for key, value in list(attempt.items()):
        if key == 'plans' and isinstance(value, list):
            for path in value:
                add_path(path)
        elif key in ('jsPlan', 'jsReceipt', 'jsComparison', 'nativePlanUnexecuted') and isinstance(value, str):
            p = Path(value)
            if p.is_file():
                add_path(p)

# Preserve all concrete evidence for the failed gzip-format attempt without recasting its status.
failed_plan_path = Path(failure_attempts[1]['jsPlan'])
failed_plan, _ = add_json(failed_plan_path)
for path, expected in failed_plan['pins'].items():
    add_path(path, expected)
for path, expected in failed_plan.get('sourceInventory', {}).items():
    add_path(path, expected)
for base, files in failed_plan.get('resourceRoots', {}).items():
    for name, expected in files.items():
        add_path(Path(base) / name, expected, tool=True)
for path in failed_plan.get('tools', {}).values():
    if isinstance(path, str) and Path(path).is_file():
        add_path(path, tool=True)
failed_receipt = json.loads(Path(failure_attempts[1]['jsReceipt']).read_text())
for command in failed_receipt['commands']:
    for stream in ('stdout', 'stderr'):
        add_path(command[stream]['path'], command[stream]['sha256'])
for guard_record in failed_receipt.get('guards', []):
    guard, _ = add_json(guard_record['path'], guard_record['sha256'])
    for path, expected in guard.get('actualPins', {}).items():
        add_path(path, expected)
for artifact in (failed_plan.get('generated'),):
    if artifact and Path(artifact).is_file():
        add_path(artifact)

# Retain exact expected source files, including the source freezes and affine fixture provenance.
source_freezes = {}
for name in ('MOTION-INDEXED-OPTIONAL-SOURCE-FREEZE.json', 'controls/indexed-optional-affine-v1/SOURCE-FREEZE.json'):
    path = LEAF / name
    raw, h = add_path(path)
    source_freezes[str(path)] = h

# Include the two immutable failed attempt plans/results as ordinary members.
script_path = Path(__file__)
add_path(script_path)
verify_path = PACKET / 'verify.py'
add_path(verify_path)

objects = {}
def write_object(raw):
    h = sha(raw)
    name = h + '.gz'
    destination = OBJECTS / name
    if not destination.exists():
        destination.write_bytes(gzip.compress(raw, mtime=0))
    compressed = destination.read_bytes()
    assert gzip.decompress(compressed) == raw
    row = {'object': 'objects/' + name, 'objectSHA256': sha(compressed), 'bytes': len(raw), 'sha256': h}
    objects[h] = row
    return row

members = []
for path in sorted(paths):
    row = dict(paths[path])
    raw = Path(path).read_bytes()
    assert sha(raw) == row['sha256']
    if raw.startswith(b'\x7fELF') and path in tool_only:
        row['hashOnly'] = 'Installed tool/resource identity only; not redistributed'
    else:
        row.update(write_object(raw))
    members.append(row)
raw_oracle_members = []
for h, raw in sorted(raw_oracles.items()):
    raw_oracle_members.append({'kind': 'decompressed-independent-oracle', **write_object(raw)})

manifest = {
    'schema': 'bendvy-content-addressed-runtime-evidence-v1',
    'scope': 'Current indexed-optional Readers source: Motion64 and Motion256 JS/Native complete-output matches, Motion1024 JS/Native exact-prefix-only deadlines, plus affine Type returned-owner control JS/Native complete-output matches. This does not qualify Motion1024, establish a speedup, or claim general shape coverage beyond the checked canonical indexed factory path and structural fallback.',
    'sourceSnapshot': {
        'sourceCommit': 'fdb441054529a35959a3aeb163ac2885edafc92f',
        'sourceFreeze': 'experiments/s-perf/canonical-api-v1/readers-runtime-v1/MOTION-INDEXED-OPTIONAL-SOURCE-FREEZE.json',
        'sourceFreezeSHA256': source_freezes[str(LEAF / 'MOTION-INDEXED-OPTIONAL-SOURCE-FREEZE.json')],
        'sourceHistoryCommit': 'dc292e7fbfaec4a43ebca9244de1c70d9a4e0961',
        'indexedObserverCommit': 'fdb441054529a35959a3aeb163ac2885edafc92f',
        'currentMasterCoreCommit': '4bc6da6f882aeb529a8047ce9f26b7328b901c82',
        'affineControlCommit': '8ddfc2f88',
        'affineControlFreeze': 'experiments/s-perf/canonical-api-v1/readers-runtime-v1/controls/indexed-optional-affine-v1/SOURCE-FREEZE.json',
        'affineControlFreezeSHA256': source_freezes[str(LEAF / 'controls/indexed-optional-affine-v1/SOURCE-FREEZE.json')],
        'affineControlFreezeCommit': '57110b688da84e30d228c473f37fe1f32c57fe6f',
    },
    'roles': role_rows,
    'rawOracles': raw_oracle_members,
    'sourceFreezes': source_freezes,
    'failedPreparationAttempts': failure_attempts,
    'members': members,
    'memberCount': len(members),
    'uniqueObjectCount': len(objects),
    'hashOnlyInstalledELFCount': sum('hashOnly' in row for row in members),
    'priorDiagnosticProfilesIncluded': False,
}
(PACKET / 'RETENTION.json').write_text(json.dumps(manifest, indent=2) + '\n')
used_objects = {row['object'] for row in members if 'object' in row}
for candidate in OBJECTS.glob('*.gz'):
    if 'objects/' + candidate.name not in used_objects:
        candidate.unlink()
print(json.dumps({
    'packet': str(PACKET), 'roles': len(role_rows), 'members': len(members),
    'objects': len(objects), 'hashOnlyInstalledELF': manifest['hashOnlyInstalledELFCount'],
    'failedAttempts': len(failure_attempts),
    'results': {r['role']: r['result'] for r in role_rows},
}, indent=2))
