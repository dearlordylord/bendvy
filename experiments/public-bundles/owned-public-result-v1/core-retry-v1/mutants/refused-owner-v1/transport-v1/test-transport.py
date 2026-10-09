import unittest,types,json
from pathlib import Path
p=Path(__file__).parent/'transport.py';m=types.ModuleType('transport');m.__file__=str(p);exec(compile(p.read_bytes(),str(p),'exec'),m.__dict__)
class EntireCounterfactual(unittest.TestCase):
 def test_whole_and_baseline(self):
  o=p.parent.parent/'oracle-v1';actual=(o/'expected.stdout').read_bytes().decode();expected=json.loads((o/'expected.json').read_bytes());m.TERM.strict_equal(actual,expected)
  for wrong in [json.loads((o/'baseline.json').read_bytes()),actual[:-1],actual.replace('returned=[7, 9]:23,end','returned=end')]:
   with self.assertRaises(ValueError):m.TERM.strict_equal(wrong,expected)
if __name__=='__main__':unittest.main()
