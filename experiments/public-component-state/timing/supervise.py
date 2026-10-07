"""Compatibility entrypoint; execution and cleanup live in scripts/task_runner.py."""
from pathlib import Path
import sys

ROOT = next(p for p in Path(__file__).resolve().parents if (p / 'scripts/task_runner.py').is_file())
sys.path.insert(0, str(ROOT / 'scripts'))
import subprocess
from task_runner import execute_split

def execute(command, timeout, env):
    env = dict(env, BEND_NO_TELEMETRY='1')
    code, stdout, stderr = execute_split(command, timeout, env)
    return subprocess.CompletedProcess(command, code, stdout, stderr)
