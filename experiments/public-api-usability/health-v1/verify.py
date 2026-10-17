#!/usr/bin/env python3
"""Finite independent arithmetic/observable failure model; no Bend imports."""
import argparse
from pathlib import Path


def validate(kind, path):
    lines = path.read_text().splitlines()
    if kind == 'foreign':
        assert lines == ['foreign-world=Rejected distinct=true cursor=0'], lines
        return
    if kind == 'controls':
        assert lines[0] == 'missing-before-effects pending=3 cursor=0', lines
        assert lines[-1] == 'failed health=10,20 cursor=0 untouched=30', lines
        lines = lines[1:-1]
    assert len(lines) == 8, lines
    assert lines[0] == 'before-barrier=' and lines[-1] == 'untouched=30', lines
    a, b = 10, 20
    for tick, line in enumerate(lines[1:-1], 1):
        a /= 2
        b /= 4
        prefix = f'tick={tick} health='
        assert line.startswith(prefix), line
        assert tuple(map(float, line[len(prefix):].split(','))) == (a, b), line


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('kind', choices=('normal', 'controls', 'foreign'))
    parser.add_argument('outputs', nargs='+', type=Path)
    args = parser.parse_args()
    for path in args.outputs:
        validate(args.kind, path)
        print(f'PASS {args.kind}: {path}')


if __name__ == '__main__':
    main()
