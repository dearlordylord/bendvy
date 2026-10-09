"""No-child actual-profile-path refusal controls, not actual profile evidence."""
import json,runpy,sys,types,unittest
from pathlib import Path
from unittest.mock import patch
H=Path(__file__).resolve().parent
class Profile(unittest.TestCase):
 def test_current_paths(self):
  original=Path('/tmp/bendvy63-named-loop-qualification-v1/JS-run.stdout').read_bytes();validate=runpy.run_path(str(H/'validate-after-profile.py'))['validate'];seen=[]
  comparator=types.SimpleNamespace(stage_joins=lambda p:seen.append(str(p)),validate_report=lambda *a:None)
  def read(path):
   seen.append(str(path))
   if str(path)=='/tmp/bendvy63-named-loop-qualification-v1/JS-run.stdout':return original
   if str(path)=='/tmp/bendvy63-named-loop-after-profile-v1/simulation.cpuprofile':return json.dumps(dict(nodes=[{'id':1}],samples=[1],timeDeltas=[100])).encode()
   if str(path)=='/tmp/bendvy63-named-loop-after-profile-v1/simulation.heapprofile':return json.dumps(dict(head={},samples=[])).encode()
   raise AssertionError('unexpected/stale profile path '+str(path))
  with patch.dict(sys.modules,simulation_delivery_compare=comparator),patch.object(Path,'read_bytes',read):
   validate('CPU',original,b'');validate('allocation',original,b'')
   with self.assertRaises(ValueError):validate('CPU',original[:-1],b'')
  self.assertIn('/tmp/bendvy63-named-loop-after-profile-v1/simulation.cpuprofile',seen);self.assertIn('/tmp/bendvy63-named-loop-after-profile-v1/simulation.heapprofile',seen);self.assertIn('/tmp/bendvy63-named-loop-stage-v1',seen)
if __name__=='__main__':unittest.main()
