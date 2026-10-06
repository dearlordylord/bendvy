#!/usr/bin/env python3
"""Reproduce phase-only gprof diagnostics and validate every output field."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT/'experiments/s-prep/fivehour-connected-gates'))
import supervisor
p = argparse.ArgumentParser()
p.add_argument('--source', type=Path, required=True)
p.add_argument('--reference', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
p.add_argument('--cpu', type=int, default=11)
a = p.parse_args()
a.output = a.output.absolute()
a.output.mkdir(exist_ok=False)
os.sched_setaffinity(0, {a.cpu})
r = {'status': 'INCOMPLETE', 'scope': 'Native computation-only sampled profile, no elapsed acceptance', 'cpu': a.cpu, 'commands': []}
sha = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
def run(argv, limit, cwd=None):
    old = Path.cwd()
    try:
        if cwd: os.chdir(cwd)
        code, output = supervisor.execute(list(map(str, argv)), limit)
    finally:
        os.chdir(old)
    r['commands'].append({'argv': list(map(str, argv)), 'limitSeconds': limit, 'exit': code, 'outputSHA256': hashlib.sha256(output.encode()).hexdigest()})
    assert code == 0, output[-1000:]
    return output
try:
    r['inputSHA256'] = sha(a.source)
    run([sys.executable, Path(__file__).with_name('materialize.py'), '--source', a.source, '--output', a.output/'phase.c'], 5)
    run(['clang', '-O3', '-g', '-pg', a.output/'phase.c', '-pthread', '-lm', '-o', a.output/'phase-profile'], 120)
    ts = run(['node', a.reference], 5)
    # Keep stderr separate: IO writes may split JSON lines around clock markers.
    redirect = 'import os,sys; fd=os.open(sys.argv[1],os.O_WRONLY|os.O_CREAT|os.O_EXCL,0o600); os.dup2(fd,2); os.close(fd); os.execv(sys.argv[2],sys.argv[2:])'
    native = run([sys.executable, '-c', redirect, a.output/'clock.txt', a.output/'phase-profile', '--threads', '1', '--gpu', 'off'], 5, a.output)
    (a.output/'TS.raw.txt').write_text(ts)
    (a.output/'Native.raw.txt').write_text(native)
    clocks = (a.output/'clock.txt').read_text().splitlines()
    assert clocks == [f'DIAGNOSTIC-CLOCK:{i}' for i in range(1, 5)], clocks
    spec = importlib.util.spec_from_file_location('validator', ROOT/'experiments/s-integrate/measurement-bend-run.py')
    v = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(v)
    observed = json.loads(ts)
    records = [x for x in native.splitlines() if x.startswith('{')]
    assert len(records) == 65 and len(observed['samples']) == 64
    for line, world in zip(records, [observed['warmup'], *observed['samples']]):
        v.validate(line, 'Motion', False, 256, world)
        assert v.normalized(json.loads(line), 'Motion') == world['final']
    flat = run(['gprof', '-b', '-p', a.output/'phase-profile', a.output/'gmon.out'], 5)
    (a.output/'flat.txt').write_text(flat)
    r.update(status='PHASE_PROFILE_FULL65_WORLDS_PASS', clocks=clocks, allFullFieldsEqual=True,
             artifacts={x: sha(a.output/x) for x in ['phase.c', 'phase.recipe.json', 'gmon.out', 'flat.txt', 'clock.txt', 'TS.raw.txt', 'Native.raw.txt']})
except Exception as e:
    r.update(status='FAIL', error=repr(e))
finally:
    (a.output/'evidence.json').write_text(json.dumps(r, indent=2)+'\n')
print(json.dumps(r))
sys.exit(0 if r['status']=='PHASE_PROFILE_FULL65_WORLDS_PASS' else 1)
