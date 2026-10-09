"""No-child diagnostic publication and strict shape controls."""
import importlib.util,json,tempfile,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('profile_run',HERE/'run.py');R=importlib.util.module_from_spec(spec);spec.loader.exec_module(R)
class Controls(unittest.TestCase):
 def test_failed_child_partial_profile_retained(self):
  with tempfile.TemporaryDirectory() as temp:
   out=Path(temp);artifact=out/'partial.cpuprofile';artifact.write_bytes(b'{partial')
   record={'commands':[]};pins={};result={'stdout':b'partial output','stderr':b'original error','exit':1,'failure':None}
   R.publish_result({'label':'CPU'},result,out,pins,record,artifact)
   self.assertEqual(record['commands'][0]['exit'],1);self.assertEqual(pins[str(artifact)],R.sha(artifact))
   self.assertEqual((out/'CPU.stderr').read_bytes(),b'original error')
 def test_publication_failure_retains_result_and_profile(self):
  with tempfile.TemporaryDirectory() as temp:
   out=Path(temp);artifact=out/'partial.heapprofile';artifact.write_bytes(b'{}');(out/'CPU.stderr').write_bytes(b'existing')
   record={'commands':[]};pins={}
   with self.assertRaises(ValueError):R.publish_result({'label':'CPU'},{'stdout':b'whole','stderr':b'error','exit':1,'failure':None},out,pins,record,artifact)
   self.assertEqual(record['commands'][0]['exit'],1);self.assertIn('publicationError',record['commands'][0]);self.assertEqual(pins[str(artifact)],R.sha(artifact))
 def test_nonregular_artifact_refuses_without_hang(self):
  with tempfile.TemporaryDirectory() as temp:
   out=Path(temp);artifact=out/'profile';artifact.mkdir();record={'commands':[]}
   with self.assertRaises(ValueError):R.publish_result({'label':'CPU'},{'stdout':b'','stderr':b'','exit':1},out,{},record,artifact)
   self.assertIn('artifactCaptureError',record['commands'][0])
if __name__=='__main__':unittest.main()
