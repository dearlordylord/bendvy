"""Seal complete Sparse source-model streams; never inspect subject output."""
import argparse
import gzip
import hashlib
import importlib.util
import json
import sys
from pathlib import Path


def compact(value):
    return json.dumps(value, separators=(',', ':'))


def oracle(schema):
    path = Path(__file__).resolve().parents[2] / f'sparse-{schema.lower()}64/model/pilot_oracle.py'
    sys.path.insert(0, str(path.parent))
    spec = importlib.util.spec_from_file_location('sparse_' + schema, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module, path.parent


def streams(schema, count, iterations):
    module, _ = oracle(schema)
    cells, fold, final, audits, cumulative = module.expected(count, iterations)
    fixture = dict(tuple=cells, fold=fold, final=final, audits=audits, cumulative=cumulative)
    final_hash = hashlib.sha256(compact(final).encode()).hexdigest()
    full = dict(final=final, audits=audits, statuses=[{'ok': True} for _ in audits],
                worksum=cumulative, ids=list(range(1, count + 1)), finalSha256=final_hash,
                oracleSha256=final_hash, fullFieldsCompared=len(final['rows']),
                samples={'first': final['rows'][0], 'last': final['rows'][-1]})
    bend, ts, phases = [], [], []
    for label, namespace in [('WARMUP', 1), ('SAMPLE', 2)]:
        canonical, world = module.report(count, iterations, namespace=namespace)
        assert b'UNSUPPORTED' not in canonical and canonical.count(b'Column{values=') == 15
        for phase in [b'seedPending=', b'seedApplied=', b'registered=', b'final=', b'afterLogicalRead=']:
            assert canonical.split(phase, 1)[1].split(b'\n', 1)[0].count(b'Column{values=') == 3
        assert len(world.audit) == iterations and len(world.scan_audits) == iterations
        # Each original scan re-ranks its actual included rows. The only role
        # correspondence is the reversible namespace term, never a row sort.
        delta_total = 0
        for audit in audits:
            delta = sum(weight * (namespace - 1) * len(audit['scans'][name]['included'])
                        * (len(audit['scans'][name]['included']) + 1) // 2
                        for weight, name in [(1, 'all'), (3, 'present'), (5, 'absent')])
            delta_total = (delta_total + delta) & module.MASK
        assert (world.cumulative - delta_total) & module.MASK == cumulative
        assert final['ledger']['totals'][0] == len(final['rows']) * iterations
        fields = 'coordinates' if schema == 'Motion' else 'levels'
        assert [r['main'][fields] for r in final['rows']] == [world.columns[0].values[i - 1] for i in world.row_entities()]
        if namespace == 1 and count != 64:
            controls = json.loads((Path(__file__).parent / 'COUNT-CANONICAL-CONTROLS.json').read_text())
            expected = controls[schema][str(count)]
            assert (len(canonical), hashlib.sha256(canonical).hexdigest()) == (expected['bytes'], expected['sha256'])
        phases.append(dict(namespace=namespace, bytes=len(canonical), sha256=hashlib.sha256(canonical).hexdigest()))
        bend.append(f'{label}\nFORCE:{fold}\nTUPLE:{json.dumps(cells)}\nCANONICAL-BEGIN\n'.encode() + canonical + b'CANONICAL-END\n')
        ts.append(f'{label}\nFORCE:{fold}\nTUPLE:{compact(cells)}\nFULL:{compact(full)}\n'.encode())
    return {'bend-expected.stdout.gz': b''.join(bend), 'ts-expected.stdout.gz': b''.join(ts),
            'expected-common.json': (compact(fixture) + '\n').encode()}, phases, len(cells), fold


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--schema', choices=['Motion', 'Health'], required=True)
    parser.add_argument('--count', choices=[64, 256, 1024], type=int, default=64)
    parser.add_argument('--iterations', choices=[64], type=int, default=64)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    original, _, _, _ = streams(args.schema, 64, 64)
    _, basis = oracle(args.schema)
    for name, raw in original.items():
        retained = (basis / name).read_bytes()
        assert raw == (gzip.decompress(retained) if name.endswith('.gz') else retained), name
    assert not args.output.exists(), 'output directory must be fresh'
    files, phases, values, fold = streams(args.schema, args.count, args.iterations)
    args.output.mkdir(parents=True)
    outputs = {}
    for name, raw in files.items():
        (args.output / name).write_bytes(gzip.compress(raw, mtime=0) if name.endswith('.gz') else raw)
        outputs[name] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())
    source = Path(__file__).resolve().parent
    pins = {str(p.relative_to(source.parents[2])): hashlib.sha256(p.read_bytes()).hexdigest()
            for directory in [source, basis] for p in sorted(directory.glob('*.py'))}
    result = dict(schema=args.schema, count=args.count, iterations=args.iterations,
                  origin='independent source model; no subject output', reproduced64='BYTE_IDENTICAL',
                  outputs=outputs, canonical=phases, tupleValues=values, fold=fold, sourcePins=pins,
                  namespaceCorrespondence='RawScore=logicalScore+(namespace-1)*sum(included ranks) modulo2^32; weighted1/3/5, cumulative preserves each prior delta.',
                  snapshotCorrespondence='Original TS optional snapshot reused with no intervening writes; original Bend three fresh scans/postfilters retained. Different strategies, complete shared observations.')
    (args.output / 'PILOT-ORACLE-BASIS.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
