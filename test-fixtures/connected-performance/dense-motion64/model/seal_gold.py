"""Seal complete source-derived Dense streams into a fresh output directory."""
import argparse
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path

from model import report


def compact(value):
    return json.dumps(value, separators=(',', ':'))


def oracle(schema):
    path = Path(__file__).resolve().parents[2] / f'dense-{schema.lower()}64/model/pilot_oracle.py'
    spec = importlib.util.spec_from_file_location('dense_' + schema, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module, path.parent


def streams(schema, count, iterations):
    module, _ = oracle(schema)
    cells, fold, final, audits = module.expected_common(count, iterations)
    fixture = dict(schema=schema, count=count, iterations=iterations, batch=1,
                   tuple=cells, fold=fold, final=final, audits=audits,
                   statuses=['Succeeded'] * len(audits), rawIds=[r['rawId'] for r in final['rows']])
    final_hash = hashlib.sha256(compact(final).encode()).hexdigest()
    full = dict(final=final, audits=audits, statuses=[{'ok': True} for _ in audits],
                worksum=sum(a['readsum'] for a in audits) % (2**32), ids=list(range(1, count + 1)),
                finalSha256=final_hash, oracleSha256=final_hash, fullFieldsCompared=count,
                samples={'first': final['rows'][0], 'last': final['rows'][-1]})
    bend, ts, phases = [], [], []
    for label, namespace in [('WARMUP', 1), ('SAMPLE', 2)]:
        canonical, world = report(schema, count, iterations, namespace=namespace, indexed=True)
        capacity = 1 << (count - 1).bit_length()
        depth = capacity.bit_length() - 1
        assert all(c.metadata.capacity == capacity and c.metadata.depth == depth
                   and not c.metadata.exceptional for c in world.columns)
        assert [sum(v != 0 for v in c.metadata.added) for c in world.columns] == [count, (count + 2) // 3, (count + 1) // 3]
        for phase in [b'seedPending=', b'seedApplied=', b'registered=', b'final=', b'afterLogicalRead=']:
            line = canonical.split(phase, 1)[1].split(b'\n', 1)[0]
            expected = (b'capacity=1;depth=0;exceptional=[]' if phase == b'seedPending='
                        else f'capacity={capacity};depth={depth};exceptional=[]'.encode())
            assert line.count(expected) == 3
        phases.append(dict(namespace=namespace, bytes=len(canonical), sha256=hashlib.sha256(canonical).hexdigest()))
        bend.append(f'{label}\nFORCE:{fold}\nTUPLE:{json.dumps(cells)}\nCANONICAL-BEGIN\n'.encode() + canonical + b'CANONICAL-END\n')
        ts.append(f'{label}\nFORCE:{fold}\nTUPLE:{compact(cells)}\nFULL:{compact(full)}\n'.encode())
    return {'bend-expected.stdout.gz': b''.join(bend), 'ts-expected.stdout.gz': b''.join(ts),
            'expected-common.json': (compact(fixture) + '\n').encode()}, phases


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--schema', choices=['Motion', 'Health'], required=True)
    parser.add_argument('--count', choices=[64, 256, 1024], type=int, default=64)
    parser.add_argument('--iterations', choices=[64], type=int, default=64)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    # Reproduce all complete qualified 64-case bytes before extrapolation.
    original, _ = streams(args.schema, 64, 64)
    _, basis = oracle(args.schema)
    for name, raw in original.items():
        retained = (basis / name).read_bytes()
        assert raw == (gzip.decompress(retained) if name.endswith('.gz') else retained), name
    assert not args.output.exists(), 'output directory must be fresh'
    raw_files, phases = streams(args.schema, args.count, args.iterations)
    args.output.mkdir(parents=True)
    results = {}
    for name, raw in raw_files.items():
        (args.output / name).write_bytes(gzip.compress(raw, mtime=0) if name.endswith('.gz') else raw)
        results[name] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())
    source_root = Path(__file__).resolve().parent
    source_pins = {str(p.relative_to(source_root.parents[2])): hashlib.sha256(p.read_bytes()).hexdigest()
                   for directory in [source_root, basis] for p in sorted(directory.glob('*.py'))}
    receipt = dict(schema=args.schema, count=args.count, iterations=args.iterations,
                   origin='independent source model; no subject output', reproduced64='BYTE_IDENTICAL',
                   outputs=results, canonical=phases, sourcePins=source_pins)
    (args.output / 'PILOT-ORACLE-BASIS.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps(receipt))


if __name__ == '__main__':
    main()
