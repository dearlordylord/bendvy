"""No-child boundary tests against root's actual patched detached-v2 run."""
import copy
import hashlib
import json
from pathlib import Path
import sys
import types
import unittest

from test_plan_guard import CommandJoins

COLLECTOR = Path('/workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/development.py')
GUARD = Path(__file__).parent / 'plan_guard.py'
CALL = "    load('development_plan_guard', PLAN_GUARD).validate(plan, output_dir=out)\n"


class RunnerImportReached(Exception):
    """Successful plan validation reaches this sentinel; no runner is imported."""


class Integration(CommandJoins):
    def harness(self, plan, *, enforcement=True):
        out = Path(plan['generated']).parent
        python = str(Path(sys.executable).resolve(strict=True))
        plan['pins'].pop(plan['tools']['python'])
        plan['tools']['python'] = python
        plan['pins'][python] = hashlib.sha256(Path(python).read_bytes()).hexdigest()
        for path in (GUARD, COLLECTOR):
            plan['pins'][str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
        for key, path in plan['tools'].items():
            if key != 'python':
                Path(path).write_bytes(b'test tool placeholder\n')
                plan['pins'][path] = hashlib.sha256(Path(path).read_bytes()).hexdigest()
        plan_path = out / 'plan.json'
        plan_path.write_text(json.dumps(plan))
        digest = hashlib.sha256(plan_path.read_bytes()).hexdigest()
        source = COLLECTOR.read_text()
        self.assertEqual(source.count(CALL), 1)
        if not enforcement:
            source = source.replace(CALL, '')
        module = types.ModuleType('isolated_collector'); module.__file__ = str(COLLECTOR)
        exec(compile(source, str(COLLECTOR), 'exec'), module.__dict__)
        module.PLAN_GUARD = GUARD
        original_load = module.load
        loaded = []

        def load(name, path):
            loaded.append(name)
            if name == 'development_plan_guard':
                self.assertEqual(module.VERIFIED_SOURCES[str(GUARD)], GUARD.read_bytes())
                return original_load(name, path)
            raise RunnerImportReached(name)

        module.load = load
        return module, plan_path, digest, loaded

    def test_valid_js_native_reach_runner_without_rewriting_commands(self):
        for role in ('js', 'native'):
            with self.subTest(role=role):
                plan = self.plan(role)
                module, path, digest, loaded = self.harness(plan)
                expected_commands = copy.deepcopy(plan['commands'])
                with self.assertRaisesRegex(RunnerImportReached, 'task_runner'):
                    module.run(path, digest)
                self.assertEqual(loaded, ['development_plan_guard', 'task_runner'])
                self.assertEqual(json.loads(path.read_text())['commands'], expected_commands)

    def test_null_native_refused_before_runner_import_or_child(self):
        plan = self.plan('js'); plan['native'] = None
        module, path, digest, loaded = self.harness(plan)
        with self.assertRaisesRegex(ValueError, 'path must be a nonempty string') as caught:
            module.run(path, digest)
        self.assertEqual(type(caught.exception).__name__, 'InvalidPlan')
        self.assertEqual(loaded, ['development_plan_guard'])

    def test_stale_emit_refused_before_runner_import_or_child(self):
        plan = self.plan('js'); plan['commands'][0]['argv'][4] = str(self.old)
        module, path, digest, loaded = self.harness(plan)
        with self.assertRaisesRegex(ValueError, 'actual argv differs') as caught:
            module.run(path, digest)
        self.assertEqual(type(caught.exception).__name__, 'InvalidPlan')
        self.assertEqual(loaded, ['development_plan_guard'])

    def test_missing_enforcement_reaches_runner_with_poisoned_argv(self):
        plan = self.plan('js'); plan['commands'][0]['argv'][4] = str(self.old)
        module, path, digest, loaded = self.harness(plan, enforcement=False)
        with self.assertRaisesRegex(RunnerImportReached, 'task_runner'):
            module.run(path, digest)
        self.assertEqual(loaded, ['task_runner'])
        self.assertEqual(json.loads(path.read_text())['commands'][0]['argv'][4], str(self.old))


def load_tests(loader, tests, pattern):
    # Use CommandJoins only for fixtures; its controls ran separately.
    names = ('test_valid_js_native_reach_runner_without_rewriting_commands',
             'test_null_native_refused_before_runner_import_or_child',
             'test_stale_emit_refused_before_runner_import_or_child',
             'test_missing_enforcement_reaches_runner_with_poisoned_argv')
    return unittest.TestSuite(Integration(name) for name in names)


if __name__ == '__main__':
    unittest.main()
