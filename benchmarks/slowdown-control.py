"""Harness-only real delay; preserve complete child output and exit status."""
import subprocess
import sys
import time

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner


delay = float(sys.argv[1])
result = task_runner.run(sys.argv[2:], timeout=5, capture_output=True)
time.sleep(delay / 1000)
sys.stdout.buffer.write(result.stdout)
sys.stderr.buffer.write(result.stderr)
raise SystemExit(result.returncode)
