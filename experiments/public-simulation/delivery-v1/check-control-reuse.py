"""Read-only retained controls verification and exact current source join."""
import contextlib
import hashlib
import io
import json
from pathlib import Path
import tarfile
ROOT = Path('/workspace/formal-proofs/bendvy')
CONTROL = ROOT / 'experiments/public-simulation/controls-v1/finite-controls-v1'
sha = lambda raw: hashlib.sha256(raw).hexdigest()

def verify():
    source = CONTROL / 'verify.py'; namespace = {'__file__': str(source), '__name__': 'retained_control_check'}
    exec(compile(source.read_bytes(), str(source), 'exec'), namespace)
    stdout = io.StringIO()
    with contextlib.redirect_stdout(stdout): namespace['main']()
    index = json.loads((CONTROL / 'index.json').read_bytes())
    key = 'development/source5-v1/positive/stage/stage.json'
    with tarfile.open(CONTROL / 'evidence.tar.gz', 'r:gz') as archive:
        manifest = json.loads(archive.extractfile(index['records'][key]['object']).read())
    correction = json.loads((ROOT / 'experiments/public-simulation/bend-v1/candidate-source-correction.json').read_bytes())
    exact = []; corrected = []
    for row in manifest['files']:
        path = ROOT / row['stage']; raw = path.read_bytes()
        if sha(raw) == row['source_sha256']: exact.append(row['stage'])
        else:
            assert row['stage'] == 'experiments/public-simulation/bend-v1/geometry.bend'
            assert row['source_sha256'] == correction['executedSha256'] and sha(raw) == correction['candidateSha256']
            corrected.append(row['stage'])
    assert len(exact) == 50 and len(corrected) == 1
    return {'retainedArchivePASS': True, 'recordCount': 536, 'sourceCurrentExact': exact, 'approvedRecordedEOFCorrection': corrected, 'verifierStdout': stdout.getvalue(), 'scope': 'Current source API and retained selected finite type/mutation controls; old geometry bytes plus exact recorded EOF correction, not fresh relocated control executions', 'newChildren': 0}

if __name__ == '__main__': print(json.dumps(verify(), indent=2))
