"""Check explicit whole-scene expectations and intended negative evidence."""
import argparse
import json
from pathlib import Path


def scenes(actual, expected):
    # Expected DTOs are independently authored, not extracted from runtime output.
    if not expected or set(actual) != set(expected):
        raise ValueError('complete scenario membership differs')
    for name in expected:
        if actual[name] != expected[name]:
            raise ValueError('whole scenario differs: ' + name)


def negative(result, stderr, required):
    if not required or any(not isinstance(x, str) or not x for x in required):
        raise ValueError('explicit intended diagnostics required')
    if result.get('exit') != 1 or result.get('failure'):
        raise ValueError('negative control must terminate with compiler refusal, not timeout/success')
    if any(text not in stderr for text in required):
        raise ValueError('intended diagnostic missing')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('actual', type=Path)
    parser.add_argument('expected', type=Path)
    parser.add_argument('--stderr', type=Path, help='check intended negative-control result instead of scenes')
    args = parser.parse_args()
    actual, expected = json.loads(args.actual.read_text()), json.loads(args.expected.read_text())
    if args.stderr:
        negative(actual, args.stderr.read_text(), expected['stderrContains'])
    else:
        scenes(actual, expected)


if __name__ == '__main__':
    main()
