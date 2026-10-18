"""Seal complete Readers source-model gold; no subject execution or output input."""
from pathlib import Path
import argparse
import gzip
import hashlib
import json
import common_model as C
from ts_model import evaluate

SOURCE = Path(__file__).parent
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def derive(count, iterations):
    records, ts_full = evaluate(count, iterations)
    worlds, canon = [], []
    original = C.O.Program
    C.O.Program = C.Observer
    try:
        for label, namespace in [('WARMUP', 1), ('SAMPLE', 2)]:
            raw, program = C.O.report(count, iterations, namespace)
            actual = program.completed()
            assert actual == records
            assert (len(program.locals), len(program.logs), len(program.reads), len(program.actor_map)) == (192, 194, 84, count + iterations)
            assert program.actor_keys[count] == C.O.Handle(namespace, C.O.Key(count + 1, 0))
            assert program.actor_keys[-1] == C.O.Handle(namespace, C.O.Key(count + 1, iterations - 1))
            cells = C.tuple_records(actual)
            worlds.append(dict(label=label, namespace=namespace, records=actual,
                               rawActorMap=program.actor_map_raw(), tuple=cells, fold=C.fold(cells),
                               canonical=dict(bytes=len(raw), sha256=sha(raw)),
                               counts=dict(reads=len(program.method_reads), stages=len(program.method_stages),
                                           localCalls=len(program.locals), txFacts=1 + len(program.locals))))
            canon.append(raw)
    finally:
        C.O.Program = original
    assert worlds[0]['tuple'] == worlds[1]['tuple']
    assert all(len(w['records']) == 280 for w in worlds)
    streams = {}
    for role in ['bend', 'ts']:
        pieces = []
        for world, raw in zip(worlds, canon):
            cells = (json.dumps(world['tuple']) if role == 'bend' else C.compact(world['tuple'])).encode()
            actors = world['rawActorMap'] if role == 'bend' else ts_full['method']['rawActorMap']
            pieces += [(world['label'] + '\nFORCE:' + str(world['fold']) + '\nTUPLE:').encode(),
                       cells, ('\nACTORS:' + C.compact(actors) + '\n').encode()]
            if role == 'bend':
                pieces += [b'CANONICAL-BEGIN\n', raw, b'CANONICAL-END\n']
            else:
                pieces += [b'FULL:', C.compact(ts_full).encode(), b'\n']
        streams[role] = b''.join(pieces)
    return worlds, canon, streams


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--count', type=int, choices=[64, 256, 1024], default=64)
    parser.add_argument('--iterations', type=int, choices=[64], default=64)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    assert not args.output.exists(), 'Use a fresh directory; frozen gold is immutable'
    basis = json.loads((SOURCE / 'SOURCE-BASIS.json').read_text())
    for group in ['sourcePins', 'reusedSourcePins']:
        for name, digest in basis[group].items():
            assert sha((SOURCE / name).read_bytes()) == digest
    qualified, _ = C.O.report(64, 64, 1)
    q = basis['qualifiedCanonical']
    assert (len(qualified), sha(qualified)) == (q['bytes'], q['sha256'])
    # Complete role hashes contain the entire scalar tuple, not merely its fold.
    old = json.loads((SOURCE / 'EXPECTED.json').read_text())
    control_worlds, control_canon, control_streams = derive(64, 64)
    assert control_canon[0] == qualified
    for world, expected in zip(control_worlds, old['worlds']):
        assert world['canonical'] == expected['canonical']
        assert (len(world['tuple']), world['fold']) == (expected['tupleValues'], expected['fold'])
    for role, raw in control_streams.items():
        assert (len(raw), sha(raw)) == (old['oracles'][role]['bytes'], old['oracles'][role]['sha256'])
    worlds, canon, streams = ((control_worlds, control_canon, control_streams) if args.count == 64
                              else derive(args.count, args.iterations))
    if str(args.count) in basis['widerCanonicalControls']:
        q = basis['widerCanonicalControls'][str(args.count)]
        assert (len(canon[0]), sha(canon[0])) == (q['bytes'], q['sha256'])
    args.output.mkdir(parents=True)
    (args.output / 'canonical-control.stdout.gz').write_bytes(gzip.compress(qualified, mtime=0))
    for namespace, raw in enumerate(canon, 1):
        (args.output / f'canonical-ns{namespace}.stdout.gz').write_bytes(gzip.compress(raw, mtime=0))
    (args.output / 'observer-fixtures.json.gz').write_bytes(gzip.compress(C.compact(worlds).encode(), mtime=0))
    common = C.compact(dict(tuple=worlds[0]['tuple'], fold=worlds[0]['fold'])).encode()
    (args.output / 'expected-common.json.gz').write_bytes(gzip.compress(common, mtime=0))
    outputs = {}
    for role, raw in streams.items():
        (args.output / f'{role}-expected.stdout').write_bytes(raw)
        packed = gzip.compress(raw, mtime=0)
        (args.output / f'{role}-expected.stdout.gz').write_bytes(packed)
        outputs[role] = dict(bytes=len(raw), sha256=sha(raw), gzipBytes=len(packed), gzipSHA256=sha(packed))
    result = dict(status='PASS', count=args.count, iterations=args.iterations,
                  scope='Independent complete Readers source model only; no subject, timing or TS private cursor claim.',
                  reproduced64='EXACT_FULL_ROLE_CANONICAL_AND_COMMON_CARRIER',
                  sourceBasisSHA256=sha((SOURCE / 'SOURCE-BASIS.json').read_bytes()),
                  canonicalControl=dict(bytes=len(qualified), sha256=sha(qualified)),
                  worlds=[{k: v for k, v in w.items() if k not in ['records', 'rawActorMap', 'tuple']} |
                          dict(records=len(w['records']), tupleValues=len(w['tuple']), actors=len(w['rawActorMap'])) for w in worlds],
                  oracles=outputs, modelPins={n: sha((SOURCE / n).read_bytes()) for n in
                      ['operation_model.py', 'common_model.py', 'ts_model.py', 'seal_gold.py', 'physical.py']})
    (args.output / 'PILOT-ORACLE-BASIS.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
