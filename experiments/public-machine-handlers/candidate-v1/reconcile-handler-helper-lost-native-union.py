"""Read/hash retained lost-retry Native partitions; no executable children."""
import argparse
import hashlib
import json
from pathlib import Path

H = Path(__file__).resolve().parent
sha = lambda b: hashlib.sha256(b).hexdigest()
p = argparse.ArgumentParser()
p.add_argument('--exit-run', required=True)
p.add_argument('--a-run', required=True)
p.add_argument('--b-run', required=True)
p.add_argument('--output', required=True)
args = p.parse_args()
joined = {}


def read(path, expected=None):
    path = Path(path).resolve()
    data = path.read_bytes()
    digest = sha(data)
    if expected is not None:
        assert digest == expected, str(path)
    joined[str(path)] = digest
    return data


def qualify(directory, subjects, probes, expected_status):
    directory = Path(directory).resolve()
    assert directory.is_relative_to(H / 'development')
    plan_bytes = read(directory / 'plan.json')
    plan = json.loads(plan_bytes)
    receipt = json.loads(read(directory / 'receipt.json'))
    assert receipt['planSHA256'] == sha(plan_bytes)
    assert receipt['status'] == expected_status
    assert len(receipt['commands']) == len(plan['commands']) == subjects
    assert receipt['probeCommandsExecuted'] == probes
    assert all(c['exit'] == 0 and c['failure'] is None for c in receipt['commands'])
    for path, digest in plan['pins'].items():
        read(path, digest)
    for path, digest in plan['configurationStates'].items():
        if digest is None:
            assert not Path(path).exists(), path
        else:
            read(path, digest)
    read(plan['privateEnvironment'], plan['environmentSHA256'])
    assert {str(f.relative_to(plan['stage'])) for f in Path(plan['stage']).rglob('*')
            if f.is_file()} == set(plan['inventory'])
    for relative, digest in plan['inventory'].items():
        read(Path(plan['stage']) / relative, digest)
    for path, digest in receipt['probePins'].items():
        read(path, digest)
    probe_members = {str(directory / 'execution-probes' / (label + suffix))
                     for label in plan['executionProbeLabels']
                     for suffix in ['.json', '.stdout', '.stderr']}
    assert len(plan['executionProbeLabels']) == probes
    assert set(receipt['probePins']) == probe_members
    assert {str(f) for f in (directory / 'execution-probes').iterdir()} == probe_members
    assert set(receipt['logs']) == {
        c['label'] + suffix for c in plan['commands'] for suffix in ['.stdout', '.stderr']
    }
    for relative, digest in receipt['logs'].items():
        read(directory / relative, digest)
    for path, digest in receipt['generated'].items():
        read(path, digest)
    allowed = set(receipt['logs']) | {'plan.json', 'receipt.json',
              'private-environment.json', 'execution-probes'}
    allowed.update(Path(path).name for path in receipt['generated']
                   if Path(path).parent == directory)
    if 'nominalRoots' in plan:
        allowed.update(['stage', 'derived'])
        assert {f.name for f in (directory / 'derived').iterdir()} == {'group-subsets.stdout'}
    assert {f.name for f in directory.iterdir()} == allowed
    assert all(not read(directory / (c['label'] + '.stderr')) for c in plan['commands'])
    return directory, plan, receipt


first, fp, fr = qualify(args.exit_run, 2, 25,
                       'STAGED_HANDLER_HELPERS_LOST_EXIT_A_NATIVE_COMPLETE16_AND2_PASS_NO_FULL_UNION')
a, ap, ar = qualify(args.a_run, 8, 85,
                    'STAGED_HANDLER_HELPERS_LOST_REMAINING_GROUP_SUBSETS_PASS_NO_FULL_UNION')
b, bp, br = qualify(args.b_run, 12, 125,
                    'STAGED_HANDLER_HELPERS_LOST_REMAINING_GROUP_SUBSETS_PASS_NO_FULL_UNION')
assert ap['group'] == 'A' and bp['group'] == 'B'
assert ap['firstExitQualification'] == bp['firstExitQualification']
assert ap['firstExitQualification']['receiptSHA256'] == joined[str(first / 'receipt.json')]
assert ap['sourceAndJSQualification'] == bp['sourceAndJSQualification']
js = Path(ap['sourceAndJSQualification']['receipt']).parent
jr = json.loads(read(js / 'receipt.json', ap['sourceAndJSQualification']['sha256']))
jpbytes = read(js / 'plan.json')
assert jr['planSHA256'] == sha(jpbytes)
jp = json.loads(jpbytes)
model_path = Path(jp['stage']) / 'lost-retry/experiments/public-machine-handlers/candidate-v1/full-mutant-lost-retry-expected.json'
model = json.loads(read(model_path, jp['inventory'][str(model_path.relative_to(jp['stage']))]))['bend']
names = [f'schema{s}_{phase}{i}{suffix}' for s in ['A', 'B']
         for phase in ['exit', 'transition', 'enter'] for i in [0, 1]
         for suffix in ['', '_missing']]
assert set(model) == set(names)
assert sum(len(model[n]) for n in names if not n.endswith('_missing')) == 96
assert sum(n.endswith('_missing') for n in names) == 12


def expected(selected):
    return ''.join(n + '|[' + ', '.join(model[n]) + ']\n' for n in selected).encode()


observed = []
union = b''
for directory, plan, roots in [(first, fp, {'lost-exit-a': fp['nominalRoot']}),
                               (a, ap, ap['nominalRoots']), (b, bp, bp['nominalRoots'])]:
    for label, root in roots.items():
        stage = Path(root['stage'])
        assert {str(f.relative_to(stage)) for f in stage.rglob('*')
                if f.is_file()} == set(root['inventory'])
        for relative, digest in root['inventory'].items():
            read(stage / relative, digest)
        # Current JS mutation source/support remain byte-identical in each narrowed root.
        for relative, digest in jp['inventory'].items():
            if relative.startswith('lost-retry/'):
                read(stage / relative[len('lost-retry/'):], digest)
        read(root['entry'], root['wrapperSHA256'])
        wanted = expected(root['names'])
        assert sha(wanted) == root['expectedSHA256']
        assert read(root['expected']) == wanted
        actual = read(directory / (label + '-run.stdout'))
        assert actual == wanted
        observed.extend(root['names'])
        union += actual
assert observed == names and union == expected(names)
for directory, receipt, selected in [(a, ar, names[4:12]), (b, br, names[12:])]:
    assert read(directory / 'derived/group-subsets.stdout', receipt['groupSubsetSHA256']) == expected(selected)
out = Path(args.output).resolve()
assert out.is_relative_to(H / 'development') and not out.exists()
out.mkdir()
(out / 'full96-and12.stdout').write_bytes(union)
result = {'status': 'READ_ONLY_CURRENT_HELPER_LOST_NATIVE_FULL96_AND12_RECONCILED',
          'completeIssue49': False, 'proofCredit': False, 'productionAdopted': False,
          'performanceQualified': False, 'observedNames': names, 'unionSHA256': sha(union),
          'receiptSHA256': {str(d / 'receipt.json'): joined[str(d / 'receipt.json')]
                            for d in [first, a, b]}, 'inputs': joined,
          'scope': 'Actual exit-A16+2, remaining-A32+4 and B48+6. No backend replay; unchanged current-JS model and exact raw concatenation. Original full-A timeout stays inconclusive.'}
(out / 'reconciliation.json').write_text(json.dumps(result, indent=2) + '\n')
print(sha((out / 'reconciliation.json').read_bytes()))
