"""Strict LC2 to complete LC1/verbose bytes, outside the consumer cap."""
import argparse
import gzip
from pathlib import Path
from codec import decode_report, LC1
from legacy import VERBOSE


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input', type=Path)
    parser.add_argument('--gzip-input', action='store_true')
    parser.add_argument('--verify-lc1', type=Path)
    parser.add_argument('--verify-verbose', type=Path)
    parser.add_argument('--gzip-expectations', action='store_true')
    parser.add_argument('--output-lc1', type=Path)
    parser.add_argument('--output-verbose', type=Path)
    args = parser.parse_args()
    raw = args.input.read_bytes()
    if args.gzip_input:
        raw = gzip.decompress(raw)
    value = decode_report(raw)
    lc1, verbose = LC1.encode_report(value), VERBOSE.report(value)
    for expected, actual in [(args.verify_lc1, lc1), (args.verify_verbose, verbose)]:
        if expected:
            previous = expected.read_bytes()
            if args.gzip_expectations:
                previous = gzip.decompress(previous)
            if actual != previous:
                raise ValueError('complete LC2 expansion differs from immutable prior oracle')
    if args.output_lc1:
        args.output_lc1.write_bytes(lc1)
    if args.output_verbose:
        args.output_verbose.write_bytes(verbose)


if __name__ == '__main__':
    main()
