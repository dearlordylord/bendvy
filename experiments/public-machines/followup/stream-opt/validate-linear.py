#!/usr/bin/env python3
"""Reconcile retained full-count capsules without starting any child process."""
import base64
import gzip
import hashlib
import importlib.util
import json
import pathlib
import tarfile

HERE = pathlib.Path(__file__).resolve().parent
EVIDENCE = HERE.parent / 'evidence'
ROOT = HERE.parents[3]


def sha(body):
    return hashlib.sha256(body).hexdigest()


def validate(name, status):
    folder = EVIDENCE / name
    inventory = json.loads((folder / 'files.json').read_text())
    assert set(inventory) == {'receipt.json', 'cohort.tar.gz', 'frozen-sources.json.gz', 'exclusions.json'}
    assert all(sha((folder / n).read_bytes()) == h for n, h in inventory.items())
    exclusions = json.loads((folder / 'exclusions.json').read_text())
    sources = json.loads(gzip.decompress((folder / 'frozen-sources.json.gz').read_bytes()))
    for n, record in sources.items():
        body = base64.b64decode(record['base64'], validate=True)
        assert sha(body) == record['sha256']
        assert not body.startswith(b'\x7fELF') and not n.endswith('environment.private.json')
    with tarfile.open(folder / 'cohort.tar.gz', 'r:gz') as archive:
        members = archive.getmembers()
        names = [m.name for m in members]
        assert len(names) == len(set(names))
        roots = {n.split('/')[0] for n in names}
        assert len(roots) == 1
        prefix = next(iter(roots)) + '/'
        assert all(m.isfile() and m.name.startswith(prefix) and '..' not in pathlib.PurePosixPath(m.name).parts for m in members)
        data = {m.name[len(prefix):]: archive.extractfile(m).read() for m in members}
    assert all(not b.startswith(b'\x7fELF') and not n.endswith('environment.private.json') for n, b in data.items())
    receipt = json.loads(data['receipt.json'])
    plan = json.loads(data['plan.json'])
    assert data['receipt.json'] == (folder / 'receipt.json').read_bytes()
    assert receipt['status'] == status and receipt['planSHA256'] == sha(data['plan.json'])
    source_pins = {n: r['sha256'] for n, r in sources.items()}
    source_pins.update({n: r['sha256'] for n, r in exclusions['sourceRecords'].items()})
    assert source_pins == plan['sources']
    def recorded_pin(relative):
        matches = [h for n, h in source_pins.items() if n.endswith('/' + relative) and '/.artifacts/' not in n]
        assert len(matches) == 1, (relative, 'ambiguous retained repository pin')
        return matches[0]
    for n in ['queue.bend', 'stream.bend', 'format-linear.bend', 'adapt-linear.py']:
        path = HERE / n
        assert recorded_pin(str(path.relative_to(ROOT))) == sha(path.read_bytes()), (name, n, 'candidate source drift')
    excluded = exclusions['artifacts']
    assert set(data) == (set(receipt['artifacts']) - set(excluded)) | {'receipt.json'}
    assert all(sha(data[n]) == h for n, h in receipt['artifacts'].items() if n not in excluded)
    assert all(receipt['artifacts'][n] == r['sha256'] for n, r in excluded.items())
    for n, record in plan.get('stagePlan', {}).items():
        assert sha(data[n]) == record['sha256']
    for command in receipt['commands']:
        label = command['label']
        assert command['exit'] == 0 and command['failure'] is None
        assert sha(gzip.decompress(data[label + '.stdout.gz'])) == command['stdoutSHA256']
        assert sha(data[label + '.stderr']) == command['stderrSHA256']
    # Use the model only after its exact retained source and dependencies match.
    for relative in ['experiments/public-machines/followup/overflow-model.py', 'experiments/public-machines/full-model.py', 'experiments/public-machines/followup/evidence/primary-ts-v1/expected.json.gz']:
        path = ROOT / relative
        assert recorded_pin(relative) == sha(path.read_bytes())
    spec = importlib.util.spec_from_file_location('retained_overflow_model', HERE.parent / 'overflow-model.py')
    model = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(model)
    expected = gzip.decompress(data['expected.json.gz'])
    assert sha(expected) == plan.get('expectedSHA256', plan.get('expectedModelSHA256'))
    assert json.loads(expected) == model.expected()
    subject = next(c for c in receipt['commands'] if c['argv'][-1] == '65537' and (c['label'] == 'run-js' or any(a.endswith('/application-native') for a in c['argv'])))
    assert subject['cap'] == 5
    model.validate(gzip.decompress(data[subject['label'] + '.stdout.gz']))
    return {'receiptSHA256': sha(data['receipt.json']), 'commands': len(receipt['commands']), 'completeRows': 14, 'requestedCount': 65537, 'capacity': 65536, 'sources': len(sources)}


def main():
    result = {
        'JS': validate('linear-js-v2', 'DEVELOPMENT_FULL65537_TWO_SCHEMA_COMPLETE_MODEL_PASS'),
        'Native': validate('linear-native-v1', 'FULL65537_LINEAR_OBSERVER_NATIVE_MODEL_PASS_NO_ISSUE_ACCEPTANCE'),
    }
    print(json.dumps({'status': 'RETAINED_FULL_ORACLES_VALIDATED_NO_CHILD', 'results': result, 'scope': 'Isolated candidate only; issue48 remains incomplete'}))


if __name__ == '__main__':
    main()
