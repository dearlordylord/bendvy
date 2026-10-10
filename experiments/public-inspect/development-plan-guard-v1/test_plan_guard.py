import copy
import hashlib
import gzip
import json
import tempfile
from pathlib import Path
import unittest

from plan_guard import InvalidPlan, validate


class CommandJoins(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.entry = self.root / 'current.bend'
        self.entry.write_text('import Base\ndef main() -> U32:\n  1\n')
        self.old = self.root / 'historical.bend'
        self.old.write_text('import Base\ndef main() -> U32:\n  0\n')

    def plan(self, role):
        out = self.root / role
        out.mkdir(exist_ok=True)
        fixture = json.loads(gzip.decompress((Path(__file__).parent / 'fixtures' / ('prepare-' + role + '.json.gz')).read_bytes()))
        tools = {key: str(self.root / key) for key in fixture['tools']}
        digest = hashlib.sha256(self.entry.read_bytes()).hexdigest()
        pins = {str(self.entry): digest} | {path: '0' * 64 for path in tools.values()}
        generated = str(out / ('scenario.js' if role == 'js' else 'scenario.c'))
        native = str(out / 'scenario.native')
        replacements = {fixture['entrypoint']: str(self.entry), fixture['generated']: generated, fixture['native']: native}
        replacements.update({fixture['tools'][key]: tools[key] for key in tools})
        for command in fixture['commands']:
            command['argv'] = [replacements.get(arg, arg) for arg in command['argv']]
        fixture.update(stage=str(out), cwd=str(self.root), entrypoint=str(self.entry), generated=generated,
                       native=native, tools=tools, sourceInventory={str(self.entry): digest},
                       importClosure=[str(self.entry)], pins=pins, resourceRoots={})
        return fixture

    def rejected(self, role, change):
        plan = self.plan(role)
        change(plan)
        with self.assertRaises(InvalidPlan):
            validate(plan, output_dir=self.root / plan['role'])

    def test_complete_js_native_positive_and_pure(self):
        for role in ('js', 'native'):
            plan = self.plan(role)
            original = copy.deepcopy(plan)
            before = sorted(str(p) for p in self.root.rglob('*'))
            outputs = validate(plan, output_dir=self.root / plan['role'])
            self.assertEqual(plan, original)
            self.assertEqual(before, sorted(str(p) for p in self.root.rglob('*')))
            self.assertIn(plan['generated'], outputs)

    def test_old_cloned_emit_entry_is_rejected_even_if_pinned(self):
        def poison(plan):
            plan['commands'][0]['argv'][4] = str(self.old)
            plan['pins'][str(self.old)] = hashlib.sha256(self.old.read_bytes()).hexdigest()
        self.rejected('js', poison)

    def test_old_emit_output_is_rejected(self):
        self.rejected('js', lambda p: p['commands'][0]['argv'].__setitem__(6, str(self.root / 'historical.js')))

    def test_js_consumer_historical_generated_is_rejected(self):
        self.rejected('js', lambda p: p['commands'][1]['argv'].__setitem__(4, str(self.root / 'historical.js')))

    def test_native_build_input_and_output_joins(self):
        for index in (5, 7):
            with self.subTest(index=index):
                self.rejected('native', lambda p: p['commands'][1]['argv'].__setitem__(index, str(self.root / 'historical')))

    def test_native_consumer_historical_binary(self):
        self.rejected('native', lambda p: p['commands'][2]['argv'].__setitem__(3, str(self.root / 'historical.native')))

    def test_all_commands_poisoned_together_cannot_escape_stage(self):
        def poison(plan):
            old = str(self.root / 'historical.js')
            plan['generated'] = old
            plan['commands'][0]['argv'][6] = old
            plan['commands'][1]['argv'][4] = old
        self.rejected('js', poison)

    def test_poisoned_stage_and_commands_do_not_change_runner_directory(self):
        plan = self.plan('js')
        historical = self.root / 'historical-output'
        historical.mkdir()
        plan['stage'] = str(historical)
        plan['generated'] = str(historical / 'scenario.js')
        plan['commands'][0]['argv'][6] = plan['generated']
        plan['commands'][1]['argv'][4] = plan['generated']
        with self.assertRaises(InvalidPlan):
            validate(plan, output_dir=self.root / 'js')

    def test_entry_inventory_closure_and_pin_required(self):
        changes = [lambda p: p['sourceInventory'].clear(), lambda p: p['importClosure'].clear(),
                   lambda p: p['pins'].pop(p['entrypoint']), lambda p: p['pins'].__setitem__(p['entrypoint'], 'f' * 64)]
        for change in changes:
            with self.subTest(change=change):
                self.rejected('js', change)

    def test_js_null_native_reproduces_preboundary_bootstrap_failure(self):
        plan = self.plan('js')
        plan['native'] = None
        with self.assertRaises(TypeError):
            Path(plan['native'])
        with self.assertRaises(InvalidPlan):
            validate(plan, output_dir=self.root / 'js')

    def test_all_prechild_dereferenced_fields_are_required(self):
        fields = ('scope', 'tools', 'pins', 'generated', 'native', 'entrypoint',
                  'sourceInventory', 'importClosure', 'resourceRoots', 'commands', 'environment', 'cwd')
        for field in fields:
            with self.subTest(field=field):
                self.rejected('js', lambda p: p.pop(field))
        self.rejected('js', lambda p: p['tools'].pop('python'))
        self.rejected('js', lambda p: p['commands'][0].pop('capSeconds'))
        self.rejected('js', lambda p: p['commands'][0].pop('argv'))
        self.rejected('js', lambda p: p['commands'][0].pop('label'))

    def test_prechild_field_shapes(self):
        for field, value in [('scope', None), ('environment', []), ('resourceRoots', []), ('commands', None)]:
            with self.subTest(field=field):
                self.rejected('js', lambda p: p.__setitem__(field, value))
        self.rejected('js', lambda p: p.__setitem__('environment', {'KEY': None}))
        self.rejected('js', lambda p: p['commands'][0].__setitem__('capSeconds', None))

    def test_malformed_pin_mapping(self):
        self.rejected('js', lambda p: p.__setitem__('pins', None))

    def test_changed_entry_bytes(self):
        plan = self.plan('js')
        self.entry.write_text('different\n')
        with self.assertRaises(InvalidPlan):
            validate(plan, output_dir=self.root / plan['role'])

    def test_fresh_raw_receipt_guard_and_artifacts(self):
        plan = self.plan('native')
        paths = validate(plan, output_dir=self.root / plan['role'])
        for path in paths:
            with self.subTest(path=path):
                target = Path(path)
                target.write_bytes(b'old')
                with self.assertRaises(InvalidPlan):
                    validate(plan, output_dir=self.root / plan['role'])
                target.unlink()

    def test_input_output_overlap(self):
        def poison(plan):
            plan['pins'][plan['generated']] = 'a' * 64
        self.rejected('js', poison)

    def test_lexical_aliases(self):
        for field in ('entrypoint', 'stage', 'generated'):
            for suffix in ('/../alias', '/./alias', '//alias'):
                with self.subTest(field=field, suffix=suffix):
                    self.rejected('js', lambda p: p.__setitem__(field, p[field] + suffix))

    def test_dangling_output_symlink(self):
        plan = self.plan('js')
        Path(plan['generated']).symlink_to(self.root / 'absent')
        with self.assertRaises(InvalidPlan):
            validate(plan, output_dir=self.root / plan['role'])

    def test_symlink_ancestor(self):
        plan = self.plan('js')
        link = self.root / 'alias'
        link.symlink_to(Path(plan['stage']), target_is_directory=True)
        plan['stage'] = str(link)
        plan['generated'] = str(link / 'scenario.js')
        with self.assertRaises(InvalidPlan):
            validate(plan, output_dir=self.root / plan['role'])

    def test_fixed_labels_and_no_extra_shell_or_flags(self):
        changes = [lambda p: p['commands'].reverse(), lambda p: p['commands'][0]['argv'].append('--other'),
                   lambda p: p['commands'][0]['argv'].__setitem__(0, '/bin/sh'),
                   lambda p: p['commands'][1]['argv'].__setitem__(2, '11')]
        for change in changes:
            with self.subTest(change=change):
                self.rejected('js', change)

    def test_legacy_source_stage_requires_actual_output_directory(self):
        plan = self.plan('js')
        out = plan['stage']
        plan['stage'] = str(self.root)
        plan['native'] = str(Path(out) / 'scenario.native')
        with self.assertRaises(InvalidPlan):
            validate(plan, output_dir=self.root)
        validate(plan, output_dir=out)


if __name__ == '__main__':
    unittest.main()
