import json,types,unittest,tempfile,py_compile,os
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def exact(path):
 m=types.ModuleType('test_module');m.__file__=str(path);exec(compile(path.read_bytes(),str(path),'exec'),m.__dict__);return m
class Controls(unittest.TestCase):
 def test_full_neutral_roundtrip(self):
  for role,file,model in [('registered','registered-transport.py',ROOT/'declaration-read-v1/oracle-v1/registered-expected.json'),('full','system-transport.py',ROOT/'system-event-v1/generic-v1/oracle-v1/full-expected.json'),('second','system-transport.py',ROOT/'system-event-v1/generic-v1/oracle-v1/second-expected.json')]:
   m=exact(HERE/file);v=json.loads(model.read_text());raw=(m.render(role,v)+'\n').encode();self.assertEqual(m.parse(role,raw),v)
   with self.assertRaises(AssertionError):m.parse(role,raw+b'\n')
 def test_interpreter_before_helper(self):
  m=exact(ROOT/'system-event-v1/generic-v1/development-run.py')
  with self.assertRaisesRegex(AssertionError,'interpreter path'):m.interpreter_and_inputs({'tools':{'python':'/wrong'}})
 def test_cached_helper_not_executed(self):
  m=exact(ROOT/'system-event-v1/generic-v1/development-run.py')
  with tempfile.TemporaryDirectory() as d:
   p=Path(d)/'helper.py';p.write_text('value="stale"\n');py_compile.compile(str(p));p.write_text('value="fresh"\n')
   m.VERIFIED_SOURCES={str(p.resolve()):b'value="captured"\n'}
   self.assertEqual(m.load('sentinel',p).value,'captured')
if __name__=='__main__':unittest.main()
