"""Independent typed-field token derivation from qualified model data, never subjects."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path

MASK = 2**32 - 1
MAX_NAT = 2**48 - 1
VERSION = b'TYPED-OBSERVATION:v1:codec-fields\n'

def natural(n, typed=True):
    assert type(n) is int and 0 <= n <= MAX_NAT
    if not typed:
        return [*map(ord, str(n)), 0]
    out = []
    while True:
        out.append(n & MASK)
        n >>= 32
        if not n:
            return out + [MASK]

def mix(acc, value):
    return (acc * 33 + value) & MASK

def fold(values, acc=0):
    for value in values:
        assert type(value) is int and 0 <= value <= MASK
        acc = mix(acc, value)
    return acc

def sized(values, encode, typed):
    return natural(len(values), typed) + [cell for item in values for cell in encode(item)]

def cells(fixture, typed):
    def row(r):
        return natural(r['rawId'], typed) + [2, *r['main']['coordinates'], r['main']['frame']] + ([1] if r['aux'] is None else [2, *r['aux']['rates'], int(r['aux']['moving'])]) + ([1] if r['flag'] is None else [2, r['flag']['group']])
    def audit(a):
        return sized(a['values'], lambda x: [x], typed) + [a['readsum']] + natural(a['updated'], typed)
    assert set(fixture['statuses']) == {'Succeeded'}
    final = fixture['final']
    return sized(final['rows'], row, typed) + final['ledger']['totals'] + [final['ledger']['epoch']] + sized(fixture['audits'], audit, typed) + sized(fixture['statuses'], lambda _: [0], typed)

def typed_error(value, acc=0):
    if value is None:
        return mix(acc, 0)
    if type(value) is bool:
        return mix(mix(acc, 1), int(value))
    if type(value) is int:
        return fold(natural(value), mix(acc, 2))
    def text(s, a):
        return fold([*natural(len(s)), *map(ord, s)], a)
    if type(value) is str:
        return text(value, mix(acc, 3))
    if type(value) is list:
        acc = fold(natural(len(value)), mix(acc, 4))
        for child in value:
            acc = typed_error(child, acc)
        return acc
    assert type(value) is dict
    acc = fold(natural(len(value)), mix(acc, 5))
    for key, child in value.items():
        acc = typed_error(child, text(key, acc))
    return acc

def controls():
    numbers = [fold(natural(n)) for n in [0, MASK, 2**32, MAX_NAT]]
    bend = dict(nat=numbers, order=[fold([*natural(2), 1, 2]), fold([*natural(2), 2, 1])], owner=[[1, 2, 3, 4, 7], [1, 2, 3, 4, 7], 1, [9, 2, 3, 4, 7]])
    fixture = dict(final=dict(rows=[dict(rawId=1, main=dict(coordinates=[1, 2, 3, 4], frame=7), aux=None, flag=None)], ledger=dict(totals=[0, 101, 102, 103], epoch=4)), audits=[dict(values=[10], readsum=10, updated=1)], statuses=['Succeeded'])
    error = lambda code: typed_error(dict(kind='SystemFailure', system='Update', error=dict(code=code, details=[1, 2])), mix(0, 3))
    js = dict(nat=numbers, snapshot=fold(cells(fixture, True)), error=[error(7), error(8)])
    assert bend['order'][0] != bend['order'][1] and js['error'][0] != js['error'][1]
    return bend, js

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    bend_control, js_control = controls()
    if args.output is None:
        print(json.dumps(dict(bend=bend_control, js=js_control), separators=(',', ':')))
        return
    base = Path(__file__).resolve().parents[2]
    expected = json.loads((base / 'model/COUNT-EXPECTED.json').read_text())['256']
    sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
    for name, digest in expected['sourcePins'].items():
        assert sha(base.parent / name.removeprefix('connected-performance/')) == digest, name
    gold = Path('/tmp/bendvy21-dense-motion-count256-independent-gold01')
    fixture_path = gold / 'expected-common.json'
    fixture_raw = fixture_path.read_bytes()
    assert hashlib.sha256(fixture_raw).hexdigest() == expected['outputs']['expected-common.json']['sha256']
    fixture = json.loads(fixture_raw)
    assert fixture['count'] == 256 and fixture['iterations'] == 64
    assert cells(fixture, False) == fixture['tuple'] and fold(fixture['tuple']) == fixture['fold']
    token = fold(cells(fixture, True))
    assert not args.output.exists(), 'fresh output required'
    args.output.mkdir()
    outputs = {}
    for role in ['bend', 'ts']:
        source = gold / (role + '-expected.stdout.gz')
        raw = gzip.decompress(source.read_bytes())
        authority = expected['outputs'][role + '-expected.stdout.gz']
        assert len(raw) == authority['bytes'] and hashlib.sha256(raw).hexdigest() == authority['sha256']
        lines = raw.splitlines(keepends=True)
        assert sum(line.startswith(b'FORCE:') for line in lines) == 2
        target = VERSION + b''.join((b'FORCE:' + str(token).encode() + b'\n') if line.startswith(b'FORCE:') else line for line in lines)
        out = args.output / source.name
        out.write_bytes(gzip.compress(target, mtime=0))
        outputs[role] = dict(path=str(out), bytes=len(target), sha256=hashlib.sha256(target).hexdigest(), gzipSHA256=sha(out), original=dict(path=str(source), bytes=len(raw), sha256=authority['sha256'], gzipSHA256=sha(source)))
    for name, value in [('controls.expected.stdout', bend_control), ('controls-js.expected.stdout', js_control)]:
        (args.output / name).write_text(json.dumps(value, separators=(',', ':')) + '\n')
    receipt = dict(status='PASS_INDEPENDENT_TYPED_FIELD_GOLD', schema='Motion', count=256, iterations=64, token=token, oldTupleValues=len(fixture['tuple']), typedFieldCells=len(cells(fixture, True)), unchangedOriginalTuple='COMPLETE_BYTE_VALUE_EQUALITY', originalCommon=dict(path=str(fixture_path), sha256=sha(fixture_path)), modelSHA256=sha(__file__), countBasisSHA256=sha(base / 'model/COUNT-EXPECTED.json'), outputs=outputs, controlSource='literal independent arithmetic; no candidate output')
    (args.output / 'MODEL-RECEIPT.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps(receipt))

if __name__ == '__main__':
    main()
