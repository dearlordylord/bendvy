#!/usr/bin/env python3
"""Materialize the frozen baseline with explicit indexed candidate overrides."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
BASELINE = 'a976667'


def materialize(destination, candidate=None):
    destination = Path(destination).resolve()
    if destination.exists():
        raise FileExistsError(f'overlay destination must be fresh: {destination}')
    candidate = Path(candidate or ROOT / 'experiments/s-perf/candidate').resolve()
    names = subprocess.check_output(
        ['git', 'ls-tree', '-r', '--name-only', BASELINE, 'experiments'],
        cwd=ROOT, text=True).splitlines()
    sources = {}
    overrides = {}
    for name in names:
        if not name.endswith('.bend'):
            continue
        data = subprocess.check_output(['git', 'show', f'{BASELINE}:{name}'], cwd=ROOT)
        replacement = candidate / Path(name).name
        if Path(name).parent == Path('experiments/s-integrate') and replacement.is_file():
            data = replacement.read_bytes()
            overrides[name] = str(replacement)
        target = destination / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
        sources[name] = hashlib.sha256(data).hexdigest()
    # Prove every relative Bend import stays within this immutable copy.
    for name in sources:
        path = destination / name
        for imported in re.findall(r'^import\s+(\S+)', path.read_text(), re.M):
            if imported.startswith('.'):
                target = (path.parent / imported).resolve()
                if not target.is_relative_to(destination) or not target.is_file():
                    raise ValueError(f'unresolved overlay import: {name}: {imported}')
    manifest = {'baseline': BASELINE, 'overrides': overrides, 'sources': sources}
    (destination / 'overlay.json').write_text(json.dumps(manifest, indent=2) + '\n')
    return manifest


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('destination', type=Path)
    parser.add_argument('--candidate', type=Path)
    args = parser.parse_args()
    result = materialize(args.destination, args.candidate)
    print(json.dumps({'baseline': BASELINE, 'sourceCount': len(result['sources']),
                      'overrides': list(result['overrides'])}))
