"""Portable source bootstrap controls plus full synthetic transport checks."""
import hashlib
import json
from pathlib import Path
import tempfile
import unittest
HERE = Path(__file__).resolve().parent
namespace = {'__file__': str(HERE / 'run-delivery.py'), '__name__': 'delivery_controls'}
exec(compile((HERE / 'run-delivery.py').read_bytes(), str(HERE / 'run-delivery.py'), 'exec'), namespace)
sha = lambda raw: hashlib.sha256(raw).hexdigest()

class Bootstrap(unittest.TestCase):
    def test_interpreter_before_import(self):
        with tempfile.TemporaryDirectory() as name:
            path = Path(name) / 'plan'; path.write_text(json.dumps({'python': '/wrong', 'pins': {}}))
            with self.assertRaisesRegex(ValueError, 'interpreter drift'): namespace['admitted'](path, sha(path.read_bytes()))
    def test_exact_plan_digest(self):
        with tempfile.TemporaryDirectory() as name:
            path = Path(name) / 'plan'; path.write_bytes(b'{}')
            with self.assertRaisesRegex(ValueError, 'exact delivery plan'): namespace['admitted'](path, '0' * 64)
    def test_regular_alias_refused(self):
        with tempfile.TemporaryDirectory() as name:
            root = Path(name); file = root / 'regular'; file.write_bytes(b'actual'); alias = root / 'alias'; alias.symlink_to(file)
            with self.assertRaises(OSError): namespace['regular'](alias)
            with self.assertRaises(ValueError): namespace['regular'](root)
    def test_nonzero_emit_retains_raw_partial_and_final_receipt(self):
        import types
        from unittest.mock import patch
        root_repo = Path('/workspace/formal-proofs/bendvy')
        def actual_module(path):
            value = types.ModuleType('control_' + path.stem); value.__file__ = str(path)
            exec(compile(path.read_bytes(), str(path), 'exec'), value.__dict__); return value
        runner = actual_module(root_repo / 'scripts/task_runner.py')
        boundary = actual_module(root_repo / 'scripts/evidence_boundary.py')
        logs = actual_module(root_repo / 'scripts/receipt-logs.py')
        with tempfile.TemporaryDirectory() as name:
            root = Path(name); stage = root / 'stage'; stage.mkdir(); source = stage / 'source'; source.write_bytes(b'fixture')
            out = root / 'output'; planpath = root / 'plan'; planpath.write_bytes(b'{}')
            plan = {'scope': 'control', 'outputRoot': str(out), 'stageRoot': str(stage), 'stagePins': {'source': sha(b'fixture')}, 'helpers': {'runner': 'runner', 'boundary': 'boundary', 'logs': 'logs', 'tools': 'tools', 'metadata': 'metadata'}, 'comparator': 'compare', 'parser': 'parser', 'tsJoiner': 'joiner', 'smallInputPaths': [], 'toolConfiguration': {'env': {}, 'taskset': '/taskset'}, 'constructorJoins': {}, 'namespaceLiterals': [], 'namespace': {}, 'configPresence': {}, 'maximumProbeCommands': 0, 'lock': str(root / 'lock'), 'commands': [{'label': 'JS-emit', 'argv': ['/fake-emit'], 'capSeconds': 30, 'emits': 'simulation.js'}]}
            def fake_execute(*args, **kwargs):
                (out / 'simulation.js').write_bytes(b'partial-emitted-js')
                return {'exit': 7, 'failure': None, 'stdout': b'compiler-out', 'stderr': b'compiler-error', 'runnerSHA256': 'controlled'}
            runner.execute_result = fake_execute
            modules = {'runner': runner, 'boundary': boundary, 'logs': logs, 'tools': types.SimpleNamespace(snapshot=lambda **kwargs: {}, verify=lambda *args, **kwargs: {}), 'metadata': types.SimpleNamespace(namespace_state=lambda *args: {}), 'compare': types.SimpleNamespace(stage_joins=lambda stage: {}), 'parser': types.SimpleNamespace(parse=lambda value: {}, render=lambda value: ''), 'joiner': types.SimpleNamespace()}
            with patch.dict(namespace, admitted=lambda *args: (plan, {}), load=lambda key, path, pins: modules[path]):
                with self.assertRaisesRegex(RuntimeError, 'unexpected command exit'): namespace['run'](planpath, 'controlled')
            record = json.loads((out / 'receipt.json').read_bytes())
            self.assertEqual(record['status'], 'INCOMPLETE'); self.assertEqual(record['guardFailures'], [])
            self.assertEqual(record['commands'][0]['exit'], 7)
            self.assertEqual(bytes.fromhex(record['commands'][0]['stdout']['rawHex']), b'compiler-out')
            self.assertEqual((out / 'JS-emit.stderr').read_bytes(), b'compiler-error')
            self.assertEqual(record['generated']['simulation.js'], sha(b'partial-emitted-js'))
            for label in ['JS-emit-post', 'final']:
                guard = json.loads((out / (label + '.guard.json')).read_bytes())
                self.assertEqual(guard['generated']['simulation.js'], sha(b'partial-emitted-js'))
    def test_source_bytes_before_helper(self):
        with tempfile.TemporaryDirectory() as name:
            file = Path(name) / 'helper.py'; file.write_bytes(b'raise RuntimeError("executed")\n')
            with self.assertRaisesRegex(ValueError, 'helper drift'): namespace['load']('bad_helper', file, {str(file): '0' * 64})

if __name__ == '__main__': unittest.main()
