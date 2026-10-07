"""Compatibility entrypoint; execution and cleanup live in scripts/task_runner.py."""
from pathlib import Path
import sys

ROOT = next(p for p in Path(__file__).resolve().parents if (p / 'scripts/task_runner.py').is_file())
sys.path.insert(0, str(ROOT / 'scripts'))
from task_runner import child_pids, enable_subreaper, kill_descendants, cleanup_owned, execute, execute_split
