import unittest,types,json
from pathlib import Path
p=Path(__file__).parent/'shared-public-join.py';m=types.ModuleType('join');m.__file__=str(p);exec(compile(p.read_bytes(),str(p),'exec'),m.__dict__)
class WholeJoin(unittest.TestCase):
 def test_all20_fullmodels(self):
  b=json.loads((p.parent/'registered-lifecycle-v1/oracle-v1/expected.json').read_bytes());t=json.loads((p.parent/'ts-semantic-v1/oracle-v1/expected.json').read_bytes());self.assertEqual(len(m.compare(b,t)['checkpoints']),20)
  for wrong in [b[:-1],b.replace('quarantine=1','quarantine=0'),b.replace('observer-registry=','omitted-registry=',1)]:
   self.assertNotEqual(wrong,b)
   with self.assertRaisesRegex(ValueError,'Entire Bend'):m.compare(wrong,t)
  for wrong in [t.replace('"retryIdentity":true','"retryIdentity":false'),t.replace('[51,52]','[51,53]'),t[:-1]]:
   self.assertNotEqual(wrong,t)
   with self.assertRaisesRegex(ValueError,'Entire TS'):m.compare(b,wrong)
 def test_partial_probe_refused(self):
  for wrong in ['missing:missing:tag:17/missing:missing:missing:missing','[1]:[2]:tag:true/missing:missing:missing:missing','[1]:[2]:tag:3']:
   with self.assertRaises(ValueError):m.rows(wrong)
if __name__=='__main__':unittest.main()
