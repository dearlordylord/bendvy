#!/usr/bin/env python3
"""Pre-backend controls using only the independently authored synthetic full term."""
import argparse
import copy
import hashlib
import importlib.util
import json
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location('scenario_parser', Path(__file__).with_name('parse-scenario.py'))
parser = importlib.util.module_from_spec(spec)
spec.loader.exec_module(parser)


class Controls(unittest.TestCase):
    def reject(self, mutate):
        raw = copy.deepcopy(self.raw)
        mutate(raw)
        with self.assertRaises(ValueError):
            parser.strict_equal(parser.normalize(raw, self.identities, self.join), self.expected)

    @staticmethod
    def phases(raw):
        return raw['fields'][0]['fields'][1]

    def test_complete_independent_synthetic(self):
        actual = parser.normalize(self.raw, self.identities, self.join)
        parser.strict_equal(actual, self.expected)
        self.assertEqual([len(actual[key]['phases']) for key in ['plain', 'transient', 'constructed']], [15, 15, 15])

    def test_all_phases_and_registration_order_preserved(self):
        self.reject(lambda raw: self.phases(raw).pop())
        self.reject(lambda raw: self.phases(raw)[1]['fields'][2]['fields'][9].reverse())

    def test_tail_payload_is_compared(self):
        def mutation(raw):
            full = self.phases(raw)[0]['fields'][2]['fields'][12]['fields'][0]['fields'][1][0]['fields'][1]['fields'][0]
            full['fields'][1][1] += 1
        self.reject(mutation)

    def test_world_clock_and_actual_owner_cursor(self):
        self.reject(lambda raw: self.phases(raw)[-1]['fields'][2]['fields'].__setitem__(11, 0))
        self.reject(lambda raw: self.phases(raw)[-1]['fields'][3][0]['fields'].__setitem__(4, 0))

    def test_disabled_and_enabled_description_distinct(self):
        def mutation(raw):
            self.phases(raw)[12]['fields'][5][0] = {'constructor': self.reverse['None'], 'fields': []}
        self.reject(mutation)

    def test_failure_does_not_become_done(self):
        def mutation(raw):
            self.phases(raw)[2]['fields'][4]['fields'][0] = {'constructor': self.reverse['Result.Done'], 'fields': [[]]}
        self.reject(mutation)

    def test_context_bound_types(self):
        def string_mode(raw):
            self.phases(raw)[1]['fields'][3][0]['fields'][6][0]['fields'][1] = 'Read'
        def int_bool(raw):
            self.phases(raw)[0]['fields'][2]['fields'][5][0] = 0
        def int_nat(raw):
            self.phases(raw)[0]['fields'][2]['fields'][4] = 2
        def nat_u32(raw):
            self.phases(raw)[0]['fields'][2]['fields'][11] = {'nat': 7}
        def list_string(raw):
            self.phases(raw)[0]['fields'][0] = ['seed']
        def string_result(raw):
            self.phases(raw)[2]['fields'][4]['fields'][0] = 'Fail'
        def bad_maybe(raw):
            self.phases(raw)[12]['fields'][5][0] = {'constructor': self.reverse['Maybe.Some'], 'fields': [1]}
        for mutation in [string_mode, int_bool, int_nat, nat_u32, list_string, string_result, bad_maybe]:
            with self.subTest(mutation=mutation.__name__):
                self.reject(mutation)

    def test_wrong_context_and_arity(self):
        def context(raw):
            stamp = self.phases(raw)[0]['fields'][2]['fields'][12]['fields'][0]['fields'][1][0]['fields'][2]
            stamp['constructor'] = self.reverse['FullCell']
        self.reject(context)
        self.reject(lambda raw: raw['fields'].append(raw['fields'][0]))

    def test_constructor_namespace_not_basename(self):
        self.reject(lambda raw: self.phases(raw)[0].__setitem__('constructor', 'forged.' + self.phases(raw)[0]['constructor']))
        self.reject(lambda raw: raw.__setitem__('constructor', self.reverse['Output.Failure']))

    def test_raw_whole_term_and_bounds(self):
        for text in [self.raw_text[:-2], self.raw_text + 'extra{}', '4294967296', '-1n', '01', '01n', '"bad\\x41"']:
            with self.subTest(text=text[:20]):
                with self.assertRaises(ValueError):
                    parser.parse_term(text)

    def test_string_full_escapes(self):
        value = 'a\0b\n\t\r\\"\x1f\x7f\ud800🎉'
        self.assertEqual(parser.parse_term(parser.string_term(value)), value)

    def test_neutral_bool_never_equals_integer(self):
        with self.assertRaises(ValueError):
            parser.strict_equal(False, 0)
        with self.assertRaises(ValueError):
            parser.strict_equal(True, 1)


def main():
    arguments = argparse.ArgumentParser()
    arguments.add_argument('--raw', required=True)
    arguments.add_argument('--identities', required=True)
    arguments.add_argument('--join', required=True)
    arguments.add_argument('--expected', required=True)
    args = arguments.parse_args()
    Controls.raw_text = Path(args.raw).read_text()
    Controls.raw = parser.parse_term(Controls.raw_text)
    Controls.identities = json.loads(Path(args.identities).read_text())['constructors']
    Controls.reverse = {semantic: raw for raw, semantic in Controls.identities.items()}
    Controls.join = json.loads(Path(args.join).read_text())
    expected_bytes = Path(args.expected).read_bytes()
    if hashlib.sha256(expected_bytes).hexdigest() != Controls.join['expectedSHA256']:
        raise ValueError('Independent expected digest mismatch')
    Controls.expected = json.loads(expected_bytes)
    result = unittest.TextTestRunner(verbosity=2).run(unittest.defaultTestLoader.loadTestsFromTestCase(Controls))
    raise SystemExit(0 if result.wasSuccessful() else 1)


if __name__ == '__main__':
    main()
