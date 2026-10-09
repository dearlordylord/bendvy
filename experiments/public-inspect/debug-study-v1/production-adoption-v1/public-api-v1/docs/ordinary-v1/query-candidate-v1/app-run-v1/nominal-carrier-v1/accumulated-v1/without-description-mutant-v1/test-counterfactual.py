#!/usr/bin/env python3
"""Complete pre-run independent counterfactual and noninterference controls."""
import copy,importlib.util,json,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('mutant_transport',HERE/'parse-app.py')
P=importlib.util.module_from_spec(spec);spec.loader.exec_module(P)
ORACLE=Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/oracle-v1/app-run-v1')
class Whole(unittest.TestCase):
    def setUp(self):
        self.inv=json.loads((HERE/'constructor-identities.json').read_text());self.assertEqual(P.build_identities(HERE/'main.bend'),self.inv)
        self.join=json.loads((ORACLE/'CONSTRUCTOR-JOIN.json').read_text());self.clean=json.loads((ORACLE/'expected.json').read_text())
        self.counter=json.loads((ORACLE/'without-description-v1/expected.json').read_text());self.raw=(ORACLE/'without-description-v1/expected.stdout').read_text()
    def check(self,raw):P.BASE.strict_equal(P.normalize(raw,self.inv,self.join),self.counter)
    def test_complete_counterfactual_and_clean_gate(self):
        self.check(self.raw)
        with self.assertRaises(ValueError):P.BASE.strict_equal(P.normalize(self.raw,self.inv,self.join),self.clean)
    def test_complete_clean_namespace_control(self):
        raw=(ORACLE/'without-description-v1/baseline-relocated.stdout').read_text()
        P.BASE.strict_equal(P.normalize(raw,self.inv,self.join),self.clean)
        with self.assertRaises(ValueError):self.check(raw)
    def test_last_world_corruption_rejected(self):
        t=P.BASE.parse_term(self.raw);t['fields'][2]['fields'][0]['fields'][2][-1]['fields'][2]['fields'][2]['fields'][11]+=1
        with self.assertRaises(ValueError):self.check(P.BASE.render_term(t))
    def test_wrong_namespace_missing_category_phase(self):
        for mode in ['namespace','category','phase']:
            t=P.BASE.parse_term(self.raw)
            if mode=='namespace':t['fields'][2]['fields'][0]['fields'][2][-1]['fields'][2]['constructor']='Wrong.Snapshot'
            elif mode=='category':t['fields'].pop()
            else:t['fields'][2]['fields'][0]['fields'][2].pop()
            with self.assertRaises(ValueError):self.check(P.BASE.render_term(t))
if __name__=='__main__':unittest.main()
