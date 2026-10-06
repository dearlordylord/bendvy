#!/usr/bin/env python3
"""Apply only the pinned private affine Health ledger transport patch."""
import argparse
import hashlib
import json
import pathlib
import shutil
import subprocess
import tempfile

HERE = pathlib.Path(__file__).resolve().parent
TARGETS = ('experiments/s-integrate/held-adapter.bend',)
BASE_QUERY = '3c8b0c7db52daa35fcfabb03fc627b12c4d718d2ec2d92f15f84490e784f5d9e'

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
    require(pins == json.loads((HERE / 'input-pins.json').read_text()), 'Exact frozen 29-module source pins required')
    require(pins == overlay['sources'], 'Overlay source pins disagree with actual sources')
    require(cache == overlay['cacheSpecialization'], 'Cache receipts disagree')
    require(cache['runtimeClosure'] == pins, 'Runtime closure must pin all 29 modules')
    require(cache['specializedClosure'] == pins, 'Specialized closure must pin all 29 modules')
    require(cache['runtimeClosureSHA256'] == closure_digest(pins), 'Closure digest mismatch')
    require(pins[TARGETS[0]] == BASE_QUERY, 'Unsupported held-adapter input revision')
    patches = [HERE/'held-adapter.patch']
    for target,patch in zip(TARGETS,patches):
        patch_text=patch.read_text()
        require(patch_text.startswith('--- a/'+target+'\n+++ b/'+target+'\n') and patch_text.count('\n--- ')==0,'Patch target mismatch')
    with tempfile.TemporaryDirectory(prefix='bendvy-held-flat-') as temp:
        stage = pathlib.Path(temp) / 'overlay'
        shutil.copytree(source, stage)
        for patch in patches:subprocess.run(['patch','--batch','--fuzz=0','-p1','-i',str(patch)],cwd=stage,check=True,capture_output=True,text=True)
        newpins = {str(p.relative_to(stage)): digest(p) for p in stage.rglob('*.bend')}
        require(newpins.keys() == pins.keys(), 'Runtime module set changed')
        require(set(name for name in pins if pins[name]!=newpins[name])==set(TARGETS),'Unexpected module mutation')
        for target in TARGETS:
            oldheaders=[line for line in (source/target).read_text().splitlines() if line.startswith(('def ','type '))]
            newlines=(stage/target).read_text().splitlines()
            require(all(line in newlines for line in oldheaders),'Original definition/type header changed')
        cache['runtimeClosure'] = newpins
        cache['specializedClosure'] = newpins.copy()
        cache['runtimeClosureSHA256'] = closure_digest(newpins)
        overlay['sources'] = newpins
        overlay['cacheSpecialization'] = cache
        receipt = {'status': 'UNMEASURED_SOURCE_VARIANT', 'variant': 'source-health-ledger-flat-v3',
                   'inputHeldAdapterSHA256': pins[TARGETS[0]], 'outputHeldAdapterSHA256': newpins[TARGETS[0]],
                   'inputClosureSHA256': closure_digest(pins), 'outputClosureSHA256': closure_digest(newpins),
                   'patchSHA256': {p.name:digest(p) for p in patches}, 'materializerSHA256': digest(pathlib.Path(__file__)),
                   'runtimeModules': len(newpins), 'changedModules': list(TARGETS),
                   'performanceAcceptance': False, 'productionAdoption': False}
        for name, value in [('overlay.json', overlay), ('cache-specialization.json', cache), ('health-ledger-flat.json', receipt)]:
            (stage / name).write_text(json.dumps(value, indent=2) + '\n')
        shutil.copytree(stage, output)
    return output / 'experiments/s-integrate'

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=pathlib.Path, required=True)
    parser.add_argument('--output', type=pathlib.Path, required=True)
    args = parser.parse_args()
    print(materialize(args.input, args.output))
