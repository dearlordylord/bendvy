#!/usr/bin/env python3
"""Pin-checked three-way source composition; conflicts fail closed."""
import argparse
import hashlib
import json
import shutil
import subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
EXPECTED = {'baseline': '409d87045a832f021c7d7a1aa880ebfd16ff8d2b9eb5035883d96f781a49daad',
            'query': '9f4ddc5fde5ac5e2b83e788f0fbe703f14182b513c52ef1326bfbb3e7855ab39',
            'fold': 'f3f9cc44c61216fbf4abf18243feba74d102c39df85cd6b89f6a6c6c8d8f1d5d'}
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
closure = lambda pins: hashlib.sha256(json.dumps(pins, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
p = argparse.ArgumentParser()
for role in EXPECTED:
    p.add_argument('--' + role, type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
inputs = {}
for role in EXPECTED:
    root = getattr(a, role).resolve(strict=True)
    assert not any(f.is_symlink() for f in root.rglob('*'))
    pins = {str(f.relative_to(root)): sha(f) for f in root.rglob('*.bend')}
    m = json.loads((root / 'overlay.json').read_text())
    c = json.loads((root / 'cache-specialization.json').read_text())
    assert len(pins) == 29 and pins == m['sources'] == c['runtimeClosure'] == c['specializedClosure']
    assert c == m['cacheSpecialization'] and closure(pins) == c['runtimeClosureSHA256'] == EXPECTED[role]
    inputs[role] = {'root': root, 'pins': pins, 'manifestSHA256': sha(root / 'overlay.json')}
changes = {r: sorted(n for n in inputs['baseline']['pins'] if inputs[r]['pins'][n] != inputs['baseline']['pins'][n]) for r in ['query', 'fold']}
prefix = 'experiments/s-integrate/'
assert changes['query'] == [prefix + 'measurement-bend.bend', prefix + 'query.bend']
assert changes['fold'] == [prefix + 'held-adapter.bend', prefix + 'measurement-bend.bend']
assert set(changes['query']) & set(changes['fold']) == {prefix + 'measurement-bend.bend'}
output = a.output.absolute()
assert output.is_relative_to(HERE) and not output.exists()
shutil.copytree(inputs['fold']['root'], output)
merged = []
for n in changes['query']:
    if n not in changes['fold']:
        shutil.copyfile(inputs['query']['root'] / n, output / n)
    else:
        cmd = ['git', 'merge-file', '-p', str(inputs['query']['root'] / n), str(inputs['baseline']['root'] / n), str(inputs['fold']['root'] / n)]
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=5)
        assert result.returncode == 0, result.stderr.decode() + result.stdout.decode()
        (output / n).write_bytes(result.stdout)
        merged.append({'module': n, 'argv': cmd, 'exit': result.returncode, 'outputSHA256': sha(output / n)})
pins = {str(f.relative_to(output)): sha(f) for f in output.rglob('*.bend')}
m = json.loads((output / 'overlay.json').read_text())
c = json.loads((output / 'cache-specialization.json').read_text())
c.update(runtimeClosure=pins, specializedClosure=pins.copy(), runtimeClosureSHA256=closure(pins))
m.update(sources=pins, cacheSpecialization=c)
r = {'status': 'ASSEMBLED_UNVERIFIED_SOURCE_JOIN', 'inputClosures': EXPECTED, 'changedModules': changes,
     'inputManifestSHA256': {k: v['manifestSHA256'] for k, v in inputs.items()}, 'threeWayMerge': merged,
     'sources': pins, 'outputClosureSHA256': closure(pins), 'recipeSHA256': sha(Path(__file__)),
     'priorIndependentGatesDoNotAcceptJoin': True, 'performanceAcceptance': False, 'productionAdoption': False}
for n, value in [('overlay.json', m), ('cache-specialization.json', c), ('source-fold-noaux-join.json', r)]:
    (output / n).write_text(json.dumps(value, indent=2) + '\n')
print(json.dumps({'status': r['status'], 'closureSHA256': closure(pins)}))
