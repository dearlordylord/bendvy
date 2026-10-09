"""Portable no-child preparation controls."""
import importlib.util
from pathlib import Path
import tempfile
import unittest
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('prepare_transitive', HERE / 'prepare-transitive-elf.py')
module = importlib.util.module_from_spec(spec)
exec(compile((HERE / 'prepare-transitive-elf.py').read_bytes(), str(HERE / 'prepare-transitive-elf.py'), 'exec'), module.__dict__)

class Controls(unittest.TestCase):
    def test_exact_observed_target_set(self):
        value = {'actualLoadedTargetPaths': ['/a', '/b'], 'actualLoadedBySubject': {'one': {'actualLoaded': [{'path': '/a'}, {'path': '/b'}]}}}
        self.assertEqual(module.target_paths(value), ['/a', '/b'])
        value['actualLoadedTargetPaths'] = ['/a']
        with self.assertRaisesRegex(ValueError, 'exactly equal'):
            module.target_paths(value)
    def test_duplicate_and_parent_escape_refused(self):
        for paths in [['/a', '/a'], ['/a/../b']]:
            with self.assertRaises(ValueError):
                module.target_paths({'actualLoadedTargetPaths': paths, 'actualLoadedBySubject': {}})
    def test_no_follow_regular_input(self):
        with tempfile.TemporaryDirectory() as root:
            file = Path(root) / 'source'; file.write_bytes(b'actual')
            self.assertEqual(module.regular_bytes(file), b'actual')
            alias = Path(root) / 'alias'; alias.symlink_to(file)
            with self.assertRaises(OSError): module.regular_bytes(alias)
            with self.assertRaises(ValueError): module.regular_bytes(root)

if __name__ == '__main__': unittest.main()
