import copy,json,unittest,types
from pathlib import Path
H=Path(__file__).resolve().parent
m=types.ModuleType('model');m.__file__=str(H/'expected.py');exec(compile((H/'expected.py').read_bytes(),m.__file__,'exec'),m.__dict__)
class Model(unittest.TestCase):
 def test_complete_frozen_models(self):
  for name,mutation in [('expected.json',False),('expected-retainer.json',True)]:
   self.assertEqual(json.loads((H/name).read_bytes()),m.model(mutation))
  self.assertEqual(len(m.model()),13)
 def test_reached_retention_frontier(self):
  a=m.model();b=m.model(True)
  self.assertEqual(a[:3],b[:3])
  self.assertEqual(a[-1]['events'],[]);self.assertEqual(b[-1]['events'],[31,32])
  self.assertEqual(a[-1]['metadata']['dropped'],1);self.assertEqual(b[-1]['metadata']['dropped'],0)
  for x,y in zip(a,b):
   for key in ('resource','clock','nextId','highWater','worldCapacity','depth','registrations','nextSystem','inspectorCursor'):
    self.assertEqual(x[key],y[key])
 def test_consuming_leaf_and_reader_paths(self):
  x=m.model();self.assertEqual(x[2]['metadata']['positions'],x[3]['metadata']['positions'])
  self.assertEqual(x[3]['clock'],1);self.assertEqual(x[7]['inspectorCursor'],x[3]['inspectorCursor'])
  a=copy.deepcopy(x[-2]);b=copy.deepcopy(x[-1]);a.pop('label');b.pop('label');a.pop('readerResult');b.pop('readerResult');self.assertEqual(a,b)
  self.assertEqual(x[-1]['readerResult']['value']['lagged'],True)
if __name__=='__main__':unittest.main()
