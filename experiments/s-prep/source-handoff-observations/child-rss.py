#!/usr/bin/env python3
"""Fresh Linux one-child peak RSS; whole child process, not active-Tx memory."""
import argparse
import json
import math
import os
import resource
import subprocess
import sys
import time
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument('--receipt', type=Path, required=True)
p.add_argument('argv', nargs=argparse.REMAINDER)
a = p.parse_args()
argv = a.argv[1:] if a.argv[:1] == ['--'] else a.argv
assert sys.platform.startswith('linux')
assert argv and not a.receipt.exists()
assert resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss == 0
env = {'PATH': '/usr/local/bin:/usr/bin:/bin', 'LANG': 'C.UTF-8', 'LC_ALL': 'C.UTF-8'}
assert dict(os.environ) == env, 'unexpected wrapper environment'
start = time.monotonic()
# Inherit the outer supervisor's process group: its timeout also owns this child.
child = subprocess.Popen(argv, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                         text=True, env=env)
timed_out = False
try:
    output = child.communicate(timeout=5)[0]
except subprocess.TimeoutExpired:
    timed_out = True
    child.kill()
    output = child.communicate()[0]
usage = resource.getrusage(resource.RUSAGE_CHILDREN)
elapsed = time.monotonic() - start
peak = usage.ru_maxrss
assert math.isfinite(elapsed) and elapsed >= 0 and peak > 0
a.receipt.write_text(json.dumps({'status': 'CHILD_PEAK_RSS_PASS' if child.returncode == 0 and not timed_out else 'CHILD_FAILED',
                                 'argv': argv, 'environment': env, 'exit': child.returncode,
                                 'timeout': timed_out, 'childLimitSeconds': 5,
                                 'peakRSSKiB': peak, 'wrapperWallSeconds': elapsed,
                                 'scope': 'Fresh Linux RUSAGE_CHILDREN for exactly one direct child; whole-process peak, not aggregate process-tree or active-Tx memory'}, indent=2) + '\n')
sys.stdout.write(output)
sys.exit(124 if timed_out else child.returncode)
