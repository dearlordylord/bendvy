"""Verify archived split lost-retry raw/source/model joins without children."""
import hashlib
import io
import json
import tarfile
from pathlib import Path

H = Path(__file__).resolve().parent
sha = lambda b: hashlib.sha256(b).hexdigest()
OUT = H / 'delivery-handler-helper-native-mutant-lost-retry-v1'
m = json.loads((OUT / 'manifest.json').read_text())
assert all(not m[k] for k in ['completeIssue49', 'proofCredit', 'productionAdopted', 'performanceQualified'])
for name, digest in m['source'].items():
    assert sha((H / name).read_bytes()) == digest
assert sha((OUT / 'REPORT.md').read_bytes()) == m['reportSHA256']


def unpack(path, record):
    blob = path.read_bytes()
    assert sha(blob) == record['sha256']
    result = {}
    with tarfile.open(fileobj=io.BytesIO(blob), mode='r:gz') as t:
        assert set(t.getnames()) == set(record['members'])
        for name, item in record['members'].items():
            assert 'private-environment' not in name
            data = t.extractfile(name).read()
            assert sha(data) == item['sha256'] and len(data) == item['bytes']
            result[name] = data
    return result


d = unpack(OUT / m['archive']['name'], m['archive'])
jmfile = H / 'delivery-handler-helper-mutants-js-v1/manifest.json'
assert sha(jmfile.read_bytes()) == m['jsCapsuleManifestSHA256']
jm = json.loads(jmfile.read_text())
ja = jm['archives']['js']
j = unpack(jmfile.parent / ja['archive'], ja)
jp = json.loads(j['plan.json'])
model = json.loads(j['stage/lost-retry/experiments/public-machine-handlers/candidate-v1/full-mutant-lost-retry-expected.json'])['bend']
names = [f'schema{s}_{phase}{i}{suffix}' for s in ['A', 'B']
         for phase in ['exit', 'transition', 'enter'] for i in [0, 1]
         for suffix in ['', '_missing']]
assert set(model) == set(names)
assert sum(len(model[n]) for n in names if not n.endswith('_missing')) == 96
assert sum(n.endswith('_missing') for n in names) == 12


def wanted(selected):
    return ''.join(n + '|[' + ', '.join(model[n]) + ']\n' for n in selected).encode()


def historical(path):
    matches = []
    for label, root in m['historicalDirectories'].items():
        if Path(path).is_relative_to(root):
            key = label + '/' + str(Path(path).relative_to(root))
            if key in d:
                matches.append(key)
    assert len(matches) == 1, path
    return d[matches[0]]


def qualify(label, subjects, probes, status):
    plan = json.loads(d[label + '/plan.json'])
    receipt = json.loads(d[label + '/receipt.json'])
    assert receipt['status'] == status
    assert receipt['planSHA256'] == sha(d[label + '/plan.json'])
    assert len(receipt['commands']) == len(plan['commands']) == subjects
    assert all(c['exit'] == 0 and c['failure'] is None for c in receipt['commands'])
    assert receipt['probeCommandsExecuted'] == probes
    expected_probes = {str(Path(m['historicalDirectories'][label]) / 'execution-probes' / (n + suffix))
                       for n in plan['executionProbeLabels'] for suffix in ['.json', '.stdout', '.stderr']}
    assert len(plan['executionProbeLabels']) == probes
    assert set(receipt['probePins']) == expected_probes
    for path, digest in receipt['probePins'].items():
        assert sha(historical(path)) == digest
    assert set(receipt['logs']) == {c['label'] + suffix for c in plan['commands'] for suffix in ['.stdout', '.stderr']}
    for name, digest in receipt['logs'].items():
        assert sha(d[label + '/' + name]) == digest
    assert all(not d[label + '/' + c['label'] + '.stderr'] for c in plan['commands'])
    for path, digest in receipt['generated'].items():
        if path.endswith('.c'):
            assert sha(historical(path)) == digest
        else:
            assert path.endswith('-native') and len(digest) == 64
    return plan, receipt


fp, fr = qualify('exit', 2, 25, 'STAGED_HANDLER_HELPERS_LOST_EXIT_A_NATIVE_COMPLETE16_AND2_PASS_NO_FULL_UNION')
ap, ar = qualify('A', 8, 85, 'STAGED_HANDLER_HELPERS_LOST_REMAINING_GROUP_SUBSETS_PASS_NO_FULL_UNION')
bp, br = qualify('B', 12, 125, 'STAGED_HANDLER_HELPERS_LOST_REMAINING_GROUP_SUBSETS_PASS_NO_FULL_UNION')
qualify('diagnostic', 2, 25, 'STAGED_HANDLER_HELPERS_LOST_EXIT_A_SOURCE_AND_C_EMISSION_PASS_NO_RUNTIME')
observed = []
union = b''
for label, plan, roots in [('exit', fp, {'lost-exit-a': fp['nominalRoot']}),
                           ('A', ap, ap['nominalRoots']), ('B', bp, bp['nominalRoots'])]:
    for rootlabel, root in roots.items():
        prefix = None
        for archive_label, directory in m['historicalDirectories'].items():
            if Path(root['stage']).is_relative_to(directory):
                prefix = archive_label + '/' + str(Path(root['stage']).relative_to(directory)) + '/'
        assert prefix is not None
        assert {n[len(prefix):] for n in d if n.startswith(prefix)} == set(root['inventory'])
        for relative, digest in root['inventory'].items():
            assert sha(d[prefix + relative]) == digest
        for relative, digest in jp['inventory'].items():
            if relative.startswith('lost-retry/'):
                assert sha(d[prefix + relative[len('lost-retry/'):]]) == digest
        assert sha(historical(root['entry'])) == root['wrapperSHA256']
        expected = wanted(root['names'])
        assert sha(expected) == root['expectedSHA256'] and historical(root['expected']) == expected
        actual = d[label + '/' + rootlabel + '-run.stdout']
        assert actual == expected
        observed.extend(root['names'])
        union += actual
assert observed == names and union == wanted(names)
assert d['A/derived/group-subsets.stdout'] == wanted(names[4:12])
assert d['B/derived/group-subsets.stdout'] == wanted(names[12:])
rr = json.loads(d['reconciliation/reconciliation.json'])
assert sha(d['reconciliation/reconciliation.json']) == m['reconciliationSHA256']
assert rr['status'] == 'READ_ONLY_CURRENT_HELPER_LOST_NATIVE_FULL96_AND12_RECONCILED'
assert union == d['reconciliation/full96-and12.stdout'] and sha(union) == rr['unionSHA256'] == m['unionSHA256']
for path, digest in rr['inputs'].items():
    # Excluded tool/private-environment/binary files remain historical hashes.
    candidates = [label + '/' + str(Path(path).relative_to(root))
                  for label, root in m['historicalDirectories'].items()
                  if Path(path).is_relative_to(root)]
    for key in candidates:
        if key in d:
            assert sha(d[key]) == digest
timeout = json.loads(d['timeout/receipt.json'])
assert timeout['status'] == 'INCOMPLETE' and timeout['planSHA256'] == sha(d['timeout/plan.json'])
assert timeout['failedCommand']['failure'] == 'child deadline'
for name, digest in timeout['logs'].items():
    assert sha(d['timeout/' + name]) == digest
for path, digest in timeout['probePins'].items():
    assert sha(historical(path)) == digest
print('FINITE_CURRENT_HELPER_LOST_NATIVE_SPLIT_FULL96_AND12_BYTE_JOINS_VERIFIED')
