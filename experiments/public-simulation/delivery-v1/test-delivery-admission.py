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
    def test_source_bytes_before_helper(self):
        with tempfile.TemporaryDirectory() as name:
            file = Path(name) / 'helper.py'; file.write_bytes(b'raise RuntimeError("executed")\n')
            with self.assertRaisesRegex(ValueError, 'helper drift'): namespace['load']('bad_helper', file, {str(file): '0' * 64})

if __name__ == '__main__': unittest.main()
