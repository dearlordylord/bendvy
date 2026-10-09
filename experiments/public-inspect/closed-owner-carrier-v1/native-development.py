#!/usr/bin/env python3
"""Focused direct development: prepare only, then a separately admitted guarded run.

No relocated imports, installed resolver discovery, or performance work.
This does not establish complete installed-tool/resolver qualification.
"""
import argparse
import fcntl
import hashlib
import importlib.util
import json
import os
import gzip
import re
import sys
from pathlib import Path

ROOT = Path('/workspace/formal-proofs/bendvy')
HERE = Path(__file__).resolve().parent
EXPECTED = '810259f78227f2b3d158c02644978b6c7ecf58b40a4b2fb398a816005b2867e2'


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def write_raw(target, value):
    target = Path(target)
    if target.exists() or target.is_symlink():
        raise ValueError('Raw output must start absent')
    with target.open('xb') as stream:
        stream.write(value)


def verify_raw(target, expected):
    target = Path(target)
    if target.is_symlink() or not target.is_file():
        raise ValueError('Raw stream must be a regular non-symlink file')
    if sha(target) != expected:
        raise ValueError('Raw stream changed')


def validate_imports(stage, inventory):
    stage = Path(stage).resolve(strict=True)
    reached = set()
    def visit(path):
        path = path.resolve(strict=True)
        if path in reached:
            return
        reached.add(path)
        for target in re.findall(r'^import\s+(\S+)', path.read_text(), re.MULTILINE):
            resolved = Path('/home/node/.bend/bend2/base.bend') if target == 'Base' else (path.parent / target).resolve(strict=True)
            if target != 'Base' and str(resolved.relative_to(stage)) not in inventory:
                raise ValueError('Import escapes frozen stage')
            if target != 'Base':
                visit(resolved)
    visit(stage / 'output-io-main.bend')
    return sorted(str(p.relative_to(stage)) for p in reached)


def prepare(out):
    out = Path(out).resolve()
    inventory = json.loads((HERE / 'source-inventory.json').read_text())
    stage = HERE / 'stage'
    actual = {str(p.relative_to(stage)): sha(p) for p in stage.rglob('*.bend')}
    if actual != inventory or len(actual) != 46:
        raise ValueError('Complete 46-file source inventory changed')
    import_closure = validate_imports(stage, inventory)
    expected = gzip.decompress((HERE / 'complete-expected.txt.gz').read_bytes())
    if len(expected) != 5077477 or hashlib.sha256(expected).hexdigest() != EXPECTED:
        raise ValueError('Independent whole oracle changed')
    tools = {'bend': '/home/node/.bend/bin/bend', 'python': str(Path(sys.executable).resolve()), 'taskset': '/usr/bin/taskset',
             'clangWrapper': '/tmp/bendvy-clang19-diagnostic/clang19',
             'clangBinary': '/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'}
    config = ROOT / 'experiments/public-simulation/delivery-v1/installed-config.py'
    configuration = load('installed_configuration', config)
    helper = load('preparation_runner', ROOT / 'scripts/task_runner.py')
    pins = {str((stage / n).resolve()): h for n,h in inventory.items()}
    extra = [config, Path(__file__), HERE / 'source-inventory.json', HERE / 'complete-expected.txt.gz',
             ROOT / 'scripts/task_runner.py', ROOT / 'scripts/evidence_boundary.py', *map(Path, tools.values())]
    pins.update({str(path.resolve(strict=True)): sha(path) for path in extra})
    resources = helper.Inputs(directories=configuration.RESOURCE_ROOTS).expected
    env = configuration.environment()
    generated = out / 'scenario.c'
    native = out / 'scenario.native'
    entry = str(stage / 'output-io-main.bend')
    plan = {'scope': 'Complete Inspector closed-owner carrier Native development only; no resolver qualification, performance or #54 completion',
            'entrypoint': entry, 'stage': str(stage), 'sourceInventory': inventory, 'importClosure': import_closure,
            'pins': pins, 'resourceRoots': resources, 'environment': env, 'cwd': str(HERE),
            'oracle': str(HERE / 'complete-expected.txt.gz'), 'oracleSHA256': EXPECTED, 'oracleBytes': 5077477,
            'generated': str(generated), 'native': str(native),
            'tools': tools, 'commands': [
                {'label': 'emit', 'argv': [tools['taskset'], '-c', '5', tools['bend'], entry, '-o', str(generated)], 'capSeconds': 30},
                {'label': 'build', 'argv': [tools['taskset'], '-c', '5', tools['clangWrapper'], '-O3', str(generated), '-o', str(native), '-pthread', '-lm'], 'capSeconds': 120},
                {'label': 'consumer', 'argv': [tools['taskset'], '-c', '5', str(native), '--threads', '1', '--gpu', 'off'], 'capSeconds': 5}],
            'postConsumer': 'Complete byte equality with original5077477B oracle; empty runtime stderr'}
    out.mkdir(parents=True, exist_ok=False)
    (out / 'plan.json').write_text(json.dumps(plan, indent=2) + '\n')
    print(sha(out / 'plan.json'))


def run(plan_path, expected_sha):
    plan_path = Path(plan_path).resolve(strict=True)
    if sha(plan_path) != expected_sha:
        raise ValueError('Admitted plan digest mismatch')
    plan = json.loads(plan_path.read_text())
    if {path: sha(path) for path in plan['pins']} != plan['pins']:
        raise ValueError('Frozen boundary changed before helper import')
    out = plan_path.parent
    runner = load('task_runner', ROOT / 'scripts/task_runner.py')
    boundary = load('evidence_boundary', ROOT / 'scripts/evidence_boundary.py')
    pins = dict(plan['pins'])
    pins[str(plan_path)] = expected_sha
    generated = Path(plan['generated'])
    native = Path(plan['native'])
    record = {'scope': plan['scope'], 'planSHA256': expected_sha, 'commands': [], 'guards': []}

    def guard(label):
        for artifact in (generated, native):
            if str(artifact) in pins and (artifact.is_symlink() or not artifact.is_file()):
                raise ValueError('Generated artifact must be a regular non-symlink file')
        for row in record['commands']:
            for key in ('stdout', 'stderr'):
                if key in row:
                    verify_raw(row[key]['path'], row[key]['sha256'])
        if validate_imports(plan['stage'], plan['sourceInventory']) != plan['importClosure']:
            raise ValueError('Import closure changed')
        actual = {path: sha(path) for path in pins}
        unchanged = actual == pins and {str(p.relative_to(plan['stage'])): sha(p) for p in Path(plan['stage']).rglob('*.bend')} == plan['sourceInventory'] and runner.Inputs(directories=plan['resourceRoots']).expected == plan['resourceRoots']
        receipt = {'label': label, 'actualPins': actual, 'unchanged': unchanged}
        target = out / (label + '.guard.json')
        target.write_text(json.dumps(receipt, indent=2) + '\n')
        record['guards'].append({'path': str(target), 'sha256': sha(target)})
        if not unchanged:
            raise ValueError('Source/oracle/tool/helper boundary changed: ' + label)

    with boundary.ReceiptBoundary(record, out / 'receipt.json', [('final boundary', lambda: guard('final'))]):
        for command in plan['commands']:
            label = command['label']
            guard(label + '-pre')
            with boundary.GuardBoundary([('post boundary', lambda: guard(label + '-post'))]):
                with open('/tmp/bendvy-parity-heavy.lock', 'a') as lock:
                    fcntl.flock(lock, fcntl.LOCK_EX)
                    try:
                        guard(label + '-acquired')
                        artifact = generated if label == 'emit' else native
                        if label in ('emit', 'build') and (artifact.exists() or artifact.is_symlink()):
                            raise ValueError('Generated output must start absent')
                        result = runner.execute_result(command['argv'], command['capSeconds'], plan['environment'], plan['cwd'], 'split')
                    finally:
                        fcntl.flock(lock, fcntl.LOCK_UN)
                row = dict(command)
                for key, value in result.items():
                    if isinstance(value, bytes):
                        target = out / (label + '.' + key)
                        write_raw(target, value)
                        row[key] = {'path': str(target), 'sha256': sha(target), 'bytes': len(value)}
                    else:
                        row[key] = value
                record['commands'].append(row)
                if label in ('emit', 'build') and artifact.is_file() and not artifact.is_symlink():
                    pins[str(artifact)] = sha(artifact)
                    record[label + 'ArtifactSHA256'] = pins[str(artifact)]
                if result['exit'] != 0 or result['failure'] is not None:
                    raise ValueError('Owned child failed: ' + label)
                if label in ('emit', 'build'):
                    artifact = generated if label == 'emit' else native
                    if artifact.is_symlink() or not artifact.is_file():
                        raise ValueError('Emit did not produce a regular non-symlink artifact')
                    pins[str(artifact)] = sha(artifact)
                    record[label + 'ArtifactSHA256'] = pins[str(artifact)]
                else:
                    if result['stderr']:
                        raise ValueError('Consumer stderr is not empty')
                    expected_bytes = gzip.decompress(Path(plan['oracle']).read_bytes())
                    if len(expected_bytes) != plan['oracleBytes'] or hashlib.sha256(expected_bytes).hexdigest() != EXPECTED:
                        raise ValueError('Whole oracle changed')
                    if result['stdout'] != expected_bytes:
                        raise ValueError('Complete consumer byte output differs from whole independent oracle')
                    record['wholeOracleSHA256'] = EXPECTED
        record['status'] = 'COMPLETE_CONSUMER_DEVELOPMENT_PASS'


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest='command', required=True)
    preparation = sub.add_parser('prepare')
    preparation.add_argument('output')
    execution = sub.add_parser('run')
    execution.add_argument('plan')
    execution.add_argument('admitted_sha256')
    args = parser.parse_args()
    if args.command == 'prepare':
        prepare(args.output)
    else:
        run(args.plan, args.admitted_sha256)


if __name__ == '__main__':
    main()
