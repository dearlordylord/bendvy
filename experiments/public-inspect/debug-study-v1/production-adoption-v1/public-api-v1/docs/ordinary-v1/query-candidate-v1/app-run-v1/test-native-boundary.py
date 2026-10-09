#!/usr/bin/env python3
"""No-child regular-file and raw-capture boundary controls."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('native_boundary', HERE / 'development-native.py')
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


if __name__ == '__main__': unittest.main()
