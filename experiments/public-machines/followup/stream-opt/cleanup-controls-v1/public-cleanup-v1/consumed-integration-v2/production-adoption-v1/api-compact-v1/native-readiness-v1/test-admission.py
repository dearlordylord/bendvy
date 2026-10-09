"""Portable tiny preimport controls; no backend or private admitted-plan mutation."""
import hashlib,importlib.util,json,tempfile,types,unittest,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent

COLLECTORS = ['development-native.py']

def module(kind):
 p=HERE/kind;m=types.ModuleType('collector_'+kind);m.__file__=str(p);exec(compile(p.read_bytes(),str(p),'exec'),m.__dict__);return m

class Admission(unittest.TestCase):
 def test_transitive_drift_before_any_load(self):
  for kind in COLLECTORS:
   with self.subTest(kind=kind),tempfile.TemporaryDirectory() as tmp:
    m=module(kind);p=Path(tmp);helper=p/'transitive.py';helper.write_text('raise AssertionError("MUST NOT EXECUTE")\n');python=str(Path(sys.executable).resolve())
    plan={'tools':{'python':python},'pins':{python:m.sha(python),str(helper):'0'*64}};f=p/'plan.json';f.write_text(json.dumps(plan));m.load=lambda *args:(_ for _ in()).throw(AssertionError('runtime reached'))
    with self.assertRaisesRegex(ValueError,'before helper import'):m.run(f,m.sha(f))
 def test_cached_module_ignored(self):
  for kind in COLLECTORS:
   with self.subTest(kind=kind),tempfile.TemporaryDirectory() as tmp:
    m=module(kind);p=Path(tmp)/'source.py';p.write_text('VALUE = 17\n');m.VERIFIED_SOURCES={str(p):p.read_bytes()};cached=types.ModuleType('malicious');cached.VALUE=99;sys.modules['malicious']=cached
    try:self.assertEqual(m.load('malicious',p).VALUE,17)
    finally:del sys.modules['malicious']
 def test_bad_plan_digest_before_import(self):
  for kind in COLLECTORS:
   with self.subTest(kind=kind),tempfile.TemporaryDirectory() as tmp:
    m=module(kind);p=Path(tmp)/'plan.json';p.write_text('{}');m.load=lambda *args:(_ for _ in()).throw(AssertionError('runtime reached'))
    with self.assertRaisesRegex(ValueError,'digest mismatch'):m.run(p,'0'*64)

if __name__=='__main__':unittest.main()
