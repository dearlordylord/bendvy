"""No-child whole-output and refusal controls for exact consuming cohorts."""
from pathlib import Path
import importlib.util,unittest,tempfile,gzip,hashlib
P=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('dev',P/'native-development.py');M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
h=lambda x:hashlib.sha256(x).hexdigest()
class Controls(unittest.TestCase):
 def test_complete_normal_and_mutant_oracles(self):
  oracle=P/'oracle-review-v1';normal=(oracle/'expected.stdout').read_bytes();mutant=(oracle/'absence-omission-expected.stdout').read_bytes()
  plan={'case':'normal','oracle':str(P/'complete-expected.txt.gz'),'oracleBytes':len(normal),'oracleSHA256':h(normal)}
  self.assertEqual(M.validate_consumer(plan,normal),[])
  for bad in [normal[:-1],normal.replace(b'absent;',b'',1),mutant]:
   with self.assertRaises(ValueError):M.validate_consumer(plan,bad)
  plan.update(case='absent-slot-omission',oracle=str(oracle/'absence-omission-expected.txt.gz'),oracleBytes=len(mutant),oracleSHA256=h(mutant),normalOracle=str(oracle/'expected.stdout'),normalOracleSHA256=h(normal),expectedWitnessCount=20)
  self.assertEqual(len(M.validate_consumer(plan,mutant)),20)
  with self.assertRaises(ValueError):M.validate_consumer(plan,normal)
  plan['expectedWitnessCount']=19
  with self.assertRaises(ValueError):M.validate_consumer(plan,mutant)
 def test_raw_absence_and_regular_guards(self):
  with tempfile.TemporaryDirectory()as directory:
   path=Path(directory)/'raw';M.write_raw(path,b'complete');M.verify_raw(path,h(b'complete'))
   with self.assertRaises(ValueError):M.write_raw(path,b'replace')
   link=Path(directory)/'symlink';link.symlink_to(path)
   with self.assertRaises(ValueError):M.write_raw(link,b'replace')
   with self.assertRaises(ValueError):M.verify_raw(link,h(b'complete'))
if __name__=='__main__':unittest.main()
