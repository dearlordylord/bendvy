"""No-child completed-result/partial-artifact publication controls."""
import tempfile,unittest,types
from pathlib import Path
HERE=Path(__file__).parent
class Publication(unittest.TestCase):
 def test_second_stream_failure_retains_result_and_partial(self):
  for name in ['development-native.py']:
   with self.subTest(name=name),tempfile.TemporaryDirectory() as tmp:
    p=HERE/name;m=types.ModuleType(name);m.__file__=str(p);exec(compile(p.read_bytes(),str(p),'exec'),m.__dict__)
    out=Path(tmp);artifact=out/'partial';artifact.write_bytes(b'partial');record={'commands':[]};pins={};original=m.write_raw
    def failing(path,data):
     if path.name.endswith('.stderr'):raise OSError('second-stream refusal')
     original(path,data)
    m.write_raw=failing
    with self.assertRaisesRegex(OSError,'second-stream refusal'):
     m.publish_result({'label':'emit','argv':['mock'],'capSeconds':30},{'exit':1,'failure':'original-child-failure','stdout':b'out','stderr':b'err'},out,pins,record,artifact)
    row=record['commands'][0];self.assertEqual(row['exit'],1);self.assertEqual(row['failure'],'original-child-failure');self.assertEqual(row['stderr']['retainedRawHex'],'657272');self.assertEqual(pins[str(artifact)],m.sha(artifact));self.assertEqual((out/'emit.stdout').read_bytes(),b'out')
 def test_artifact_capture_does_not_replace_publication_failure(self):
  for name in ['development-native.py']:
   with tempfile.TemporaryDirectory() as tmp:
    p=HERE/name;m=types.ModuleType(name);m.__file__=str(p);exec(compile(p.read_bytes(),str(p),'exec'),m.__dict__);out=Path(tmp);artifact=out/'link';artifact.symlink_to(out/'absent');record={'commands':[]}
    m.write_raw=lambda *args:(_ for _ in()).throw(OSError('primary'))
    with self.assertRaisesRegex(OSError,'primary'):m.publish_result({'label':'emit'},{'exit':1,'stdout':b'x'},out,{},record,artifact)
    self.assertIn('artifactCaptureError',record['commands'][0])
if __name__=='__main__':unittest.main()
