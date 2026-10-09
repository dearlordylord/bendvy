import json,unittest
import wire
class PureString(unittest.TestCase):
 def test_three_full_semantic_bodies(self):
  for prefix in ['expected','mutant-expected','flow-only-expected']:
   rows=(wire.HERE/(prefix+'.stdout')).read_text()
   raw=wire.expected(prefix)
   self.assertEqual(json.loads(raw),rows[:-1])
   self.assertEqual(raw.count(b'\n'),1)
   self.assertTrue(raw.startswith(b'"SCHEMA=A\\n'))
   self.assertTrue(raw.endswith(b'"\n'))
 def test_pinned_char_rules(self):
  self.assertEqual(wire.pure_string('"\\\n\t\r\0\x01\x7f'),b'"\\"\\\\\\n\\t\\r\\0\\u{1}\\u{7f}"\n')
  self.assertEqual(wire.pure_string('é'),b'"\xc3\xa9"\n')
if __name__=='__main__':unittest.main()
