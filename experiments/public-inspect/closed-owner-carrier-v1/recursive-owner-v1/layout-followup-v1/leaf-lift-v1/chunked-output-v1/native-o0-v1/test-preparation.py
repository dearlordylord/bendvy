"""No-child controls for the reused development recipe."""
import hashlib,json,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
path=Path(__file__).with_name('development.py')
M={'__file__':str(path),'__name__':'candidate_development'}
exec(compile(path.read_bytes(),str(path),'exec'),M)
class Controls(unittest.TestCase):
 def test_failed_emission_receipt_refuses_before_child(self):
  import sys,types
  with tempfile.TemporaryDirectory()as directory:
   root=Path(directory);c=root/'input.c';c.write_bytes(b'exact retained C');old=root/'prior-plan.json';old.write_bytes(b'{}');receipt=root/'prior-receipt.json';digest=hashlib.sha256(old.read_bytes()).hexdigest();csha=hashlib.sha256(c.read_bytes()).hexdigest();receipt.write_text(json.dumps({'planSHA256':digest,'emitArtifactSHA256':csha,'commands':[{'label':'emit','exit':1,'failure':None}]}));python=Path(sys.executable).resolve();pins={str(x):hashlib.sha256(x.read_bytes()).hexdigest()for x in [python,c,old,receipt]};plan=root/'plan.json';plan.write_text(json.dumps({'tools':{'python':str(python)},'pins':pins,'scope':'control','generated':str(c),'native':str(root/'absent.native'),'retainedC':{'plan':str(old),'planSHA256':digest,'receipt':str(receipt),'sha256':csha}}));fake=types.SimpleNamespace(execute_result=lambda *a,**k:(_ for _ in ()).throw(AssertionError('child launched')))
   with patch.dict(M,{'load':lambda *a:fake}):
    with self.assertRaisesRegex(ValueError,'emission did not succeed'):M['run'](plan,hashlib.sha256(plan.read_bytes()).hexdigest())
 def test_wrong_digest_before_helpers(self):
  with tempfile.TemporaryDirectory() as directory:
   plan=Path(directory)/'plan.json';plan.write_text('{}')
   with patch.dict(M,{'load':lambda *args: (_ for _ in ()).throw(AssertionError('helper loaded'))}):
    with self.assertRaisesRegex(ValueError,'digest'):M['run'](plan,'0'*64)
 def test_wrong_interpreter_before_helpers(self):
  with tempfile.TemporaryDirectory() as directory:
   plan=Path(directory)/'plan.json';plan.write_text(json.dumps({'tools':{'python':'/unapproved/interpreter'},'pins':{}}))
   digest=hashlib.sha256(plan.read_bytes()).hexdigest()
   with patch.dict(M,{'load':lambda *args: (_ for _ in ()).throw(AssertionError('helper loaded'))}):
    with self.assertRaisesRegex(ValueError,'interpreter'):M['run'](plan,digest)
 def test_raw_regular_exclusive_and_link(self):
  with tempfile.TemporaryDirectory() as directory:
   root=Path(directory);target=root/'raw';M['write_raw'](target,b'whole');M['verify_raw'](target,hashlib.sha256(b'whole').hexdigest())
   with self.assertRaises(ValueError):M['write_raw'](target,b'overwrite')
   link=root/'link';link.symlink_to(target)
   with self.assertRaises(ValueError):M['verify_raw'](link,hashlib.sha256(b'whole').hexdigest())
   with self.assertRaises(ValueError):M['write_raw'](link,b'overwrite')
   target.write_bytes(b'changed')
   with self.assertRaises(ValueError):M['verify_raw'](target,hashlib.sha256(b'whole').hexdigest())
 def test_captured_source_ignores_loader_cache(self):
  with tempfile.TemporaryDirectory() as directory:
   helper=Path(directory)/'helper.py';helper.write_text('value="disk"')
   with patch.dict(M,{'VERIFIED_SOURCES':{str(helper.resolve()):b'value="captured"'}}):self.assertEqual(M['load']('captured_helper',helper).value,'captured')
 def test_full_oracle_last_byte_rejects(self):
  import gzip
  raw=gzip.decompress(path.with_name('complete-expected.txt.gz').read_bytes())
  self.assertEqual(len(raw),5077477);self.assertEqual(hashlib.sha256(raw).hexdigest(),M['EXPECTED'])
  self.assertNotEqual(hashlib.sha256(raw[:-1]+b'!').hexdigest(),M['EXPECTED'])
 def test_second_stream_failure_retains_child_and_partial_artifact(self):
  import sys,types
  with tempfile.TemporaryDirectory() as directory:
   root=Path(directory);stage=root/'stage';stage.mkdir();entry=stage/'output-io-main.bend';entry.write_text('def main() -> U32: 0\n')
   artifact=root/'partial.c';native=root/'unused.native';interpreter=Path(sys.executable).resolve()
   pins={str(interpreter):hashlib.sha256(interpreter.read_bytes()).hexdigest()}
   boundary_path=M['ROOT']/'scripts/evidence_boundary.py';boundary=types.ModuleType('actual_boundary');exec(compile(boundary_path.read_bytes(),str(boundary_path),'exec'),boundary.__dict__)
   def completed(*args):
    artifact.write_bytes(b'partial generated C')
    return {'exit':17,'failure':'mock child failure','stdout':b'first full raw','stderr':b'failed full raw\x00\xff','runnerSHA256':'mock-only'}
   runner=types.SimpleNamespace(execute_result=completed,Inputs=lambda **kwargs:types.SimpleNamespace(expected={}))
   plan={'scope':'mock publication control only','tools':{'python':str(interpreter)},'pins':pins,'generated':str(artifact),'native':str(native),'stage':str(stage),'sourceInventory':{'output-io-main.bend':hashlib.sha256(entry.read_bytes()).hexdigest()},'importClosure':['output-io-main.bend'],'resourceRoots':{},'environment':{},'cwd':str(root),'commands':[{'label':'emit','argv':['mock-only'],'capSeconds':30}]}
   plan_path=root/'plan.json';plan_path.write_text(json.dumps(plan));digest=hashlib.sha256(plan_path.read_bytes()).hexdigest();original_write=M['write_raw']
   def write(target,value):
    if Path(target).name=='emit.stderr':
     Path(target).write_bytes(b'partial stream')
     raise OSError('injected second stream publication')
    return original_write(target,value)
   def helper(name,*args):return runner if name=='task_runner' else boundary
   with patch.dict(M,{'load':helper,'write_raw':write}):
    with self.assertRaisesRegex(OSError,'second stream'):M['run'](plan_path,digest)
   receipt=json.loads((root/'receipt.json').read_text());self.assertEqual(receipt['status'],'INCOMPLETE');self.assertIn('injected second stream',receipt['error']);self.assertEqual(receipt['guardFailures'],[])
   self.assertEqual(len(receipt['commands']),1);row=receipt['commands'][0]
   self.assertEqual(row['exit'],17);self.assertEqual(row['failure'],'mock child failure')
   self.assertTrue(row['stdout']['published']);self.assertEqual((root/'emit.stdout').read_bytes(),b'first full raw')
   self.assertFalse(row['stderr']['published']);self.assertEqual(bytes.fromhex(row['stderr']['unpublishedHex']),b'failed full raw\x00\xff')
   self.assertEqual(row['stderr']['bytes'],len(b'failed full raw\x00\xff'))
   self.assertEqual(row['stderr']['partialSHA256'],hashlib.sha256(b'partial stream').hexdigest())
   self.assertEqual(receipt['emitArtifactSHA256'],hashlib.sha256(b'partial generated C').hexdigest())
   self.assertEqual([Path(row['path']).name for row in receipt['guards']],['emit-pre.guard.json','emit-acquired.guard.json','emit-post.guard.json','final.guard.json'])
if __name__=='__main__':unittest.main()
