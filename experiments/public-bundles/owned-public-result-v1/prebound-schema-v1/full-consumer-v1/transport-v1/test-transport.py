import unittest,types,json,hashlib
from pathlib import Path
p=Path(__file__).parent/'transport.py';m=types.ModuleType('transport');m.__file__=str(p);exec(compile(p.read_bytes(),str(p),'exec'),m.__dict__)
class CompleteString(unittest.TestCase):
 def test_complete_independent_literal(self):
  oracle=Path('/workspace/formal-proofs/bendvy-worktrees/review-46-native22-launch/experiments/public-bundles/owned-public-result-v1/prebound-schema-v1/full-consumer-v1/oracle-v1');actual=(oracle/'expected.stdout').read_bytes()
  self.assertEqual(len(actual),16012)
  self.assertEqual(hashlib.sha256(actual).hexdigest(),'db26a088d15fe4ee897fb3991f03b54ef344897d848cdc32bd47f2aa42e8fd8b')
  expected=json.loads((oracle/'expected.json').read_bytes());m.TERM.strict_equal(actual.decode('utf8'),expected)
  self.assertEqual(len(actual.decode().splitlines()),10)
  for wrong in [expected[:-1],expected.replace('observer-registry=', 'dropped-registry=',1),expected[:expected.rfind('B-cleanup')],expected.replace('[111, 112]','[111, 113]')]:
   self.assertNotEqual(wrong,expected)
   with self.assertRaises(ValueError):m.TERM.strict_equal(wrong,expected)
 def test_whole_wrong_binding(self):
  oracle=Path('/workspace/formal-proofs/bendvy-worktrees/review-46-native22-launch/experiments/public-bundles/owned-public-result-v1/prebound-schema-v1/full-consumer-v1/oracle-v1')
  raw=(oracle/'wrong-binding-expected.stdout').read_bytes();expected=json.loads((oracle/'wrong-binding-expected.json').read_bytes())
  self.assertEqual(len(raw),9660);self.assertEqual(hashlib.sha256(raw).hexdigest(),'3265f682b3650308fdfa89c6ccaa65f8fadc784e961c146db672a91ab1b8bab3');m.TERM.strict_equal(raw.decode(),expected)
  self.assertEqual(expected.count('SEED_SCHEMA_BIND_REJECTED'),5)
  for wrong in [expected[:-1],expected.replace('SEED_SCHEMA_BIND_REJECTED','UNEXPECTED_SEED_EXECUTION',1),expected[:expected.rfind('B-cleanup')],json.loads((oracle/'expected.json').read_bytes())]:
   self.assertNotEqual(wrong,expected)
   with self.assertRaises(ValueError):m.TERM.strict_equal(wrong,expected)
 def test_requires_string(self):
  for value in [None,[],{'before':'some'}]:
   with self.assertRaises(ValueError):m.TERM.strict_equal(value,'whole')
if __name__=='__main__':unittest.main()
