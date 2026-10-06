#!/usr/bin/env python3
"""One adjacent exact-work diagnostic; never a qualified cohort or keep."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import sys

ROOT = Path('/workspace/formal-proofs/bendvy')
sys.path.insert(0, str(ROOT / 'experiments/s-prep/fivehour-connected-gates'))
import supervisor

p = argparse.ArgumentParser()
p.add_argument('--baseline-overlay', type=Path, required=True)
p.add_argument('--candidate-overlay', type=Path, required=True)
p.add_argument('--baseline-native', type=Path, required=True)
p.add_argument('--candidate-native', type=Path, required=True)
p.add_argument('--baseline-js', type=Path)
p.add_argument('--candidate-js', type=Path)
p.add_argument('--schema', choices=['Motion', 'Health'], default='Motion')
p.add_argument('--cpu', type=int, default=11)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
a.output = a.output.absolute()
a.output.mkdir(exist_ok=False)
os.sched_setaffinity(0, {a.cpu})
sha = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
r = {'status': 'INCOMPLETE', 'scope': 'One adjacent source-bound full65 comparison; no qualification, cohort, adoption or canonical allowance reset', 'schema': a.schema, 'cpu': a.cpu, 'batch': 64, 'count': 256, 'commands': [], 'inputPins': {}}

def run(role, argv):
    code, out = supervisor.execute(list(map(str, argv)), 5)
    target = a.output / (role + '.txt')
    target.write_text(out)
    r['commands'].append({'role': role, 'argv': list(map(str, argv)), 'limitSeconds': 5, 'exit': code, 'outputSHA256': sha(target)})
    assert code == 0, out[-1000:]
    return out

try:
    for role, overlay in [('baseline', a.baseline_overlay), ('candidate', a.candidate_overlay)]:
        m = json.loads((overlay / 'overlay.json').read_text())
        pins = {str(path.relative_to(overlay)): sha(path) for path in overlay.rglob('*.bend')}
        assert len(pins) == 29 and pins == m['sources'], 'Runtime source mismatch'
        cache = json.loads((overlay / 'cache-specialization.json').read_text())
        assert cache == m['cacheSpecialization'] and cache['runtimeClosure'] == cache['specializedClosure'] == pins
        assert cache['runtimeClosureSHA256'] == hashlib.sha256(json.dumps(pins, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
        r['inputPins'][role] = {'manifestSHA256': sha(overlay / 'overlay.json'), 'runtimeSources': pins}
    for label, path in [('baseline-native', a.baseline_native), ('candidate-native', a.candidate_native), ('baseline-js', a.baseline_js), ('candidate-js', a.candidate_js)]:
        if path:
            r['inputPins'][label] = {'path': str(path.absolute()), 'SHA256': sha(path)}
    reference = a.output / 'reference.mjs'
    source = ROOT / 'experiments/s-integrate/measurement-samples-reference.mjs'
    run('prepare-ts', [sys.executable, ROOT / 'experiments/s-prep/fivehour-measurement/prepare-ts.py', '--source', source, '--output', reference, '--schema', a.schema, '--batch', '64'])
    r['inputPins']['reference'] = {'sourceSHA256': sha(source), 'derivedSHA256': sha(reference)}
    outputs = {'TS': run('TS', ['node', reference])}
    for role, binary in [('baseline-Native', a.baseline_native), ('candidate-Native', a.candidate_native)]:
        outputs[role] = run(role, [binary.absolute(), '--threads', '1', '--gpu', 'off'])
    for role, script in [('baseline-JS', a.baseline_js), ('candidate-JS', a.candidate_js)]:
        if script:
            outputs[role] = run(role, ['node', script.absolute()])
    ts = json.loads(outputs['TS'])
    assert ts['schema'] == a.schema and ts['count'] == 256 and ts['iterations'] == 64 and ts['batch'] == 64 and len(ts['samples']) == 64
    spec = importlib.util.spec_from_file_location('validator', ROOT / 'experiments/s-integrate/measurement-bend-run.py')
    v = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(v)
    r['timingAcceptance'] = False
    for role, out in outputs.items():
        if role == 'TS':
            continue
        lines = out.splitlines()
        records = [line for line in lines if line.startswith('{')]
        assert len(records) == 65
        for line, world in zip(records, [ts['warmup'], *ts['samples']]):
            v.validate(line, a.schema, False, 256, world)
            assert v.normalized(json.loads(line), a.schema) == world['final']
        clocks = [line for line in lines if line.startswith('BATCH-MILLISECONDS:')]
        assert len(clocks) == 1
        assert float(clocks[0].split(':', 1)[1]) >= 0
    r.update(status='ONE_ADJACENT_ALL_FULL65_WORLDS_PASS', allFullFieldsEqual=True)
except Exception as error:
    r['error'] = repr(error)
finally:
    (a.output / 'evidence.json').write_text(json.dumps(r, indent=2) + '\n')
print(json.dumps(r))
sys.exit(0 if r['status'] == 'ONE_ADJACENT_ALL_FULL65_WORLDS_PASS' else 1)
