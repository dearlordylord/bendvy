"""No-child lossless actual ordinary delivery packet verifier."""
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
    planpath = '/tmp/bendvy63-named-loop-qualification-plan-v2.json'; digest = sha(raws[planpath])
    assert digest == manifest['planSHA256'] == '4a4367b17e3bffff1cea4e3f53181eaa7607fdc91d604234f316e8423e10873b'
    plan = json.loads(raws[planpath]); root = Path(plan['outputRoot']); receipt = json.loads(raws[str(root / 'receipt.json')])
    assert receipt['planSHA256'] == digest and receipt['closedResolverQualified'] is False
    assert receipt['status'] == 'RELOCATED_SIMULATION_SEMANTIC_DELIVERY_PASS_NOT_TIMING_OR_FULL_PARITY'
    assert not receipt.get('error') and not receipt.get('guardFailures')
    assert len(receipt['commands']) == 7 and len(receipt['guards']) == 24 and len(receipt['probes']) == 140
    for planned, actual in zip(plan['commands'], receipt['commands']):
        assert actual['label'] == planned['label'] and actual['argv'] == planned['argv']
        assert actual['argv'][:3] == ['/usr/bin/taskset', '-c', '5']
        assert actual['capSeconds'] == planned['capSeconds'] and actual['exit'] == 0 and actual['failure'] is None
        for stream in ['stdout', 'stderr']:
            raw = raws[str(root / (actual['label'] + '.' + stream))]; binding = actual[stream]
            assert raw.hex() == binding['rawHex'] and sha(raw) == binding['sha256'] and len(raw) == binding['bytes']
            if stream == 'stderr': assert raw == b''
    for binding in receipt['guards']:
        raw = raws[binding['path']]; assert sha(raw) == binding['sha256']
        guard = json.loads(raw); assert guard['unchanged'] is True
        assert guard['actualPins'] == dict(plan['pins'], **{planpath: manifest['planSHA256']})
        for path, digest in guard['stagePins'].items(): assert sha(raws[str(Path(plan['stageRoot']) / path)]) == digest
        for path, digest in guard['rawPins'].items(): assert sha(raws[str(root / path)]) == digest
    for name, digest in receipt['generated'].items(): assert sha(raws[str(root / name)]) == digest
    for path, raw in raws.items():
        if path in plan['pins']: assert sha(raw) == plan['pins'][path]
    assert receipt['cases']['JS-run']['stdoutSHA256'] == receipt['cases']['Native-run']['stdoutSHA256']
    for label in ['TS', 'JS-run', 'Native-run']: assert receipt['cases'][label]['completeMatch'] is True
    assert raws[str(root/'JS-run.stdout')]==raws[str(root/'Native-run.stdout')] and sha(raws[str(root/'JS-run.stdout')])=='4473bc5dbab2005bc4ae7d9cdce86ead92f498f488cfc728840e6f7e786af1ca'
    assert receipt['cases']['JS-run']['fullOracleSHA256']==receipt['cases']['Native-run']['fullOracleSHA256']==plan['oracleSHA256']=='f821c68264eb25c33a674841d0f2abcf466a9d6372e888cfc40b7ae691ae071a'
    return plan, receipt, raws
if __name__ == '__main__':
    _, receipt, raws = verified(); print(json.dumps({'members': len(raws), 'commands': 7, 'guards': 24, 'probes': 140, 'lossless': 'PASS', 'ordinarySemanticDelivery': 'PASS', 'timingOrFullParity': False, 'newChildren': 0}))
