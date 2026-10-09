"""No-child lossless archive and exact incomplete acquisition joins."""
import gzip
import hashlib
import json
from pathlib import Path
HERE = Path(__file__).resolve().parent
sha = lambda raw: hashlib.sha256(raw).hexdigest()

def verify():
    manifest = json.loads((HERE / 'MANIFEST.json').read_bytes()); raws = {}
    for row in manifest['members']:
        file = HERE / row['archive']; assert file.is_file() and not file.is_symlink()
        packed = file.read_bytes(); assert sha(packed) == row['archiveSHA256']
        raw = gzip.decompress(packed); assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        assert row['source'] not in raws; raws[row['source']] = raw
    assert {str(p.relative_to(HERE)) for p in (HERE / 'archive').glob('*.gz')} == {row['archive'] for row in manifest['members']}
    planpath = '/tmp/bendvy63-resolver-acquisition-plan-v2.json'
    digest = sha(raws[planpath]); assert digest == '18957d17d6fbb48efd1210ed3c16472bbdc8cf553d24445614fd300d7d84132a'
    plan = json.loads(raws[planpath]); root = Path(plan['outputRoot']); receipt = json.loads(raws[str(root / 'receipt.json')])
    assert receipt['planSHA256'] == digest and receipt['status'] == 'INCOMPLETE'
    assert receipt['error'] == 'TimeoutError: child deadline' and receipt['guardFailures'] == []
    assert receipt['closedResolverQualified'] is False and len(receipt['commands']) == 1
    command = receipt['commands'][0]
    assert command['exit'] is None and command['failure'] == 'child deadline' and command['capture'] == 'split'
    assert command['runnerSHA256'] == plan['sourcePins'][plan['helpers']['runner']]
    for stream in ['stdout', 'stderr']:
        assert raws[str(root / ('acquisition.' + stream))] == bytes.fromhex(command[stream]['rawHex']) == b''
    pins = dict(plan['sourcePins']); pins[planpath] = digest
    assert len(receipt['guards']) == 4
    for label, binding in zip(['pre', 'acquired', 'post', 'final'], receipt['guards']):
        assert binding['path'] == str(root / (label + '.guard.json'))
        raw = raws[binding['path']]; assert sha(raw) == binding['sha256']; guard = json.loads(raw)
        assert guard['label'] == label and guard['unchanged'] is True and guard['actualPins'] == pins
        expected = {} if label in ['pre', 'acquired'] else {str(root / 'inner/started.json'): sha(raws[str(root / 'inner/started.json')])}
        assert guard['retainedArtifacts'] == expected
    assert plan['outerCapSeconds'] == 5 and plan['allHashingInsideOuterCap'] is True
    assert plan['command'][:3] == ['/usr/bin/taskset', '-c', '5']
    assert len(plan['declaration']['resolver_inputs']) == 893 and len(plan['declaration']['loader_search_directories']) == 64
    assert len(plan['declaration']['discoveryCommands']) == 8
    inner = {p for p in raws if p.startswith(str(root / 'inner') + '/')}
    assert inner == {str(root / 'inner/started.json')}
    started = json.loads(raws[str(root / 'inner/started.json')]); assert started['outerCapSeconds'] == 5 and started['cost'] == plan['cost']
    for path, raw in raws.items():
        if path in plan['sourcePins']: assert sha(raw) == plan['sourcePins'][path]
    return {'members': len(raws), 'guards': 4, 'actual': 'INCOMPLETE_DEADLINE_PRESERVED', 'resolverAdmission': False, 'newChildren': 0}

if __name__ == '__main__': print(json.dumps(verify()))
