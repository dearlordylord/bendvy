"""Offline controls only: no Node, compiler, benchmark or profiler execution."""
import ast
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('identity_profile', HERE / 'profile.py')
profile = importlib.util.module_from_spec(spec)
spec.loader.exec_module(profile)


class ProfileControls(unittest.TestCase):
    def test_full_output_rejects_wrong_middle_and_missing_application(self):
        expected = {'checkpoints': [{'label': str(i), 'payload': [i, i + 1]} for i in range(22)]}
        line = json.dumps(expected).encode()
        complete = b'\n'.join([line] * 10) + b'\n'
        profile.validate_output(complete, expected, 10)
        wrong = complete.splitlines()
        wrong[5] = wrong[5].replace(b'"payload": [10, 11]', b'"payload": [10, 12]')
        for raw in (b'\n'.join(wrong), b'\n'.join(complete.splitlines()[:9]), complete + line):
            with self.assertRaises(ValueError):
                profile.validate_output(raw, expected, 10)

    def test_actual_before_complete_cohort_and_artifact(self):
        recipe = profile.read(HERE / 'recipe.json')
        binding, expected, _plan = profile.cohort(recipe['before'], recipe['beforePlanSHA256'],
                                                 recipe['beforeArtifactSHA256'])
        self.assertEqual(binding['generatedSHA256'], recipe['beforeArtifactSHA256'])
        self.assertEqual(len(expected['checkpoints']), 22)
        self.assertGreater(len(binding['pins']), 100)

    def test_error_incomplete_and_failed_commands_are_not_accepted(self):
        recipe = profile.read(HERE / 'recipe.json')
        real_read = profile.read
        for mutation in ('ERROR', 'INCOMPLETE', 'failed-command'):
            def altered(path):
                value = real_read(path)
                if str(path).endswith('/cohort/receipt.json'):
                    if mutation == 'failed-command':
                        value['commands'][0]['exit'] = 1
                    else:
                        value['status'] = mutation
                return value
            with self.subTest(mutation=mutation), patch.object(profile, 'read', side_effect=altered):
                with self.assertRaises(ValueError):
                    profile.cohort(recipe['before'], recipe['beforePlanSHA256'])

    def test_statistical_regression_is_still_a_correct_profile_prerequisite(self):
        recipe = profile.read(HERE / 'recipe.json')
        real_read = profile.read
        def regression(path):
            value = real_read(path)
            if str(path).endswith('/cohort/receipt.json'):
                value['status'] = 'REGRESSION'
            elif str(path).endswith('/receipt.json'):
                value['commands'][0]['exit'] = 1
            return value
        original_loads = json.loads
        def summary(value, *args, **kwargs):
            result = original_loads(value, *args, **kwargs)
            if isinstance(result, dict) and set(result) == {'status', 'endpoints', 'descriptiveTargets'}:
                result['status'] = 'REGRESSION'
            return result
        with patch.object(profile, 'read', side_effect=regression), patch.object(profile.json, 'loads', side_effect=summary):
            profile.cohort(recipe['before'], recipe['beforePlanSHA256'])

    def test_before_imported_core_matches_preserved_source_join(self):
        basis = profile.read(HERE / 'SOURCE-BASIS.json')
        self.assertEqual(len(basis['gitPreGenerationCoreBodyJoin']), 15)
        for path, expected in basis['importClosure'].items():
            self.assertEqual(profile.sha(path), expected)

    def test_driver_has_exact_profile_options_and_no_generated_body_edit(self):
        driver = (HERE / 'profile.mjs').read_text()
        self.assertEqual(driver.count('await import(pathToFileURL(generated).href)'), 1)
        self.assertIn('samplingInterval: 32768', driver)
        self.assertIn('interval: 100', driver)
        self.assertIn('includeObjectsCollectedByMajorGC: true', driver)
        self.assertIn('includeObjectsCollectedByMinorGC: true', driver)
        self.assertIn('code !== 0', driver)
        self.assertNotIn('readFile', driver)
        self.assertNotIn('.replace(', driver)

    def test_tool_guard_matches_snapshot_probe_cpu_and_keeps_children_on11(self):
        # Exercise the actual nested guard with a verifier that enforces the
        # retained snapshot configuration; no ldd or backend is invoked.
        source = ast.parse((HERE / 'profile.py').read_text())
        execute = next(node for node in source.body
                       if isinstance(node, ast.FunctionDef) and node.name == 'execute')
        guard = next(node for node in execute.body
                     if isinstance(node, ast.FunctionDef) and node.name == 'tools_guard')
        plan = profile.read('/tmp/bendvy38-generational-profile-actual01/plan.json')
        snapshot = profile.decode_snapshot(profile.read(plan['toolSnapshot']))
        self.assertEqual(snapshot['cpu'], 3)
        self.assertEqual(plan['cpu'], 11)
        calls = []
        class Verifier:
            def verify(self, expected, **configuration):
                self_test.assertEqual(configuration['cpu'], expected['cpu'])
                self_test.assertEqual(configuration['env'], plan['environment'])
                calls.append(configuration)
        self_test = self
        namespace = {'owned': Verifier(), 'snapshot': snapshot, 'plan': plan,
                     'task_runner': profile.task_runner}
        module = ast.Module(body=[guard], type_ignores=[])
        exec(compile(ast.fix_missing_locations(module), '<actual tools_guard>', 'exec'), namespace)
        namespace['tools_guard']()
        self.assertEqual(len(calls), 1)
        for command in plan['commands']:
            self.assertEqual(command['argv'][1:3], ['-c', '11'])
            self.assertEqual(command['capSeconds'], 5)

    def test_missing_after_artifact_refuses_preparation_without_output(self):
        recipe = profile.read(HERE / 'recipe.json')
        real_cohort = profile.cohort
        def absent_after(directory, *args):
            if directory == recipe['after']:
                raise FileNotFoundError('After completed cohort is required')
            return real_cohort(directory, *args)
        with tempfile.TemporaryDirectory() as temporary, patch.object(profile, 'cohort', side_effect=absent_after):
            output = Path(temporary) / 'profile'
            with self.assertRaises(FileNotFoundError):
                profile.prepare(output)
            self.assertFalse(output.exists())


if __name__ == '__main__':
    unittest.main()
