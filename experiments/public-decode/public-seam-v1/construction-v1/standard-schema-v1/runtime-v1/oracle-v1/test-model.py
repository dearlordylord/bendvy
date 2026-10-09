import runpy, unittest
from pathlib import Path
M=runpy.run_path(str(Path(__file__).with_name('expected.py')))
class Model(unittest.TestCase):
 def test_full_routes(self):
  rows=M['expected']();self.assertEqual(len(rows),28)
  self.assertEqual([x['label']for x in rows[:14]],M['LABELS'])
  for a,b in zip(rows[:14],rows[14:]):
   if a['label']!='hostRefusal':self.assertEqual(a['report'],b['report'])
 def test_insert_retired_owner(self):
  r=M['component']('insert');self.assertEqual(r['barrier']['mail']['retired'],[M['owner'](7,99)])
  self.assertEqual(r['barrier']['column']['stamps'][0]['stamp']['added'],1)
 def test_failure_retains_complete_recovery(self):
  r=M['component']('failedInsert');self.assertEqual(r['before'],r['barrier'])
  rec=r['instance']['recoveries'][0];self.assertFalse(rec['output']['spawned'])
  self.assertEqual(rec['packets'][0]['owner']['value']['words'],[71,72])
 def test_resource_rollback_and_refusal(self):
  r=M['resource']('failedResource');self.assertEqual(r['before'],r['after'])
  r=M['resource']('resourceDownstreamRefusal');self.assertEqual(r['result']['error']['$'],'Admission')
  self.assertEqual(r['result']['owner']['raw'],M['text']('9,8'))

class Transport(unittest.TestCase):
 def setUp(self):self.T=runpy.run_path(str(Path(__file__).with_name('transport-expected.py')))
 def test_all_variants_order_and_bit_preservation(self):
  rows=self.T['expected']();self.assertEqual(len(rows),29)
  self.assertEqual({r['output']['result']['raw']['$']for r in rows[:19]}, {'Missing','Null','Number','SignedInteger','Float','Binary64','Text','Utf16Text','Boolean','Handle','Array','Object'})
  bits=[r['output']['result']['raw']['value']['$f32Bits']for r in rows[4:10]]
  self.assertEqual(bits,[0,2147483648,1,2143289344,2139095040,4286578688])
  fields=rows[18]['output']['result']['raw']['fields']
  self.assertEqual([f['name']for f in fields],[self.T['string']('x'),self.T['string']('x'),self.T['string']('🌍')])
 def test_exact_refusal_and_extra_remainder(self):
  rows=self.T['expected']();self.assertTrue(all(r['output']['result']==self.T['c']('TransportRefused',remaining=[])for r in rows[20:25]+rows[26:]))
  self.assertEqual(rows[25]['output']['result'],self.T['c']('Extra',raw=self.T['c']('Null'),remaining=[self.T['string']('null')]))
 def test_complete_model_corruptions_are_distinct(self):
  import copy
  expected=self.T['expected']()
  for edit in ('lastRemainder','duplicateField','negativeZero','nanBits','omitCase'):
   altered=copy.deepcopy(expected)
   if edit=='lastRemainder':altered[25]['output']['result']['remaining']=[]
   elif edit=='duplicateField':altered[18]['output']['result']['raw']['fields'].pop(1)
   elif edit=='negativeZero':altered[5]['output']['result']['raw']['value']['$f32Bits']=0
   elif edit=='nanBits':altered[7]['output']['result']['raw']['value']=None
   else:altered.pop()
   self.assertNotEqual(altered,expected,edit)

if __name__=='__main__':unittest.main()
