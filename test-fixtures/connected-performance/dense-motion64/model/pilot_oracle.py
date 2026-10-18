"""Dense B1 method pilot: independent complete records, never reads subject output."""
import gzip
import hashlib
import json
from pathlib import Path
from model import report
from state import derived_shared, IndexedMetadata, IndexedColumn


def natural(value):
    assert isinstance(value, int) and value >= 0
    return [*map(ord, str(value)), 0]


def sized(values, encode):
    return natural(len(values)) + [cell for value in values for cell in encode(value)]


def expected_common():
    raw, world = report('Motion', indexed=True)
    final, summary = derived_shared('Motion', 64)
    assert final['ledger']['totals'] == world.ledger
    audits = [dict(values=values, readsum=sum(values), updated=len(values)) for values in world.audit]
    assert [a['readsum'] for a in audits] == [a['readSum'] for a in summary]
    rows = sized(final['rows'], lambda row: natural(row['rawId']) + [2, *row['main']['coordinates'], row['main']['frame']]
                 + ([1] if row['aux'] is None else [2, *row['aux']['rates'], int(row['aux']['moving'])])
                 + ([1] if row['flag'] is None else [2, row['flag']['group']]))
    audit_cells = sized(audits, lambda a: sized(a['values'], lambda x: [x]) + [a['readsum']] + natural(a['updated']))
    statuses = sized(world.statuses, lambda status: [0] if status == 'Succeeded' else (_ for _ in ()).throw(ValueError(status)))
    cells = rows + [*world.ledger, 4] + audit_cells + statuses
    fold = 0
    for cell in cells:
        fold = (fold * 33 + cell) % (2**32)
    return cells, fold, final, audits


def canonical(namespace, indexed=True):
    return report('Motion', namespace=namespace, indexed=indexed)[0]


def complete_stream(indexed):
    cells, fold, _, _ = expected_common()
    tuple_text = '[' + ', '.join(map(str, cells)) + ']'
    result = bytearray()
    for label, namespace in [('WARMUP', 1), ('SAMPLE', 2)]:
        result += f'{label}\nFORCE:{fold}\nTUPLE:{tuple_text}\nCANONICAL-BEGIN\n'.encode()
        result += canonical(namespace, indexed)
        result += b'CANONICAL-END\n'
    return bytes(result)


def check_indexed_state():
    metadata = IndexedMetadata()
    assert metadata.show() == 'added=leaf:0;changed=leaf:0;capacity=1;depth=0;exceptional=[]'
    assert metadata.get(64) == (0, 0)
    metadata.clear(64)
    assert metadata.capacity == 1
    metadata.set(4, (0, 9))
    assert metadata.capacity == 4 and metadata.depth == 2
    assert metadata.added == [0, 0, 0, 0] and metadata.changed == [0, 0, 0, 9]
    metadata.clear(4)
    assert metadata.capacity == 4 and metadata.changed == [0, 0, 0, 0]
    metadata.set(0, (0, 0))
    assert metadata.exceptional == [(0, (0, 0))] and metadata.show().endswith("exceptional=[0:0:0]")
    metadata.set(131073, (0, 7))
    metadata.set(0, (3, 0))
    assert metadata.exceptional == [(0, (3, 0)), (131073, (0, 7))]
    assert metadata.capacity == 4 and metadata.get(131073) == (0, 7)
    metadata.clear(0)
    assert metadata.exceptional == [(131073, (0, 7))]
    metadata.set(131072, (5, 6))
    assert metadata.capacity == 131072 and metadata.depth == 17
    assert metadata.get(131072) == (5, 6) and metadata.get(131071) == (0, 0)
    column = IndexedColumn(values=[None] * 8)
    assert len(column.values) == 8 and column.metadata.capacity == 1
    column.write(2, [1, 2, 3, 4], 10)
    column.write(2, [2, 2, 3, 4], 11)
    assert column.metadata.get(2) == (10, 11)
    assert len(column.values) == 8 and column.metadata.capacity == 2
    for namespace in [1, 2]:
        raw, final = report('Motion', namespace=namespace, indexed=True)
        assert b'UNSUPPORTED' not in raw and raw.count(b'Indexed{owned(') == 15
        assert all(c.metadata.capacity == 64 and c.metadata.depth == 6 and not c.metadata.exceptional for c in final.columns)
        assert [sum(v != 0 for v in c.metadata.added) for c in final.columns] == [64, 22, 21]
        for c in final.columns:
            assert all(c.metadata.get(entity) == stamp for entity, stamp in c.stamps.items())
        assert raw.split(b'seedPending=', 1)[1].split(b'\n', 1)[0].count(b'capacity=1;depth=0;exceptional=[]') == 3
        for phase in [b'seedApplied=', b'registered=', b'final=', b'afterLogicalRead=']:
            assert raw.split(phase, 1)[1].split(b'\n', 1)[0].count(b'capacity=64;depth=6;exceptional=[]') == 3


if __name__ == '__main__':
    here = Path(__file__).resolve().parent
    check_indexed_state()
    # Reproduce the qualified Plain stream before sealing its Indexed successor.
    plain = complete_stream(False)
    assert len(plain) == 226988 and hashlib.sha256(plain).hexdigest() == '0375eec332d8509226d2eafd8b5d48ac592f38caf6f89c30f449b9599d1a2ebf'
    cells, fold, final, audits = expected_common()
    fixture = {'schema': 'Motion', 'count': 64, 'iterations': 64, 'batch': 1,
               'tuple': cells, 'fold': fold, 'final': final, 'audits': audits,
               'statuses': ['Succeeded'] * len(audits), 'rawIds': [r['rawId'] for r in final['rows']]}
    common = (json.dumps(fixture, separators=(',', ':')) + '\n').encode()
    assert common == (here / 'expected-common.json').read_bytes()
    assert len(cells) == 5448 and fold == 709905077
    assert hashlib.sha256(common).hexdigest() == '6c0335274e9ef25a8bdbdf5ff53af3c67abe03c27303855be61507008088e43f'
    ts = here / 'ts-expected.stdout.gz'
    assert hashlib.sha256(ts.read_bytes()).hexdigest() == '0fb7fe3ae36df0bb62dc37a841ac914bba718b9bb83d7e3be6f4e55b86e1fd7b'
    raw = complete_stream(True)
    (here / 'bend-expected.stdout.gz').write_bytes(gzip.compress(raw, mtime=0))
    print(json.dumps({'tupleValues': len(cells), 'fold': fold, 'plainReproducedBytes': len(plain),
                      'indexedBytes': len(raw), 'indexedSHA256': hashlib.sha256(raw).hexdigest(),
                      'commonAndTS': 'BYTE_IDENTICAL', 'finiteGrowthBoundsAndAllFivePhases': 'PASS'}))
