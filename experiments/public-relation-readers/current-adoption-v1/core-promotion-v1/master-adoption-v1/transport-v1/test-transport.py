"""Complete current namespace and error controls; no backend/output input."""
import copy,importlib.util,json,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('typed',HERE/'transport.py');T=importlib.util.module_from_spec(spec);spec.loader.exec_module(T)
INV=json.loads((HERE/'constructor-identities.json').read_text())
ORACLE=Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-relation-readers/current-adoption-v1/oracle-v1/declaration-adoption-v1/expected.json')
class Whole(unittest.TestCase):
 def setUp(self):
  self.t=T.Transport(INV['entrypoint']);self.model=json.loads(ORACLE.read_text());self.raw=self.t.inverse(self.model,self.t.resolve('Candidate',self.t.entry,{}))
 def gate(self,value):T.TERM.strict_equal(self.t.normalize(T.TERM.render_term(value)),self.model)
 def test_whole_and_current_inventory(self):
  self.assertEqual(self.t.inventory(),INV);self.gate(self.raw)
 def test_none_and_arity(self):
  with self.assertRaises(ValueError):self.gate({'constructor':'Candidate','fields':[{'constructor':'None','fields':[]}]})
  raw=copy.deepcopy(self.raw);raw['fields'].append(7)
  with self.assertRaises(ValueError):self.gate(raw)
 def test_wrong_namespace(self):
  raw=copy.deepcopy(self.raw);raw['constructor']='foreign.Candidate'
  with self.assertRaises(ValueError):self.gate(raw)
 def test_last_owner_corruption(self):
  model=copy.deepcopy(self.model)
  def change(v):
   if isinstance(v,dict):
    for k,x in reversed(list(v.items())):
     if type(x)is int:v[k]=x+1;return True
     if change(x):return True
   if isinstance(v,list):
    for x in reversed(v):
     if change(x):return True
   return False
  self.assertTrue(change(model))
  with self.assertRaises(ValueError):self.gate(self.t.inverse(model,self.t.resolve('Candidate',self.t.entry,{})))
if __name__=='__main__':unittest.main()
