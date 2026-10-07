#!/usr/bin/env python3
"""Read-only source freeze; deliberately performs no builds or measurements."""
import argparse, hashlib, json, pathlib, re, subprocess

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner

ROOT = pathlib.Path(__file__).resolve().parents[2]
HERE = pathlib.Path(__file__).resolve().parent
FEATURES = ['public-nested-provision', 'public-schedule-readers', 'public-schema-fragments']

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def closure(entries):
    found = set()
    pending = list(entries)
    while pending:
        path = pending.pop().resolve()
        if path in found:
            continue
        assert path.is_file(), path
        found.add(path)
        for token in re.findall(r'^import\s+(\S+)', path.read_text(), re.M):
            if token == 'Base':
                continue
            assert token.endswith('.bend'), (path, token)
            imported = (path.parent / token).resolve()
            assert imported.is_relative_to(ROOT), imported
            pending.append(imported)
    return found

def snapshot():
    inputs = set(HERE.glob('*')) | {p for p in (HERE/'nested-candidate').glob('*') if p.is_file()} | {ROOT / 'scripts/task_runner.py', ROOT / '.references/bend2/bend2/main.ts'}
    inputs |= set((ROOT/'src/ecs').rglob('*.bend'))
    for feature in FEATURES:
        directory = ROOT / 'experiments' / feature
        authored = {p for p in directory.iterdir() if p.is_file() and p.suffix in {'.bend', '.mjs', '.json', '.py', '.md'}}
        inputs |= authored
        inputs |= closure(p for p in authored if p.suffix == '.bend')
    inputs |= {ROOT / p for p in ['docs/SPEC.md', 'docs/tickets/32-p-schedule-provide.md', 'docs/tickets/33-p-schedule-readers.md', 'docs/parity/fragments.md', 'benchmarks/README.md', 'benchmarks/contract.json', '.references/sources.json']}
    return {str(p.relative_to(ROOT)): digest(p) for p in sorted(inputs) if p.is_file()}

def external():
    directories = [ROOT / '.references/bevy-ts/packages/core/src', pathlib.Path('/home/node/.bend/bend2')]
    files = {p for d in directories for p in d.rglob('*') if p.is_file()}
    files |= {ROOT / '.references/bevy-ts/package.json', ROOT / '.references/bevy-ts/packages/core/package.json'}
    return {str(p): digest(p) for p in sorted(files)}

def notice_cache():
    path=pathlib.Path('/home/node/.bend/check.json')
    return {'path':str(path),'SHA256':digest(path) if path.is_file() else None,'scope':'Daily update-notice cache; not checker configuration or executable/compiler input. Future child commands set BEND_NO_TELEMETRY=1.'}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=pathlib.Path, required=True)
    args = parser.parse_args()
    assert not args.output.exists(), 'Output must be fresh'
    sources, dependencies = snapshot(), external()
    manifest = json.loads((ROOT / '.references/sources.json').read_text())['sources']
    heads = {}
    for name, entry in manifest.items():
        actual = task_runner.check_output(['git', '-C', str(ROOT / '.references' / name), 'rev-parse', 'HEAD'], timeout=5, text=True).strip()
        assert actual == entry['commit'], (name, actual, entry['commit'])
        heads[name] = actual
    assert sources == snapshot() and dependencies == external(), 'Source drift during freeze'
    args.output.mkdir(parents=True)
    receipt = {'status': 'PREFLIGHT_ONLY_REPAIR_AND_TIMING_ADAPTER_REVIEW_PENDING', 'sources': sources, 'external': dependencies, 'referenceHeads': heads, 'noticeCacheObserved':notice_cache(), 'scope': 'No builds, timings, equivalent-retry assertion or performance verdict'}
    (args.output / 'preflight.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps({'status': receipt['status'], 'sourceCount': len(sources), 'externalCount': len(dependencies)}))

if __name__ == '__main__':
    main()
