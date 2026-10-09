#!/usr/bin/env python3
"""No-child omission/drift controls for exact progressive native stage pins."""
import copy
import importlib.util
from pathlib import Path
import tempfile
import unittest

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('app_native_aggregate', HERE / 'aggregate-native.py')
A = importlib.util.module_from_spec(spec)
spec.loader.exec_module(A)


class Pins(unittest.TestCase):
    def test_progressive_full_pins_and_omission_drift(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            plan_path = root / 'plan.json'
            plan_path.write_text('{}')
            source = root / 'source.bend'
            source.write_text('source')
            c = root / 'scenario.c'
            c.write_bytes(b'C artifact')
            native = root / 'scenario.native'
            native.write_bytes(b'Native artifact')
            plan = {'pins': {str(source): A.sha(source)}, 'generated': str(c), 'native': str(native)}
            receipt = {'planSHA256': A.sha(plan_path), 'emitArtifactSHA256': A.sha(c), 'buildArtifactSHA256': A.sha(native), 'commands': []}
            for label in ('emit', 'build', 'consumer'):
                row = {'label': label}
                for stream in ('stdout', 'stderr'):
                    path = root / (label + '.' + stream)
                    path.write_bytes((label + stream).encode())
                    row[stream] = {'path': str(path), 'sha256': A.sha(path)}
                receipt['commands'].append(row)
            expected = A.expected_guard_pins(plan_path, plan, receipt)
            self.assertEqual(len(expected['emit-pre']), 2)
            self.assertEqual(len(expected['emit-post']), 5)
            self.assertEqual(len(expected['build-post']), 8)
            self.assertEqual(len(expected['final']), 10)
            for label, pins in expected.items():
                A.verify_guard_state({'label': label, 'actualPins': pins}, expected)
                for kind in ('omission', 'drift', 'extra'):
                    changed = copy.deepcopy(pins)
                    key = next(iter(changed))
                    if kind == 'omission': del changed[key]
                    elif kind == 'drift': changed[key] = '0' * 64
                    else: changed['unadmitted-extra'] = '0' * 64
                    with self.assertRaises(ValueError): A.verify_guard_state({'label': label, 'actualPins': changed}, expected)
            changed = dict(expected['build-post'])
            del changed[str(c)]
            with self.assertRaises(ValueError): A.verify_guard_state({'label': 'build-post', 'actualPins': changed}, expected)
            with self.assertRaises(ValueError): A.verify_guard_state({'label': 'emit-pre', 'actualPins': expected['final']}, expected)


if __name__ == '__main__': unittest.main()
