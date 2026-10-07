"""Freeze minimal source/Node development; never discover libraries or run a backend at preparation."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import os
import re
import runpy
import shutil
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'scripts'))
import task_runner
import selected_reference

def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

def closure(path, files):
    path = Path(path).resolve()
    if path in files:
        return
    files.add(path)
    if path.suffix == '.bend':
        for name in re.findall(r'^\s*import\s+(\S+)', path.read_text(), re.M):
            if name != 'Base':
                closure(path.parent / name, files)

def prepare(remaining=False, node_only=False):
    out = ROOT / '.artifacts' / ('inspect54-promotion-source-node-' + str(time.time_ns()))
    out.mkdir(parents=True)
    files = set()
    for name in ['query-api.bend', 'condition.bend', 'cardinality-main.bend']:
        closure(HERE / name, files)
    files.update(HERE / name for name in ['development.py', 'cardinality-reference.mjs', 'cardinality-oracle.py', 'check-reference.mjs', 'check-oracle.py'])
    files.update(ROOT / 'scripts' / name for name in ['task_runner.py', 'receipt-logs.py', 'selected_reference.py'])
    files.add(ROOT / '.references/sources.json')
    # Reused artifacts are explicitly selected by their original delivery.
    # This byte binding grants no semantic acceptance to the new references.
    bindings = [
        selected_reference.binding(ROOT,
            ROOT / 'experiments/public-inspect/bend-candidate/full-v2/RESOURCE-DELIVERY-FILES.json',
            'experiments/public-inspect/bend-candidate/full-v2/resource-reference.mjs'),
        selected_reference.binding(ROOT,
            ROOT / 'experiments/public-inspect/bend-candidate/full-v2/RETENTION-FAIL-SKIP-DELIVERY-FILES.json',
            'experiments/public-inspect/bend-candidate/full-v2/retention-fail-skip-oracle.json'),
    ]
    for binding in bindings:
        files.update([Path(binding['manifest']), Path(binding['reference'])])
    tools = {name: str(Path(shutil.which(name)).resolve()) for name in ['bend', 'node', 'taskset']}
    files.update(map(Path, tools.values()))
    ts = (ROOT / '.references/bevy-ts/packages/core').resolve()
    files.add(ts / 'package.json')
    files.add(ts.parents[1] / 'package.json')
    directories = [Path('/home/node/.bend/bend2'), ts / 'src']
    cardinality = load(HERE / 'cardinality-oracle.py', 'promotion_cardinality_oracle').EXPECTED
    check = load(HERE / 'check-oracle.py', 'promotion_check_oracle').expected()
    oracle = out / 'oracle.json'
    oracle.write_text(json.dumps({'cardinality': cardinality, 'check': check}, indent=2) + '\n')
    files.add(oracle)
    env = dict(os.environ, BEND_NO_TELEMETRY='1')
    private = out / 'private-environment.json'
    private.write_text(json.dumps(env, sort_keys=True))
    private.chmod(0o600)
    prefix = [tools['taskset'], '-c', '5']
    commands = [{'label': name.removesuffix('.bend') + '-source', 'kind': 'source',
                 'argv': prefix + [tools['bend'], str(HERE / name), '--check-only'], 'seconds': 5}
                for name in ['query-api.bend', 'condition.bend', 'cardinality-main.bend']]
    if node_only:
        commands = []
    elif remaining:
        commands = commands[2:]
    commands += [{'label': name + '-ts', 'kind': name,
                  'argv': prefix + [tools['node'], str(HERE / (name + '-reference.mjs'))], 'seconds': 5}
                 for name in ['cardinality', 'check']]
    inputs = task_runner.Inputs(files=files, directories=directories)
    plan = {'status': 'PREPARED_UNADMITTED_SOURCE_NODE_ONLY', 'files': sorted(map(str, files)),
            'directories': list(map(str, directories)), 'inputs': inputs.expected, 'commands': commands,
            'selectedReferenceBindings': bindings, 'privateEnvironment': str(private),
            'environmentSHA256': sha(private), 'oracle': str(oracle),
            'scope': ('Two actual Node reference applications only; all three prior source passes retained without rerun. ' if node_only else 'Remaining cardinality source check and two actual Node reference applications only; prior passed source checks not repeated. ' if remaining else 'Three source checks and two actual Node reference applications only; ') + 'Complete authored oracles. No Bend execution/JS/Native/negative/mutant/performance/full54 acceptance.'}
    path = out / 'plan.json'
    path.write_text(json.dumps(plan, indent=2) + '\n')
    print(path)
    print(sha(path))

def run(path):
    path = Path(path).resolve()
    out = path.parent
    plan = json.loads(path.read_text())
    inputs = task_runner.Inputs(files=[path, *plan['files']], directories=map(Path, plan['directories']))
    # The plan itself is an additive immutable input; compare the original set.
    original = task_runner.Inputs(files=plan['files'], directories=map(Path, plan['directories']))
    assert original.expected == plan['inputs']
    private = Path(plan['privateEnvironment'])
    assert sha(private) == plan['environmentSHA256']
    env = json.loads(private.read_text())
    logs = runpy.run_path(str(ROOT / 'scripts/receipt-logs.py'))['CommandLogs'](out, [c['label'] for c in plan['commands']])
    runner = task_runner.Runner(logs, inputs=inputs, env=env, cwd=ROOT)
    oracle = json.loads(Path(plan['oracle']).read_text())
    receipt = {'status': 'INCOMPLETE', 'planSHA256': sha(path), 'commands': [], 'scope': plan['scope']}
    def guard():
        inputs.guard()
        logs.guard()
        assert sha(private) == plan['environmentSHA256']
        for binding in plan['selectedReferenceBindings']:
            selected_reference.verify(ROOT, binding)
    try:
        for command in plan['commands']:
            guard()
            result = runner.run(command['label'], command['argv'], command['seconds'])
            receipt['commands'].append({'label': command['label'], 'exit': result['exit'], 'failure': result['failure']})
            if command['kind'] != 'source':
                assert json.loads(result['stdout']) == oracle[command['kind']]
            guard()
        receipt['status'] = 'SOURCE_AND_COMPLETE_NODE_QUERY_CHECK_ORACLES_PASS'
    except BaseException as error:
        receipt['error'] = str(error)
        raise
    finally:
        receipt['logs'] = dict(logs.hashes)
        (out / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
        print(out)

parser = argparse.ArgumentParser()
parser.add_argument('--prepare', action='store_true')
parser.add_argument('--run')
parser.add_argument('--remaining', action='store_true')
parser.add_argument('--node-only', action='store_true')
args = parser.parse_args()
if args.prepare:
    prepare(args.remaining, args.node_only)
else:
    run(args.run)
