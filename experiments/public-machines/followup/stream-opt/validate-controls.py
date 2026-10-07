#!/usr/bin/env python3
"""Validate retained full mutant oracles and raw receipts without child execution."""
import base64
import gzip
import hashlib
import importlib.util
import json
import pathlib
import tarfile

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[3]
FOLDER = HERE.parent / 'evidence/linear-controls-v1'


def sha(body):
    return hashlib.sha256(body).hexdigest()


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    inventory = json.loads((FOLDER / 'files.json').read_text())
    assert set(inventory) == {'receipt.json', 'cohort.tar.gz', 'frozen-sources.json.gz', 'exclusions.json'}
    assert all(sha((FOLDER / n).read_bytes()) == h for n, h in inventory.items())
    excluded = json.loads((FOLDER / 'exclusions.json').read_text())
    sources = json.loads(gzip.decompress((FOLDER / 'frozen-sources.json.gz').read_bytes()))
    pins = {}
    for name, record in sources.items():
        body = base64.b64decode(record['base64'], validate=True)
        assert sha(body) == record['sha256']
        assert not body.startswith(b'\x7fELF') and not name.endswith('environment.private.json')
        assert '__pycache__' not in pathlib.PurePosixPath(name).parts
        pins[name] = record['sha256']
    pins.update({n: r['sha256'] for n, r in excluded['inputRecords'].items()})
    with tarfile.open(FOLDER / 'cohort.tar.gz', 'r:gz') as archive:
        members = archive.getmembers()
        names = [m.name for m in members]
        assert len(names) == len(set(names))
        roots = {n.split('/')[0] for n in names}
        assert len(roots) == 1
        prefix = next(iter(roots)) + '/'
        assert all(m.isfile() and m.name.startswith(prefix) and '..' not in pathlib.PurePosixPath(m.name).parts for m in members)
        data = {m.name[len(prefix):]: archive.extractfile(m).read() for m in members}
    assert all(not body.startswith(b'\x7fELF') and not n.endswith('environment.private.json') for n, body in data.items())
    receipt = json.loads(data['receipt.json'])
    plan = json.loads(data['plan.json'])
    assert data['receipt.json'] == (FOLDER / 'receipt.json').read_bytes()
    assert receipt['status'] == 'FIVE_REACHED_BOTH_SCHEMA_MUTANTS_FOUR_NEGATIVES_PASS_NO_ISSUE_ACCEPTANCE'
    assert receipt['planSHA256'] == sha(data['plan.json'])
    input_pins = {}
    for path, record in plan['inputSnapshot'].items():
        if isinstance(record, dict):
            input_pins.update({str(pathlib.PurePosixPath(path) / n): h for n, h in record.items()})
        else:
            input_pins[path] = record
    assert pins == input_pins
    assert all(pins[n] == h for n, h in plan['sources'].items())
    assert set(data) == (set(receipt['artifacts']) - set(excluded['artifacts'])) | {'receipt.json'}
    assert all(sha(data[n]) == h for n, h in receipt['artifacts'].items() if n not in excluded['artifacts'])
    assert all(receipt['artifacts'][n] == r['sha256'] for n, r in excluded['artifacts'].items())
    assert all(sha(data[n]) == h for n, h in plan['initialArtifacts'].items() if n not in excluded['artifacts'])
    assert len(receipt['commands']) == plan['maxChildren'] == 210
    for command in receipt['commands']:
        label = command['label']
        assert command['failure'] is None
        assert sha(gzip.decompress(data[label + '.stdout.gz'])) == command['stdoutSHA256']
        assert sha(data[label + '.stderr']) == command['stderrSHA256']
    modules = [HERE / 'controls.py', HERE / 'mutant-oracles.py', HERE.parent / 'overflow-model.py', HERE.parent.parent / 'full-model.py', HERE.parent / 'evidence/primary-ts-v1/expected.json.gz']
    for path in modules:
        relative = str(path.relative_to(ROOT))
        matches = [h for n, h in pins.items() if n.endswith('/' + relative) and '/.artifacts/' not in n]
        assert len(matches) == 1 and matches[0] == sha(path.read_bytes()), (relative, 'retained dependency drift')
    controls = load('retained_controls', HERE / 'controls.py')
    oracles = load('retained_control_oracles', HERE / 'mutant-oracles.py')
    model = load('retained_control_model', HERE.parent / 'overflow-model.py')
    assert json.loads(gzip.decompress(data['expected.json.gz'])) == model.expected()
    jobs = {job['label']: job for job in plan['commands']}
    assert len(jobs) == len(receipt['subjects']) == 14
    subjects = {subject['label']: subject for subject in receipt['subjects']}
    assert set(subjects) == set(jobs)
    by_child = {command['label']: command for command in receipt['commands']}
    subject_children = {subject['childLabel'] for subject in subjects.values()}
    assert len(subject_children) == 14
    assert all(command['exit'] == 0 for command in receipt['commands'] if command['label'] not in subject_children)
    witnesses = []
    for label, job in jobs.items():
        subject = subjects[label]
        child = by_child[subject['childLabel']]
        assert child['argv'] == job['argv'] and child['cap'] == job['cap']
        assert child['exit'] == job['expectedExit'] == subject['exit']
        raw = gzip.decompress(data[child['label'] + '.stdout.gz'])
        assert subject['produced'] == {n: sha(data[n]) for n in job['newArtifacts']}
        if job.get('validate') == 'negative':
            assert raw == b'' and sha(data[child['label'] + '.stderr']) == job['expectedStderrSHA256']
        if job.get('validate') == 'mutant':
            assert job['argv'][-1] == '65537' and job['cap'] == 5
            expected = json.loads(gzip.decompress(data[job['oracleArtifact']]))
            oracles.validate(job['mutant'], raw, model, expected)
            witnesses.append({'mutant': job['mutant'], 'witnesses': controls.witness(job['mutant'], raw, model)})
    assert witnesses == receipt['witnesses'] and len(witnesses) == 5
    print(json.dumps({'status': 'RETAINED_FIVE_EXACT_FULL_ORACLES_FOUR_NEGATIVES_VALIDATED_NO_CHILD', 'receiptSHA256': sha(data['receipt.json']), 'commands': 210, 'mutants': 5, 'rowsPerMutant': 14, 'capacity': 65536, 'requestedCount': 65537, 'scope': 'Finite isolated candidate controls; no issue closure'}))


if __name__ == '__main__':
    main()
