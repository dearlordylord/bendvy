#!/usr/bin/env python3
"""Apply only the pinned held-adapter transport patch to a verified fresh overlay."""
import argparse
import hashlib
import json
import pathlib
import shutil
import subprocess
import tempfile

HERE = pathlib.Path(__file__).resolve().parent
ADAPTER = 'experiments/s-integrate/held-adapter.bend'
BASE_ADAPTER = 'c3bbe8c8cf1db8417cc4941e490c8b0d88c64bde3046ef1f785ac42362d01038'

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
    require(len(pins) == 29, 'Expected exactly 29 runtime modules')
    require(pins == overlay['sources'], 'Overlay source pins disagree with actual sources')
    require(cache == overlay['cacheSpecialization'], 'Cache receipts disagree')
    require(cache['runtimeClosure'] == pins, 'Runtime closure must pin all 29 modules')
    require(cache['specializedClosure'] == pins, 'Specialized closure must pin all 29 modules')
    require(cache['runtimeClosureSHA256'] == closure_digest(pins), 'Closure digest mismatch')
    require(pins[ADAPTER] == BASE_ADAPTER, 'Unsupported held-adapter input revision')
    patch = HERE / 'held-adapter.patch'
    patch_text = patch.read_text()
    require(patch_text.startswith('--- a/' + ADAPTER + '\n+++ b/' + ADAPTER + '\n'), 'Patch target mismatch')
    require(patch_text.count('\n--- ') == 0, 'Patch must affect held-adapter only')
    with tempfile.TemporaryDirectory(prefix='bendvy-boxed-point-context-fusion-') as temp:
        stage = pathlib.Path(temp) / 'overlay'
        shutil.copytree(source, stage)
        subprocess.run(['patch', '--batch', '--fuzz=0', '-p1', '-i', str(patch)], cwd=stage, check=True, capture_output=True, text=True)
        newpins = {str(p.relative_to(stage)): digest(p) for p in stage.rglob('*.bend')}
        require(newpins.keys() == pins.keys(), 'Runtime module set changed')
        require([name for name in pins if pins[name] != newpins[name]] == [ADAPTER], 'Unexpected module mutation')
        oldheaders = [line for line in (source / ADAPTER).read_text().splitlines() if line.startswith(('def ', 'type '))]
        newlines = (stage / ADAPTER).read_text().splitlines()
        require(all(line in newlines for line in oldheaders), 'Public definition/type header changed')
        cache['runtimeClosure'] = newpins
        cache['specializedClosure'] = newpins.copy()
        cache['runtimeClosureSHA256'] = closure_digest(newpins)
        overlay['sources'] = newpins
        overlay['cacheSpecialization'] = cache
        receipt = {'status': 'UNMEASURED_SOURCE_VARIANT', 'variant': 'boxed-point-context-v1',
                   'inputAdapterSHA256': pins[ADAPTER], 'outputAdapterSHA256': newpins[ADAPTER],
                   'inputClosureSHA256': closure_digest(pins), 'outputClosureSHA256': closure_digest(newpins),
                   'patchSHA256': digest(patch), 'materializerSHA256': digest(pathlib.Path(__file__)),
                   'runtimeModules': len(newpins), 'changedModules': [ADAPTER],
                   'performanceAcceptance': False, 'productionAdoption': False}
        for name, value in [('overlay.json', overlay), ('cache-specialization.json', cache), ('boxed-point-context.json', receipt)]:
            (stage / name).write_text(json.dumps(value, indent=2) + '\n')
        shutil.copytree(stage, output)
    return output / 'experiments/s-integrate'

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=pathlib.Path, required=True)
    parser.add_argument('--output', type=pathlib.Path, required=True)
    args = parser.parse_args()
    print(materialize(args.input, args.output))
