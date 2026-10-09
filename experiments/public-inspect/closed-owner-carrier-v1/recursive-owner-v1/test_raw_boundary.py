"""No-child controls for raw file boundaries."""
import hashlib
import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('development', Path(__file__).with_name('native-development.py'))
M = importlib.util.module_from_spec(spec)
spec.loader.exec_module(M)


class RawBoundary(unittest.TestCase):
    def test_regular_and_preexisting_outputs(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            normal = root / 'normal'
            M.write_raw(normal, b'raw')
            digest = hashlib.sha256(b'raw').hexdigest()
            M.verify_raw(normal, digest)
            with self.assertRaises(ValueError):
                M.write_raw(normal, b'overwrite')
            for name, destination in [('linked', normal), ('dangling', root / 'absent')]:
                target = root / name
                target.symlink_to(destination)
                with self.assertRaises(ValueError):
                    M.write_raw(target, b'overwrite')
                with self.assertRaises(ValueError):
                    M.verify_raw(target, digest)
            self.assertEqual(normal.read_bytes(), b'raw')
            self.assertFalse((root / 'absent').exists())


if __name__ == '__main__':
    unittest.main()
