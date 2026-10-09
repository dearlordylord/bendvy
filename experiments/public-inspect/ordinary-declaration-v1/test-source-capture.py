import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('capture_source', Path(__file__).with_name('check-source.py'))
capture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(capture)

class CaptureTests(unittest.TestCase):
    def test_bytes(self):
        with tempfile.TemporaryDirectory() as directory:
            out = Path(directory)
            result = capture.capture(out, ['mock'], lambda *args, **kwargs: {'exit': 1, 'failure': None, 'stdout': b'raw\x00', 'stderr': b'error'})
            self.assertEqual((out / 'stdout').read_bytes(), b'raw\x00')
            self.assertEqual(result['exit'], 1)
            self.assertEqual(result['raw']['stderr']['bytes'], 5)

    def test_before_child_failure(self):
        def refused(*args, **kwargs):
            raise OSError('before child')
        with tempfile.TemporaryDirectory() as directory:
            out = Path(directory)
            with self.assertRaisesRegex(OSError, 'before child'):
                capture.capture(out, ['mock'], refused)
            import json
            result = json.loads((out / 'result.json').read_text())
            self.assertEqual(result['status'], 'INCOMPLETE')
            self.assertEqual(result['raw'], {})
            self.assertIn('before child', result['error'])

if __name__ == '__main__':
    unittest.main()
