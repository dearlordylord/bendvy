#!/usr/bin/env python3
"""Sample allocations between the exact sparse query entry/return helpers."""
import argparse
import hashlib
import json
import os
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 'fivehour-connected-gates'))
import supervisor

p = argparse.ArgumentParser()
p.add_argument('--built', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
p.add_argument('--cpu', type=int, default=9)
a = p.parse_args()
a.output.mkdir(exist_ok=False)
os.sched_setaffinity(0, {a.cpu})
r = {'status': 'INCOMPLETE', 'scope': 'One sparse query allocation sample per source; profiler overhead, no qualified speed/heap acceptance', 'commands': [], 'cases': []}
try:
    for role in ['original', 'candidate']:
        source = a.built / (role + '.js')
        target = a.output / (role + '.js')
        profile = a.output / (role + '.heapprofile')
        argv = ['python3', str(HERE.parent / 'js-profile/heap-sampling-probe.py'), '--input', str(source), '--output', str(target), '--profile', str(profile)]
        code, out = supervisor.execute(argv, 5)
        r['commands'].append({'argv': argv, 'limitSeconds': 5, 'exit': code})
        assert code == 0, out
        text = target.read_text()
        start = 'function $sparse_grown$(_rows_0) {'
        end = 'function $sparse_finished$(_result_0) {'
        assert text.count(start) == text.count(end) == 1 and '__sparse_start' not in text
        text = 'let __sparse_start;\n' + text.replace(start, start + '\n__allocation_phase("start"); __sparse_start = performance.now();')
        text = text.replace(end, end + '\nconst __sparse_ms = performance.now() - __sparse_start; __allocation_phase("end"); console.error("SPARSE-PROFILE-MS:" + __sparse_ms);')
        target.write_text(text)
        argv = ['node', str(target)]
        code, out = supervisor.execute(argv, 5)
        r['commands'].append({'argv': argv, 'limitSeconds': 5, 'exit': code})
        (a.output / (role + '.txt')).write_text(out)
        assert code == 0 and 'SPARSE-HIGH-PASS' in out
        sample = json.loads(profile.read_text())
        def total(node):
            return node['selfSize'] + sum(total(child) for child in node.get('children', []))
        clocks = [line.split(':', 1)[1] for line in out.splitlines() if line.startswith('SPARSE-PROFILE-MS:')]
        assert len(clocks) == 1
        r['cases'].append({'role': role, 'sourceSHA256': hashlib.sha256(source.read_bytes()).hexdigest(), 'instrumentedSHA256': hashlib.sha256(target.read_bytes()).hexdigest(), 'sampledSelfBytes': total(sample['head']), 'profiledMS': float(clocks[0])})
    r['status'] = 'BOTH_SPARSE_HEAP_OUTPUTS_PASS'
except Exception as error:
    r['error'] = repr(error)
finally:
    (a.output / 'evidence.json').write_text(json.dumps(r, indent=2) + '\n')
print(json.dumps(r))
sys.exit(0 if r['status'] == 'BOTH_SPARSE_HEAP_OUTPUTS_PASS' else 1)
