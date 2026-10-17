#!/usr/bin/env python3
"""Independent full-output oracle for the heterogeneous health consumer."""
import argparse
from decimal import Decimal
from pathlib import Path


def expected():
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


def validate(path):
    actual = path.read_bytes()
    if actual != expected():
        raise ValueError(f'{path}: complete health/service output differs')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('outputs', nargs='+', type=Path)
    args = parser.parse_args()
    for path in args.outputs:
        validate(path)
        print(f'PASS normal: {path}')


if __name__ == '__main__':
    main()
