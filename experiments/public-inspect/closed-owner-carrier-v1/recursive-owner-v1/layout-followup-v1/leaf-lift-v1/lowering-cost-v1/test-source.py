from pathlib import Path
import difflib
import gzip
import hashlib
import json
import shutil
import sys
import unittest

HERE = Path(__file__).resolve().parent
ROOT = next(p for p in HERE.parents if (p / 'scripts/task_runner.py').is_file())
sys.path.insert(0, str(ROOT / 'scripts'))
from task_runner import run

CLEAN = '32fb66e09f608ce9e4b173384bcfeec453db8c5bc96650e26ad861bef815a8d9'
CACHE = 'b7d3fe0fbcbef0b78e3fdb2739f7397bd5e22f483fb05308c5b50005560f1560'


def validate(clean, cache, source, meta):
    def digest(raw):
        return hashlib.sha256(raw).hexdigest()
    if meta['cleanSHA256'] != CLEAN or meta['cacheSHA256'] != CACHE:
        raise ValueError('wrong baseline identity')
    if digest(clean) != CLEAN or digest(cache) != CACHE:
        raise ValueError('wrong frozen baseline bytes')
    if digest(source) != meta['instrumentedSHA256']:
        raise ValueError('instrumented bytes differ')
    inverse = source.decode().replace('import * as Cost from "./cost.mjs";\n', '', 1)
    inverse = inverse.replace('import * as Bend from "' + meta['bend'] + '";',
                              'import * as Bend from "./bend.ts";', 1)
    for line in ('  Cost.count(text === undefined ? "cacheMisses" : "cacheHits");\n',
                 '  Cost.count("valTo",fl.def);\n', '  Cost.line(line,fl.def);\n',
                 '  Cost.body(fl.def);\n',
                 '      const costToken=Cost.enter(k);let costCompleted=false;\n      try {\n',
                 '      costCompleted=true;\n      } finally { Cost.leave(costToken,costCompleted); }\n'):
        inverse = inverse.replace(line, '', 1)
    if inverse.encode() != cache:
        raise ValueError('instrumentation inverse differs from cache baseline')


class Source(unittest.TestCase):
    def setUp(self):
        self.clean = gzip.decompress((HERE / 'clean-comp.ts.gz').read_bytes())
        self.cache = gzip.decompress((HERE / 'cache-comp.ts.gz').read_bytes())
        self.source = (HERE / 'cost-comp.ts').read_bytes()
        self.meta = json.loads((HERE / 'COPY.json').read_bytes())

    def test_cache_and_observational_delta_are_separate(self):
        validate(self.clean, self.cache, self.source, self.meta)
        primary = ROOT / '.references/bend2/bend2/comp.ts'
        if primary.is_file():
            self.assertEqual(self.clean, primary.read_bytes())
        logical = self.meta['cacheSource'].split('/experiments/', 1)[1]
        current = ROOT / 'experiments' / logical
        if current.is_file():
            self.assertEqual(self.cache, current.read_bytes())
        for old, new, name, labels in (
                (self.clean, self.cache, 'cache.patch', ('clean32fb', 'cacheb7d3')),
                (self.cache, self.source, 'observational.patch', ('cacheb7d3', 'cost-comp.ts'))):
            patch = ''.join(difflib.unified_diff(old.decode().splitlines(True),
                           new.decode().splitlines(True), fromfile=labels[0], tofile=labels[1]))
            self.assertEqual(patch, (HERE / name).read_text())

    def test_wrong_baseline_metadata_cannot_preserve_inverse_credit(self):
        wrong = dict(self.meta, cleanSHA256=self.meta['cacheSHA256'])
        with self.assertRaisesRegex(ValueError, 'wrong baseline identity'):
            validate(self.clean, self.cache, self.source, wrong)

    def test_matching_digest_cannot_hide_changed_instrumented_semantics(self):
        changed = self.source.replace(b'const WIDE = 247', b'const WIDE = 246', 1)
        self.assertNotEqual(changed, self.source)
        wrong = dict(self.meta, instrumentedSHA256=hashlib.sha256(changed).hexdigest())
        with self.assertRaisesRegex(ValueError, 'instrumentation inverse differs'):
            validate(self.clean, self.cache, changed, wrong)

    def test_boundary_is_actual_done_defs_not_guessed_fid(self):
        self.assertIn('for (const [k, tld] of done_defs(fl).reverse()) {\n      const costToken=Cost.enter(k)', self.source.decode())
        self.assertNotIn(b'emit_body_observed', self.source)
        self.assertNotIn(b'Cost.enter(fl.def)', self.source)

    def test_clock_counter_controls_without_compiler_imports(self):
        node = shutil.which('node')
        self.assertIsNotNone(node, 'available Node required')
        result = run([node, str(HERE / 'controls.mjs')], timeout=5,
                     cwd=HERE, capture_output=True, check=True)
        self.assertIn(b'PASS per-definition clocks/counters/unfinished cutoff stack; no compiler', result.stdout)


if __name__ == '__main__':
    unittest.main()
