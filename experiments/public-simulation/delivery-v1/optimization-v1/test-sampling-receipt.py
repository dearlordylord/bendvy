"""No-child incomplete/postguard refusal controls for the actual preparation seam."""
import copy,runpy,unittest
from pathlib import Path
admit=runpy.run_path(str(Path(__file__).with_name('prepare-sampling.py')))['admit_receipt']
class Receipt(unittest.TestCase):
 def test_terminal_only(self):
  good=dict(planSHA256='frozen',status='REACHED_TIMING_SEQUENCE_CONTROLS_PASS_NOT_MEASUREMENT',commands=[dict(exit=0,failure=None)for _ in range(4)],cases={name:dict(reachedControlMatch=True)for name in ['timed-TS','timed-JS','timed-Native']})
  admit(good,'frozen')
  for field,value in [('status','INCOMPLETE'),('error','final capture failed'),('guardFailures',['final drift']),('planSHA256','different')]:
   bad=copy.deepcopy(good);bad[field]=value
   with self.assertRaises(ValueError):admit(bad,'frozen')
  for mutator in [lambda r:r['commands'].pop(),lambda r:r['commands'][3].update(exit=1),lambda r:r['commands'][3].update(failure='deadline'),lambda r:r['cases'].pop('timed-Native'),lambda r:r['cases']['timed-JS'].update(reachedControlMatch=False)]:
   bad=copy.deepcopy(good);mutator(bad)
   with self.assertRaises(ValueError):admit(bad,'frozen')
if __name__=='__main__':unittest.main()
