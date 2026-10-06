"""Harness-only real delay; preserve complete child output and exit status."""
import subprocess
import sys
import time

delay = float(sys.argv[1])
result = subprocess.run(sys.argv[2:], capture_output=True)
time.sleep(delay / 1000)
sys.stdout.buffer.write(result.stdout)
sys.stderr.buffer.write(result.stderr)
raise SystemExit(result.returncode)
