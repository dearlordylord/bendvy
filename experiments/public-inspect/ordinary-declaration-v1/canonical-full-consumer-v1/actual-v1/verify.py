"""Archive-only exact plan, source, guard, raw and whole-oracle joins."""
import gzip
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
manifest = json.loads((HERE / 'manifest.json').read_text())
objects = {}
for digest, row in manifest['members'].items():
    raw = gzip.decompress((HERE / row['member']).read_bytes())
    assert row['sha256'] == digest == hashlib.sha256(raw).hexdigest()
    assert row['bytes'] == len(raw)
    objects[digest] = raw

for cohort in manifest['cohorts']:
    files = cohort['files']
    plan_path = cohort['plan']
    plan_sha = files[plan_path]
    plan = json.loads(objects[plan_sha])
    receipt_path = str(Path(plan_path).with_name('receipt.json'))
    receipt = json.loads(objects[files[receipt_path]])
    assert receipt['planSHA256'] == plan_sha
    assert receipt.get('guardFailures', []) == []
    for path, digest in plan['pins'].items():
        assert manifest['sourceObjects'].get(path, manifest['externalPins'].get(path)) == digest
    assert manifest['sourceObjects']['/home/node/.bend/bend2/base.bend'] == plan['resourceRoots']['/home/node/.bend/bend2']['base.bend']
    reached = set()
    def visit(path):
        path = str(Path(path))
        assert path in plan['sourceInventory']
        if path in reached:
            return
        reached.add(path)
        digest = plan['sourceInventory'][path]
        assert manifest['sourceObjects'][path] == digest
        for target in re.findall(r'^import\s+(\S+)', objects[digest].decode(), re.MULTILINE):
            if target != 'Base':
                # Normalize lexical .. without consulting live files or symlinks.
                parts = []
                for part in (Path(path).parent / target).parts:
                    if part == '..':
                        parts.pop()
                    elif part != '.':
                        parts.append(part)
                visit(str(Path(*parts)))
    entries = plan.get('sourceEntries', [plan['entrypoint']])
    for entry in entries:
        visit(entry)
    assert sorted(reached) == plan['importClosure'] == sorted(plan['sourceInventory'])
    expected_files = {plan_path, receipt_path}
    pins = dict(plan['pins'])
    pins[plan_path] = plan_sha
    guard_index = 0
    def guard(label):
        global guard_index
        row = receipt['guards'][guard_index]
        guard_index += 1
        assert files[row['path']] == row['sha256']
        body = json.loads(objects[row['sha256']])
        assert body['label'] == label and body['unchanged']
        assert body['actualPins'] == pins
        expected_files.add(row['path'])
    for index, command in enumerate(receipt['commands']):
        planned = plan['commands'][index]
        assert all(command[key] == value for key, value in planned.items())
        label = command['label']
        guard(label + '-pre')
        guard(label + '-acquired')
        for stream in ('stdout', 'stderr'):
            row = command[stream]
            assert row['published'] and files[row['path']] == row['sha256']
            assert len(objects[row['sha256']]) == row['bytes']
            pins[row['path']] = row['sha256']
            expected_files.add(row['path'])
        if label in ('emit', 'build') and label + 'ArtifactSHA256' in receipt:
            path = plan['generated'] if label == 'emit' else plan['native']
            assert files[path] == receipt[label + 'ArtifactSHA256']
            pins[path] = files[path]
            expected_files.add(path)
        guard(label + '-post')
    guard('final')
    assert guard_index == len(receipt['guards'])
    assert set(files) == expected_files
    if cohort['name'] == 'prepared-source04':
        assert receipt['status'] == 'COMPLETE_SOURCE_CONTROL_PASS'
        assert len(receipt['commands']) == len(plan['commands']) == 6
        for command in receipt['commands']:
            assert command['failure'] is None and command['sourceControlPassed']
            assert command['exit'] == command['expectedExit']
            stderr = objects[command['stderr']['sha256']]
            assert all(token.encode() in stderr for token in command['stderrContains'])
    elif cohort['name'] == 'prepared-native04':
        assert receipt['status'] == 'INCOMPLETE'
        assert receipt['error'] == 'ValueError: Owned child failed: emit'
        assert len(receipt['commands']) == 1
        command = receipt['commands'][0]
        assert command['exit'] is None and command['failure'] == 'child deadline'
        assert command['capSeconds'] == 30
        assert all(command[stream]['bytes'] == 0 for stream in ('stdout', 'stderr'))
        assert plan['generated'] not in files and plan['native'] not in files
    else:
        assert receipt['status'] == 'COMPLETE_CONSUMER_DEVELOPMENT_PASS'
        assert len(receipt['commands']) == len(plan['commands']) == 2
        assert all(command['exit'] == 0 and command['failure'] is None for command in receipt['commands'])
        command = receipt['commands'][-1]
        actual = objects[command['stdout']['sha256']]
        expected = gzip.decompress(objects[manifest['sourceObjects'][plan['oracle']]])
        assert actual == expected and len(actual) == plan['oracleBytes']
        assert hashlib.sha256(actual).hexdigest() == plan['oracleSHA256'] == receipt['wholeOracleSHA256']
        assert objects[command['stderr']['sha256']] == b''
        if plan['subject'] == 'reader':
            normal = gzip.decompress(objects[manifest['sourceObjects'][plan['normalOracle']]])
            assert len(normal) == 5077477
            assert hashlib.sha256(normal).hexdigest() == plan['normalOracleSHA256']
            assert actual != normal and receipt['completeNormalBaselineRejected']

held = manifest['held']
assert held['status'] == 'HELD_UNATTEMPTED'
assert held['sha256'] in objects
assert json.loads(objects[held['sha256']])['subject'] == 'reader'
print('PASS', len(objects), 'archive objects; exact source/plan/raw/guard joins; whole normal and reader equality; Native failure and held reader scope')
