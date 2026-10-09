import unittest,types,json,hashlib
from pathlib import Path
p=Path(__file__).parent/'transport.py';m=types.ModuleType('transport');m.__file__=str(p);exec(compile(p.read_bytes(),str(p),'exec'),m.__dict__)
class CompleteString(unittest.TestCase):
 def test_complete_independent_literal(self):
  oracle=p.parent.parent/'oracle-v1';actual=(oracle/'expected.stdout').read_bytes()
  self.assertEqual(len(actual),16012)
  self.assertEqual(hashlib.sha256(actual).hexdigest(),'db26a088d15fe4ee897fb3991f03b54ef344897d848cdc32bd47f2aa42e8fd8b')
  expected=json.loads((oracle/'expected.json').read_bytes());m.TERM.strict_equal(actual.decode('utf8'),expected)
  self.assertEqual(len(actual.decode().splitlines()),10)
  for wrong in [expected[:-1],expected.replace('observer-registry=', 'dropped-registry=',1),expected[:expected.rfind('B-cleanup')],expected.replace('[111, 112]','[111, 113]')]:
   self.assertNotEqual(wrong,expected)
   with self.assertRaises(ValueError):m.TERM.strict_equal(wrong,expected)
 def test_requires_string(self):
  for value in [None,[],{'before':'some'}]:
   with self.assertRaises(ValueError):m.TERM.strict_equal(value,'whole')
if __name__=='__main__':unittest.main()
