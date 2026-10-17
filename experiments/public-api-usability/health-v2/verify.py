#!/usr/bin/env python3
"""Independent full-output oracle for the heterogeneous health consumer."""
import argparse
from decimal import Decimal
from pathlib import Path


def expected(kind='normal'):
    if kind == 'missing':
        # Admission precedes the barrier and both registered systems.
        return b'missing=Service:1 pending=3 query-cursor=0 service-ready=false\n'
    if kind != 'normal':
        raise ValueError(f'Unknown scenario: {kind}')
    # The empty query completes before the barrier, so the service still runs.
    lines = ['before-barrier=', 'service=1']
    first, second = Decimal(10), Decimal(20)
    for tick in range(1, 7):
        first /= 2
        second /= 4
        lines.extend([
            f'tick={tick} health={first:f},{second:f}',
            f'service={tick + 1}',
        ])
    lines.append('untouched=30')
    return ('\n'.join(lines) + '\n').encode('ascii')


def validate(path, kind='normal'):
    actual = path.read_bytes()
    if actual != expected(kind):
        raise ValueError(f'{path}: complete health/service output differs')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--kind', choices=('normal', 'missing'), default='normal')
    parser.add_argument('outputs', nargs='+', type=Path)
    args = parser.parse_args()
    for path in args.outputs:
        validate(path, args.kind)
        print(f'PASS {args.kind}: {path}')


if __name__ == '__main__':
    main()
