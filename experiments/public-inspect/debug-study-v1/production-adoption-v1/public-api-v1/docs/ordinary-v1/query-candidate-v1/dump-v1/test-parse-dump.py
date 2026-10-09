#!/usr/bin/env python3
"""Whole prebackend oracle controls, never partial value checks."""
import copy
import importlib.util
import json
from pathlib import Path
import unittest

HERE=Path(__file__).resolve().parent
ORACLE=Path("/workspace/formal-proofs/bendvy-worktrees/reader53-adoption/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/oracle-v1/dump-v1")
spec=importlib.util.spec_from_file_location('dump_parser_controls',HERE/'parse-dump.py')
P=importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)


def term(value):
    if isinstance(value,list):return '['+','.join(map(term,value))+']'
    if isinstance(value,dict):
        if set(value)=={'nat'}:return str(value['nat'])+'n'
        return value['constructor']+'{'+','.join(map(term,value['fields']))+'}'
    if type(value)==str:return P.BASE.string_term(value)
    if type(value)==int:return str(value)
    raise ValueError('Invalid raw Data')


class Complete(unittest.TestCase):
    def setUp(self):
        self.inventory=json.loads((HERE/'constructor-identities.json').read_text())
        self.join=json.loads((ORACLE/'CONSTRUCTOR-JOIN.json').read_text())
        self.expected=json.loads((ORACLE/'expected.json').read_text())
        self.raw=(ORACLE/'synthetic.stdout').read_text()
        self.parsed=P.BASE.parse_term(self.raw)

    def gate(self,raw):
        P.BASE.strict_equal(P.normalize(raw,self.inventory,self.join),self.expected)

    def report(self):
        return self.parsed['fields'][2]['fields'][1]['fields'][0]

    def test_complete_normal_and_mutant_roundtrip(self):
        self.assertEqual(P.build_identities(HERE/'main.bend'),self.inventory)
        self.gate(self.raw)
        inventory=json.loads((HERE/'disabled-execution-mutant-v1/constructor-identities.json').read_text())
        self.assertEqual(P.build_identities(HERE/'disabled-execution-mutant-v1/main.bend'),inventory)
        actual=P.normalize((ORACLE/'synthetic-disabled-mutant.stdout').read_text(),inventory,json.loads((ORACLE/'CONSTRUCTOR-JOIN-disabled-mutant.json').read_text()))
        P.BASE.strict_equal(actual,json.loads((ORACLE/'expected-disabled-mutant.json').read_text()))
        with self.assertRaises(ValueError):P.BASE.strict_equal(actual,self.expected)

    def test_missing_category(self):
        self.parsed['fields'].pop()
        with self.assertRaises(ValueError):self.gate(term(self.parsed))

    def test_omitted_last_phase(self):
        self.report()['fields'][1].pop()
        with self.assertRaises(ValueError):self.gate(term(self.parsed))

    def test_last_owner_cursor_drift(self):
        snapshot=self.report()['fields'][1][-1]
        snapshot['fields'][3][-1]['fields'][4]+=1
        with self.assertRaises(ValueError):self.gate(term(self.parsed))

    def test_last_pending_and_event_drift(self):
        for index,value in ((8,1),(7,[])):
            with self.subTest(index=index):
                raw=copy.deepcopy(self.parsed)
                raw['fields'][2]['fields'][1]['fields'][0]['fields'][1][-1]['fields'][2]['fields'][index]=value
                with self.assertRaises(ValueError):self.gate(term(raw))

    def test_reader_namespace_offset_and_primitive_nat(self):
        for index,value in ((0,2),(1,{'nat':1}),(1,0)):
            with self.subTest(index=index):
                raw=copy.deepcopy(self.parsed)
                raw['fields'][2]['fields'][0]['fields'][index]=value
                with self.assertRaises(ValueError):self.gate(term(raw))

    def test_population_row_omission_and_namespace(self):
        rows=self.report()['fields'][2][1]['fields'][0]['fields'][1]
        rows[-1]['fields'][0]['fields'][0]=999
        with self.assertRaises(ValueError):self.gate(term(self.parsed))
        rows.pop()
        with self.assertRaises(ValueError):self.gate(term(self.parsed))

    def test_unknown_constructor_namespace_and_bool_int(self):
        self.parsed['constructor']='forged.Output'
        with self.assertRaises(ValueError):self.gate(term(self.parsed))
        self.parsed=P.BASE.parse_term(self.raw)
        self.report()['fields'][1][-1]['fields'][2]['fields'][5][1]=1
        with self.assertRaises(ValueError):self.gate(term(self.parsed))


if __name__=='__main__':unittest.main()
