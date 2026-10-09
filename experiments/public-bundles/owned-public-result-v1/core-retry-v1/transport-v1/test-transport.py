import unittest,types
from pathlib import Path
p=Path(__file__).parent/'transport.py';m=types.ModuleType('transport');m.__file__=str(p);exec(compile(p.read_bytes(),str(p),'exec'),m.__dict__)
class CompleteString(unittest.TestCase):
 def test_exact(self):m.TERM.strict_equal(m.Transport(p).normalize('first\nlast\n'),'first\nlast\n')
 def test_complete_independent_literal(self):
  import json,hashlib
  oracle=p.parent.parent/'oracle-v1';actual=(oracle/'expected.stdout').read_bytes()
  self.assertEqual(len(actual),413)
  self.assertEqual(hashlib.sha256(actual).hexdigest(),'be2a5ef953db00a218013d108942834f513671262c1d966a944c7ce1a50dd8f3')
  expected=json.loads((oracle/'expected.json').read_bytes());m.TERM.strict_equal(actual.decode('utf8'),expected)
  for wrong in [actual.decode()[:-1],actual.decode().replace('returned=[7, 9]:11,end','returned=end'),actual.decode().split('retry-first=')[0]]:
   with self.assertRaises(ValueError):m.TERM.strict_equal(wrong,expected)
 def test_no_projection(self):
  for value in ['first\n','first\nlast','first\nwrong\n',None]:
   with self.assertRaises(ValueError):m.TERM.strict_equal(value,'first\nlast\n')
if __name__=='__main__':unittest.main()
