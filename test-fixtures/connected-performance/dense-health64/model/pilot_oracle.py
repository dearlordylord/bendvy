"""Dense B1 method pilot: independent complete records, never reads subject output."""
import gzip
import hashlib
import json
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "dense-motion64/model"))
from model import report
from state import derived_shared


def natural(value):
    assert isinstance(value, int) and value >= 0
    return [*map(ord, str(value)), 0]


def sized(values, encode):
    return natural(len(values)) + [cell for value in values for cell in encode(value)]


def expected_common():
    raw, world = report('Health', indexed=True)
    final, summary = derived_shared('Health', 64)
    assert final['ledger']['totals'] == world.ledger
    for row in final['rows']:
        i = row['rawId'] - 1
        assert row['main'] == {'levels': world.columns[0].values[i], 'reserve': 9, 'class': 2}
        aux = world.columns[1].values[i] if i < len(world.columns[1].values) else None
        assert row['aux'] == (None if aux is None else {'layers': aux, 'grade': 3})
        flag = world.columns[2].values[i] if i < len(world.columns[2].values) else None
        assert row['flag'] == (None if flag is None else {'group': flag})
    audits = [dict(values=values, readsum=sum(values), updated=len(values)) for values in world.audit]
    assert [a['readsum'] for a in audits] == [a['readSum'] for a in summary]
    rows = sized(final['rows'], lambda row: natural(row['rawId']) + [2, *row['main']['levels'], row['main']['reserve'], row['main']['class']]
                 + ([1] if row['aux'] is None else [2, *row['aux']['layers'], row['aux']['grade']])
                 + ([1] if row['flag'] is None else [2, row['flag']['group']]))
    audit_cells = sized(audits, lambda a: sized(a['values'], lambda x: [x]) + [a['readsum']] + natural(a['updated']))
    statuses = sized(world.statuses, lambda status: [0] if status == 'Succeeded' else (_ for _ in ()).throw(ValueError(status)))
    cells = rows + [*world.ledger, 4] + audit_cells + statuses
    fold = 0
    for cell in cells:
        fold = (fold * 33 + cell) % (2**32)
    return cells, fold, final, audits


def canonical(namespace):
    return report('Health', namespace=namespace, indexed=True)[0]


if __name__ == '__main__':
    here = Path(__file__).resolve().parent
    cells, fold, final, audits = expected_common()
    fixture = {'schema': 'Health', 'count': 64, 'iterations': 64, 'batch': 1,
               'tuple': cells, 'fold': fold, 'final': final, 'audits': audits,
               'statuses': ['Succeeded'] * len(audits), 'rawIds': [r['rawId'] for r in final['rows']]}
    compact = lambda value: json.dumps(value, separators=(',', ':'))
    common = (compact(fixture) + '\n').encode()
    assert common == (here / 'expected-common.json').read_bytes()
    full = dict(final=final, audits=audits, statuses=[{'ok': True} for _ in audits],
                worksum=sum(a['readsum'] for a in audits) % (2**32), ids=list(range(1,65)),
                finalSha256=hashlib.sha256(compact(final).encode()).hexdigest(),
                oracleSha256=hashlib.sha256(compact(final).encode()).hexdigest(),
                fullFieldsCompared=64, samples={'first':final['rows'][0], 'last':final['rows'][-1]})
    bend = []; ts = []; canonical_shapes = []
    plain_expected = [{'bytes': 88801, 'sha256': 'd897dc6238a59570f38af2d4a30e6d78117f50b238329754bc6557529b1db131'}, {'bytes': 88801, 'sha256': '6fc7d01c5a8cddea111dd2c6723f850b8768a1186c7d38fbfdff0c83d2598dce'}]
    for (label, ns), plain_pin in zip([('WARMUP', 1), ('SAMPLE', 2)], plain_expected):
        original, _ = report('Health', namespace=ns)
        assert len(original) == plain_pin['bytes'] and hashlib.sha256(original).hexdigest() == plain_pin['sha256']
        raw, world = report('Health', namespace=ns, indexed=True)
        assert b'UNSUPPORTED' not in raw and raw.count(b'Indexed{owned(') == 15
        assert all(c.metadata.capacity == 64 and c.metadata.depth == 6 and not c.metadata.exceptional for c in world.columns)
        assert [sum(x != 0 for x in c.metadata.added) for c in world.columns] == [64,22,21]
        for phase in [b'seedPending=', b'seedApplied=', b'registered=', b'final=', b'afterLogicalRead=']:
            wire = raw.split(phase, 1)[1].split(b'\n', 1)[0]
            assert wire.count(b'capacity=1;depth=0;exceptional=[]' if phase == b'seedPending=' else b'capacity=64;depth=6;exceptional=[]') == 3
        (here / f'canonical-ns{ns}.stdout.gz').write_bytes(gzip.compress(raw, mtime=0))
        canonical_shapes.append({'namespace':ns,'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest()})
        bend.append(f'{label}\nFORCE:{fold}\nTUPLE:{json.dumps(cells)}\nCANONICAL-BEGIN\n'.encode()+raw+b'CANONICAL-END\n')
        ts.append(f'{label}\nFORCE:{fold}\nTUPLE:{compact(cells)}\nFULL:{compact(full)}\n'.encode())
    assert b''.join(ts) == gzip.decompress((here/'ts-expected.stdout.gz').read_bytes())
    raw = b''.join(bend); (here/'bend-expected.stdout.gz').write_bytes(gzip.compress(raw,mtime=0))
    print(json.dumps({'tupleValues':len(cells),'fold':fold,'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),'canonical':canonical_shapes,'commonAndHistoricalTS':'BYTE_IDENTICAL'}))
