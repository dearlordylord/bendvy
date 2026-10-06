#!/usr/bin/env python3
"""Replay finite consumer controls in a fresh directory; never edit the library."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import tarfile

HERE = Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
assert not args.output.exists(), 'Use a fresh output directory'
args.output.mkdir(parents=True)
provenance = json.loads((HERE / 'provenance.json').read_text())
digest = lambda path: hashlib.sha256(Path(path).read_bytes()).hexdigest()
assert digest(HERE / 'library.tar.xz') == provenance['libraryArchiveSHA256']
for path, expected in provenance['toolPins'].items():
    assert digest(path) == expected, ('tool drift', path)
for name, reference in provenance['referenceCommits'].items():
    checkout = Path('/workspace/formal-proofs/bendvy/.references') / name
    head = subprocess.check_output(['git', '-C', str(checkout), 'rev-parse', 'HEAD'], text=True).strip()
    assert head == reference['commit'], ('reference drift', name)
library = args.output / 'library'
library.mkdir()
pins = json.loads((HERE / 'library-manifest.json').read_text())['files']
with tarfile.open(HERE / 'library.tar.xz', 'r:xz') as archive:
    assert sorted(m.name for m in archive.getmembers()) == sorted(pins)
    for member in archive.getmembers():
        assert member.isfile() and Path(member.name).name == member.name
        data = archive.extractfile(member).read()
        assert hashlib.sha256(data).hexdigest() == pins[member.name]
        target = library / member.name
        target.write_bytes(data)
        target.chmod(0o444)
for source, target in [('blind-consumer', 'consumer'), ('coordinator', 'coordinator'), ('assisted-consumer', 'assisted')]:
    shutil.copytree(HERE / source, args.output / target)
receipts = []

def run(argv, seconds, expected_exit=0, fragments=()):
    process = subprocess.Popen(argv, cwd=args.output, stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT, text=True, start_new_session=True)
    timed_out = False
    try:
        output = process.communicate(timeout=seconds)[0]
    except subprocess.TimeoutExpired:
        timed_out = True
        os.killpg(process.pid, signal.SIGKILL)
        output = process.communicate()[0]
    receipt = {'argv': argv, 'seconds': seconds, 'exit': process.returncode,
               'timeout': timed_out, 'output': output}
    receipt['passed'] = not timed_out and process.returncode == expected_exit and all(x in output for x in fragments)
    receipts.append(receipt)
    (args.output / 'receipts.json').write_text(json.dumps(receipts, indent=2) + '\n')
    assert receipt['passed'], receipt
    return output

run(['bend', 'version'], 5, fragments=('bend 2.0.35',))
run(['bend', 'guide'], 5)
positives = {'structural': '[2]', 'lifecycle': '[5]', 'query-constant-control': '[42]'}
for name in ['import-query', 'structural', 'lifecycle', 'query-constant-control',
             'read-control', 'owner-control', 'schema-control', 'system-control']:
    run(['bend', f'consumer/{name}.bend'], 5, fragments=(positives[name],) if name in positives else ())
negatives = {
    'attempt-unerased-query': ('SOME PROOFS FAIL', 'Location: query'),
    'minimal': ('SOME PROOFS FAIL', 'expected : -get', 'Location: observer'),
    'undeclared-access': ('expected : PositionToken', 'observed : HealthToken', 'Location: read'),
    'write-through-read': ('expected : a function type', 'Location: read'),
    'cross-schema': ('expected : S.Handle<Game>', 'observed : S.Handle<Other>', 'Location: remove'),
    'duplicate-owner': ('consumed more than once', 'Location: duplicate'),
    'system-registration': ('expected : K.BodyKind', 'Location: register'),
}
for name, fragments in negatives.items():
    run(['bend', f'consumer/{name}.bend'], 5, 1, fragments)
run(['bend', 'coordinator/template-observer.bend'], 5, fragments=('[3]',))
run(['bend', 'consumer/lifecycle.bend', '-o', 'consumer/lifecycle.mjs'], 30)
run(['node', 'consumer/run-lifecycle.mjs'], 5, fragments=('"head":5',))
run(['bend', 'coordinator/template-observer.bend', '-o', 'coordinator/template-observer.mjs'], 30)
run(['node', 'coordinator/run-template-observer.mjs'], 5, fragments=('"head":3',))
# Assisted controls are separate from the immutable first blind pass.
run(['bend', 'assisted/template-query.bend'], 5, fragments=('[3]',))
run(['bend', 'assisted/template-array-query.bend'], 5, fragments=('[3]',))
run(['bend', 'assisted/public-setter-control.bend'], 5, fragments=('Four{9, 3, 3, 3}',))
run(['bend', 'assisted/template-public-setter-negative.bend'], 5, 1,
    ('expected : T.Position', 'Location: observer'))
assert all(digest(library / name) == value for name, value in pins.items())
result = {'status': 'FINITE_CONSUMER_REPLAY_PASS', 'libraryFiles': len(pins),
          'commands': len(receipts), 'fullSimulation': 'BLOCKED_ON_USER_SYSTEM_AND_COMPONENT_INTERFACES',
          'scope': 'Finite checks and JS structural/query execution; no Native/performance/refinement acceptance'}
(args.output / 'summary.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result))
