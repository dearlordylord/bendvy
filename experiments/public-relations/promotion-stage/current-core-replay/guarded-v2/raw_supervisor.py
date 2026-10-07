"""Compatibility entrypoint; execution and cleanup live in scripts/task_runner.py."""
from pathlib import Path
import sys

ROOT = next(p for p in Path(__file__).resolve().parents if (p / 'scripts/task_runner.py').is_file())
sys.path.insert(0, str(ROOT / 'scripts'))
from task_runner import execute_result

def execute(command, timeout, env=None):
    return execute_result(command, timeout, env, capture='merged-stdout')
