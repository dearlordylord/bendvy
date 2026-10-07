"""Reconcile packaged retained bytes with stdlib only. Executes no child/backend."""
import gzip
import hashlib
import json
import tarfile
from pathlib import PurePosixPath
from pathlib import Path

ROOT = Path(__file__).resolve().parent

def digest(data):
    return hashlib.sha256(data).hexdigest()

def main():
    manifest = json.loads((ROOT / 'manifest.json').read_text())
    assert manifest['developmentOnly'] is True
    assert manifest['acceptance'] is False and manifest['completeIssue43'] is False
    actual = {str(p.relative_to(ROOT)) for p in ROOT.rglob('*') if p.is_file()}
    assert actual == set(manifest['files']) | {'manifest.json'}, 'file membership changed'
    for name, expected in manifest['files'].items():
        assert digest((ROOT / name).read_bytes()) == expected, name
    snapshot = manifest['snapshot']
    data = gzip.decompress((ROOT / snapshot['path']).read_bytes())
    assert len(data) == snapshot['decodedBytes'], 'snapshot byte count'
    assert digest(data) == snapshot['decodedSHA256'], 'snapshot lossless hash'
    objects = {}
    with tarfile.open(ROOT / 'objects.tar.gz', 'r:gz') as archive:
        for member in archive.getmembers():
            name = member.name
            path = PurePosixPath(name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert name not in objects and str(path) == name, 'duplicate or noncanonical member'
            objects[name] = archive.extractfile(member).read()
    assert set(objects) == set(manifest['objects']), 'archive membership changed'
    for name, expected in manifest['objects'].items():
        assert digest(objects[name]) == expected, name
    evidence = 'evidence/fullcount-lossless-v7-001/'
    receipt = json.loads(objects[evidence + 'receipt.json'])
    assert digest(objects[evidence + 'receipt.json']) == manifest['retainedReceiptSHA256']
    assert receipt['retainedSnapshotSHA256'] == snapshot['decodedSHA256']
    for name, expected in receipt['rawPins'].items():
        assert digest(objects[evidence + name]) == expected, name
    commands = [name for name in objects if name.startswith(evidence) and name.endswith('.json') and name != evidence + 'receipt.json']
    assert len(commands) == 11
    for path in commands:
        command = json.loads(objects[path])
        assert command['exit'] == 0 and command['failure'] is None, path
        assert command['timeout'] == 5 and command['acceptance'] is False, path
    prior = json.loads(objects['evidence/fullcount-phased-v5-001/decode-full-json.json'])
    assert prior['failure'] == 'child deadline' and prior['exit'] is None
    print(json.dumps({'retainedBytesReconciled': True, 'childrenExecuted': 0,
        'retainedRuntimeCommands': len(commands), 'snapshotBytes': len(data),
        'developmentOnly': True, 'acceptance': False, 'completeIssue43': False,
        'originalFullJSONGate': 'UNMET'}))

if __name__ == '__main__':
    main()
