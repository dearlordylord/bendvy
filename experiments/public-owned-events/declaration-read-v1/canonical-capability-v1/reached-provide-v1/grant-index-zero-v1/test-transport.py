import copy,json,types,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
ORACLE=Path('/workspace/formal-proofs/bendvy-worktrees/review-46-native22-launch/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/reached-provide-v1/grant-index-zero-v1/oracle-v1')
def helper():
 p=HERE/'transport.py';m=types.ModuleType('counter_transport');m.__file__=str(p);exec(compile(p.read_bytes(),str(p),'exec'),m.__dict__);return m
class Controls(unittest.TestCase):
 def test_complete_models_and_rejection(self):
  m=helper();values={}
  for name in ['baseline','counterfactual']:
   value=json.loads((ORACLE/(name+'.json')).read_text());raw=(ORACLE/(name+'.stdout')).read_bytes()
   self.assertEqual(m.parse('registered',raw),value);self.assertEqual((m.render('registered',value)+'\n').encode(),raw);values[name]=value
  self.assertNotEqual(values['baseline'],values['counterfactual'])
  self.assertNotEqual((ORACLE/'baseline.stdout').read_bytes(),(ORACLE/'counterfactual.stdout').read_bytes())
 def test_owner_and_missing_frontier_rejected(self):
  m=helper();v=json.loads((ORACLE/'counterfactual.json').read_text());altered=copy.deepcopy(v);altered['ownedOutput']['log']['rows'][0]['payload']['sentinel'][-1]+=1
  self.assertNotEqual(m.parse('registered',(m.render('registered',altered)+'\n').encode()),v)
  del altered['ownedOutput']
  with self.assertRaises(AssertionError):m.render('registered',altered)
 def test_wrong_direct_namespace_refused(self):
  m=helper();raw=(ORACLE/'counterfactual.stdout').read_bytes();p,t=m.parser('registered');original=p.name(str(HERE.parent/'source/declaration-read-v1/registered-v1/observation.bend'),'LogView');changed=raw.replace(original.encode(),b'observation.LogView',1)
  self.assertNotEqual(changed,raw)
  with self.assertRaises(AssertionError):m.parse('registered',changed)
if __name__=='__main__':unittest.main()
