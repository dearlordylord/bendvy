from pathlib import Path
import unittest,gzip,json,hashlib
HERE=Path(__file__).resolve().parent
class Source(unittest.TestCase):
 def test_cache_and_observational_delta_are_separate(self):
  clean=gzip.decompress((HERE/'clean-comp.ts.gz').read_bytes());cache=gzip.decompress((HERE/'cache-comp.ts.gz').read_bytes());meta=json.loads((HERE/'COPY.json').read_bytes())
  self.assertEqual(hashlib.sha256(clean).hexdigest(),meta['cleanSHA256']);self.assertEqual(hashlib.sha256(cache).hexdigest(),meta['cacheSHA256'])
  self.assertEqual(clean,Path(meta['cleanSource']).read_bytes());self.assertEqual(cache,Path(meta['cacheSource']).read_bytes())
  source=(HERE/'cost-comp.ts').read_bytes();self.assertEqual(hashlib.sha256(source).hexdigest(),meta['instrumentedSHA256'])
  source=source.decode().replace('import * as Cost from "./cost.mjs";\n','',1).replace('import * as Bend from "'+meta['bend']+'";','import * as Bend from "./bend.ts";',1)
  for line in ('  Cost.count(text === undefined ? "cacheMisses" : "cacheHits");\n','  Cost.count("valTo",fl.def);\n','  Cost.line(line,fl.def);\n','  Cost.body(fl.def);\n','      const costToken=Cost.enter(k);let costCompleted=false;\n      try {\n','      costCompleted=true;\n      } finally { Cost.leave(costToken,costCompleted); }\n'):source=source.replace(line,'',1)
  self.assertEqual(source.encode(),cache)
 def test_boundary_is_actual_done_defs_not_guessed_fid(self):
  s=(HERE/'cost-comp.ts').read_text();self.assertIn('for (const [k, tld] of done_defs(fl).reverse()) {\n      const costToken=Cost.enter(k)',s)
  self.assertNotIn('emit_body_observed',s);self.assertNotIn('Cost.enter(fl.def)',s)
if __name__=='__main__':unittest.main()
