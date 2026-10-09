"""Portable shallow-only metadata controls; no loader/helper discovery."""
from pathlib import Path
import tempfile
import unittest
HERE = Path(__file__).resolve().parent
namespace = {'__file__': str(HERE / 'prepare.py'), '__name__': 'controls_preparation'}
exec(compile((HERE / 'prepare.py').read_bytes(), str(HERE / 'prepare.py'), 'exec'), namespace)

class Controls(unittest.TestCase):
    def test_shallow_all_names_and_no_descent(self):
        with tempfile.TemporaryDirectory() as name:
            root = Path(name); (root / 'plain.a').write_bytes(b'123'); (root / 'nested').mkdir(); (root / 'nested/private').write_bytes(b'x' * 100)
            (root / 'alias.so').symlink_to('plain.a')
            absent = root / 'absent'
            rows, files = namespace['shallow_rows']([str(root), str(absent)])
            self.assertEqual({r['name'] for r in rows[str(root)]['children']}, {'plain.a', 'nested', 'alias.so'})
            self.assertEqual(files, {str(root / 'plain.a'): 3})
            self.assertEqual(rows[str(absent)]['kind'], 'absent')
    def test_broken_link_is_not_silently_absent(self):
        with tempfile.TemporaryDirectory() as name:
            root = Path(name); (root / 'broken').symlink_to('missing')
            with self.assertRaises(FileNotFoundError): namespace['shallow_rows']([str(root)])
    def test_search_file_refused(self):
        with tempfile.TemporaryDirectory() as name:
            file = Path(name) / 'file'; file.write_bytes(b'no')
            with self.assertRaises(ValueError): namespace['shallow_rows']([str(file)])
    def test_legacy_source_order(self):
        # glibc2.36 temp entries in bit order: atomics, platform, tls.
        temp = ['atomics', 'aarch64', 'tls']
        actual = ['/'.join(temp[index] for index in range(2, -1, -1) if mask & (1 << index)) for mask in range(7, -1, -1)]
        self.assertEqual(actual, ['tls/aarch64/atomics', 'tls/aarch64', 'tls/atomics', 'tls', 'aarch64/atomics', 'aarch64', 'atomics', ''])

if __name__ == '__main__': unittest.main()
