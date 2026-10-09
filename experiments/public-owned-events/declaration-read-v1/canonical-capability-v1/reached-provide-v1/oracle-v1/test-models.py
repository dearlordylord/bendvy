import copy,hashlib,json,types,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
m=types.ModuleType('independent_expected');m.__file__=str(HERE/'expected.py');exec(compile((HERE/'expected.py').read_bytes(),str(HERE/'expected.py'),'exec'),m.__dict__)
class Models(unittest.TestCase):
 def test_complete_models_and_raw(self):
  for role in m.roles:
   value,raw=m.model(role);self.assertEqual(value,json.loads((HERE/(role+'-expected.json')).read_bytes()));self.assertEqual(raw,(HERE/(role+'-expected.stdout')).read_bytes());self.assertEqual(value,json.loads((m.ROOT/m.roles[role][0]).read_bytes()))
 def test_complete_retained_nested_fields(self):
  for role in m.roles:
   value,raw=m.model(role)
   self.assertGreater(len(raw),1000)
   self.assertIn(b'World',raw)
   self.assertTrue(raw.endswith(b'\n'))
 def test_source_basis_current(self):
  basis=json.loads((HERE/'source-basis.json').read_bytes())
  for path,digest in basis['pins'].items():self.assertEqual(hashlib.sha256(Path(path).read_bytes()).hexdigest(),digest,path)
if __name__=='__main__':unittest.main()
