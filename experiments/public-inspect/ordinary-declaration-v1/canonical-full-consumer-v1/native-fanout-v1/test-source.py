"""Exact diagnostic inverse and consumer delta controls; no compiler import."""
import hashlib,json,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
class Controls(unittest.TestCase):
 def test_probe_exact_reference_inverse(self):
  copy=json.loads((HERE/'PROBE-COPY.json').read_text());original=Path(copy['referenceComp']).read_bytes();addition=(HERE/'probe-addition.txt').read_bytes();actual=(HERE/'probe-comp.ts').read_bytes()
  self.assertEqual(hashlib.sha256(original).hexdigest(),copy['referenceCompSha256'])
  rebound=original.replace(b'import * as Bend from "./bend.ts";',('import * as Bend from "'+copy['bend']+'";').encode())
  self.assertEqual(actual,rebound+addition)
  self.assertEqual(hashlib.sha256(actual).hexdigest(),copy['copySha256'])
  for forbidden in copy['prohibitedCalls']:self.assertNotIn(forbidden.encode(),addition)
  for required in ['file_book(','fun_of(','term_any(','flat_call(','fl.sites.get(','values instanceof Map','row.length>1']:self.assertIn(required.encode(),addition)
 def test_only_private_source_delta(self):
  delta=json.loads((HERE/'DELTA.json').read_text());self.assertEqual(len(delta['joins']),47)
  for row in delta['joins']:
   candidate=Path(row['candidate']);current=hashlib.sha256(candidate.read_bytes()).hexdigest()
   self.assertEqual(current,delta['modifiedSha256'] if str(candidate)==delta['modified'] else row['relocatedSha256'])
  text=Path(delta['modified']).read_text();original=delta['originalCheckTarget'];renamed=original.replace('def check_target(','def check_target_body(')
  self.assertIn(renamed,text)
  a=text.index('def check_target_flag(');b=text.index('def check_predicate(',a)
  self.assertEqual(text[a:b],delta['candidateCheckTarget'])
  self.assertEqual(delta['candidateCheckTarget'].count('case True{}:check_target_body('),1)
  self.assertEqual(delta['candidateCheckTarget'].count('case False{}:check_target_body('),1)
  old_signature=original.split(':\n',1)[0];self.assertIn(old_signature+':\n',text)
if __name__=='__main__':unittest.main()
