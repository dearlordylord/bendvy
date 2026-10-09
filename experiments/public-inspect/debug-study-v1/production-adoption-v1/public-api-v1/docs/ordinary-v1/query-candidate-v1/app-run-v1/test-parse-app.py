#!/usr/bin/env python3
"""Whole independent synthetic App controls, before any backend observation."""
import copy
import importlib.util
import json
from pathlib import Path
import unittest

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('app_parser', HERE / 'parse-app.py')
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)
ORACLE = Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/oracle-v1/app-run-v1')


class Complete(unittest.TestCase):
    def setUp(self):
        self.inventory = json.loads((HERE / 'constructor-identities.json').read_text())
        self.assertEqual(P.build_identities(HERE / 'main.bend'), self.inventory)
        self.join = json.loads((ORACLE / 'CONSTRUCTOR-JOIN.json').read_text())
        self.expected = json.loads((ORACLE / 'expected.json').read_text())
        self.raw = (ORACLE / 'synthetic-complete.stdout').read_text()
        self.term = P.BASE.parse_term(self.raw)

    def compare(self, term):
        actual = P.normalize(P.BASE.render_term(term), self.inventory, self.join)
        P.BASE.strict_equal(actual, self.expected)

    def test_complete_sixty_phase_join(self): self.compare(self.term)

    def test_partition_identity_and_full_slots(self):
        for index, category in enumerate(('plain', 'transient', 'constructed')):
            inventory = json.loads((HERE / (category + '-identities.json')).read_text())
            self.assertEqual(P.build_identities(HERE / (category + '.bend')), inventory)
            inverse = {semantic: token for token, semantic in inventory['constructors'].items()}
            def remap(value):
                if type(value) is list: return [remap(x) for x in value]
                if type(value) is dict and set(value) == {'constructor', 'fields'}:
                    return {'constructor': inverse[self.inventory['constructors'][value['constructor']]], 'fields': remap(value['fields'])}
                return value
            raw = P.BASE.render_term(remap(self.term['fields'][index]))
            P.BASE.strict_equal(P.normalize(raw, inventory, self.join, category), self.expected[category])
            with self.assertRaises(ValueError): P.normalize(raw, inventory, self.join, 'transient' if category == 'plain' else 'plain')

    def test_corrupted_last_phase_and_removed_record(self):
        for target in ('clock', 'removed'):
            term = copy.deepcopy(self.term)
            report = term['fields'][2]['fields'][0]
            if target == 'clock': report['fields'][2][-1]['fields'][2]['fields'][2]['fields'][11] += 1
            else: report['fields'][4].pop()
            with self.assertRaises(ValueError): self.compare(term)

    def test_wrong_namespace_missing_category_omitted_phase(self):
        for target in ('namespace', 'category', 'phase'):
            term = copy.deepcopy(self.term)
            if target == 'namespace': term['fields'][2]['fields'][0]['fields'][2][-1]['fields'][2]['constructor'] = 'Wrong.Snapshot'
            elif target == 'category': term['fields'].pop()
            else: term['fields'][2]['fields'][0]['fields'][2].pop()
            with self.assertRaises(ValueError): self.compare(term)

    def test_raw_type_confusions_and_failure(self):
        term = copy.deepcopy(self.term)
        trace = term['fields'][2]['fields'][0]['fields'][2][-1]['fields'][1]['fields'][2]
        args = trace['fields'][1][-1]['fields'][1]['fields'][0]
        args['fields'][0] = 0
        with self.assertRaises(ValueError): self.compare(term)
        term = copy.deepcopy(self.term)
        term['fields'][0]['fields'][0]['fields'][2][-1]['fields'][1]['fields'][2]['fields'][0] = {'constructor': 'True', 'fields': []}
        with self.assertRaises(ValueError): self.compare(term)
        term = copy.deepcopy(self.term)
        term['fields'][0] = {'constructor': 'output.Failure', 'fields': []}
        with self.assertRaises(ValueError): self.compare(term)

    def test_exact_arity_truncation_and_trailing_data(self):
        for raw in (self.raw[:-3], self.raw + ' 0'):
            with self.assertRaises(ValueError): P.normalize(raw, self.inventory, self.join)
        term = copy.deepcopy(self.term)
        term['fields'][0]['fields'].append(0)
        with self.assertRaises(ValueError): self.compare(term)


if __name__ == '__main__': unittest.main()
