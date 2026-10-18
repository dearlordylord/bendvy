"""Dense B1 method pilot: independent complete records, never reads subject output."""
import gzip
import hashlib
import json
from pathlib import Path
from model import report
from state import derived_shared


def natural(value):
    assert isinstance(value, int) and value >= 0
    return [*map(ord, str(value)), 0]


def sized(values, encode):
    return natural(len(values)) + [cell for value in values for cell in encode(value)]


def expected_common():
    raw, world = report('Motion')
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


def canonical(namespace):
    return report('Motion', namespace=namespace)[0]


if __name__ == '__main__':
    cells, fold, final, audits = expected_common()
    here = Path(__file__).resolve().parent
    fixture = {'schema': 'Motion', 'count': 64, 'iterations': 64, 'batch': 1,
               'tuple': cells, 'fold': fold, 'final': final, 'audits': audits,
               'statuses': ['Succeeded'] * len(audits), 'rawIds': [r['rawId'] for r in final['rows']]}
    (here / 'expected-common.json').write_text(json.dumps(fixture, separators=(',', ':')) + '\n')
    for ns in [1, 2]:
        raw = canonical(ns)
        (here / f'canonical-ns{ns}.stdout.gz').write_bytes(gzip.compress(raw, mtime=0))
    print(json.dumps({'tupleValues': len(cells), 'fold': fold,
                      'canonical': [{'namespace': ns, 'bytes': len(canonical(ns)), 'sha256': hashlib.sha256(canonical(ns)).hexdigest()} for ns in [1, 2]]}))
