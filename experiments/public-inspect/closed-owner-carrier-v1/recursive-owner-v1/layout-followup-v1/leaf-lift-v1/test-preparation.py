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
 def test_full_oracle_last_byte_rejects(self):
  import gzip
  raw=gzip.decompress(path.with_name('complete-expected.txt.gz').read_bytes())
  self.assertEqual(len(raw),5077477);self.assertEqual(hashlib.sha256(raw).hexdigest(),M['EXPECTED'])
  self.assertNotEqual(hashlib.sha256(raw[:-1]+b'!').hexdigest(),M['EXPECTED'])
if __name__=='__main__':unittest.main()
