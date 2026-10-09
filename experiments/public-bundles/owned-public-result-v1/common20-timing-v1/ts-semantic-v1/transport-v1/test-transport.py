import unittest,types,json,hashlib
from pathlib import Path
p=Path(__file__).parent/'transport.py';m=types.ModuleType('transport');m.__file__=str(p);exec(compile(p.read_bytes(),str(p),'exec'),m.__dict__)
class CompleteString(unittest.TestCase):
 def test_entire_original_independent_literal(self):
  o=p.parent.parent/'oracle-v1';raw=(o/'expected.stdout').read_bytes();self.assertEqual(hashlib.sha256(raw).hexdigest(),'ee4c8437e4a2644cd9931945e9e40e8368810d4b8c321bec1534ab9874436974');expected=json.loads((o/'expected.json').read_bytes());m.TERM.strict_equal(raw.decode(),expected)
  full=json.loads(expected);self.assertEqual(len(full),10);self.assertEqual(sum(len(a['checkpoints']) for a in full),20)
  for wrong in [expected[:-1],expected.replace('"retryIdentity":true','"retryIdentity":false'),json.dumps(full[:-1]),expected.replace('[51,52]','[51,53]')]:
   self.assertNotEqual(wrong,expected)
   with self.assertRaises(ValueError):m.TERM.strict_equal(wrong,expected)
if __name__=='__main__':unittest.main()
