#!/usr/bin/env python3
"""Whole-program sparse constructor comparison; includes identical setup."""
import argparse
import collections
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
r = {'status': 'INCOMPLETE', 'scope': 'Whole-program sparse construction counts including setup; no heap/time acceptance', 'commands': [], 'cases': []}
try:
    for role in ['original', 'candidate']:
        target = a.output / (role + '.js')
        argv = ['node', '--expose-internals', str(HERE.parent / 'js-allocation-map/instrument.cjs'), str(a.built / (role + '.js')), str(target)]
        code, out = supervisor.execute(argv, 5)
        r['commands'].append({'argv': argv, 'limitSeconds': 5, 'exit': code})
        assert code == 0, out
        source = target.read_text()
        assert source.count('let __allocation_active=false;') == 1
        source = source.replace('let __allocation_active=false;', 'let __allocation_active=true;')
        target.write_text('process.on("exit",()=>__allocation_phase("end"));\n' + source)
        argv = ['node', str(target)]
        code, out = supervisor.execute(argv, 5)
        r['commands'].append({'argv': argv, 'limitSeconds': 5, 'exit': code})
        (a.output / (role + '.txt')).write_text(out)
        assert code == 0 and 'SPARSE-HIGH-PASS' in out
        reports = [line for line in out.splitlines() if line.startswith('ALLOCATION-COUNTS:')]
        assert len(reports) == 1
        counts = json.loads(reports[0].split(':', 1)[1])
        sites = json.loads(Path(str(target) + '.sites.json').read_text())['sites']
        assert len(counts) == len(sites)
        kinds = collections.Counter()
        for site, count in zip(sites, counts):
            kinds[site['kind'].split('s-integrate/')[-1]] += count
        r['cases'].append({'role': role, 'total': sum(counts), 'kinds': dict(kinds), 'generatedSHA256': hashlib.sha256(target.read_bytes()).hexdigest()})
    r['delta'] = r['cases'][1]['total'] - r['cases'][0]['total']
    r['status'] = 'ORIGINAL_CANDIDATE_SPARSE_OUTPUTS_PASS'
except Exception as error:
    r['error'] = repr(error)
finally:
    (a.output / 'evidence.json').write_text(json.dumps(r, indent=2) + '\n')
print(json.dumps(r))
sys.exit(0 if r['status'] == 'ORIGINAL_CANDIDATE_SPARSE_OUTPUTS_PASS' else 1)
