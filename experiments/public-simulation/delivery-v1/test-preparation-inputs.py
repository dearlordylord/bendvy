"""Metadata-only immutable input boundary controls; no tools/backend."""
import importlib.util
import os
from pathlib import Path
import tempfile
import unittest
spec=importlib.util.spec_from_file_location('simulation_prepare',Path(__file__).with_name('prepare.py'))
prepare=importlib.util.module_from_spec(spec);spec.loader.exec_module(prepare)
class Inputs(unittest.TestCase):
    def test_regular_bytes(self):
        with tempfile.TemporaryDirectory() as directory:
            path=Path(directory)/'source';path.write_bytes(b'exact\n')
            self.assertEqual(prepare.regular_bytes(path),b'exact\n')
    def test_same_bytes_leaf_alias_refused(self):
        with tempfile.TemporaryDirectory() as directory:
            source=Path(directory)/'source';source.write_bytes(b'exact\n')
            alias=Path(directory)/'alias';alias.symlink_to(source)
            with self.assertRaises(OSError):prepare.regular_bytes(alias)
    def test_fifo_refused_without_blocking(self):
        with tempfile.TemporaryDirectory() as directory:
            path=Path(directory)/'fifo';os.mkfifo(path)
            with self.assertRaises(ValueError):prepare.regular_bytes(path)
    def test_directory_refused(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises((OSError,ValueError)):prepare.regular_bytes(Path(directory))
if __name__=='__main__':unittest.main()
