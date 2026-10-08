"""Read-only finite Native reconciliation after derived-output log membership failure."""
import hashlib
import json
from pathlib import Path

H = Path(__file__).resolve().parent
run = H / 'development/handler-helper-normal-native-1791426418232820419'
sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
planPath, receiptPath = run / 'plan.json', run / 'receipt.json'
p, r = json.loads(planPath.read_text()), json.loads(receiptPath.read_text())
observationPath = H / 'development/handler-helper-native-finalization-failure/observation.json'
observation = json.loads(observationPath.read_text())
assert observation['session'] == 90536 and observation['exitCode'] == 1 and observation['receiptStatusNotAuthoritativeTerminalAcceptance']
assert observation['kind'] == 'transcribed actual tool result, not original stderr byte log'
assert sha(planPath) == 'd1c4066774d9255cc95b8bf469e5048a0cdd029f776ba695ab4234aeca07ec1c'
assert sha(receiptPath) == 'bb22dc1dc583c7b284cdd6f52ce68c8a025bbafd8e0ed6996f6cc0df92a33754'
assert r['planSHA256'] == sha(planPath)
assert len(r['commands']) == len(p['commands']) == 6
assert r['probeCommandsExecuted'] == 65
assert all(c['exit'] == 0 and c['failure'] is None for c in r['commands'])
assert all(sha(f) == digest for f, digest in p['pins'].items())
assert all(sha(f) == digest for f, digest in p['tools']['pins'].items())
assert sha(p['privateEnvironment']) == p['environmentSHA256']
stage = Path(p['stage'])
assert {str(f.relative_to(stage)): sha(f) for f in stage.rglob('*') if f.is_file()} == p['inventory']
for f, digest in p['configurationStates'].items():
    assert (sha(f) if Path(f).is_file() else None) == digest
assert all(sha(f) == digest for f, digest in r['generated'].items())
assert all(sha(f) == digest for f, digest in r['probePins'].items())
assert set(p['executionProbeLabels']) == {Path(f).stem for f in r['probePins'] if f.endswith('.json')}
assert set(r['probePins']) == {str(f) for f in (run / 'execution-probes').iterdir()}
for label in p['executionProbeLabels']:
    probe = json.loads((run / 'execution-probes' / (label + '.json')).read_text())
    assert probe['exit'] == 0 and probe['failure'] is None and probe['seconds'] == 5
    assert not (run / 'execution-probes' / (label + '.stderr')).read_bytes()
expectedLogs = {c['label'] + suffix for c in p['commands'] for suffix in ['.stdout', '.stderr']}
assert set(r['logs']) == expectedLogs
assert all(sha(run / name) == digest for name, digest in r['logs'].items())
assert all(not (run / (c['label'] + '.stderr')).read_bytes() for c in p['commands'])
assert {f.name for suffix in ['*.stdout', '*.stderr'] for f in run.glob(suffix)} == expectedLogs | {'full96-and12-union.stdout'}
expected = json.loads((stage / 'experiments/public-machine-handlers/candidate-v1/full-expected.json').read_text())['bend']
names = [f'schema{s}_{phase}{position}{suffix}' for s in ['A', 'B'] for phase in ['exit', 'transition', 'enter'] for position in [0, 1] for suffix in ['', '_missing']]
assert set(expected) == set(names)
assert sum(len(expected[n]) for n in names if not n.endswith('_missing')) == 96
assert len([n for n in names if n.endswith('_missing')]) == 12
raw = []
for schema in ['A', 'B']:
    wanted = ('\n'.join(n + '|[' + ', '.join(expected[n]) + ']' for n in names if n.startswith('schema' + schema + '_')) + '\n').encode()
    observed = (run / ('schema-' + schema.lower() + '-run.stdout')).read_bytes()
    assert observed == wanted
    raw.append(observed)
union = b''.join(raw)
assert union == (run / 'full96-and12-union.stdout').read_bytes()
assert hashlib.sha256(union).hexdigest() == r['unionSHA256']
print(json.dumps({'status': 'READ_ONLY_NATIVE_SUBJECTS_AND_EXPLICIT_DERIVED_UNION_RECONCILED', 'historicalTerminalExit': 1, 'originalReceiptNotTerminalAcceptance': True, 'planSHA256': sha(planPath), 'receiptSHA256': sha(receiptPath), 'subjectCount': 6, 'probeCount': 65, 'unionSHA256': r['unionSHA256'], 'terminalObservation': str(observationPath), 'terminalObservationSHA256': sha(observationPath), 'backendReplay': False, 'completeIssue49': False, 'proofCredit': False}, indent=2))
