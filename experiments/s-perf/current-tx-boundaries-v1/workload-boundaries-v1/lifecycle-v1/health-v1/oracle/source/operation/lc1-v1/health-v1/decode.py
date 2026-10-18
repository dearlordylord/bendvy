"""Strict offline actual/expected LC1 expansion; never part of the consumer cap."""
import argparse
import gzip
from pathlib import Path
import sys
from codec import decode_report
from verbose import report


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input', type=Path)
    parser.add_argument('--gzip-input', action='store_true')
    parser.add_argument('--output', type=Path)
    parser.add_argument('--verify-old', type=Path)
    parser.add_argument('--gzip-old', action='store_true')
    args = parser.parse_args()
    raw = args.input.read_bytes()
    if args.gzip_input:
        raw = gzip.decompress(raw)
    expanded = report(decode_report(raw))
    if args.verify_old:
        previous = args.verify_old.read_bytes()
        if args.gzip_old:
            previous = gzip.decompress(previous)
        if expanded != previous:
            raise ValueError('complete expanded observation differs from immutable old oracle')
    if args.output:
        args.output.write_bytes(expanded)
    elif not args.verify_old:
        sys.stdout.buffer.write(expanded)


if __name__ == '__main__':
    main()
