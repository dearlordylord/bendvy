#!/usr/bin/env python3
"""Python-only synthetic transport controls; no backend output inspected."""
import importlib.util
import json
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('partition_transport', HERE / 'transport.py')
T = importlib.util.module_from_spec(spec)
spec.loader.exec_module(T)
P = T.PARSER
ORACLE = Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/oracle-v1')


class Transport(unittest.TestCase):
    def setUp(self):
        self.join = json.loads((ORACLE / 'CONSTRUCTOR-JOIN.json').read_text())
        self.expected = json.loads((ORACLE / 'expected.json').read_text())
        original = json.loads((HERE.parent / 'constructor-identities.json').read_text())['constructors']
        whole = P.parse_term((ORACLE / 'synthetic-complete.stdout').read_text())
        self.inventories = {}
        self.raw = {}
        for i, category in enumerate(T.CATEGORIES):
            inventory = json.loads((HERE / (category + '-identities.json')).read_text())
            self.assertEqual(P.build_identities(HERE / (category + '.bend')), inventory)
            inverse = {semantic: token for token, semantic in inventory['constructors'].items()}
            def remap(value):
                if type(value) is list:
                    return [remap(x) for x in value]
                if type(value) is dict and set(value) == {'constructor', 'fields'}:
                    return {'constructor': inverse[original[value['constructor']]], 'fields': remap(value['fields'])}
                return value
            term = {'constructor': 'Report', 'fields': [remap(whole['fields'][i])]}
            self.inventories[category] = inventory
            self.raw[category] = P.render_term(term)

    def test_full_unchanged_45_phase_oracle(self):
        self.assertEqual(T.aggregate(self.raw, self.inventories, self.join, self.expected), self.expected)

    def test_missing_category(self):
        del self.raw['plain']
        with self.assertRaises(ValueError): T.aggregate(self.raw, self.inventories, self.join, self.expected)

    def test_wrong_root_and_arity_and_namespace(self):
        for raw in ('Failure{}', 'Report{}', 'Report{0}', 'Wrong.Report{0}'):
            with self.assertRaises(ValueError): T.normalize(raw, self.inventories['plain'], self.join, 'plain')

    def test_wrong_actual_category(self):
        with self.assertRaises(ValueError): T.normalize(self.raw['plain'], self.inventories['plain'], self.join, 'transient')

    def test_complete_phase_omission(self):
        raw = P.parse_term(self.raw['plain'])
        raw['fields'][0]['fields'][1].pop()
        self.raw['plain'] = P.render_term(raw)
        with self.assertRaises(ValueError): T.aggregate(self.raw, self.inventories, self.join, self.expected)


if __name__ == '__main__': unittest.main()
