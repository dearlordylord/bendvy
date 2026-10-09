import copy,json,types,unittest
from pathlib import Path
H=Path(__file__).resolve().parent

def load(name):
 path=H/name;p=types.ModuleType(name);p.__file__=str(path);exec(compile(path.read_bytes(),str(path),'exec'),p.__dict__);return p
class Transport(unittest.TestCase):
 def test_whole_models_and_raw(self):
  for transport,oracle in [('transport.py','expected.json'),('transport-retainer.py','expected-retainer.json')]:
   p=load(transport);model=json.loads((H/oracle).read_bytes());raw=(p.render('generic',model)+'\n').encode()
   self.assertEqual(p.parse('generic',raw),model)
   with self.assertRaises(AssertionError):p.parse('generic',raw+b'\n')
 def test_complete_fields_and_typed_errors(self):
  p=load('transport.py');model=json.loads((H/'expected.json').read_bytes())
  for edit in [lambda x:x[-1].pop('resource'),lambda x:x[-1].update(clock=True),lambda x:x[-1]['readerResult']['value'].update(lagged=0)]:
   bad=copy.deepcopy(model);edit(bad)
   with self.assertRaises(AssertionError):p.render('generic',bad)
 def test_counter_rejects_entire_baseline(self):
  p=load('transport-retainer.py');a=json.loads((H/'expected.json').read_bytes());b=json.loads((H/'expected-retainer.json').read_bytes())
  self.assertNotEqual(a,b);self.assertNotEqual(p.render('generic',a),p.render('generic',b))
if __name__=='__main__':unittest.main()
