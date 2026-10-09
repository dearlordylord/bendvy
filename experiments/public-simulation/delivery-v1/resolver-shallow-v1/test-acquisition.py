"""Portable no-child admission/bootstrap controls."""
import hashlib
import json
from pathlib import Path
import py_compile
import sys
import tempfile
import unittest
HERE = Path(__file__).resolve().parent
namespace = {'__file__': str(HERE / 'acquire.py'), '__name__': 'acquisition_controls'}
exec(compile((HERE / 'acquire.py').read_bytes(), str(HERE / 'acquire.py'), 'exec'), namespace)
sha = lambda raw: hashlib.sha256(raw).hexdigest()

class Controls(unittest.TestCase):
    def test_wrong_interpreter_refuses_before_helper(self):
        with tempfile.TemporaryDirectory() as name:
            path = Path(name) / 'plan.json'; path.write_text(json.dumps({'python': '/wrong/python', 'sourcePins': {}}))
            with self.assertRaisesRegex(ValueError, 'interpreter drift'): namespace['admitted'](path, sha(path.read_bytes()))
    def test_bad_plan_digest_refuses(self):
        with tempfile.TemporaryDirectory() as name:
            path = Path(name) / 'plan.json'; path.write_bytes(b'{}')
            with self.assertRaisesRegex(ValueError, 'exact acquisition plan'): namespace['admitted'](path, '0' * 64)
    def test_exact_helper_bytes_ignore_stale_pyc(self):
        with tempfile.TemporaryDirectory() as name:
            path = Path(name) / 'helper.py'; path.write_bytes(b'VALUE=1\n'); py_compile.compile(str(path)); metadata = path.stat()
            path.write_bytes(b'VALUE=2\n')
            import os
            os.utime(path, ns=(metadata.st_atime_ns, metadata.st_mtime_ns))
            module = namespace['load']('controlled_helper', path, {str(path.resolve()): sha(path.read_bytes())})
            self.assertEqual(module.VALUE, 2)
    def test_probe_result_survives_second_stream_publication_failure(self):
        import types
        from unittest.mock import patch
        with tempfile.TemporaryDirectory() as name:
            root = Path(name)
            command = {'name': 'one', 'argv': ['/taskset', '-c', '5', '/ldd', '/tool']}
            declaration = {'resolver_inputs': [], 'loader_search_directories': [], 'namespace': {}, 'cost': {}, 'discoveryCommands': [command], 'configuration': {'execute': 'adapter', 'env': {}}}
            plan = {'outputRoot': str(root), 'declaration': declaration, 'resourceMetadata': {}, 'toolPins': {}, 'helpers': {'runner': 'runner', 'pins': 'pins', 'metadata': 'metadata'}}
            result = {'exit': 7, 'failure': None, 'stdout': b'completed', 'stderr': b'error'}
            class FakePins:
                def __init__(self, **kwargs): kwargs['execute'](command['argv'], 5, {})
            modules = {'runner': types.SimpleNamespace(execute_result=lambda *args: result), 'pins': types.SimpleNamespace(PinnedTools=FakePins), 'metadata': types.SimpleNamespace(namespace_state=lambda *args: {})}
            actual_publish = namespace['publish']
            def failing_publish(path, raw):
                if str(path).endswith('.stderr'): raise OSError('controlled second-stream failure')
                return actual_publish(path, raw)
            with patch.dict(namespace, admitted=lambda *args: (plan, {}), load=lambda key, path, pins: modules[path], publish=failing_publish):
                with self.assertRaisesRegex(OSError, 'second-stream failure'): namespace['worker']('unused', 'unused')
            retained = json.loads((root / 'inner/one.result.json').read_bytes())
            self.assertEqual(retained['exit'], 7); self.assertIsNone(retained['failure'])
            self.assertEqual(bytes.fromhex(retained['stdout']['rawHex']), b'completed')
            self.assertEqual(bytes.fromhex(retained['stderr']['rawHex']), b'error')
            self.assertEqual((root / 'inner/one.stdout').read_bytes(), b'completed')
            self.assertFalse((root / 'inner/one.stderr').exists())
    def test_regular_no_follow_and_no_overwrite(self):
        with tempfile.TemporaryDirectory() as name:
            root = Path(name); path = root / 'result'; namespace['publish'](path, b'raw')
            with self.assertRaises(FileExistsError): namespace['publish'](path, b'changed')
            alias = root / 'alias'; alias.symlink_to(path)
            with self.assertRaises(OSError): namespace['regular'](alias)
            with self.assertRaises(ValueError): namespace['regular'](root)

if __name__ == '__main__': unittest.main()
