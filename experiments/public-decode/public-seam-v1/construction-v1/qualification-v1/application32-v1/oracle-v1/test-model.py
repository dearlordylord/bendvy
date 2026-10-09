"""Small source-model checks; no compiler or application child."""
import importlib.util
import json
from pathlib import Path
import unittest
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('independent_application32',HERE/'expected.py')
M=importlib.util.module_from_spec(spec)
exec(compile((HERE/'expected.py').read_bytes(),str(HERE/'expected.py'),'exec'),M.__dict__)

class ModelTests(unittest.TestCase):
    def test_complete_order_and_fresh_roots(self):
        model=M.expected()
        self.assertEqual(len(model),32)
        self.assertEqual([x['name'] for x in model],list(M.CASES)*4)
        for item in model:
            for phase in ('before','committed','barrier'):
                self.assertEqual(item['value'][phase]['meta']['namespace'],1)
            self.assertEqual(item['value']['instance']['pending'],[])
            self.assertEqual(item['value']['instance']['recoveries'],[])
    def test_physical_write_and_deferred_spawn(self):
        insert=M.report('array3','insert')
        spawn=M.report('array3','spawn')
        self.assertEqual(insert['committed']['meta']['clock'],2)
        self.assertEqual(insert['barrier']['store']['marker']['stamps'],[M.entry(1,3,3)])
        self.assertEqual(spawn['committed']['pending'],3)
        self.assertEqual(spawn['committed']['live'],[False,True,False,False])
        self.assertEqual(spawn['barrier']['live'],[False,True,True,False])
        self.assertEqual(spawn['barrier']['store']['values']['stamps'],[M.entry(2,3,3),M.entry(1,1,1)])
    def test_refusal_owner_and_error(self):
        report=M.report('nestedMissing','insert')
        refusal=report['result']['output']['value']
        self.assertEqual(refusal['owner'],M.some(report['original']))
        self.assertEqual(refusal['error']['error'],M.c('Invalid',path='$.items[1].value',expected='integer',actual=M.c('Missing')))
        self.assertEqual(report['committed']['store'],report['before']['store'])
        self.assertEqual(report['barrier']['meta']['clock'],2)
    def test_canonical_resource_and_flags(self):
        report=M.report('struct64','resource')
        self.assertEqual(report['committed']['meta']['clock'],1)
        resource=report['committed']['resource']
        self.assertEqual(len(resource['raw']['fields']),64)
        self.assertEqual(len(resource['original']['fields']),65)
        self.assertEqual(resource['words'],[111,222])
        self.assertEqual(resource['flags'],[True,False])
        self.assertEqual(report['before']['resource']['flags'],[False,True])
    def test_frozen_entire_model(self):
        self.assertEqual(json.loads((HERE/'expected.json').read_text()),M.expected())

if __name__=='__main__':unittest.main()
