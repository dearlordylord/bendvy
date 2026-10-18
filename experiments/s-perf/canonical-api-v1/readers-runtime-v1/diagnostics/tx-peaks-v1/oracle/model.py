"""Finite source-derived Readers metric oracle; never reads subject outputs."""
import argparse
import json
from pathlib import Path


def samples(count, iterations=64):
    # Independent model.py transaction_fact(3/count, 0/spawn, 1/update, 2/dispose).
    domain = [dict(kind='seed', undo=count, commands=count, events=0)]
    for _ in range(iterations):
        domain.extend([dict(kind='spawn', undo=1, commands=1, events=0),
                       dict(kind='update', undo=1, commands=0, events=1),
                       dict(kind='dispose', undo=0, commands=2, events=0)])
    # Prime + Drain each invoke Fast and Slow. Update invokes Fast every loop,
    # and Slow when iteration % 4 == 3. Actual callback Unit grant mutates no Tx.
    readers = [dict(kind='reader', undo=0, commands=0, events=0)
               for _ in range(4 + iterations + iterations // 4)]
    return domain + readers


def expected(count, iterations=64, counter=False):
    values = samples(count, iterations)
    if counter:
        values = [dict(value, undo=0) for value in values]
    return (json.dumps(dict(samples=values), separators=(',', ':')) + '\n').encode()


def summary(count, iterations=64):
    values = samples(count, iterations)
    return dict(count=count, iterations=iterations, samples=len(values),
                domainSamples=1 + 3 * iterations,
                readerCallbackSamples=4 + iterations + iterations // 4,
                maxima={key: max(value[key] for value in values)
                        for key in ['undo', 'commands', 'events']},
                nonzeroUndo=sum(value['undo'] != 0 for value in values))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--count', type=int, required=True)
    parser.add_argument('--iterations', type=int, default=64)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--counter', action='store_true')
    args = parser.parse_args()
    assert args.count in [64, 256, 1024] and args.iterations == 64
    assert not args.output.exists()
    args.output.write_bytes(expected(args.count, args.iterations, args.counter))
    print(json.dumps(summary(args.count, args.iterations), sort_keys=True))
