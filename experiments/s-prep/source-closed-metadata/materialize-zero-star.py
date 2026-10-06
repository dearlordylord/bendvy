#!/usr/bin/env python3
"""Reproduce the exact closed private source frontier; no compiler changes."""
import argparse
import hashlib
import json
import pathlib
import shutil
import subprocess
import tempfile

HERE = pathlib.Path(__file__).resolve().parent
CHANGED = ['experiments/s-integrate/commands.bend', 'experiments/s-integrate/host.bend', 'experiments/s-integrate/identity.bend', 'experiments/s-integrate/measurement-bend.bend', 'experiments/s-integrate/observations.bend', 'experiments/s-integrate/query.bend', 'experiments/s-integrate/raw-boundaries.bend', 'experiments/s-integrate/reader-host.bend', 'experiments/s-integrate/storage.bend', 'experiments/s-integrate/streams.bend', 'experiments/s-integrate/transaction-dispatch-adapters.bend', 'experiments/s-integrate/transaction.bend']


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def closure_digest(pins):
    return hashlib.sha256(json.dumps(pins, sort_keys=True, separators=(',', ':')).encode()).hexdigest()

def require(condition, message):
    if not condition:
        raise ValueError(message)

def materialize(source, output):
    source = source.resolve(strict=True)
    output = output.absolute()
    require(not output.exists(), 'Output must be fresh and absent')
    require(not output.is_relative_to(source), 'Output cannot be inside input')
    require(not any(p.is_symlink() for p in source.rglob('*')), 'Symlinks are not supported')
    overlay = json.loads((source / 'overlay.json').read_text())
    cache = json.loads((source / 'cache-specialization.json').read_text())
    pins = {str(p.relative_to(source)): digest(p) for p in source.rglob('*.bend')}
    require(pins == json.loads((HERE / 'input-pins.json').read_text()), 'Unsupported full source closure')
    require(len(pins) == 29, 'Expected exactly 29 runtime modules')
    require(pins == overlay['sources'], 'Overlay source pins disagree with actual sources')
    require(cache == overlay['cacheSpecialization'], 'Cache receipts disagree')
    require(cache['runtimeClosure'] == pins, 'Runtime closure must pin all 29 modules')
    require(cache['specializedClosure'] == pins, 'Specialized closure must pin all 29 modules')
    require(cache['runtimeClosureSHA256'] == closure_digest(pins), 'Closure digest mismatch')
    patch = HERE / 'zero-star-source.patch'
    expected = json.loads((HERE / 'zero-star-output-pins.json').read_text())
    with tempfile.TemporaryDirectory(prefix='bendvy-zero-star-source-') as temp:
        stage = pathlib.Path(temp) / 'overlay'
        shutil.copytree(source, stage)
        subprocess.run(['patch', '--batch', '--fuzz=0', '-p1', '-i', str(patch)], cwd=stage, check=True, capture_output=True, text=True)
        newpins = {str(p.relative_to(stage)): digest(p) for p in stage.rglob('*.bend')}
        require(newpins.keys() == pins.keys(), 'Runtime module set changed')
        require(sorted(name for name in pins if pins[name] != newpins[name]) == CHANGED, 'Unexpected module mutation')
        require(newpins == expected, 'Derived source does not match verified closure')
        for name in pins:
            oldheaders = [line for line in (source / name).read_text().splitlines() if line.startswith(('def ', 'type '))]
            newlines = (stage / name).read_text().splitlines()
            require(all(line in newlines for line in oldheaders), 'Original public header changed: ' + name)
        cache['runtimeClosure'] = newpins
        cache['specializedClosure'] = newpins.copy()
        cache['runtimeClosureSHA256'] = closure_digest(newpins)
        overlay['sources'] = newpins
        overlay['cacheSpecialization'] = cache
        receipt = {'status': 'UNMEASURED_SOURCE_VARIANT', 'variant': 'source-closed-private-zero-star-static-schema',

                   'inputClosureSHA256': closure_digest(pins), 'outputClosureSHA256': closure_digest(newpins),
                   'patchSHA256': digest(patch), 'materializerSHA256': digest(pathlib.Path(__file__)),
                   'runtimeModules': len(newpins), 'changedModules': CHANGED,
                   'performanceAcceptance': False, 'productionAdoption': False}
        for name, value in [('overlay.json', overlay), ('cache-specialization.json', cache), ('zero-star-source.json', receipt)]:
            (stage / name).write_text(json.dumps(value, indent=2) + '\n')
        shutil.copytree(stage, output)
    return output / 'experiments/s-integrate'

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=pathlib.Path, required=True)
    parser.add_argument('--output', type=pathlib.Path, required=True)
    args = parser.parse_args()
    print(materialize(args.input, args.output))
