#!/usr/bin/env python3
"""No-child regular-file and raw-capture boundary controls."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from types import SimpleNamespace

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('js_boundary', HERE / 'development-js.py')
N = importlib.util.module_from_spec(spec)
spec.loader.exec_module(N)


class Boundary(unittest.TestCase):
    def test_regular_capture_and_digest(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / 'raw.stdout'
            N.write_raw(target, b'complete raw\n')
            self.assertEqual(N.sha(target), N.hashlib.sha256(b'complete raw\n').hexdigest())
            with self.assertRaises(ValueError): N.write_raw(target, b'replace')

    def test_linked_capture_refused_without_changing_target(self):
        with tempfile.TemporaryDirectory() as tmp:
            original = Path(tmp) / 'original'
            original.write_bytes(b'keep')
            target = Path(tmp) / 'raw.stdout'
            target.symlink_to(original)
            with self.assertRaises(ValueError): N.write_raw(target, b'changed')
            with self.assertRaises(ValueError): N.sha(target)
            self.assertEqual(original.read_bytes(), b'keep')
            target.unlink()
            target.symlink_to(Path(tmp) / 'absent')
            with self.assertRaises(ValueError): N.write_raw(target, b'new')
            with self.assertRaises(ValueError): N.sha(target)

    def test_nonregular_capture_and_hash_refused(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / 'raw.stdout'
            target.mkdir()
            with self.assertRaises(ValueError): N.write_raw(target, b'changed')
            with self.assertRaises(ValueError): N.sha(target)

    def test_failed_emit_partial_artifact_retained_without_consumer(self):
        with tempfile.TemporaryDirectory() as tmp:
            old = json.loads((HERE / 'main-js-v1/plan.json').read_text())
            old['pins'] = {p: N.sha(p) for p in old['pins']}
            generated = Path(tmp) / 'scenario.js'
            old['generated'] = str(generated)
            old['commands'][0]['argv'][-1] = str(generated)
            old['commands'][1]['argv'][-1] = str(generated)
            plan = Path(tmp) / 'plan.json'
            plan.write_text(json.dumps(old))
            calls = []
            def failed_emit(*args):
                calls.append(args)
                generated.write_bytes(b'partial generated output')
                return {'exit': 1, 'failure': 'controlled emit failure',
                        'stdout': b'original stdout', 'stderr': b'original stderr'}
            real_load = N.load
            def load(name, path):
                return SimpleNamespace(execute_result=failed_emit) if name == 'task_runner' else real_load(name, path)
            with patch.object(N, 'load', load):
                with self.assertRaisesRegex(ValueError, 'Owned child failed: emit'):
                    N.run(plan, N.sha(plan))
            receipt = json.loads((Path(tmp) / 'receipt.json').read_text())
            self.assertEqual(len(calls), 1)
            self.assertEqual(receipt['commands'][0]['failure'], 'controlled emit failure')
            self.assertEqual(receipt['generatedSHA256'], N.sha(generated))
            self.assertEqual((Path(tmp) / 'emit.stdout').read_bytes(), b'original stdout')
            self.assertEqual((Path(tmp) / 'emit.stderr').read_bytes(), b'original stderr')
            for label in ('emit-post', 'final'):
                guard = json.loads((Path(tmp) / (label + '.guard.json')).read_text())
                self.assertTrue(guard['unchanged'])
                self.assertEqual(guard['actualPins'][str(generated)], N.sha(generated))
            self.assertNotEqual(receipt.get('status'), 'DEVELOPMENT_PASS')

    def test_actual_interpreter_path_and_hash_drift_refused_before_helpers(self):
        with tempfile.TemporaryDirectory() as tmp:
            actual=str(Path(N.sys.executable).resolve(strict=True))
            for planned,digest in (('/unapproved/python','0'*64),(actual,'0'*64)):
                with self.subTest(planned=planned):
                    target=Path(tmp)/'plan.json'
                    target.write_text(json.dumps({'tools':{'python':planned},'pins':{planned:digest}}))
                    with self.assertRaisesRegex(ValueError,'Actual executor interpreter'):
                        N.run(target,N.sha(target))


if __name__ == '__main__': unittest.main()
