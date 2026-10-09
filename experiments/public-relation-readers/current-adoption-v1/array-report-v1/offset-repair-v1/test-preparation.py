"""No-child exact source-delta and full consuming boundary controls."""
import gzip, hashlib, importlib.util, json, re, tempfile, unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('repair', HERE / 'development-run.py')
N = importlib.util.module_from_spec(spec)
spec.loader.exec_module(N)

class Preparation(unittest.TestCase):
    def test_exact_parentheses_only(self):
        old = (HERE.parent / 'development-native-v2/scenario.c').read_bytes()
        new = gzip.decompress((HERE / 'source.c.gz').read_bytes())
        pattern = rb'(\b(?P<array>[A-Za-z_][A-Za-z_0-9]*) == h(?P<index>[0-9]+) \? q(?P=index) : blk_loc\(e\.mem, (?P=array)\))(?= \+)'
        self.assertEqual(new, re.sub(pattern, lambda m: b'(' + m.group(1) + b')', old))
        self.assertEqual(len(list(re.finditer(pattern, old))), 456)

    def test_whole_oracle_and_failed_partial_build(self):
        for fail in (False, True):
            with self.subTest(fail=fail), tempfile.TemporaryDirectory() as tmp:
                plan = json.loads((HERE / 'prepared-plan.json').read_text())
                native = Path(tmp) / 'scenario.native'
                plan['native'] = str(native)
                target = Path(tmp) / 'plan.json'
                target.write_text(json.dumps(plan))
                calls = []
                def child(*args):
                    calls.append(args)
                    if len(calls) == 1:
                        native.write_bytes(b'partial' if fail else b'mock binary')
                        return {'exit': 1 if fail else 0, 'failure': None, 'stdout': b'', 'stderr': b'primary build failure' if fail else b''}
                    return {'exit': 0, 'failure': None, 'stdout': (HERE.parent / 'transport-v1/synthetic.stdout').read_bytes(), 'stderr': b''}
                real_load = N.load
                with patch.object(N, 'load', lambda name,path: SimpleNamespace(execute_result=child, Inputs=real_load(name,path).Inputs) if name == 'task_runner' else real_load(name,path)):
                    if fail:
                        with self.assertRaisesRegex(ValueError, 'Owned child failed: build'): N.run(target,N.sha(target))
                    else: N.run(target,N.sha(target))
                receipt = json.loads((Path(tmp) / 'receipt.json').read_text())
                self.assertEqual(receipt['buildArtifactSHA256'], N.sha(native))
                self.assertEqual(len(calls), 1 if fail else 2)
                final = json.loads((Path(tmp) / 'final.guard.json').read_text())
                self.assertTrue(final['unchanged'])
                self.assertEqual(final['actualPins'][str(native)], N.sha(native))
                if not fail:
                    self.assertEqual(receipt['wholeOracleSHA256'], N.EXPECTED)
                    self.assertEqual(receipt['status'], 'PATCHED_C_DEVELOPMENT_PASS')

if __name__ == '__main__': unittest.main()
