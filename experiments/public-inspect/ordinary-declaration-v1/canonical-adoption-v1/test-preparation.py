"""No-child controls for the reused development recipe."""
import hashlib,json,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
path=Path(__file__).with_name('development.py')
M={'__file__':str(path),'__name__':'candidate_development'}
exec(compile(path.read_bytes(),str(path),'exec'),M)
class Controls(unittest.TestCase):
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
   plan={'scope':'mock publication control only','tools':{'python':str(interpreter)},'pins':pins,'generated':str(artifact),'native':str(native),'stage':str(stage),'entrypoint':str(entry),'sourceInventory':{str(entry):hashlib.sha256(entry.read_bytes()).hexdigest()},'importClosure':[str(entry)],'resourceRoots':{},'environment':{},'cwd':str(root),'commands':[{'label':'emit','argv':['mock-only'],'capSeconds':30}]}
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
 def test_actual_runtime_whole_counter_gate(self):
  import gzip,sys,types
  counter=b'MOCK.Report{MOCK.Delivered{[]},MOCK.Delivered{[]}}\n'
  baseline=b'MOCK.Report{MOCK.Delivered{[Read]},MOCK.Delivered{[Read]}}\n'
  for label,raw,valid in [('counter',counter,True),('normal',baseline,False),('last-byte',counter[:-1]+b'!',False),('omitted-owner',b'MOCK.Report{}\n',False)]:
   with self.subTest(label=label),tempfile.TemporaryDirectory() as directory:
    root=Path(directory);stage=root/'stage';stage.mkdir();entry=stage/'main.bend';entry.write_text('import Base\ndef main() -> U32: 0\n')
    oracle=root/'counter.gz';oracle.write_bytes(gzip.compress(counter));normal=root/'normal.gz';normal.write_bytes(gzip.compress(baseline))
    interpreter=Path(sys.executable).resolve()
    pins={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in [interpreter,oracle,normal]}
    boundary_path=M['ROOT']/'scripts/evidence_boundary.py';boundary=types.ModuleType('actual_boundary');boundary.__file__=str(boundary_path)
    exec(compile(boundary_path.read_bytes(),str(boundary_path),'exec'),boundary.__dict__)
    runner=types.SimpleNamespace(execute_result=lambda *args:{'exit':0,'failure':None,'stdout':raw,'stderr':b''},Inputs=lambda **kwargs:types.SimpleNamespace(expected={}))
    plan={'scope':'mock complete consumer gate only','subject':'mutant','tools':{'python':str(interpreter)},'pins':pins,'generated':str(root/'unused.js'),'native':str(root/'unused.native'),'stage':str(stage),'entrypoint':str(entry),'sourceInventory':{str(entry):hashlib.sha256(entry.read_bytes()).hexdigest()},'importClosure':[str(entry)],'resourceRoots':{},'environment':{},'cwd':str(root),'commands':[{'label':'consumer','argv':['mock-only'],'capSeconds':5}], 'oracle':str(oracle),'oracleSHA256':hashlib.sha256(counter).hexdigest(),'oracleBytes':len(counter),'normalOracle':str(normal),'normalOracleSHA256':hashlib.sha256(baseline).hexdigest(),'normalOracleBytes':len(baseline)}
    plan_path=root/'plan.json';plan_path.write_text(json.dumps(plan));digest=hashlib.sha256(plan_path.read_bytes()).hexdigest()
    with patch.dict(M,{'load':lambda name,*args:runner if name=='task_runner' else boundary}):
     if valid:M['run'](plan_path,digest)
     else:
      with self.assertRaisesRegex(ValueError,'Complete consumer byte output'):M['run'](plan_path,digest)
    receipt=json.loads((root/'receipt.json').read_text())
    self.assertEqual((root/'consumer.stdout').read_bytes(),raw)
    if valid:
     self.assertEqual(receipt['status'],'COMPLETE_CONSUMER_DEVELOPMENT_PASS')
     self.assertTrue(receipt['completeNormalBaselineRejected'])
    else:self.assertEqual(receipt['status'],'INCOMPLETE')
class PriorGuardControl(unittest.TestCase):
 def test_actual_run_refuses_prior_guard_byte_drift(self):
  import sys,types,gzip
  with tempfile.TemporaryDirectory() as directory:
   root=Path(directory);entry=root/'main.bend';entry.write_text('import Base\ndef main() -> U32: 0\n')
   interpreter=Path(sys.executable).resolve();artifact=root/'scenario.js'
   boundary_path=M['ROOT']/'scripts/evidence_boundary.py';boundary=types.ModuleType('actual_boundary');boundary.__file__=str(boundary_path)
   exec(compile(boundary_path.read_bytes(),str(boundary_path),'exec'),boundary.__dict__)
   calls=[]
   oracle=root/'oracle.gz';oracle.write_bytes(gzip.compress(b'complete captured'))
   def completed(argv,*args):
    calls.append(argv[0])
    if argv[0]=='mock-emit':artifact.write_bytes(b'generated mock')
    else:(root/'emit-pre.guard.json').write_bytes(b'tampered earlier guard')
    return {'exit':0,'failure':None,'stdout':b'complete captured','stderr':b''}
   runner=types.SimpleNamespace(execute_result=completed,Inputs=lambda **kwargs:types.SimpleNamespace(expected={}))
   plan={'scope':'mock prior guard tampering only','tools':{'python':str(interpreter)},'pins':{str(interpreter):hashlib.sha256(interpreter.read_bytes()).hexdigest()},'generated':str(artifact),'native':str(root/'unused.native'),'stage':str(root),'entrypoint':str(entry),'sourceInventory':{str(entry):hashlib.sha256(entry.read_bytes()).hexdigest()},'importClosure':[str(entry)],'resourceRoots':{},'environment':{},'cwd':str(root),'commands':[{'label':'emit','argv':['mock-emit'],'capSeconds':30},{'label':'consumer','argv':['mock-consumer'],'capSeconds':5}]}
   plan.update({'subject':'normal','oracle':str(oracle),'oracleBytes':len(b'complete captured'),'oracleSHA256':hashlib.sha256(b'complete captured').hexdigest()})
   plan_path=root/'plan.json';plan_path.write_text(json.dumps(plan));digest=hashlib.sha256(plan_path.read_bytes()).hexdigest()
   with patch.dict(M,{'load':lambda name,*args:runner if name=='task_runner' else boundary}):
    with self.assertRaisesRegex(ValueError,'Raw stream changed'):M['run'](plan_path,digest)
   receipt=json.loads((root/'receipt.json').read_text())
   self.assertEqual(calls,['mock-emit','mock-consumer']);self.assertEqual(receipt['status'],'INCOMPLETE')
   self.assertEqual(len(receipt['commands']),2);self.assertTrue(receipt['guardFailures'])
   self.assertEqual((root/'consumer.stdout').read_bytes(),b'complete captured')
if __name__=='__main__':unittest.main()
