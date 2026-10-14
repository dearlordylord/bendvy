import copy
import importlib.util
import sys
import types
from unittest.mock import patch
import hashlib
import gzip
import json
import tempfile
from pathlib import Path
import unittest

from plan_guard import InvalidPlan, validate, validate_consumer_stderr, validate_stderr_policy, validate_ts_imports


class TSClosure(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def graph(self):
        sources = {
            'main.mjs': "import {run} from './reference.ts';\nconsole.log(run(1));\n",
            'reference.ts': "import type {Value} from './types.ts'\nexport {run} from './cycle.ts'\nimport './effect.ts'\n",
            'types.ts': "export type Value = import('./cycle.ts').Value\n",
            'cycle.ts': "import {run} from './reference.ts'\nexport type Value = number\n",
            'effect.ts': "export const value = 1\n",
        }
        for name, source in sources.items():
            (self.root / name).write_text(source)
        return {str(self.root / name): hashlib.sha256((self.root / name).read_bytes()).hexdigest() for name in sources}

    def test_complete_static_type_reexport_sideeffect_cycle(self):
        inventory = self.graph()
        self.assertEqual(validate_ts_imports(self.root / 'main.mjs', inventory), sorted(inventory))

    def test_compact_reexports_include_pinned_dependency(self):
        for source in ("export{value}from './dependency.mjs'", "export*from './dependency.mjs'"):
            with self.subTest(source=source):
                main = self.root / 'main.mjs'
                dependency = self.root / 'dependency.mjs'
                main.write_text(source)
                dependency.write_text('export const value = 1\n')
                inventory = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in (main, dependency)}
                self.assertEqual(validate_ts_imports(main, inventory), sorted(inventory))

    def test_compact_reexports_reject_missing_dependency(self):
        for source in ("export{value}from './dependency.mjs'", "export*from './dependency.mjs'"):
            with self.subTest(source=source):
                main = self.root / 'main.mjs'
                dependency = self.root / 'dependency.mjs'
                main.write_text(source)
                dependency.write_text('export const value = 1\n')
                inventory = {str(main): hashlib.sha256(main.read_bytes()).hexdigest()}
                with self.assertRaises(InvalidPlan):
                    validate_ts_imports(main, inventory)

    def test_unsupported_quoted_reexport_fails_closed_even_when_target_pinned(self):
        for source in ('export { "a-b" as c } from "./dependency.mjs"',
                       'export{"a-b"as c}from"./dependency.mjs"'):
            for include in (False, True):
                with self.subTest(source=source, target_pinned=include):
                    main = self.root / 'main.mjs'
                    dependency = self.root / 'dependency.mjs'
                    main.write_text(source)
                    dependency.write_text('export const value = 1\n')
                    inventory = {str(main): hashlib.sha256(main.read_bytes()).hexdigest()}
                    if include:
                        inventory[str(dependency)] = hashlib.sha256(dependency.read_bytes()).hexdigest()
                    with self.assertRaisesRegex(InvalidPlan, 'unsupported named re-export'):
                        validate_ts_imports(main, inventory)

    def test_local_named_export_with_quoted_name_has_no_edge(self):
        main = self.root / 'main.mjs'
        main.write_text('const value = 1; export { value as "a-b" };\n')
        inventory = {str(main): hashlib.sha256(main.read_bytes()).hexdigest()}
        self.assertEqual(validate_ts_imports(main, inventory), sorted(inventory))

    def test_export_const_and_function_do_not_create_module_edges(self):
        main = self.root / 'main.mjs'
        main.write_text("export const value = 'from untracked';\nexport function call(){return value;}\n")
        inventory = {str(main): hashlib.sha256(main.read_bytes()).hexdigest()}
        self.assertEqual(validate_ts_imports(main, inventory), sorted(inventory))

    def test_literal_import_is_pinned_dependency_regardless_of_type_or_runtime(self):
        inventory = self.graph()
        main = self.root / 'main.mjs'
        main.write_text(main.read_text() + "const extra = import('./types.ts')\n")
        inventory[str(main)] = hashlib.sha256(main.read_bytes()).hexdigest()
        self.assertEqual(validate_ts_imports(main, inventory), sorted(inventory))
        inventory.pop(str(self.root / 'types.ts'))
        with self.assertRaises(InvalidPlan):
            validate_ts_imports(main, inventory)

    def test_missing_unused_escape_and_changed_dependency(self):
        for defect in ('missing', 'unused', 'escape', 'changed', 'symlink'):
            with self.subTest(defect=defect):
                inventory = self.graph()
                if defect == 'missing':
                    inventory.pop(str(self.root / 'types.ts'))
                elif defect == 'unused':
                    extra = self.root / 'unused.ts'
                    extra.write_text('export const x = 1\n')
                    inventory[str(extra)] = hashlib.sha256(extra.read_bytes()).hexdigest()
                elif defect == 'escape':
                    main = self.root / 'main.mjs'
                    main.write_text("import './outside.ts'\n")
                    (self.root / 'outside.ts').write_text('export const x = 1\n')
                    inventory[str(main)] = hashlib.sha256(main.read_bytes()).hexdigest()
                elif defect == 'changed':
                    (self.root / 'types.ts').write_text('changed\n')
                else:
                    target = self.root / 'types.ts'
                    target.unlink()
                    target.symlink_to(self.root / 'cycle.ts')
                with self.assertRaises((InvalidPlan, OSError)):
                    validate_ts_imports(self.root / 'main.mjs', inventory)
                if defect == 'symlink':
                    (self.root / 'types.ts').unlink()

    def test_nested_and_computed_template_imports_fail_closed(self):
        for source in ["const x = `${(()=>{const z={};return import('./types.ts')})()}`;",
                       "const x = `${(()=>{const z={};return import(name)})()}`;"]:
            with self.subTest(source=source):
                inventory = self.graph()
                main = self.root / 'main.mjs'
                main.write_text(source)
                inventory[str(main)] = hashlib.sha256(main.read_bytes()).hexdigest()
                with self.assertRaisesRegex(InvalidPlan, 'unsupported import in template'):
                    validate_ts_imports(main, inventory)

    def test_nested_backtick_cannot_hide_runtime_import(self):
        inventory = self.graph()
        main = self.root / 'main.mjs'
        main.write_text("const x = `${(()=>{const z=`plain`;return import('./types.ts')})()}`;")
        inventory[str(main)] = hashlib.sha256(main.read_bytes()).hexdigest()
        with self.assertRaisesRegex(InvalidPlan, 'unsupported import in template'):
            validate_ts_imports(main, inventory)

    def test_template_comment_separated_imports_fail_closed(self):
        for expression in ("import/*comment*/('./types.ts')", "import /*comment*/ ('./types.ts')",
                           "import//comment\n('./types.ts')"):
            with self.subTest(expression=expression):
                inventory = self.graph()
                main = self.root / 'main.mjs'
                main.write_text('const x = `${' + expression + '}`;')
                inventory[str(main)] = hashlib.sha256(main.read_bytes()).hexdigest()
                with self.assertRaisesRegex(InvalidPlan, 'unsupported import in template'):
                    validate_ts_imports(main, inventory)

    def test_template_plain_import_word_is_not_a_module_call(self):
        main = self.root / 'main.mjs'
        main.write_text('export const value = `Step ${1}. Is an import undefined?`;\n')
        inventory = {str(main): hashlib.sha256(main.read_bytes()).hexdigest()}
        self.assertEqual(validate_ts_imports(main, inventory), sorted(inventory))

    def test_computed_bare_and_selector_rejected(self):
        for source in ["const x = import(name)",
                       "import x from 'unadmitted-package'", "import './types.ts?other'",
                       "const x = `value ${import('./types.ts')}`"]:
            with self.subTest(source=source):
                inventory = self.graph()
                main = self.root / 'main.mjs'
                main.write_text(source)
                inventory[str(main)] = hashlib.sha256(main.read_bytes()).hexdigest()
                with self.assertRaises(InvalidPlan):
                    validate_ts_imports(main, inventory)


class TSCollectorBoundary(unittest.TestCase):
    def test_actual_collector_dispatches_ts_closure_before_owned_child(self):
        root = Path(__file__).resolve().parents[3]
        path = root / 'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/development.py'
        spec = importlib.util.spec_from_file_location('ts_collector_control', path)
        collector = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(collector)
        boundary_spec = importlib.util.spec_from_file_location('ts_boundary_control', root / 'scripts/evidence_boundary.py')
        boundary = importlib.util.module_from_spec(boundary_spec)
        boundary_spec.loader.exec_module(boundary)
        class ChildSentinel(Exception):
            pass
        for missing in (False, True):
            with self.subTest(missing_dependency=missing), tempfile.TemporaryDirectory() as temporary:
                base = Path(temporary)
                out = base / 'output'
                out.mkdir()
                entry = base / 'consumer.mjs'
                dependency = base / 'reference.ts'
                entry.write_text("import {run} from './reference.ts';\nconsole.log(run(1));\n")
                dependency.write_text('export const run = n => String(n)\n')
                python = str(Path(sys.executable).resolve())
                taskset = '/usr/bin/taskset'
                sources = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in (entry, dependency)}
                inventory = dict(sources)
                if missing:
                    inventory.pop(str(dependency))
                files = [Path(python), Path(taskset), collector.PLAN_GUARD,
                         root / 'scripts/task_runner.py', root / 'scripts/evidence_boundary.py']
                pins = sources | {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
                plan = dict(scope='No-child TS dispatch control', role='ts', entrypoint=str(entry),
                            stage=str(base), cwd=str(base), sourceInventory=inventory,
                            importClosure=sorted(inventory), pins=pins, resourceRoots={}, environment={},
                            tools={'python':python,'taskset':taskset,'node':python},
                            generated=str(out / 'scenario.js'), native=str(out / 'scenario.native'),
                            commands=[{'label':'consumer','capSeconds':5,'argv':[taskset,'-c','3',python,str(entry)]}])
                plan_path = out / 'plan.json'
                plan_path.write_text(json.dumps(plan))
                runner = types.SimpleNamespace(Inputs=lambda **kwargs: types.SimpleNamespace(expected={}),
                                               execute_result=lambda *args: (_ for _ in ()).throw(ChildSentinel()))
                def load(name, source):
                    if source == collector.PLAN_GUARD:
                        return sys.modules['plan_guard']
                    if source.name == 'task_runner.py':
                        return runner
                    return boundary
                with patch.object(collector, 'load', side_effect=load), patch.object(collector, 'validate_imports', side_effect=AssertionError('Bend parser used for TS')):
                    with self.assertRaises(InvalidPlan if missing else ChildSentinel):
                        collector.run(plan_path, hashlib.sha256(plan_path.read_bytes()).hexdigest())
                receipt = json.loads((out / 'receipt.json').read_bytes())
                self.assertEqual(receipt['commands'], [])
                self.assertTrue(all(json.loads(Path(row['path']).read_bytes())['unchanged'] for row in receipt['guards']))


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

    def ts_plan(self):
        plan = self.plan('js')
        out = self.root / 'ts'
        out.mkdir(exist_ok=True)
        entry = self.root / 'consumer.mjs'
        entry.write_text("const {run}=await import('./reference.ts');\nconsole.log(run(1));\n")
        digest = hashlib.sha256(entry.read_bytes()).hexdigest()
        plan.update(role='ts', stage=str(out), entrypoint=str(entry),
                    generated=str(out / 'scenario.js'), native=str(out / 'scenario.native'),
                    sourceInventory={str(entry): digest}, importClosure=[str(entry)])
        plan['pins'][str(entry)] = digest
        plan['tools'] = {key: plan['tools'][key] for key in ('python', 'taskset', 'node')}
        plan['commands'] = [{'label': 'consumer', 'capSeconds': 5,
                             'argv': [plan['tools']['taskset'], '-c', '3', plan['tools']['node'], str(entry)]}]
        return plan

    def test_ts_entry_only_positive_and_pure(self):
        plan = self.ts_plan()
        original = copy.deepcopy(plan)
        before = sorted(str(p) for p in self.root.rglob('*'))
        outputs = validate(plan, output_dir=self.root / 'ts')
        self.assertEqual(plan, original)
        self.assertEqual(before, sorted(str(p) for p in self.root.rglob('*')))
        self.assertIn(str(self.root / 'ts' / 'consumer.stdout'), outputs)
        self.assertNotIn(str(self.root / 'ts' / 'emit.stdout'), outputs)

    def test_ts_wrong_node_entry_order_cap_and_alias_rejected(self):
        changes = [
            lambda p: p['commands'][0]['argv'].__setitem__(3, '/historical/node'),
            lambda p: p['commands'][0]['argv'].__setitem__(4, str(self.old)),
            lambda p: p['commands'][0].__setitem__('label', 'emit'),
            lambda p: p['commands'].append(copy.deepcopy(p['commands'][0])),
            lambda p: p['commands'][0].__setitem__('capSeconds', 30),
            lambda p: p['commands'][0]['argv'].append('--extra'),
            lambda p: p['commands'][0]['argv'].__setitem__(4, p['entrypoint'] + '/../alias'),
            lambda p: p['pins'].__setitem__(str(self.root / 'ts' / 'consumer.stdout'), 'a' * 64),
            lambda p: p['tools'].pop('node'),
        ]
        for change in changes:
            with self.subTest(change=change):
                plan = self.ts_plan()
                change(plan)
                with self.assertRaises(InvalidPlan):
                    validate(plan, output_dir=self.root / 'ts')

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


class ConsumerTelemetry(unittest.TestCase):
    def setUp(self):
        self.stdout = b'first\nsecond\n'
        digest = 2166136261
        for byte in self.stdout:
            digest = ((digest ^ byte) * 16777619) & 0xffffffff
        self.value = {'elapsedNs':'123', 'bytes':len(self.stdout), 'digest':digest, 'intervals':2}
        self.plan = {'oracleBytes':len(self.stdout), 'consumerStderrPolicy':
                     dict(self.value, kind='interval-telemetry-v1', elapsedNs='decimal-string')}

    def encoded(self, value=None):
        return (json.dumps(self.value if value is None else value, separators=(',', ':'))+'\n').encode()

    def test_default_requires_empty_stderr(self):
        self.assertIsNone(validate_consumer_stderr({}, self.stdout, b''))
        with self.assertRaises(InvalidPlan):
            validate_consumer_stderr({}, self.stdout, self.encoded())

    def test_complete_declared_telemetry(self):
        self.assertEqual(validate_consumer_stderr(self.plan, self.stdout, self.encoded()), self.value)

    def test_rejects_malformed_policy_before_child(self):
        for key, value in [('kind','unknown'), ('elapsedNs','number'), ('bytes',True),
                           ('bytes',1), ('digest',-1), ('intervals',0)]:
            plan = copy.deepcopy(self.plan)
            plan['consumerStderrPolicy'][key] = value
            with self.subTest(key=key, value=value), self.assertRaises(InvalidPlan):
                validate_stderr_policy(plan)
        plan = copy.deepcopy(self.plan)
        plan['consumerStderrPolicy']['extra'] = 1
        with self.assertRaises(InvalidPlan):
            validate_stderr_policy(plan)

    def test_rejects_log_noise_duplicate_and_noncanonical_json(self):
        raw = self.encoded()
        candidates = [b'', raw[:-1], raw+b'\n', b'noise\n'+raw,
                      raw.replace(b'"bytes":', b'"elapsedNs":"0","bytes":'),
                      raw.replace(b'"bytes":', b'"extra":0,"bytes":'),
                      json.dumps(self.value).encode()+b'\n']
        for candidate in candidates:
            with self.subTest(candidate=candidate), self.assertRaises(InvalidPlan):
                validate_consumer_stderr(self.plan, self.stdout, candidate)

    def test_rejects_wrong_types_values_and_captured_output(self):
        for key, value in [('elapsedNs',123), ('elapsedNs','-1'), ('elapsedNs','١'),
                           ('bytes',True), ('digest',0), ('intervals',1)]:
            telemetry = dict(self.value)
            telemetry[key] = value
            with self.subTest(key=key), self.assertRaises(InvalidPlan):
                validate_consumer_stderr(self.plan, self.stdout, self.encoded(telemetry))
        with self.assertRaises(InvalidPlan):
            validate_consumer_stderr(self.plan, b'other\nsecond\n', self.encoded())


if __name__ == '__main__':
    unittest.main()
