import unittest,types
from pathlib import Path
p=Path(__file__).parent/'transport.py';m=types.ModuleType('transport');m.__file__=str(p);exec(compile(p.read_bytes(),str(p),'exec'),m.__dict__)
class CompleteString(unittest.TestCase):
 def test_exact(self):m.TERM.strict_equal(m.Transport(p).normalize('first\nlast\n'),'first\nlast\n')
 def test_no_projection(self):
  for value in ['first\n','first\nlast','first\nwrong\n',None]:
   with self.assertRaises(ValueError):m.TERM.strict_equal(value,'first\nlast\n')
if __name__=='__main__':unittest.main()
