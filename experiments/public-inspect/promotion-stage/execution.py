"""Freeze owned source/interpreter/JS development without executing child probes.

Native/resolver/negative/mutant/final qualification is a separate admitted stage.
"""
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

CONFIG_NAMES = ('check.json', 'bend.json', 'bender.json', 'package.json', '.bend.json', 'bend.config.json')

def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def closure(path, files):
    path = Path(path).resolve()
    if path in files:
        return
    files.add(path)
    if path.suffix == '.bend':
        for name in re.findall(r'^\s*import\s+(\S+)', path.read_text(), re.M):
            if name != 'Base':
                closure(path.parent / name, files)

def oracle_module(name):
    path = HERE / name
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.EXPECTED

def configs():
    parents = {HERE, *HERE.parents, Path('/home/node/.bend')}
    paths = {parent / name for parent in parents for name in CONFIG_NAMES}
    return {str(path): sha(path) if path.is_file() else None for path in sorted(paths)}

def join_receipt(path, kind, files):
    path = Path(path).resolve()
    receipt = json.loads(path.read_text())
    plan_path = path.parent / 'plan.json'
    plan = json.loads(plan_path.read_text())
    assert receipt['planSHA256'] == sha(plan_path)
    assert receipt['status'] == kind.upper() + '_COMPLETE_PASS'
    assert all(command['exit'] == 0 and command['failure'] is None for command in receipt['commands'])
    assert len(receipt['commands']) == (1 if kind == 'source' else 2)
    original = task_runner.Inputs(files=plan['files'], directories=map(Path, plan['directories']))
    assert original.expected == plan['inputs']
    for name, digest in receipt['logs'].items():
        file = path.parent / name
        assert sha(file) == digest
        files.add(file)
    files.update([path, plan_path, Path(plan['oracle'])])
    return {'receipt': str(path), 'receiptSHA256': sha(path), 'plan': str(plan_path), 'planSHA256': sha(plan_path)}

def prepare(kind, receipt):
    out = ROOT / '.artifacts' / ('inspect54-promotion-' + kind + '-' + str(time.time_ns()))
    out.mkdir()
    files = set()
    for entry in ['cardinality-main.bend', 'check-main.bend']:
        closure(HERE / entry, files)
    source_files = sorted(map(str, files))
    files.update(HERE / name for name in ['execution.py', 'cardinality-oracle.py', 'check-bend-oracle.py'])
    files.update(ROOT / 'scripts' / name for name in ['task_runner.py', 'receipt-logs.py'])
    tools = {name: str(Path(shutil.which(name)).resolve()) for name in ['bend', 'node', 'taskset']}
    tools['python'] = str(Path(sys.executable).resolve())
    files.update(map(Path, tools.values()))
    directories = [Path('/home/node/.bend/bend2')]
    oracle = out / 'oracle.json'
    oracle.write_text(json.dumps({'cardinality': oracle_module('cardinality-oracle.py'),
                                 'check': oracle_module('check-bend-oracle.py')}, indent=2) + '\n')
    files.add(oracle)
    joins = []
    if kind != 'source':
        assert receipt, 'exact preceding complete receipt required'
        joins.append(join_receipt(receipt, 'source' if kind == 'interpreter' else 'interpreter', files))
    prefix = [tools['taskset'], '-c', '5']
    if kind == 'source':
        commands = [{'label': 'check-main-source', 'argv': prefix + [tools['bend'], str(HERE / 'check-main.bend'), '--check-only'], 'seconds': 5, 'oracle': None}]
    elif kind == 'interpreter':
        commands = [{'label': name + '-interpreter', 'argv': prefix + [tools['bend'], str(HERE / (name + '-main.bend'))], 'seconds': 5, 'oracle': name} for name in ['cardinality', 'check']]
    else:
        commands = []
        for name in ['cardinality', 'check']:
            generated = out / (name + '.js')
            commands.extend([
                {'label': name + '-emit-js', 'argv': prefix + [tools['bend'], str(HERE / (name + '-main.bend')), '-o', str(generated)], 'seconds': 30, 'oracle': None, 'generated': str(generated)},
                {'label': name + '-run-js', 'argv': prefix + [tools['node'], str(generated)], 'seconds': 5, 'oracle': name},
            ])
    private = out / 'private-environment.json'
    private.write_text(json.dumps(dict(os.environ, BEND_NO_TELEMETRY='1'), sort_keys=True))
    private.chmod(0o600)
    inputs = task_runner.Inputs(files=files, directories=directories)
    plan = {'kind': kind, 'status': 'PREPARED_UNADMITTED', 'commands': commands,
            'files': sorted(map(str, files)), 'sourceFiles': source_files, 'directories': list(map(str, directories)),
            'inputs': inputs.expected, 'configurationStates': configs(), 'joins': joins,
            'privateEnvironment': str(private), 'environmentSHA256': sha(private), 'oracle': str(oracle),
            'scope': 'Owned ' + kind + ' development only. No source proof/TS rerun/Native/negative/mutant/resolver/performance/full54 qualification. Complete independent cardinality/check oracles; diagnostic writes are outside Check.run and excluded from feature timing.'}
    path = out / 'plan.json'
    path.write_text(json.dumps(plan, indent=2) + '\n')
    print(path)
    print(sha(path))

def run(path):
    path = Path(path).resolve()
    out = path.parent
    plan = json.loads(path.read_text())
    original = task_runner.Inputs(files=plan['files'], directories=map(Path, plan['directories']))
    assert original.expected == plan['inputs']
    private = Path(plan['privateEnvironment'])
    assert sha(private) == plan['environmentSHA256']
    env = json.loads(private.read_text())
    oracle = json.loads(Path(plan['oracle']).read_text())
    inputs = task_runner.Inputs(files=[path, *plan['files']], directories=map(Path, plan['directories']))
    logs = runpy.run_path(str(ROOT / 'scripts/receipt-logs.py'))['CommandLogs'](out, [c['label'] for c in plan['commands']])
    runner = task_runner.Runner(logs, inputs=inputs, env=env, cwd=ROOT)
    generated = {}
    receipt = {'status': 'INCOMPLETE', 'planSHA256': sha(path), 'commands': [], 'scope': plan['scope']}
    def guard():
        runner.inputs.guard()
        logs.guard()
        assert configs() == plan['configurationStates']
        assert sha(private) == plan['environmentSHA256']
        assert all(sha(file) == digest for file, digest in generated.items())
    try:
        for command in plan['commands']:
            guard()
            if 'generated' in command:
                assert not Path(command['generated']).exists()
            try:
                result = runner.run(command['label'], command['argv'], command['seconds'])
            except BaseException as error:
                result = getattr(error, 'result', None)
                receipt['commands'].append({'label': command['label'], 'exit': result['exit'] if result else None,
                                            'failure': result['failure'] if result else str(error), 'error': str(error)})
                raise
            receipt['commands'].append({'label': command['label'], 'exit': result['exit'], 'failure': result['failure']})
            if command['oracle']:
                assert json.loads(result['stdout']) == oracle[command['oracle']], 'complete oracle mismatch: ' + command['label']
            if 'generated' in command:
                file = command['generated']
                generated[file] = sha(file)
                runner.inputs = task_runner.Inputs(files=[path, *plan['files'], *generated], directories=map(Path, plan['directories']))
            guard()
        receipt['status'] = plan['kind'].upper() + '_COMPLETE_PASS'
    except BaseException as error:
        receipt['error'] = str(error)
        raise
    finally:
        receipt['generated'] = generated
        receipt['logs'] = dict(logs.hashes)
        (out / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
        print(out)

parser = argparse.ArgumentParser()
parser.add_argument('--prepare', choices=['source', 'interpreter', 'js'])
parser.add_argument('--receipt')
parser.add_argument('--run')
args = parser.parse_args()
if args.prepare:
    prepare(args.prepare, args.receipt)
else:
    run(args.run)
