"""Check explicit whole-scene expectations and intended negative evidence."""
import argparse
from dataclasses import dataclass
import json
import re
from pathlib import Path


def scenes(actual, expected):
    # Expected DTOs are independently authored, not extracted from runtime output.
    if not expected or set(actual) != set(expected):
        raise ValueError('complete scenario membership differs')
    for name in expected:
        if actual[name] != expected[name]:
            raise ValueError('whole scenario differs: ' + name)


@dataclass(frozen=True)
class TypeMismatch:
    expected: str
    observed: str

    @classmethod
    def parse(cls, value):
        message = ('use diagnostic {"kind": "type-mismatch", "expected": "Cap.Write", '
                   '"observed": "Cap.Read"}; distinct outer type constructors are required')
        if (not isinstance(value, dict) or set(value) != {'kind', 'expected', 'observed'}
                or value['kind'] != 'type-mismatch'):
            raise ValueError(message)
        for key in ('expected', 'observed'):
            if (not isinstance(value[key], str)
                    or not re.fullmatch(r'[A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*', value[key])):
                raise ValueError(message)
        if value['expected'] == value['observed']:
            raise ValueError(message)
        return cls(value['expected'], value['observed'])

    def matches(self, stderr):
        errors = re.split(r'(?m)^Error:[ \t]*\r?$', stderr)
        if len(errors) != 2:
            return False
        body = re.split(r'(?m)^(?:Context|Location):', errors[1], maxsplit=1)[0]
        expected = re.findall(r'(?m)^- expected[ \t]*:[ \t]*(.+)$', body)
        observed = re.findall(r'(?m)^- observed[ \t]*:[ \t]*(.+)$', body)
        return (len(expected) == 1 and len(observed) == 1
                and re.match(re.escape(self.expected) + r'\s*(?:<|$)', expected[0].strip()) is not None
                and re.match(re.escape(self.observed) + r'\s*(?:<|$)', observed[0].strip()) is not None)


def negative(result, stderr, expectation):
    if (not isinstance(result, dict) or type(result.get('exit')) is not int
            or result['exit'] != 1 or result.get('failure') is not None):
        raise ValueError('negative control must terminate with compiler refusal, not timeout/success')
    mismatch = TypeMismatch.parse(expectation)
    if not mismatch.matches(stderr):
        raise ValueError('intended type mismatch missing: expected ' + mismatch.expected
                         + ', observed ' + mismatch.observed
                         + '; arity, parser and unrelated diagnostics do not qualify')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('actual', type=Path)
    parser.add_argument('expected', type=Path)
    parser.add_argument('--stderr', type=Path, help='check intended negative-control result instead of scenes')
    args = parser.parse_args()
    actual, expected = json.loads(args.actual.read_text()), json.loads(args.expected.read_text())
    if args.stderr:
        negative(actual, args.stderr.read_text(), expected.get('diagnostic'))
    else:
        scenes(actual, expected)


if __name__ == '__main__':
    main()
