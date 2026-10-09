"""No-child controls for the existing source capture and final guard composition."""
import importlib.util
import json
from pathlib import Path
from types import SimpleNamespace
import tempfile
import unittest
from unittest.mock import patch

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('source_boundary', HERE / 'check-source.py')
N = importlib.util.module_from_spec(spec)
spec.loader.exec_module(N)


class SourceBoundary(unittest.TestCase):
    def exercise(self, exit_code, drift=False):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            plan = json.loads((HERE / 'plan.json').read_text())
            plan['heavyLock'] = str(root / 'source.lock')
            sentinel = root / 'sentinel'
            sentinel.write_bytes(b'original')
            plan['pins'][str(sentinel)] = N.sha(sentinel)
            plan_path = root / 'plan.json'
            plan_path.write_text(json.dumps(plan))
            calls = []

            def fake(argv, cap, environment, cwd, capture):
                calls.append((argv, cap, environment, cwd, capture))
                if drift:
                    sentinel.write_bytes(b'changed')
                return {'exit': exit_code, 'failure': None, 'capture': 'split',
                        'stdout': b'controlled source stdout', 'stderr': b'controlled source stderr'}

            real_load = N.load

            def load(name, path):
                if name == 'existing_source_runner':
                    return SimpleNamespace(execute_result=fake)
                return real_load(name, path)

            with patch.object(N, 'load', load):
                if exit_code or drift:
                    with self.assertRaises(Exception):
                        N.run(plan_path, N.sha(plan_path))
                else:
                    N.run(plan_path, N.sha(plan_path))
            self.assertEqual(calls, [(plan['argv'], 5, plan['environment'], plan['cwd'], 'split')])
            capture = root / 'capture'
            receipt = json.loads((capture / 'receipt.json').read_text())
            self.assertEqual((capture / 'stdout').read_bytes(), b'controlled source stdout')
            self.assertEqual((capture / 'stderr').read_bytes(), b'controlled source stderr')
            self.assertEqual(len(receipt['guards']), 4)
            for label in ('pre', 'acquired', 'post', 'final'):
                guard = json.loads((capture / (label + '.guard.json')).read_text())
                self.assertEqual(guard['unchanged'], not (drift and label in ('post', 'final')))
            self.assertEqual(receipt.get('status') == 'SOURCE_PREREQUISITE_PASS', not (exit_code or drift))

    def test_exact_source_capture_without_children(self):
        self.exercise(0)

    def test_failed_source_raw_and_final_receipt_retained(self):
        self.exercise(1)

    def test_post_and_final_drift_prevent_pass(self):
        self.exercise(0, drift=True)


if __name__ == '__main__':
    unittest.main()
