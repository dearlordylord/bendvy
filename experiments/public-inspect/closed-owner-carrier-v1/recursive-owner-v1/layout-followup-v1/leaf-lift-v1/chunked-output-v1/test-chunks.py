from pathlib import Path
import unittest,gzip,hashlib,json
h=Path(__file__).resolve().parent
class Chunks(unittest.TestCase):
 def test_whole_source_oracle_and_reached_countermodels(self):
  raw=gzip.decompress((h/'complete-expected.txt.gz').read_bytes());self.assertEqual(hashlib.sha256(raw).hexdigest(),'810259f78227f2b3d158c02644978b6c7ecf58b40a4b2fb398a816005b2867e2');self.assertEqual(len(raw),5077477)
  first=b'schema|Workshop\n';second=b'phase|';self.assertTrue(raw.startswith(first+second))
  drop=gzip.decompress((h/'expected-drop.txt.gz').read_bytes());reorder=gzip.decompress((h/'expected-reorder.txt.gz').read_bytes());self.assertEqual(drop,raw[len(first):]);self.assertEqual(reorder,second+first+raw[len(first+second):]);self.assertNotEqual(drop,raw);self.assertNotEqual(reorder,raw)
 def test_empty_multiline_unicode_leaf_order_and_lf(self):
  chunks=['','a\nb','λ','\n',''];self.assertEqual(''.join(chunks),'a\nbλ\n');self.assertNotEqual(''.join(reversed(chunks)),''.join(chunks))
 def test_complete_module_delta(self):
  inv=json.loads((h/'source-inventory.json').read_bytes());old=json.loads((h.parent/'source-inventory.json').read_bytes());self.assertEqual(len(inv),46);self.assertEqual([k for k in inv if inv[k]!=old[k]],['output-adapter.bend']);self.assertTrue(all(hashlib.sha256((h/'stage'/k).read_bytes()).hexdigest()==v for k,v in inv.items()))
if __name__=='__main__':unittest.main()
