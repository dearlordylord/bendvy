"""No-child lossless actual complete timed application qualification packet verifier."""
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
    planpath = '/tmp/bendvy63-named-loop-timing-qualification-plan-v3.json'; digest = sha(raws[planpath])
    assert digest == manifest['planSHA256'] == '58ce9622d0f755531bfec9c17c4b800265ef5d5f423ae7f8d1dc91770e90e2f0'
    plan = json.loads(raws[planpath]); root = Path(plan['outputRoot']); receipt = json.loads(raws[str(root / 'receipt.json')])
    assert receipt['planSHA256'] == digest and receipt['closedResolverQualified'] is False
    assert receipt['status'] == 'REACHED_TIMING_SEQUENCE_CONTROLS_PASS_NOT_MEASUREMENT'
    assert not receipt.get('error') and not receipt.get('guardFailures')
    assert len(receipt['commands']) == 4 and len(receipt['guards']) == 15 and len(receipt['probes']) == 92
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
    # Full output is joined byte-exact to the independently qualified original;
    # clock type/protocol checks mirror the exact archived application validator.
    for command in plan['commands']:
        if command.get('control'):
            role=command['control']; stdout=raws[str(root / (command['label']+'.stdout'))]; stderr=raws[str(root / (command['label']+'.stderr'))]
            original='/tmp/bendvy63-named-loop-qualification-v1/'+('TS.stdout' if role=='TS' else 'JS-run.stdout')
            assert stdout==raws[original]
            lines=stderr.decode().splitlines(); assert len(lines)==1; metric=json.loads(lines[0])
            assert set(metric)==({'simulationNs','transportNs'}if role=='Native'else{'simulationNs','transportNs','bytes'})
            assert all(type(metric[k])is str and metric[k].isdecimal()for k in ['simulationNs','transportNs'])
            if role!='Native':assert type(metric['bytes'])is int and metric['bytes']==len(stdout)
            assert receipt['cases'][command['label']]['reachedControlMatch'] is True
    return plan, receipt, raws
if __name__ == '__main__':
    _, receipt, raws = verified(); print(json.dumps({'members': len(raws), 'commands': 4, 'guards': 15, 'probes': 92, 'lossless': 'PASS', 'fullApplicationQualification': 'PASS', 'timingOrFullParity': False, 'newChildren': 0}))
