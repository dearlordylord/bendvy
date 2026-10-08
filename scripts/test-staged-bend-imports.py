"""Actual staged paths/bytes: missing entry, extra parent and library controls."""
import hashlib
from pathlib import Path
import tempfile
import unittest
import staged_bend_imports as staged


class Imports(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.stage = Path(self.tmp.name) / 'stage'
        self.stage.mkdir()

    def put(self, name, text):
        path = self.stage / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)
        return path

    def inventory(self):
        return {p.relative_to(self.stage).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
                for p in self.stage.rglob('*') if p.is_file()}

    def test_nested_lexical_parents_and_full_closure(self):
        self.put('app/middle/main.bend', '# header\nimport ../../src/query.bend as Q\ndef main() -> U32: 0\n')
        self.put('src/query.bend', 'import ./component.bend as C # comment\n')
        self.put('src/component.bend', '# terminal\n')
        bound = staged.verify(self.stage, 'app/middle/main.bend', self.inventory())
        self.assertEqual({r['relative'] for r in bound['consumed']},
                         {'app/middle/main.bend', 'src/query.bend', 'src/component.bend'})

    def test_missing_entry_not_replaced_by_same_byte_file(self):
        self.put('actual.bend', 'def main() -> U32: 0\n')
        with self.assertRaisesRegex(RuntimeError, 'entry not selected'):
            staged.verify(self.stage, 'missing.bend', self.inventory())

    def test_extra_parent_escapes_even_when_external_same_bytes_exist(self):
        self.put('app/main.bend', 'import ../../src/core.bend as C\n')
        self.put('src/core.bend', '# core\n')
        external = self.stage.parent / 'src/core.bend'
        external.parent.mkdir()
        external.write_text('# core\n')
        with self.assertRaisesRegex(RuntimeError, 'escapes owned root'):
            staged.verify(self.stage, 'app/main.bend', self.inventory())

    def test_missing_middle_and_unlisted_import(self):
        self.put('main.bend', 'import ./middle/core.bend as C\n')
        self.put('core.bend', '# same bytes are not the requested path\n')
        with self.assertRaisesRegex(RuntimeError, 'missing.*import'):
            staged.verify(self.stage, 'main.bend', self.inventory())
        self.put('middle/core.bend', '# selected?\n')
        inventory = self.inventory()
        del inventory['middle/core.bend']
        with self.assertRaisesRegex(RuntimeError, 'missing.*import'):
            staged.verify(self.stage, 'main.bend', inventory)

    def test_missing_intermediate_parent_path_and_existing_middle(self):
        self.put('main.bend', 'import missing/../core.bend as C\n')
        self.put('core.bend', '# core\n')
        with self.assertRaisesRegex(RuntimeError, 'missing literal import file'):
            staged.verify(self.stage, 'main.bend', self.inventory())
        (self.stage/'missing').mkdir()
        self.assertEqual(len(staged.verify(self.stage, 'main.bend', self.inventory())['consumed']), 2)

    def test_entry_and_import_hash_drift(self):
        self.put('main.bend', 'import core.bend as C\n')
        self.put('core.bend', '# original\n')
        inventory = self.inventory()
        self.put('core.bend', '# changed\n')
        with self.assertRaisesRegex(RuntimeError, 'bytes changed'):
            staged.verify(self.stage, 'main.bend', inventory)
        inventory = self.inventory()
        self.put('main.bend', '# changed entry\n')
        with self.assertRaisesRegex(RuntimeError, 'bytes changed'):
            staged.verify(self.stage, 'main.bend', inventory)

    def test_symlink_escape_and_in_stage_alias(self):
        self.put('main.bend', 'import alias.bend as A\n')
        core = self.put('core.bend', '# core\n')
        (self.stage/'alias.bend').symlink_to(core)
        with self.assertRaisesRegex(RuntimeError, 'symlink/path alias'):
            staged.verify(self.stage, 'main.bend', self.inventory())

    def test_explicit_base_and_its_pinned_relative_import(self):
        self.put('main.bend', 'import Base\ndef main() -> U32: 0\n')
        library = self.stage.parent/'library'
        library.mkdir()
        (library/'base.bend').write_text('import helper.bend as H\n')
        (library/'helper.bend').write_text('# helper\n')
        inventory = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in library.iterdir()}
        with self.assertRaisesRegex(RuntimeError, 'unbound pinned library'):
            staged.verify(self.stage, 'main.bend', self.inventory())
        libraries = {'Base': dict(root=library, entry='base.bend', inventory=inventory)}
        bound = staged.verify(self.stage, 'main.bend', self.inventory(), libraries)
        self.assertEqual(len(bound['consumed']), 3)
        (library/'helper.bend').write_text('# drift\n')
        with self.assertRaisesRegex(RuntimeError, 'bytes changed'):
            staged.verify(self.stage, 'main.bend', self.inventory(), libraries)

    def test_library_binding_cannot_replace_owned_relative_import(self):
        self.put('main.bend', '# valid\n')
        with self.assertRaisesRegex(ValueError, 'library binding'):
            staged.verify(self.stage, 'main.bend', self.inventory(),
                          {'../core.bend': dict(root=self.stage, entry='main.bend', inventory=self.inventory())})

    def test_import_cycle_refused_but_shared_diamond_allowed(self):
        self.put('main.bend', 'import a.bend as A\nimport b.bend as B\n')
        self.put('a.bend', 'import c.bend as C\n')
        self.put('b.bend', 'import c.bend as C\n')
        self.put('c.bend', '# leaf\n')
        self.assertEqual(len(staged.verify(self.stage, 'main.bend', self.inventory())['consumed']), 4)
        self.put('c.bend', 'import main.bend as M\n')
        with self.assertRaisesRegex(RuntimeError, 'import cycle'):
            staged.verify(self.stage, 'main.bend', self.inventory())

    def test_scan_all_catches_broken_second_cohort_entry(self):
        self.put('read.bend', '# valid\n')
        self.put('write.bend', 'import absent.bend as A\n')
        staged.verify(self.stage, 'read.bend', self.inventory())
        with self.assertRaisesRegex(RuntimeError, 'missing.*import'):
            staged.verify(self.stage, 'read.bend', self.inventory(), scan_all=True)

    def test_import_header_not_ffi_or_body_string(self):
        self.put('main.bend', '# comment\ndef foreign() -> IO Unit:\n  import "effect.c"\n')
        self.assertEqual(len(staged.verify(self.stage, 'main.bend', self.inventory())['consumed']), 1)
        self.put('main.bend', 'import core.bend\n')
        with self.assertRaisesRegex(RuntimeError, 'malformed leading import'):
            staged.verify(self.stage, 'main.bend', self.inventory())

    def test_noncanonical_entry_inventory(self):
        self.put('main.bend', '# leaf\n')
        with self.assertRaises(ValueError):
            staged.verify(self.stage, './main.bend', self.inventory())

    def test_shared_alias_keeps_separate_literal_inputs(self):
        self.put('nested/main.bend', 'import ../adapter.bend as G\nimport ../gameplay.bend as G\n')
        self.put('adapter.bend', 'def cleanup() -> Unit:\n  ()\n')
        self.put('gameplay.bend', 'def gameplay() -> Unit:\n  ()\n')
        result = staged.verify(self.stage, 'nested/main.bend', self.inventory())
        self.assertEqual({item['relative'] for item in result['consumed']},
                         {'nested/main.bend', 'adapter.bend', 'gameplay.bend'})
        self.assertEqual([edge['import'] for edge in result['imports']],
                         ['../adapter.bend', '../gameplay.bend'])


if __name__ == '__main__':
    unittest.main()
