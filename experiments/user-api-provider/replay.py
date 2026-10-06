#!/usr/bin/env python3
"""Replay bounded public-provider controls, each command under five seconds."""
import argparse
import ast
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile

parser = argparse.ArgumentParser()
parser.add_argument('--evidence', type=Path)
options = parser.parse_args()
here = Path(__file__).resolve().parent
root = here.parents[1]
manifest = json.loads((here / 'controls.json').read_text())
records = []

def run(argv):
    completed = subprocess.run(argv, capture_output=True, text=True, timeout=5)
    record = {'command': argv, 'exit': completed.returncode,
              'stdout': completed.stdout, 'stderr': completed.stderr}
    records.append(record)
    return completed

version = run(['bend', 'version'])
assert version.returncode == 0
assert run(['bend', 'guide']).returncode == 0
for item in manifest['positive']:
    result = run(['bend', str(here / item['file'])])
    assert result.returncode == item['expectedExit'], item['file']
    assert result.stdout.strip() == item['expectedOutput'], item['file']
for item in manifest['negative']:
    result = run(['bend', str(here / item['file'])])
    assert result.returncode == item['expectedExit'], item['file']
    diagnostic = result.stdout + result.stderr
    assert all(text in diagnostic for text in item['requiredDiagnostic']), item['file']
with tempfile.TemporaryDirectory(prefix='bendvy-provider-replay-') as directory:
    directory = Path(directory)
    for name in manifest['compiled']:
        expected = ast.literal_eval(next(item['expectedOutput'] for item in manifest['positive'] if item['file'] == name))
        native = directory / name.removesuffix('.bend')
        javascript = native.with_suffix('.mjs')
        assert run(['bend', str(here / name), '-o', str(native)]).returncode == 0, name
        observed = run([str(native)])
        assert observed.returncode == 0 and ast.literal_eval(observed.stdout.strip()) == expected, name
        assert run(['bend', str(here / name), '-o', str(javascript)]).returncode == 0, name
        observed = run(['node', str(here / 'run-js.mjs'), str(javascript)])
        assert observed.returncode == 0 and json.loads(observed.stdout) == expected, name
pins = {str(path.relative_to(root)): hashlib.sha256(path.read_bytes()).hexdigest()
        for path in sorted((root / 'src/ecs').glob('*.bend'))}
result = {'status': 'PASS_SCOPED_FINITE_PROVIDER_CONTROLS',
          'positiveControls': len(manifest['positive']),
          'negativeControls': len(manifest['negative']),
          'nativeAndJSPrograms': len(manifest['compiled']),
          'sourceSHA256': pins, 'commands': records}
if options.evidence:
    options.evidence.parent.mkdir(parents=True, exist_ok=True)
    options.evidence.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({key: result[key] for key in ('status', 'positiveControls', 'negativeControls', 'nativeAndJSPrograms')}))
