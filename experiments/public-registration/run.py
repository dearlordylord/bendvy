"""Exact-source disposal canary; infrastructure, not full #36 acceptance."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner
from task_runner import run as _run_command


ROOT = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser()
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
output = args.output.resolve()
output.mkdir(parents=True, exist_ok=False)
receipt = {'status': 'INCOMPLETE', 'commands': [], 'sources': {}}
for path in [ROOT/'src/ecs/world.bend', ROOT/'src/ecs/registration.bend', Path(__file__), Path(__file__).with_name('main.bend')]:
    receipt['sources'][str(path.relative_to(ROOT))] = hashlib.sha256(path.read_bytes()).hexdigest()
env = os.environ.copy()
env['BENDVY_CLANG19_ROOT'] = '/tmp/bendvy-clang19-diagnostic/root'

def run(command, seconds, label):
    command = list(map(str, command))
    result = _run_command(command, timeout=seconds, cwd=ROOT, env=env, capture_output=True, text=True)
    (output/(label+'.stdout')).write_text(result.stdout)
    (output/(label+'.stderr')).write_text(result.stderr)
    receipt['commands'].append({'argv':command, 'seconds':seconds, 'exit':result.returncode})
    (output/'receipt.json').write_text(json.dumps(receipt, indent=2)+'\n')
    if result.returncode:
        raise RuntimeError(label+' failed')
    return result.stdout

entry = Path(__file__).with_name('main.bend')
run(['bend',entry,'--check-only'],5,'checker')
run(['bend',entry,'-o',output/'main.js'],30,'js-emit')
run(['bend',entry,'-o',output/'main.c'],30,'c-emit')
run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',output/'main.c','-o',output/'main.native','-pthread','-lm'],120,'native-build')
expected = 'False\nTrue\nTrue\nFalse\nFalse\nTrue\n'
for label,command in [('JS',['node',output/'main.js']),('Native',[output/'main.native'])]:
    assert run(command,5,label)==expected, label+' disposal observations differ'
for path,sha in receipt['sources'].items():
    assert hashlib.sha256((ROOT/path).read_bytes()).hexdigest()==sha, 'Source drift: '+path
receipt['status']='PASS'
receipt['scope']='Exact registration disposal infrastructure; not Local or ECS proof acceptance'
(output/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({'status':'PASS','observationsPerBackend':6}))
