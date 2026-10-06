#!/usr/bin/env python3
"""Apply only the pinned view recursive Data view patch to a verified fresh overlay."""
import argparse
import hashlib
import json
import pathlib
import shutil
import subprocess
import tempfile

HERE = pathlib.Path(__file__).resolve().parent
MODULES = ['experiments/s-integrate/'+m+'.bend' for m in ['types','cached-payload','host-render','measurement-bend','prototype-static-client']]

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
    require(pins == json.loads((HERE/'input-pins.json').read_text()), 'Unsupported full input source closure')
    patch = HERE / 'views.patch'
    require([x[6:] for x in patch.read_text().splitlines() if x.startswith('--- a/')] == MODULES, 'Patch module catalog mismatch')
    with tempfile.TemporaryDirectory(prefix='bendvy-native-view-boxing-fusion-') as temp:
        stage = pathlib.Path(temp) / 'overlay'
        shutil.copytree(source, stage)
        subprocess.run(['patch', '--batch', '--fuzz=0', '-p1', '-i', str(patch)], cwd=stage, check=True, capture_output=True, text=True)
        newpins = {str(p.relative_to(stage)): digest(p) for p in stage.rglob('*.bend')}
        require(newpins.keys() == pins.keys(), 'Runtime module set changed')
        require(newpins == json.loads((HERE/'output-pins.json').read_text()), 'Unsupported output source closure')
        require(sorted(name for name in pins if pins[name] != newpins[name]) == sorted(MODULES), 'Unexpected module mutation')
        for module in MODULES:
            oldheaders = [line for line in (source/module).read_text().splitlines() if line.startswith(('def ', 'type '))]
            newlines = (stage/module).read_text().splitlines()
            require(all(line in newlines for line in oldheaders), 'Public header changed')
        cache['runtimeClosure'] = newpins
        cache['specializedClosure'] = newpins.copy()
        cache['runtimeClosureSHA256'] = closure_digest(newpins)
        overlay['sources'] = newpins
        overlay['cacheSpecialization'] = cache
        receipt = {'status': 'UNMEASURED_SOURCE_VARIANT', 'variant': 'native-view-boxing-v1',
                   'inputSourcePins': pins, 'outputSourcePins': newpins,
                   'inputClosureSHA256': closure_digest(pins), 'outputClosureSHA256': closure_digest(newpins),
                   'patchSHA256': digest(patch), 'materializerSHA256': digest(pathlib.Path(__file__)),
                   'runtimeModules': len(newpins), 'changedModules': MODULES,
                   'performanceAcceptance': False, 'productionAdoption': False}
        for name, value in [('overlay.json', overlay), ('cache-specialization.json', cache), ('native-view-boxing.json', receipt)]:
            (stage / name).write_text(json.dumps(value, indent=2) + '\n')
        shutil.copytree(stage, output)
    return output / 'experiments/s-integrate'

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=pathlib.Path, required=True)
    parser.add_argument('--output', type=pathlib.Path, required=True)
    args = parser.parse_args()
    print(materialize(args.input, args.output))
