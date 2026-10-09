#!/usr/bin/env python3
"""No-child regular-file and raw-capture boundary controls."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from types import SimpleNamespace

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('js_boundary', HERE / 'development-diagnostic-native.py')
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

    def test_failed_emit_partial_artifact_retained_without_consumer(self):
        with tempfile.TemporaryDirectory() as tmp:
            prepared = Path(tmp) / 'prepared'
            oracle = HERE.parents[3] / 'oracle-v1'
            N.prepare(prepared, oracle, 'normal')
            old = json.loads((prepared / 'plan.json').read_text())
            old['pins'] = {p: N.sha(p) for p in old['pins']}
            generated = Path(tmp) / 'scenario.c'
            old['generated'] = str(generated)
            old['commands'][0]['argv'][-1] = str(generated)
            old['commands'][1]['argv'][5] = str(generated)
            plan = Path(tmp) / 'plan.json'
            plan.write_text(json.dumps(old))
            calls = []
            def failed_emit(*args):
                calls.append(args)
                generated.write_bytes(b'partial generated output')
                return {'exit': 1, 'failure': 'controlled emit failure',
                        'stdout': b'original stdout', 'stderr': b'original stderr'}
            real_load = N.load
            def load(name, path):
                return SimpleNamespace(execute_result=failed_emit, Inputs=real_load(name, path).Inputs) if name == 'task_runner' else real_load(name, path)
            with patch.object(N, 'load', load):
                with self.assertRaisesRegex(ValueError, 'Owned child failed: emit'):
                    N.run(plan, N.sha(plan))
            receipt = json.loads((Path(tmp) / 'receipt.json').read_text())
            self.assertEqual(len(calls), 1)
            self.assertEqual(receipt['commands'][0]['failure'], 'controlled emit failure')
            self.assertEqual(receipt['generatedSHA256'], N.sha(generated))
            self.assertEqual((Path(tmp) / 'emit.stdout').read_bytes(), b'original stdout')
            self.assertEqual((Path(tmp) / 'emit.stderr').read_bytes(), b'original stderr')
            for label in ('emit-post', 'final'):
                guard = json.loads((Path(tmp) / (label + '.guard.json')).read_text())
                self.assertTrue(guard['unchanged'])
                self.assertEqual(guard['actualPins'][str(generated)], N.sha(generated))
            self.assertNotEqual(receipt.get('status'), 'DIAGNOSTIC_NATIVE_PASS')

    def test_complete_normal_native_plan_binding_without_children(self):
        oracle = HERE.parents[3] / 'oracle-v1'
        parser = N.load('parser_plan_controls', HERE / 'parse-handlers.py')
        expected_entries = {'normal': 'main.bend'}
        with tempfile.TemporaryDirectory() as tmp:
            for kind, entry in expected_entries.items():
                out = Path(tmp) / kind
                N.prepare(out, oracle, kind)
                plan = json.loads((out / 'plan.json').read_text())
                self.assertEqual(Path(plan['entrypoint']).name, entry)
                self.assertEqual(plan['expectedSHA256'], N.sha(plan['oracle']))
                self.assertTrue(plan['diagnosticOnly'])
                self.assertEqual(plan['sourcePrerequisite'], 'UNMET')
                self.assertFalse(plan['acceptance'])
                inventory = json.loads(Path(plan['constructorInventory']).read_text())
                self.assertEqual(parser.build_identities(plan['entrypoint']), inventory)
                self.assertEqual(len(inventory['sourceSHA256']), 80)
                self.assertEqual(len(inventory['constructors']), 147)
                self.assertEqual([c['capSeconds'] for c in plan['commands']], [30, 120, 5])
                self.assertTrue(all(c['argv'][:3] == [plan['tools']['taskset'], '-c', '11']
                                    for c in plan['commands']))

    def test_failed_build_partial_native_retained_without_runtime(self):
        with tempfile.TemporaryDirectory() as tmp:
            prepared = Path(tmp) / 'prepared'
            N.prepare(prepared, HERE.parents[3] / 'oracle-v1', 'normal')
            plan = prepared / 'plan.json'
            data = json.loads(plan.read_text())
            generated, native = Path(data['generated']), Path(data['native'])
            calls = []
            def controlled(*args):
                calls.append(args)
                if len(calls) == 1:
                    generated.write_bytes(b'complete controlled C')
                    return {'exit': 0, 'failure': None, 'stdout': b'', 'stderr': b''}
                native.write_bytes(b'partial controlled executable')
                return {'exit': None, 'failure': 'controlled build deadline',
                        'stdout': b'build raw stdout', 'stderr': b'build raw stderr'}
            real_load = N.load
            def load(name, path):
                return SimpleNamespace(execute_result=controlled, Inputs=real_load(name,path).Inputs) if name == 'task_runner' else real_load(name,path)
            with patch.object(N, 'load', load):
                with self.assertRaisesRegex(ValueError, 'Owned child failed: build'):
                    N.run(plan, N.sha(plan))
            receipt = json.loads((prepared / 'receipt.json').read_text())
            self.assertEqual(len(calls), 2)
            self.assertEqual(receipt['nativeSHA256'], N.sha(native))
            self.assertEqual((prepared / 'build.stdout').read_bytes(), b'build raw stdout')
            self.assertEqual((prepared / 'build.stderr').read_bytes(), b'build raw stderr')
            self.assertFalse((prepared / 'consumer.stdout').exists())
            self.assertEqual(len(receipt['guards']), 7)
            self.assertNotEqual(receipt.get('status'), 'DIAGNOSTIC_NATIVE_PASS')
            for label in ('build-post', 'final'):
                guard = json.loads((prepared / (label + '.guard.json')).read_text())
                self.assertTrue(guard['unchanged'])
                self.assertEqual(guard['actualPins'][str(native)], N.sha(native))

    def test_native_resource_membership_drift_stops_before_children(self):
        with tempfile.TemporaryDirectory() as tmp:
            prepared = Path(tmp) / 'prepared'
            N.prepare(prepared, HERE.parents[3] / 'oracle-v1', 'normal')
            plan = prepared / 'plan.json'
            real_load = N.load
            calls = []
            def unexpected(*args):
                calls.append(args)
                raise AssertionError('resource drift launched a child')
            def load(name, path):
                return SimpleNamespace(execute_result=unexpected,
                                       Inputs=lambda **kw: SimpleNamespace(expected={})) if name == 'task_runner' else real_load(name,path)
            with patch.object(N, 'load', load):
                with self.assertRaisesRegex(ValueError, 'boundary changed: emit-pre'):
                    N.run(plan, N.sha(plan))
            self.assertEqual(calls, [])
            receipt = json.loads((prepared / 'receipt.json').read_text())
            self.assertFalse(receipt['commands'])
            self.assertEqual(receipt['status'], 'INCOMPLETE')
            self.assertFalse(json.loads((prepared / 'emit-pre.guard.json').read_text())['unchanged'])

    def test_diagnostic_scope_and_affinity_refused_before_helpers(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / 'plan.json'
            for wrong in ({'diagnosticOnly': False}, {'sourcePrerequisite': 'PASS'},
                          {'acceptance': True}):
                plan = {'diagnosticOnly': True, 'sourcePrerequisite': 'UNMET', 'acceptance': False}
                plan.update(wrong)
                target.write_text(json.dumps(plan))
                with self.assertRaisesRegex(ValueError, 'Diagnostic source prerequisite'):
                    N.run(target, N.sha(target))
            target.write_text(json.dumps({'diagnosticOnly': True,
                                          'sourcePrerequisite': 'UNMET', 'acceptance': False}))
            with patch.object(N.os, 'sched_getaffinity', return_value={5}):
                with self.assertRaisesRegex(ValueError, 'outside actual allowed affinity'):
                    N.run(target, N.sha(target))

    def test_actual_interpreter_path_and_hash_drift_refused_before_helpers(self):
        with tempfile.TemporaryDirectory() as tmp:
            actual=str(Path(N.sys.executable).resolve(strict=True))
            for planned,digest in (('/unapproved/python','0'*64),(actual,'0'*64)):
                with self.subTest(planned=planned):
                    target=Path(tmp)/'plan.json'
                    target.write_text(json.dumps({'diagnosticOnly':True,'sourcePrerequisite':'UNMET','acceptance':False,'tools':{'python':planned},'pins':{planned:digest}}))
                    with self.assertRaisesRegex(ValueError,'Actual executor interpreter'):
                        N.run(target,N.sha(target))


if __name__ == '__main__': unittest.main()
