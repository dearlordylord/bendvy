#!/usr/bin/env python3
"""Finite controls for disposable experiment storage; no project archive scan."""
import importlib.util
import os
from pathlib import Path
import sys
import tempfile
import unittest
from task_runner import run

spec = importlib.util.spec_from_file_location(
    'experiment_state', Path(__file__).with_name('check-experiment-state.py'))
state = importlib.util.module_from_spec(spec)
spec.loader.exec_module(state)


class ExperimentStateTests(unittest.TestCase):
    def test_only_policy_readme_can_be_tracked(self):
        self.assertEqual(state.tracked_errors(['experiments/README.md', 'src/core.bend']), [])
        self.assertTrue(state.tracked_errors(['experiments/old/results/receipt.json']))

    def test_raw_archive_cannot_hide_under_an_experiment(self):
        self.assertTrue(state.tracked_errors(['experiments/renamed/objects/' + 'a' * 64 + '.gz']))

    def test_small_temporary_experiment_needs_present_purpose(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            experiment = root / 'experiments' / 'query-check'
            experiment.mkdir(parents=True)
            (experiment / 'main.bend').write_text('import Base\n')
            self.assertTrue(state.local_errors(root))
            (experiment / 'README.md').write_text(
                'Why: reproduce the current query refusal.\n'
                'Remove when: the permanent regression test passes.\n')
            self.assertEqual(state.local_errors(root), [])

    def test_budget_stops_large_tree(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            folder = root / 'experiments'
            folder.mkdir()
            for i in range(state.LIMIT + 1):
                (folder / f'case-{i}').mkdir()
            self.assertIn('exceeds', state.local_errors(root)[0])

    def test_symlink_cannot_hide_an_archive(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'experiments').symlink_to(root, target_is_directory=True)
            self.assertIn('symlink', state.local_errors(root)[0])

    def test_no_experiments_is_valid(self):
        with tempfile.TemporaryDirectory() as directory:
            self.assertEqual(state.local_errors(Path(directory)), [])

    def test_real_index_refuses_archive_and_clean_preserves_policy(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
            run(['git', 'init', '-q', str(root)], env=env, timeout=5, check=True,
                capture_output=True)
            folder = root / 'experiments'
            folder.mkdir()
            policy = folder / 'README.md'
            policy.write_text('Temporary state policy\n')
            scratch = folder / 'old'
            scratch.mkdir()
            (scratch / 'receipt.json').write_text('{}\n')
            run(['git', 'add', '.'], cwd=root, env=env, timeout=5, check=True,
                capture_output=True)
            command = [sys.executable, str(Path(state.__file__)), '--root', str(root)]
            result = run(command, env=env, timeout=5, capture_output=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn(b'tracked experiment', result.stdout)
            run(command + ['--clean'], env=env, timeout=5, check=True,
                capture_output=True)
            self.assertEqual(policy.read_text(), 'Temporary state policy\n')
            self.assertFalse(scratch.exists())
            # A working-tree deletion cannot conceal a still-staged archive.
            self.assertNotEqual(run(command, env=env, timeout=5,
                                    capture_output=True).returncode, 0)
            run(['git', 'add', '-u'], cwd=root, env=env, timeout=5, check=True,
                capture_output=True)
            self.assertEqual(run(command, env=env, timeout=5,
                                 capture_output=True).returncode, 0)


if __name__ == '__main__':
    unittest.main()
