import copy,unittest
import expected as model
class CompleteModel(unittest.TestCase):
 def test_all_rows_and_fields(self):
  for role,count,fields in [('normal',17,27),('mutant',17,27),('flow-only',5,21)]:
   value=model.expected(role)
   self.assertEqual(list(value),['A','B'])
   for rows in value.values():
    self.assertEqual(len(rows),count)
    self.assertEqual(len({r['label'] for r in rows}),count)
    self.assertTrue(all(len(r['fields'])==fields for r in rows))
   self.assertTrue(model.render(value).endswith('\n'))
 def test_optional_actual_frames(self):
  rows={r['label']:r for r in model.expected()['A']}
  self.assertEqual(rows['required-reader-missing']['fields'],rows['missing-initial']['fields'])
  self.assertEqual(rows['true-or-missing']['fields']['conditions'],'[true-or]')
  self.assertEqual(rows['negated-missing']['fields']['conditions'],'[true-or, not]')
  self.assertEqual(rows['flow-only-false-gate']['fields']['level'],'missing')
  self.assertEqual(rows['flow-only-false-gate']['fields']['conditions'],'[true-or, not, exists]')
 def test_failed_ownership_and_clock(self):
  rows={r['label']:r for r in model.expected()['A']}
  before=rows['old-pending']['fields'];failed=rows['failed-publisher']['fields']
  for key in ['cells','owned','flow','level','flowStream','levelStream']:
   if key.endswith('Stream'):continue # frameStart is allowed to advance before body failure.
   self.assertEqual(before[key],failed[key])
  self.assertEqual((before['componentClock'],failed['componentClock']),('1','2'))
  self.assertEqual(failed['next'],'3')
  self.assertEqual(failed['queue'],'0')
  self.assertEqual(rows['failed-reader']['fields']['flowStream'].split('positions=')[1].split(',dropped')[0],before['flowStream'].split('positions=')[1].split(',dropped')[0])
 def test_reached_mutant_not_equal(self):
  normal=model.expected();mutant=model.expected('mutant')
  self.assertNotEqual(normal,mutant)
  a=mutant['A'][1]
  self.assertEqual(a['status'],'ok');self.assertEqual(a['fields']['tick'],'1')
  self.assertIn('3:1:0',a['fields']['flowStream'])
  self.assertEqual(normal['A'][1]['status'],'machine-provision-rejected')
 def test_flow_only_preserves_missing_level(self):
  rows=model.expected('flow-only')['A']
  self.assertTrue(all(r['fields']['level']=='missing' for r in rows))
  self.assertEqual(rows[0]['fields'],rows[1]['fields']);self.assertEqual(rows[1]['fields'],rows[2]['fields'])
  self.assertEqual(rows[-1]['fields'],rows[-2]['fields'])
  self.assertEqual(rows[-1]['status'],'current:Boot')
if __name__=='__main__':unittest.main()
