#!/usr/bin/env python3
"""Pin retained #20 evidence without modifying historical inputs or references."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
REFERENCE_ROOT = Path('/workspace/formal-proofs/bendvy/.references')
BASELINE = '56b72f6'
PREFIXES = ('experiments/s-perf/', 'experiments/s-integrate/',
            'experiments/s-integrate-trace/', 'experiments/t01/',
            'docs/reports/s-perf-completion.md', 'docs/reviews/s-perf-final-',
            'docs/design/s-perf-')


def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args], timeout=5)


def digest(value):
    return hashlib.sha256(value).hexdigest()


def snapshot():
    commit = git('rev-parse', BASELINE).decode().strip()
    files = git('ls-tree', '-r', '--name-only', commit).decode().splitlines()
    sources = {}
    for name in files:
        if name.startswith(PREFIXES):
            frozen = git('show', f'{commit}:{name}')
            actual = ROOT / name
            if not actual.is_file() or actual.is_symlink() or actual.read_bytes() != frozen:
                raise ValueError(f'retained input changed: {name}')
            sources[name] = digest(frozen)
    refs = json.loads((ROOT / 'experiments/s-perf/baseline.json').read_text())['references']
    observations = {}
    for name, pin in refs.items():
        path = REFERENCE_ROOT / name
        head = subprocess.check_output(['git', '-C', str(path), 'rev-parse', 'HEAD'], timeout=5).decode().strip()
        dirty = subprocess.check_output(['git', '-C', str(path), 'status', '--porcelain', '--untracked-files=no'], timeout=5).decode()
        if head != pin['commit'] or dirty:
            raise ValueError(f'reference mismatch or tracked drift: {name}')
        observations[name] = {'commit': head, 'trackedClean': True, 'path': str(path)}
    return {'scope': 'Retained #20 inputs for direct S-PREP #22; no loop/session authority',
            'commit': commit, 'sources': sources, 'references': observations,
            'historicalFailuresRetained': True,
            'autoresearchWallClockBudgetSeconds': 3600,
            'budgetSource': 'User authorized one hour of Autoresearch, then results',
            'contractAccepted': False, 'productThresholdsApproved': False}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    parser.add_argument('--verify', type=Path)
    args = parser.parse_args()
    if bool(args.output) == bool(args.verify):
        parser.error('choose exactly one of --output or --verify')
    record = snapshot()
    if args.verify:
        if record != json.loads(args.verify.read_text()):
            raise ValueError('frozen manifest drift')
        print(json.dumps({'status': 'PASS', 'sources': len(record['sources']), 'references': len(record['references'])}))
    else:
        with args.output.open('x') as target:
            target.write(json.dumps(record, indent=2) + '\n')
        print(json.dumps({'status': 'FROZEN', 'sources': len(record['sources'])}))


if __name__ == '__main__':
    main()
