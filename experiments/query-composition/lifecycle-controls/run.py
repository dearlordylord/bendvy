#!/usr/bin/env python3
"""Finite lifecycle controls; source hashes and exact observations on JS/Native."""
import hashlib
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
OUT = Path(os.environ.get('BENDVY_LIFECYCLE_OUTPUT', '/tmp/bendvy-lifecycle-controls'))
EXPECTED = {
    'self-writes': 'self-first:true;self-repeat:true;self-failure:true;failed-self-stamp:true;restored-owner:true;self-retry:true;self-repeat-after-retry:true;\n',
    'stamps': 'empty:true;add:true;equal-write:true;rollback:true;same-name-other-family:true;restored-owner:true;remove:true;re-add:true;\n',
    'column': 'projection-neutral:true;clear:true\n',
    'cursors': 'A-first:true;B-independent:true;A-repeat:true;A-failure:true;A-retry:true;B-later:true;A-repeat-after-retry:true;\n',
    'boundaries': 'deferred-before-barrier:true;deferred-after-barrier:true;exhaustion-recovers-incoming:true;exhaustion-clock:true;exhaustion-preserves-stamp:true;\n',
}

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    OUT.mkdir(parents=True, exist_ok=True)
    sources = sorted((ROOT / 'src/ecs').glob('*.bend')) + sorted(HERE.glob('*.bend')) + [ROOT / 'examples/user-simulation/schema.bend', HERE / 'run.py', HERE / 'self-writes-reference.mjs']
    receipt = {'status': 'INCOMPLETE', 'sources': {str(p.relative_to(ROOT)): sha(p) for p in sources}, 'commands': [], 'observations': {}}
    env = os.environ.copy()
    env['BENDVY_CLANG19_ROOT'] = '/tmp/bendvy-clang19-diagnostic/root'
    def run(cmd, seconds, label):
        result = subprocess.run(['timeout', '--signal=KILL', str(seconds), *map(str, cmd)], cwd=ROOT, env=env, text=True, capture_output=True)
        (OUT / (label + '.stdout')).write_text(result.stdout)
        (OUT / (label + '.stderr')).write_text(result.stderr)
        receipt['commands'].append({'argv': list(map(str, cmd)), 'limitSeconds': seconds, 'exit': result.returncode, 'label': label})
        (OUT / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
        assert result.returncode == 0, f'{label}: exit {result.returncode}: {result.stdout} {result.stderr}'
        return result.stdout
    reference = run(['node', HERE / 'self-writes-reference.mjs'], 5, 'self-writes-TS')
    receipt['reference'] = json.loads(reference)
    assert receipt['reference'] == {'counts': [1, 0, 1, 1, 0], 'failed': True, 'retryRestoredPayload': [{'value': 7, 'owned': [71, 72]}]}
    for name, expected in EXPECTED.items():
        entry = HERE / (name + '.bend')
        checked = run(['bend', entry, '--check-only'], 5, name + '-check')
        assert 'ALL PROOFS CHECK' in checked
        run(['bend', entry, '-o', OUT / (name + '.js')], 30, name + '-emit-js')
        run(['bend', entry, '-o', OUT / (name + '.c')], 30, name + '-emit-c')
        run(['/tmp/bendvy-clang19-diagnostic/clang19', '-O3', OUT / (name + '.c'), '-o', OUT / (name + '.native'), '-pthread', '-lm'], 120, name + '-clang')
        receipt['observations'][name] = {}
        for backend, cmd in [('JS', ['node', OUT / (name + '.js')]), ('Native', [OUT / (name + '.native')])]:
            actual = run(cmd, 5, name + '-' + backend)
            assert actual == expected, f'{name}/{backend}: {actual!r} != {expected!r}'
            receipt['observations'][name][backend] = actual
    for p in sources:
        assert sha(p) == receipt['sources'][str(p.relative_to(ROOT))], f'source changed: {p}'
    receipt['status'] = 'PASS_FINITE_LIFECYCLE_BOTH_BACKENDS'
    (OUT / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(receipt['status'])

if __name__ == '__main__':
    main()
