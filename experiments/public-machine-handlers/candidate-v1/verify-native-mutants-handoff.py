"""Verify retained archive/raw/source hashes and diagnostic joins; no model recomputation or child tools."""
import hashlib
import io
import json
import tarfile
from pathlib import Path

import importlib.util

H = Path(__file__).resolve().parent
OUT = H / 'delivery-native-mutants-v1'
sha = lambda data: hashlib.sha256(data).hexdigest()
manifest = json.loads((OUT / 'manifest.json').read_text())
assert not any(manifest[k] for k in ['completeIssue49', 'acceptanceQualified',
                                    'performanceQualified', 'proofCredit'])
for name, digest in manifest['source'].items():
    assert sha((H / name).read_bytes()) == digest, name
assert sha((OUT / 'REPORT.md').read_bytes()) == manifest['reportSHA256']
archives = {}
for label, archive in manifest['archives'].items():
    blob = (OUT / archive['archive']).read_bytes()
    assert sha(blob) == archive['sha256'], label
    with tarfile.open(fileobj=io.BytesIO(blob), mode='r:gz') as tar:
        assert set(tar.getnames()) == set(archive['members']), label
        members = {}
        for name, recorded in archive['members'].items():
            assert 'private-environment' not in name
            data = tar.extractfile(name).read()
            assert len(data) == recorded['bytes'] and sha(data) == recorded['sha256'], name
            members[name] = data
        archives[label] = members
absolute = {str(Path(manifest['archives'][label]['historicalDirectory']) / name): data
            for label, members in archives.items() for name, data in members.items()}
# First A reused C from the separately selected ordinary qualification capsule.
qualification = json.loads((H / 'delivery-qualification-v1/manifest.json').read_text())
prior = qualification['archives']['native-emission']
blob = (H / 'delivery-qualification-v1' / prior['archive']).read_bytes()
assert sha(blob) == prior['sha256']
with tarfile.open(fileobj=io.BytesIO(blob), mode='r:gz') as tar:
    for name, recorded in prior['members'].items():
        data = tar.extractfile(name).read()
        assert sha(data) == recorded['sha256'] and len(data) == recorded['bytes']
        absolute[str(Path(prior['historicalDirectory']) / name)] = data
for label, members in archives.items():
    plan = json.loads(members['plan.json'])
    receipt = json.loads(members['receipt.json'])
    for name, digest in plan['inventory'].items():
        assert sha(members['stage/' + name]) == digest
    for path, digest in receipt['probePins'].items():
        assert sha(absolute[path]) == digest
    for path, digest in receipt.get('generated', {}).items():
        if Path(path).suffix == '.c':
            assert sha(absolute[path]) == digest
    for source, joined in plan.get('sourceJoins', {}).items():
        relative = Path(source).relative_to(H.parents[2])
        compiled = str(Path(plan['stage']) / relative)
        assert sha(absolute[compiled]) == joined['sha256'] == plan['pins'][source]
    for command in plan['commands']:
        if '-clang' in command['label'] or command['label'] == 'clang':
            source = next(arg for arg in command['argv'] if arg.endswith('.c'))
            if source in absolute:
                recorded = plan['pins'].get(source)
                if recorded is not None:
                    assert sha(absolute[source]) == recorded
first = json.loads(archives['first-whole-a']['receipt.json'])
assert first['status'] == 'WHOLE_MARKER_A_NATIVE_COMPLETE48_AND6_PASS_PARTIAL_TWO_SCHEMA_SCOPE'
assert first['probeCommandsExecuted'] == 25 and len(first['commands']) == 2
partial = json.loads(archives['remaining-five-failed']['receipt.json'])
assert partial['status'] == 'INCOMPLETE' and partial['probeCommandsExecuted'] == 180
assert len(partial['commands']) == 17 and partial['failedCommand']['failure'] == 'child deadline'
assert not archives['remaining-five-failed']['premature-publication-B-emit.stdout']
assert not archives['remaining-five-failed']['premature-publication-B-emit.stderr']
diagnostic = json.loads(archives['phase-exit-emission']['receipt.json'])
assert diagnostic['status'] == 'PREMATURE_B_EXIT_PHASE_EMISSION_PASS_NO_NATIVE_RUN'
assert diagnostic['probeCommandsExecuted'] == 25 and len(diagnostic['commands']) == 2
phase_partial = json.loads(archives['phase-native-failed']['receipt.json'])
assert phase_partial['status'] == 'INCOMPLETE' and phase_partial['probeCommandsExecuted'] == 70
assert len(phase_partial['commands']) == 6 and phase_partial['failedCommand']['failure'] == 'child deadline'
final = json.loads(archives['enter-native-final']['receipt.json'])
assert final['status'] == 'THREE_NATIVE_COMPLETE96_AND12_VARIANTS_ENTER_SINGLE_UNIONS_PASS'
assert final['probeCommandsExecuted'] == 85 and len(final['commands']) == 8
for label, receipt in [('first-whole-a', first), ('remaining-five-failed', partial),
                       ('phase-exit-emission', diagnostic), ('phase-native-failed', phase_partial),
                       ('enter-native-final', final)]:
    assert all(c['exit'] == 0 and c['failure'] is None for c in receipt['commands'])
    for name, digest in receipt['logs'].items():
        assert sha(archives[label][name]) == digest
for variant in ['lost-retry', 'premature-publication', 'whole-marker-rollback']:
    oracle = json.loads((H / ('full-mutant-' + variant + '-expected.json')).read_text())['bend']
    names = [f'schema{s}_{phase}{position}{suffix}' for s in ['A', 'B']
             for phase in ['exit', 'transition', 'enter'] for position in [0, 1]
             for suffix in ['', '_missing']]
    expected = ('\n'.join(name + '|[' + ', '.join(oracle[name]) + ']' for name in names) + '\n').encode()
    raw = archives['enter-native-final'][variant + '-union.stdout']
    assert raw == expected
    if variant == 'whole-marker-rollback':
        left = archives['first-whole-a']['run-native.stdout']
        assert not archives['first-whole-a']['run-native.stderr']
    else:
        left = archives['remaining-five-failed'][variant + '-A-run.stdout']
        assert not archives['remaining-five-failed'][variant + '-A-run.stderr']
    if variant == 'premature-publication':
        right = (archives['phase-native-failed']['exit-run.stdout']
                 + archives['phase-native-failed']['transition-run.stdout']
                 + archives['enter-native-final']['enter0-run.stdout']
                 + archives['enter-native-final']['enter1-run.stdout'])
        assert all(not archives['phase-native-failed'][phase + '-run.stderr']
                   for phase in ['exit', 'transition'])
        assert all(not archives['enter-native-final'][name + '-run.stderr']
                   for name in ['enter0', 'enter1'])
    else:
        right = archives['remaining-five-failed'][variant + '-B-run.stdout']
        assert not archives['remaining-five-failed'][variant + '-B-run.stderr']
    assert left + right == raw
print(json.dumps({'status': 'LOSSLESS_THREE_NATIVE_COMPLETE96_AND12_BYTE_UNIONS_VERIFIED',
                  'completeIssue49': False, 'proofCredit': False}))
