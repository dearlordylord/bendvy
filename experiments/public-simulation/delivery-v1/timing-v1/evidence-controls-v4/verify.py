"""No-child lossless actual reached timing-control packet verifier."""
import gzip, hashlib, json
from pathlib import Path
HERE = Path(__file__).resolve().parent
sha = lambda raw: hashlib.sha256(raw).hexdigest()
def verified():
    manifest = json.loads((HERE / 'MANIFEST.json').read_bytes()); raws = {}
    for row in manifest['members']:
        path = HERE / row['archive']; assert path.is_file() and not path.is_symlink()
        packed = path.read_bytes(); assert sha(packed) == row['archiveSHA256']
        raw = gzip.decompress(packed); assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        assert row['source'] not in raws; raws[row['source']] = raw
    assert {str(p.relative_to(HERE)) for p in (HERE / 'archive').iterdir()} == {r['archive'] for r in manifest['members']}
    planpath = '/tmp/bendvy63-timing-sequence-controls-plan-v4.json'; digest = sha(raws[planpath])
    assert digest == manifest['planSHA256'] == '93026e2b56be34d49ee145da19b2b64be26e5ab20e93122ed1f41e0b4b6c0889'
    plan = json.loads(raws[planpath]); root = Path(plan['outputRoot']); receipt = json.loads(raws[str(root / 'receipt.json')])
    assert receipt['planSHA256'] == digest and receipt['closedResolverQualified'] is False
    assert receipt['status'] == 'REACHED_TIMING_SEQUENCE_CONTROLS_PASS_NOT_MEASUREMENT'
    assert not receipt.get('error') and not receipt.get('guardFailures')
    assert len(receipt['commands']) == 7 and len(receipt['guards']) == 24 and len(receipt['probes']) == 179
    for planned, actual in zip(plan['commands'], receipt['commands']):
        assert actual['label'] == planned['label'] and actual['argv'] == planned['argv']
        assert actual['argv'][:3] == ['/usr/bin/taskset', '-c', '5']
        assert actual['capSeconds'] == planned['capSeconds'] and actual['exit'] == planned.get('expectedExit', 0) and actual['failure'] is None
        for stream in ['stdout', 'stderr']:
            raw = raws[str(root / (actual['label'] + '.' + stream))]; binding = actual[stream]
            assert raw.hex() == binding['rawHex'] and sha(raw) == binding['sha256'] and len(raw) == binding['bytes']
            if not planned.get('control') and stream == 'stderr': assert raw == b''
    for binding in receipt['guards']:
        raw = raws[binding['path']]; assert sha(raw) == binding['sha256']
        guard = json.loads(raw); assert guard['unchanged'] is True
        assert guard['actualPins'] == dict(plan['pins'], **{planpath: manifest['planSHA256']})
        for path, digest in guard['stagePins'].items(): assert sha(raws[str(Path(plan['stageRoot']) / path)]) == digest
        for path, digest in guard['rawPins'].items(): assert sha(raws[str(root / path)]) == digest
    for name, digest in receipt['generated'].items(): assert sha(raws[str(root / name)]) == digest
    for path, raw in raws.items():
        if path in plan['pins']: assert sha(raw) == plan['pins'][path]
    validator = {}; exec(compile(raws[plan['qualificationValidator']], plan['qualificationValidator'], 'exec'), validator)
    for command in plan['commands']:
        if command.get('control'):
            validator['validate'](command['control'], raws[str(root / (command['label']+'.stdout'))], raws[str(root / (command['label']+'.stderr'))])
            assert receipt['cases'][command['label']]['reachedControlMatch'] is True
    return plan, receipt, raws
if __name__ == '__main__':
    _, receipt, raws = verified(); print(json.dumps({'members': len(raws), 'commands': 7, 'guards': 24, 'probes': 179, 'lossless': 'PASS', 'reachedControls': 'PASS', 'timingOrFullParity': False, 'newChildren': 0}))
