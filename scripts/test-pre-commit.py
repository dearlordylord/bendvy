"""Exercise hook selection against real staged paths in disposable repositories."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


HOOK = Path(__file__).resolve().parents[1] / '.githooks/pre-commit'


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
        self.assertEqual(calls, ['scripts/check-python-source.py --staged'])

    def test_python_callers_and_shared_infrastructure(self):
        for name in ['experiments/public-debug/run.py', 'scripts/bend-check',
                     'benchmarks/contract.json', '.githooks/pre-commit',
                     '.github/workflows/check.yml']:
            with self.subTest(name=name):
                calls = self.check_paths([name])
                self.assertEqual(calls[0], 'scripts/check-python-source.py --staged')
                self.assertIn('scripts/test-task-runner.py', calls)
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
            self.assertEqual(calls, ['scripts/check-python-source.py --staged'])
            self.assertEqual(index.read_bytes(), before)


if __name__ == '__main__':
    unittest.main()
