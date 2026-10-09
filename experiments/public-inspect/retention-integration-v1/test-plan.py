"""No-child prepared plan admission checks; actual existing interpreter boundary."""
import hashlib,json,types,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
RUNNER=ROOT/'experiments/public-owned-events/declaration-read-v1/development-run.py'
r=types.ModuleType('existing_collector');r.__file__=str(RUNNER);exec(compile(RUNNER.read_bytes(),str(RUNNER),'exec'),r.__dict__)
class Plans(unittest.TestCase):
 def test_four_exact_current_cohorts(self):
  for row in json.loads((HERE/'PREPARED.json').read_bytes())['plans']:
   path=Path(row['plan']);plan=r.admitted_plan(path,row['planSha256']);r.interpreter_and_inputs(plan)
   self.assertEqual(len(plan['commands']),3 if row['native']else 2)
   self.assertFalse((path.parent/'receipt.json').exists())
   for name in ('raw','generated'):self.assertEqual(list((path.parent/name).iterdir()),[])
 def test_wrong_digest_and_interpreter_refuse_before_helpers(self):
  row=json.loads((HERE/'PREPARED.json').read_bytes())['plans'][0];path=Path(row['plan'])
  with self.assertRaisesRegex(AssertionError,'digest'):r.admitted_plan(path,'0'*64)
  plan=r.admitted_plan(path,row['planSha256']);plan['tools']['python']='/wrong/interpreter'
  with self.assertRaisesRegex(AssertionError,'interpreter path'):r.interpreter_and_inputs(plan)
if __name__=='__main__':unittest.main()
