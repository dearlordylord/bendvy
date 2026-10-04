#!/usr/bin/env python3
"""Synthetic boundary controls, not an Autoresearch session or qualification."""
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import time

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('boundary', HERE / 'segment-run.py')
M = importlib.util.module_from_spec(spec)
spec.loader.exec_module(M)
receipts = []
with tempfile.TemporaryDirectory(prefix='bendvy-budget-control-') as tmp:
    folder = Path(tmp)
    code = "import subprocess,sys,time; p=subprocess.Popen([sys.executable,'-c','import time; time.sleep(30)'],start_new_session=True); print(p.pid,flush=True); time.sleep(30)"
    try:
        M.run([sys.executable, '-c', code], folder, time.monotonic()+0.4, M.ENV)
        raise AssertionError('deadline not enforced')
    except TimeoutError:
        pass
    pid = int((folder / 'stdout.txt').read_text().strip())
    time.sleep(.05)
    status = Path('/proc') / str(pid) / 'status'
    assert not status.exists() or '\nState:\tZ' in status.read_text(), 'grandchild survives'
    receipts.extend(['deadline kills parent and new-session grandchild', 'stdout retained'])
try:
    M.remaining(time.monotonic()-1)
    raise AssertionError('exhausted deadline accepted')
except TimeoutError:
    receipts.append('exhausted allowance rejected')
try:
    M.confined('/tmp/bendvy-unapproved-artifact')
    raise AssertionError('escape accepted')
except ValueError:
    receipts.append('artifact-root escape rejected')
source = 'import ./storage.bend\ntype T {x:U32}\ndef f(x:U32,\n  callback:U32->U32)->U32:\n  x\n'
assert M.signatures(source) == M.signatures(source.replace('  x\n', '  1\n'))
for name, changed in [('type', source.replace('x:U32}', 'x:U32,y:U32}')),
                      ('multiline parameter', source.replace('callback:U32->U32', 'callback:U64->U32')),
                      ('result', source.replace(')->U32:', ')->U64:')),
                      ('import', source.replace('./storage.bend', './query.bend'))]:
    assert M.signatures(source) != M.signatures(changed), name
    receipts.append(name+' drift rejected')
for name in ('storage.bend', 'query.bend'):
    text = (HERE.parent / 's-perf/candidate' / name).read_text()
    assert M.signatures(text)['definitions']
receipts.append('actual candidate multiline declarations parse')
for extension in ('@unsafe def extra()->U32: 1\n', 'law extra()->Bool: True{}\n'):
    try:
        M.signatures(source + extension)
        raise AssertionError('unsupported declaration accepted')
    except ValueError:
        pass
receipts.append('annotated helper/new law rejected')
assert M.signatures(source) != M.signatures(source + '  import "./external.js"\n')
assert M.signatures(source) != M.signatures(source + '  def extra()->U32: 1\n')
receipts.append('indented import/helper additions rejected')
for value in (float('nan'), float('inf')):
    try:
        M.remaining(value)
        raise AssertionError('nonfinite deadline accepted')
    except ValueError:
        pass
receipts.append('nonfinite deadlines rejected')
manifest = {'checkout': str(M.ROOT), 'artifactRoot': str(M.ARTIFACTS),
            'environment': dict(M.ENV, TMPDIR='task-owned per invocation under artifactRoot')}
for value in (float('nan'), float('inf'), -1, time.monotonic()+100, True):
    try:
        M.validate_start({'startedMonotonicSeconds': value}, manifest)
        raise AssertionError('invalid start accepted')
    except ValueError:
        pass
receipts.append('invalid/future starts rejected')
assert M.validate_start({'startedMonotonicSeconds': time.monotonic()}, manifest) > time.monotonic()
try:
    M.validate_start({'startedMonotonicSeconds': time.monotonic()}, dict(manifest, checkout='/tmp/other-checkout'))
    raise AssertionError('wrong checkout accepted')
except ValueError:
    pass
receipts.append('wrong checkout rejected')
with tempfile.TemporaryDirectory(prefix='bendvy-orphan-control-') as tmp:
    folder = Path(tmp)
    code = "import subprocess,sys; p=subprocess.Popen([sys.executable,'-c','import time; time.sleep(30)'],start_new_session=True); print(p.pid,flush=True)"
    try:
        M.run([sys.executable, '-c', code], folder, time.monotonic()+0.4, M.ENV)
        raise AssertionError('orphan-held pipe missed deadline')
    except TimeoutError:
        pass
    pid = int((folder / 'stdout.txt').read_text().strip())
    time.sleep(.05)
    status = Path('/proc') / str(pid) / 'status'
    assert not status.exists() or '\nState:\tZ' in status.read_text(), 'orphan survives'
receipts.append('exited-parent new-session orphan killed')
print(json.dumps({'status': 'PASS', 'scope': 'Synthetic execution and scope controls only', 'controls': receipts}, indent=2))
