#!/usr/bin/env python3
"""Exact compile-partition namespace/whole-aggregate controls, no child."""
import copy
import importlib.util
import json
from pathlib import Path
import unittest
HERE=Path(__file__).resolve().parent
ORACLE=Path('/workspace/formal-proofs/bendvy-worktrees/reader53-adoption/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/oracle-v1/dump-v1')
spec=importlib.util.spec_from_file_location('native_dump_transport',HERE/'parse-native.py')
P=importlib.util.module_from_spec(spec);spec.loader.exec_module(P)
spec=importlib.util.spec_from_file_location('normal_dump_controls',HERE/'test-semantic-dump.py')
T=importlib.util.module_from_spec(spec);spec.loader.exec_module(T)


def relocate(value,old,new):
    if isinstance(value,list):return [relocate(v,old,new) for v in value]
    if isinstance(value,dict):
        if set(value)=={'nat'}:return dict(value)
        semantic=old[value['constructor']]
        candidates=[token for token,meaning in new.items() if meaning==semantic]
        if len(candidates)!=1:raise ValueError('Synthetic positive constructor identity ambiguous')
        return {'constructor':candidates[0],'fields':[relocate(v,old,new) for v in value['fields']]}
    return value


def inputs():
    expected=json.loads((ORACLE/'expected.json').read_text())
    join=json.loads((ORACLE/'CONSTRUCTOR-JOIN.json').read_text())
    whole=P.BASE.parse_term((ORACLE/'synthetic.stdout').read_text())
    old=json.loads((HERE/'constructor-identities.json').read_text())['constructors']
    rows={}
    for index,cat in enumerate(P.CATEGORIES):
        inv=json.loads((HERE/(cat+'-identities.json')).read_text())
        if P.build_identities(Path(inv['entrypoint']))!=inv:raise ValueError('Native source identity drift')
        rows[cat]=(inv,relocate(whole['fields'][index],old,inv['constructors']))
    return expected,join,rows


class Partition(unittest.TestCase):
    def test_full_three_actual_category_terms_equal_whole_model(self):
        expected,join,rows=inputs()
        actual={cat:P.normalize(T.term(term),inv,join,cat) for cat,(inv,term) in rows.items()}
        P.BASE.strict_equal(actual,expected)

    def test_missing_category_or_wrong_category_refused(self):
        expected,join,rows=inputs();actual={cat:P.normalize(T.term(term),inv,join,cat) for cat,(inv,term) in rows.items()}
        actual.pop('constructed')
        with self.assertRaises(ValueError):P.BASE.strict_equal(actual,expected)
        inv,term=rows['plain']
        with self.assertRaises(ValueError):P.normalize(T.term(term),inv,join,'transient')

    def test_last_state_and_namespace_not_hidden_by_partition_context(self):
        expected,join,rows=inputs();inv,term=rows['constructed']
        term['fields'][1]['fields'][0]['fields'][1][-1]['fields'][3][-1]['fields'][4]+=1
        with self.assertRaises(ValueError):P.BASE.strict_equal(P.normalize(T.term(term),inv,join,'constructed'),expected['constructed'])
        term['constructor']='forged.Kept'
        with self.assertRaises(ValueError):P.normalize(T.term(term),inv,join,'constructed')


if __name__=='__main__':
    # Whole data below is source-relocated independent synthetic only, never output.
    expected,join,rows=inputs()
    for cat,(inv,term) in rows.items():
        (HERE/'native-entries-v1'/(cat+'-synthetic.stdout')).write_text(T.term(term)+'\n')
    unittest.main()
