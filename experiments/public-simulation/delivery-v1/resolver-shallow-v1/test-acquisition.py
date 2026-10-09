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
    def test_regular_no_follow_and_no_overwrite(self):
        with tempfile.TemporaryDirectory() as name:
            root = Path(name); path = root / 'result'; namespace['publish'](path, b'raw')
            with self.assertRaises(FileExistsError): namespace['publish'](path, b'changed')
            alias = root / 'alias'; alias.symlink_to(path)
            with self.assertRaises(OSError): namespace['regular'](alias)
            with self.assertRaises(ValueError): namespace['regular'](root)

if __name__ == '__main__': unittest.main()
