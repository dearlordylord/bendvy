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
import sys
import stat
from pathlib import Path

ROOT = Path('/workspace/formal-proofs/bendvy')
HERE = Path(__file__).resolve().parent
EXPECTED = '3ac85c490f3f861ef62bbebf5400d2e3c754b16e2bcd9a7373e96c234260f37f'


def sha(path):
    path = Path(path)
    if path.is_symlink() or not path.is_file():
        raise ValueError('Pinned/generated/raw file must be regular and non-symlink')
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
    with os.fdopen(fd, 'rb') as source:
        if not stat.S_ISREG(os.fstat(source.fileno()).st_mode):
            raise ValueError('Pinned/generated/raw descriptor must be regular')
        return hashlib.sha256(source.read()).hexdigest()


def write_raw(path, data):
    path = Path(path)
    if path.exists() or path.is_symlink():
        raise ValueError('Raw capture must start absent and non-symlink')
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
    with os.fdopen(fd, 'wb') as output:
        if not stat.S_ISREG(os.fstat(output.fileno()).st_mode):
            raise ValueError('Raw capture descriptor is not regular')
        output.write(data)
    if path.is_symlink() or not path.is_file():
        raise ValueError('Raw capture changed file type')


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def prepare(out, oracle, category):
    if category not in ('plain', 'transient', 'constructed'):
        raise ValueError('Unknown category')
    out = Path(out).resolve()
    oracle = Path(oracle).resolve()
    parser = load('scenario_parser', HERE / 'parse-app.py')
    identities = json.loads((HERE / (category + '-identities.json')).read_text())
    if parser.build_identities(HERE / (category + '.bend')) != identities:
        raise ValueError('Frozen original source/constructor inventory changed')
    if sha(oracle / 'expected.json') != EXPECTED:
        raise ValueError('Independent whole oracle changed')
    tools = {'bend': '/home/node/.bend/bin/bend', 'python': str(Path(sys.executable).resolve()), 'taskset': str(Path('/usr/bin/taskset').resolve(strict=True))}
    tools['clangWrapper'] = '/tmp/bendvy-clang19-diagnostic/clang19'
    tools['clangBinary'] = '/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'
    config = ROOT / 'experiments/public-simulation/delivery-v1/installed-config.py'
    extra = [HERE.parent.parent.parent / 'parse-scenario.py', config, Path(__file__), HERE / 'parse-app.py', HERE / (category + '-identities.json'),
             ROOT / 'scripts/task_runner.py', ROOT / 'scripts/evidence_boundary.py',
             Path('/home/node/.bend/bend2/base.bend'), oracle / 'expected.json', oracle / 'CONSTRUCTOR-JOIN.json',
             oracle / 'synthetic-complete.stdout', HERE / 'synthetic-complete.stdout', HERE / 'TRANSPORT-PREPARED.json', *map(Path, tools.values())]
    pins = dict(identities['sourceSHA256'])
    pins.update({str(path.resolve(strict=True)): sha(path) for path in extra})
    env = load('installed_configuration', config).environment()
    generated = out / 'scenario.c'
    native = out / 'scenario.native'
    plan = {'scope': 'direct development only; no complete resolver qualification or #56 completion',
            'category': category, 'entrypoint': identities['entrypoint'], 'constructorInventory': str(HERE / (category + '-identities.json')),
            'pins': pins, 'environment': env, 'cwd': str(HERE), 'oracle': str(oracle / 'expected.json'),
            'join': str(oracle / 'CONSTRUCTOR-JOIN.json'), 'generated': str(generated), 'native': str(native),
            'tools': tools, 'commands': [
                {'label': 'emit', 'argv': [tools['taskset'], '-c', '5', tools['bend'], identities['entrypoint'], '-o', str(generated)], 'capSeconds': 30},
                {'label': 'build', 'argv': [tools['taskset'], '-c', '5', tools['clangWrapper'], '-O3', str(generated), '-o', str(native), '-pthread', '-lm'], 'capSeconds': 120},
                {'label': 'consumer', 'argv': [tools['taskset'], '-c', '5', str(native), '--threads', '1', '--gpu', 'off'], 'capSeconds': 5}],
            'postConsumer': 'Complete20phase App category transport against unchanged3ac85c fulloracle; actualapplicationpolicy only'}
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
    parser = load('scenario_parser', HERE / 'parse-app.py')
    runner = load('task_runner', ROOT / 'scripts/task_runner.py')
    boundary = load('evidence_boundary', ROOT / 'scripts/evidence_boundary.py')
    inventory = json.loads(Path(plan['constructorInventory']).read_text())
    pins = dict(plan['pins'])
    pins[str(plan_path)] = expected_sha
    generated = Path(plan['generated'])
    native = Path(plan['native'])
    record = {'scope': plan['scope'], 'planSHA256': expected_sha, 'commands': [], 'guards': []}

    def guard(label):
        for artifact in (generated, native):
            if str(artifact) in pins and (artifact.is_symlink() or not artifact.is_file()):
                raise ValueError('Generated artifact must be a regular non-symlink file')
        actual = {path: sha(path) for path in pins}
        unchanged = actual == pins and parser.build_identities(plan['entrypoint']) == inventory
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
                        pins[str(target)] = row[key]['sha256']
                    else:
                        row[key] = value
                record['commands'].append(row)
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
                    actual = parser.normalize(result['stdout'].decode(), inventory, json.loads(Path(plan['join']).read_text()), plan['category'])
                    expected_bytes = Path(plan['oracle']).read_bytes()
                    if hashlib.sha256(expected_bytes).hexdigest() != EXPECTED:
                        raise ValueError('Whole oracle changed')
                    parser.BASE.strict_equal(actual, json.loads(expected_bytes)[plan['category']])
                    record['wholeOracleSHA256'] = EXPECTED
        record['status'] = 'CATEGORY_DEVELOPMENT_PASS'
        record['category'] = plan['category']


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest='command', required=True)
    preparation = sub.add_parser('prepare')
    preparation.add_argument('output')
    preparation.add_argument('oracle_directory')
    preparation.add_argument('category', choices=('plain', 'transient', 'constructed'))
    execution = sub.add_parser('run')
    execution.add_argument('plan')
    execution.add_argument('admitted_sha256')
    args = parser.parse_args()
    if args.command == 'prepare':
        prepare(args.output, args.oracle_directory, args.category)
    else:
        run(args.plan, args.admitted_sha256)


if __name__ == '__main__':
    main()
