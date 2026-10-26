"""Disposable child actions for the canonical collector's refusal controls."""
import os
from pathlib import Path
import signal
import sys
import time

mode, directory = sys.argv[1:]
root = Path(directory)
print('control stdout', flush=True)
print('control stderr', file=sys.stderr, flush=True)
if mode == 'nonzero':
    sys.exit(7)
elif mode == 'produce':
    (root / 'actual/artifacts/value').write_bytes(b'original\n')
elif mode == 'artifact-drift':
    (root / 'actual/artifacts/value').write_bytes(b'changed\n')
elif mode == 'consume':
    (root / 'consumed').write_text('unexpected consumption')
elif mode == 'input-drift':
    (root / 'resources/token').write_text('changed\n')
elif mode == 'receipt-failure':
    (root / 'actual/receipt.json').mkdir()
elif mode == 'cancel':
    # Walk actual ownership ancestors, never signal a PID inferred from a name
    # search outside this child's ancestry. The exact collector path is frozen.
    (root / 'child-identity.json').write_text(__import__('json').dumps({
        'pid': os.getpid(),
        'start': Path('/proc/self/stat').read_text().rsplit(')', 1)[1].split()[19]}))
    parent = os.getppid()
    collector = str(root / 'collect.py').encode()
    while parent > 1:
        proc = Path('/proc') / str(parent)
        if collector in (proc / 'cmdline').read_bytes().split(b'\0'):
            os.kill(parent, signal.SIGTERM)
            time.sleep(20)
            raise RuntimeError('collector cancellation did not terminate child')
        parent = int((proc / 'stat').read_text().rsplit(')', 1)[1].split()[1])
    raise RuntimeError('owned collector ancestor unavailable')
elif mode != 'oracle':
    raise ValueError(mode)
