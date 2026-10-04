#!/usr/bin/env python3
"""Bounded language-route diagnostics; success is not an owned ECS theorem."""
import hashlib
import json
import os
from pathlib import Path
import signal
import shutil
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
CHECK = ROOT / 'experiments/t01/bend-check'
SOURCE_ROOT = Path('/workspace/formal-proofs/bendvy')


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run(path, flag, expected, diagnostic, env=None):
    start = time.monotonic()
    args = [str(CHECK), str(path), flag]
    process = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                               text=True, start_new_session=True, env=env)
    try:
        output = process.communicate(timeout=6)[0]
    except subprocess.TimeoutExpired:
        os.killpg(process.pid, signal.SIGKILL)
        process.communicate()
        raise AssertionError('Five-second wrapper watchdog failed')
    assert process.returncode == expected, (args, process.returncode, output)
    assert diagnostic in output, (args, output)
    return {'command': args, 'exit_code': process.returncode, 'output': output,
            'elapsed_seconds': round(time.monotonic() - start, 4)}


def main():
    frozen = json.loads((HERE / 'subjects.json').read_text())
    for name, digest in frozen['canonical_sources'].items():
        assert sha(ROOT / name) == digest, name
    text = (ROOT / 'experiments/t11-replacement/LAWS.bend').read_text()
    assert frozen['exact_original_block'] in text
    cases = [
        ('infrastructure.bend', 0, 'ALL PROOFS CHECK'),
        ('template-negative.bend', 1, 'a template applied to closed ~ arguments'),
        ('delayed-negative.bend', 1, 'expected : -guard'),
        ('witness-negative.bend', 1, 'expected : -guard'),
        ('same-branches-negative.bend', 1, 'expected : P.SameBranches(guard)'),
        ('false-negative.bend', 1, 'expected : 0n'),
    ]
    evidence = {'status': 'Diagnostic matrix PASS; no original owned theorem inhabitant found',
                'checker_limit_seconds': 5, 'cases': [], 'canonical_sources': frozen['canonical_sources']}
    for name, expected, diagnostic in cases:
        row = {'file': name, 'expected_result': 'accepted' if expected == 0 else 'initial checker rejection', 'runs': []}
        for flag in ['--check-only', '--verdict']:
            row['runs'].append(run(HERE / name, flag, expected, diagnostic))
        evidence['cases'].append(row)
    evidence['forced_kernel_failure'] = run(HERE / 'infrastructure.bend', '--verdict', 1,
                                            'mismatch', dict(os.environ, BENDTT='/usr/bin/false'))
    evidence['source_hashes'] = {path.name: sha(path) for path in sorted(HERE.glob('*.bend'))}
    evidence['runner_sha256'] = sha(HERE / 'run.py')
    evidence['inventory_sha256'] = sha(HERE / 'PLAN.md')
    inspected = [Path.home() / '.bend/bend2/base.bend', Path.home() / '.bend/bend2/bendtt.lean',
                 SOURCE_ROOT / '.references/bend2/bend2/bend.ts',
                 SOURCE_ROOT / 'experiments/p-owned-route/README.md',
                 SOURCE_ROOT / 'experiments/p-owned-route/guard-witness.bend',
                 SOURCE_ROOT / 'experiments/p-owned-route/empty-family.bend']
    evidence['inspected_source_hashes'] = {str(path): sha(path) for path in inspected}
    evidence['compiler_sha256'] = sha(Path(shutil.which('bend')).resolve())
    evidence['compiler_version'] = subprocess.run(['bend', 'version'], capture_output=True, text=True, check=True).stdout.strip()
    evidence['pinned_checker_source_commit'] = subprocess.run(['git', '-C', str(SOURCE_ROOT / '.references/bend2'), 'rev-parse', 'HEAD'], capture_output=True, text=True, check=True).stdout.strip()
    (HERE / 'evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
    print(evidence['status'])


if __name__ == '__main__':
    main()
