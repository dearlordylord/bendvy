from pathlib import Path
import tarfile,hashlib,json,unittest
HERE=Path(__file__).resolve().parent
class Source(unittest.TestCase):
 def test_exact_compiler_inverse_and_no_emission_export(self):
  copy=json.loads((HERE/'COPY.json').read_bytes())
  with tarfile.open(copy['archive'])as archive:original=archive.extractfile('comp.ts').read()
  source=(HERE/'probe-comp.ts').read_bytes();addition=(HERE/'addition.txt').read_bytes()
  self.assertEqual(hashlib.sha256(original).hexdigest(),copy['originalCompSHA256'])
  self.assertEqual(hashlib.sha256(source).hexdigest(),copy['copySHA256'])
  rebound=original.replace(b'import * as Bend from "./bend.ts";',('import * as Bend from "'+copy['bend']+'";').encode())
  self.assertEqual(source,rebound+addition)
  self.assertNotIn(b'emit_body(',addition);self.assertNotIn(b'val_to(',addition);self.assertNotIn(b'compile_book(',addition)
  self.assertIn(b'file_book(',addition);self.assertIn(b'fun_of(',addition);self.assertIn(b'lay_node(',addition)
 def test_exact_generated_membership_not_suffix_guess(self):
  source=(HERE/'addition.txt').read_text()
  self.assertIn('values instanceof Map',source);self.assertIn('origins.length>1',source)
  self.assertNotIn('split("~")',source)
if __name__=='__main__':unittest.main()
