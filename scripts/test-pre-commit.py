"""Exercise hook selection against real staged paths in disposable repositories."""
import os
import runpy
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch


HOOK = Path(__file__).resolve().parents[1] / '.githooks/pre-commit'
REGISTRY = runpy.run_path(str(HOOK.parent.parent / 'scripts/run-admission-controls.py'))


class Selection(unittest.TestCase):
    def check_paths(self, names):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            # Hooks may inherit GIT_DIR/WORK_TREE/INDEX_FILE from the real repo.
            env = {key: value for key, value in os.environ.items()
                   if not key.startswith('GIT_')}
            env.update(GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_GLOBAL=os.devnull)
            subprocess.run(['git', 'init', '-q', str(root)], env=env, check=True)
            for name in names:
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text('fixture\n')
            subprocess.run(['git', 'add', '--', *names], cwd=root, env=env, check=True)
            binary = root / 'fake-bin'
            binary.mkdir()
            calls = root / 'calls'
            python = binary / 'python3'
            python.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >> "$HOOK_CALLS"\n')
            python.chmod(0o755)
            env.update(PATH=str(binary) + os.pathsep + os.environ['PATH'],
                       HOOK_CALLS=str(calls))
            subprocess.run(['/bin/sh', str(HOOK)], cwd=root, env=env, check=True,
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            return calls.read_text().splitlines()

    def test_documentation_and_retained_data(self):
        calls = self.check_paths(['docs/parity/README.md', 'evidence/receipt.json',
                                  'src/ecs/component.bend'])
        self.assertEqual(calls, ['scripts/check-python-source.py --staged',
                                 'scripts/run-admission-controls.py'])

    def test_python_callers_and_shared_infrastructure(self):
        for name in ['experiments/public-debug/run.py', 'scripts/bend-check',
                     'benchmarks/contract.json', '.githooks/pre-commit',
                     '.github/workflows/check.yml']:
            with self.subTest(name=name):
                calls = self.check_paths([name])
                self.assertEqual(calls[0], 'scripts/check-python-source.py --staged')
                self.assertIn('scripts/test-task-runner.py', calls)
                self.assertIn('scripts/run-admission-controls.py', calls)
                self.assertIn('benchmarks/test-statistics.py', calls)
                self.assertEqual(calls[-1], 'scripts/test-pre-commit.py')

    def test_mixed_paths_and_quoted_names(self):
        calls = self.check_paths(['docs/notes with spaces.md',
                                  'experiments/public-debug/odd\nname.py'])
        self.assertIn('scripts/test-task-runner.py', calls)

    def test_inherited_repository_environment_is_isolated(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            env = {key: value for key, value in os.environ.items()
                   if not key.startswith('GIT_')}
            subprocess.run(['git', 'init', '-q', str(root)], env=env, check=True)
            (root / 'sentinel').write_text('unchanged\n')
            subprocess.run(['git', 'add', 'sentinel'], cwd=root, env=env, check=True)
            index = root / '.git/index'
            before = index.read_bytes()
            with patch.dict(os.environ, GIT_DIR=str(root / '.git'),
                            GIT_WORK_TREE=str(root), GIT_INDEX_FILE=str(index)):
                calls = self.check_paths(['docs/only.md'])
            self.assertEqual(calls, ['scripts/check-python-source.py --staged',
                                 'scripts/run-admission-controls.py'])
            self.assertEqual(index.read_bytes(), before)

    def test_registered_simulation_controls(self):
        selected = REGISTRY['selected']
        prefix = 'experiments/public-simulation/delivery-v1/optimization-v1/'
        for changed, control in [('prepare-sampling.py','test-sampling-receipt.py'),
                                 ('validate-timing.py','test-timing.py'),
                                 ('validate-after-profile.py','test-after-profile.py')]:
            self.assertEqual(selected({prefix + changed}), [prefix + control])
        self.assertEqual(selected({'docs/notes.md'}), [])
        self.assertEqual(len(selected({'scripts/task_runner.py'})), 7)

    def test_registered_source_attempt_preservation(self):
        prefix = REGISTRY['CHUNKED_OUTPUT']
        for changed in ('check-source.py', 'test-source-preservation.py'):
            with self.subTest(changed=changed):
                calls = self.check_paths([prefix + changed])
                self.assertEqual(calls.count('scripts/run-admission-controls.py'), 1)
                self.assertEqual(REGISTRY['selected']({prefix + changed}),
                                 [prefix + 'test-source-preservation.py'])

    def test_registered_inspector_collector_controls(self):
        prefix = REGISTRY['INSPECTOR_LEAF']
        for changed in ('development.py', 'test-preparation.py'):
            self.assertEqual(REGISTRY['selected']({prefix + changed}),
                             [prefix + 'test-preparation.py'])


    def test_registered_lowering_source_controls(self):
        prefix = REGISTRY['LOWERING_COST']
        for changed in ('cost-comp.ts', 'COPY.json', 'clean-comp.ts.gz',
                        'cache-comp.ts.gz', 'cache.patch', 'observational.patch',
                        'test-source.py', 'controls.mjs', 'cost.mjs'):
            with self.subTest(changed=changed):
                # Exercise an actual staged path, not only a guessed selector call.
                calls = self.check_paths([prefix + changed])
                self.assertIn('scripts/run-admission-controls.py', calls)
                self.assertEqual(calls.count('scripts/run-admission-controls.py'), 1)
                self.assertEqual(REGISTRY['selected']({prefix + changed}),
                                 [prefix + 'test-source.py'])

    def test_real_cost_only_stage_runs_registered_inverse_control(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
            env.update(GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_GLOBAL=os.devnull)
            subprocess.run(['git', 'init', '-q', str(root)], env=env, check=True)
            prefix = REGISTRY['LOWERING_COST']
            dependencies = next(d for c, d in REGISTRY['CONTROL_SETS']
                                if c == prefix + 'test-source.py')
            for name in dependencies:
                target = root / name
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes((HOOK.parent.parent / name).read_bytes())
            subprocess.run(['git', 'add', '.'], cwd=root, env=env, check=True)
            subprocess.run(['git', '-c', 'user.name=Fixture', '-c',
                            'user.email=fixture@example.invalid', 'commit', '-qm', 'baseline'],
                           cwd=root, env=env, check=True)
            # Only metadata is staged; no Python/shared path triggers broad tests.
            target = root / (prefix + 'COPY.json')
            target.write_bytes(target.read_bytes() + b'\n')
            subprocess.run(['git', 'add', str(target)], cwd=root, env=env, check=True)
            result = subprocess.run([sys.executable, str(root / 'scripts/run-admission-controls.py')],
                                    cwd=root, env=env, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr.decode())
            self.assertIn(b'Ran 5 tests', result.stderr)
            # Mutant retains the exact source inverse but mislabels clean identity.
            import json
            metadata = json.loads(target.read_bytes())
            metadata['cleanSHA256'] = metadata['cacheSHA256']
            target.write_text(json.dumps(metadata))
            subprocess.run(['git', 'add', str(target)], cwd=root, env=env, check=True)
            result = subprocess.run([sys.executable, str(root / 'scripts/run-admission-controls.py')],
                                    cwd=root, env=env, capture_output=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn(b'wrong baseline identity', result.stderr)

    def admission_fixture(self, unstaged=False, unstaged_helper=False, sampling=None):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            env = {key: value for key, value in os.environ.items()
                   if not key.startswith('GIT_')}
            env.update(GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_GLOBAL=os.devnull)
            subprocess.run(['git', 'init', '-q', str(root)], env=env, check=True)
            script = root / 'scripts/run-admission-controls.py'
            script.parent.mkdir()
            script.write_bytes(HOOK.parent.parent.joinpath(
                'scripts/run-admission-controls.py').read_bytes())
            collector = root / ('experiments/public-relation-readers/'
                'current-adoption-v1/ts-reference-v1/fullcapacity-v1/run.py')
            collector.parent.mkdir(parents=True)
            collector.write_text('# frozen collector\n')
            control = collector.with_name('test-admission.py')
            control.write_text("from pathlib import Path\n"
                               "Path('control-ran').write_text('yes')\n"
                               "raise SystemExit(23)\n")
            for name in sorted(set().union(*(dependencies for _, dependencies in REGISTRY['CONTROL_SETS'])) - {
                    'scripts/run-admission-controls.py', str(collector.relative_to(root)), str(control.relative_to(root))}):
                dependency = root / name
                dependency.parent.mkdir(parents=True, exist_ok=True)
                if name == 'scripts/task_runner.py':
                    dependency.write_bytes(HOOK.parent.parent.joinpath(name).read_bytes())
                else:
                    dependency.write_text('# frozen dependency\n')
            if sampling is not None:
                control.write_text("from pathlib import Path\nPath('control-ran').write_text('yes')\n")
                prefix = 'experiments/public-simulation/delivery-v1/optimization-v1/'
                receipt_control = root / (prefix + 'test-sampling-receipt.py')
                receipt_control.write_bytes((HOOK.parent.parent / (prefix + 'test-sampling-receipt.py')).read_bytes())
                source = (HOOK.parent.parent / (prefix + 'prepare-sampling.py')).read_text()
                if sampling == 'mutant':
                    token = " or receipt.get('guardFailures')"
                    self.assertEqual(source.count(token), 1)
                    source = source.replace(token, '')
                (root / (prefix + 'prepare-sampling.py')).write_text(source)
            subprocess.run(['git', 'add', '.'], cwd=root, env=env, check=True)
            if unstaged:
                collector.write_text('# different working-tree collector\n')
            if unstaged_helper:
                helper = root / 'scripts/task_runner.py'
                helper.write_bytes(helper.read_bytes() + b'\n# unstaged helper drift\n')
            result = subprocess.run([sys.executable, str(script)], cwd=root,
                env=env, capture_output=True)
            return result.returncode, (root / 'control-ran').exists(), result.stderr

    def test_registered_sampling_control_blocks_real_guard_mutant(self):
        exitcode, ran, stderr = self.admission_fixture(sampling='positive')
        self.assertEqual(exitcode, 0, stderr.decode())
        self.assertTrue(ran)
        exitcode, ran, stderr = self.admission_fixture(sampling='mutant')
        self.assertNotEqual(exitcode, 0)
        self.assertTrue(ran)
        self.assertIn(b'ValueError not raised', stderr)

    def test_admission_failure_stops_commit(self):
        exitcode, ran, stderr = self.admission_fixture(unstaged=False)
        self.assertNotEqual(exitcode, 0)
        self.assertTrue(ran)

    def test_unstaged_collector_cannot_qualify_staged_bytes(self):
        exitcode, ran, stderr = self.admission_fixture(unstaged=True)
        self.assertNotEqual(exitcode, 0)
        self.assertFalse(ran)

    def test_unstaged_transitive_helper_is_refused_before_control(self):
        exitcode, ran, stderr = self.admission_fixture(unstaged_helper=True)
        self.assertNotEqual(exitcode, 0)
        self.assertFalse(ran)
        self.assertIn(b'Stage the complete admission-control change: scripts/task_runner.py',
                      stderr)


if __name__ == '__main__':
    unittest.main()
