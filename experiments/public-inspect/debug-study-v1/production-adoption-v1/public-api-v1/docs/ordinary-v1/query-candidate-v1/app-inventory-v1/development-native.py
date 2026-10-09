#!/usr/bin/env python3
"""Focused direct development: prepare only, then a separately admitted guarded run.

No relocated imports, installed resolver discovery, or performance work.
Native compiles the unchanged complete main/resource entries, not category slices.
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


def prepare(out, oracle, kind):
    if kind not in ('main', 'resource'):
        raise ValueError('Known complete consuming entry required')
    entry_name = 'main.bend' if kind == 'main' else 'resource-main.bend'
    inventory_name = 'main-identities.json' if kind == 'main' else 'resource-identities.json'
    oracle_name = 'expected-v2.json' if kind == 'main' else 'resource-expected-v2.json'
    join_name = 'CONSTRUCTOR-JOIN.json'
    synthetic_name = 'main-synthetic.stdout' if kind == 'main' else 'resource-synthetic.stdout'
    expected_sha = {'main': '5bba9880ca4236a4440c0773ebc53b9242385b34b2d16cc87165c8f16e50546f', 'resource': 'ff6ae8abf5f41b292bb83531a23961eb610b4f23d5b561da3490d84ac7315294'}[kind]
    out = Path(out).resolve()
    oracle = Path(oracle).resolve()
    parser = load('scenario_parser', HERE / 'parse-inventory.py')
    identities = json.loads((HERE / inventory_name).read_text())
    if parser.build_identities(HERE / entry_name) != identities:
        raise ValueError('Frozen original source/constructor inventory changed')
    review = json.loads((oracle / 'PARSER-REVIEW.json').read_text())
    role_key = 'expectedV2SHA256' if kind == 'main' else 'resourceExpectedV2SHA256'
    if sha(oracle / oracle_name) != expected_sha or review[role_key] != expected_sha:
        raise ValueError('Independent whole oracle changed')
    if review['joinSHA256'] != sha(oracle / join_name) or review['parserSHA256'] != sha(HERE / 'parse-inventory.py'):
        raise ValueError('Independent typed transport review changed')
    tools = {'bend': '/home/node/.bend/bin/bend-2.0.35', 'python': str(Path(sys.executable).resolve()), 'taskset': str(Path('/usr/bin/taskset').resolve(strict=True))}
    tools['clangWrapper'] = '/tmp/bendvy-clang19-diagnostic/clang19'
    tools['clangBinary'] = '/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'
    config = ROOT / 'experiments/public-simulation/delivery-v1/installed-config.py'
    extra = [config, HERE.parent / 'parse-scenario.py', HERE.parent / 'app-run-v1/nominal-carrier-v1/accumulated-v1/parse-app.py',
             Path(__file__), HERE / 'parse-inventory.py', HERE / inventory_name,
             ROOT / 'scripts/task_runner.py', ROOT / 'scripts/evidence_boundary.py',
             Path('/home/node/.bend/bend2/base.bend'), oracle / oracle_name, oracle / join_name,
             oracle / synthetic_name, oracle / 'source-basis.json', oracle / 'expected.py',
             oracle / 'expected-v2.py', oracle / 'PARSER-REVIEW.json', oracle / 'SYNTHETIC-CHECKS.json',
             oracle / 'test-synthetic.py', oracle / 'synthetic-raw.py',
             HERE / 'NATIVE-TRANSPORT-PREPARED.json', HERE / 'test-native-boundary.py', HERE / 'test-js-boundary.py', HERE / 'TRANSPORT-PREPARED.json', *map(Path, tools.values())]
    pins = dict(identities['sourceSHA256'])
    pins.update({str(path.resolve(strict=True)): sha(path) for path in extra})
    configuration = load('installed_configuration', config)
    env = configuration.environment()
    resources = load('task_runner', ROOT / 'scripts/task_runner.py').Inputs(directories=configuration.RESOURCE_ROOTS)
    generated = out / 'scenario.c'
    native = out / 'scenario.native'
    plan = {'scope': 'direct development only; no complete resolver qualification or #56 completion',
            'kind': kind, 'expectedSHA256': expected_sha, 'entrypoint': identities['entrypoint'], 'constructorInventory': str(HERE / inventory_name),
            'resourceRoots': [str(root) for root in resources.directories], 'resourceInventory': resources.expected,
            'pins': pins, 'environment': env, 'cwd': str(HERE), 'oracle': str(oracle / oracle_name),
            'join': str(oracle / join_name), 'generated': str(generated), 'native': str(native),
            'tools': tools, 'commands': [
                {'label': 'emit', 'argv': [tools['taskset'], '-c', '5', tools['bend'], identities['entrypoint'], '-o', str(generated)], 'capSeconds': 30},
                {'label': 'build', 'argv': [tools['taskset'], '-c', '5', tools['clangWrapper'], '-O3', str(generated), '-o', str(native), '-pthread', '-lm'], 'capSeconds': 120},
                {'label': 'consumer', 'argv': [tools['taskset'], '-c', '5', str(native), '--threads', '1', '--gpu', 'off'], 'capSeconds': 5}],
            'postConsumer': 'Strict entire ordinary App schema/system/access/schedule inventory, unchanged full60baseline and nine complete noninterference snapshots OR standalone full affine resource/world control against independent frozen expected; no public56/performance claim'}
    out.mkdir(parents=True, exist_ok=False)
    (out / 'plan.json').write_text(json.dumps(plan, indent=2) + '\n')
    print(sha(out / 'plan.json'))


def run(plan_path, expected_sha):
    plan_path = Path(plan_path).resolve(strict=True)
    if sha(plan_path) != expected_sha:
        raise ValueError('Admitted plan digest mismatch')
    plan = json.loads(plan_path.read_text())
    actual_python = str(Path(sys.executable).resolve(strict=True))
    if actual_python != plan['tools']['python'] or sha(actual_python) != plan['pins'][actual_python]:
        raise ValueError('Actual executor interpreter path/hash differs from admitted plan')
    if {path: sha(path) for path in plan['pins']} != plan['pins']:
        raise ValueError('Frozen boundary changed before helper import')
    out = plan_path.parent
    parser = load('scenario_parser', HERE / 'parse-inventory.py')
    runner = load('task_runner', ROOT / 'scripts/task_runner.py')
    boundary = load('evidence_boundary', ROOT / 'scripts/evidence_boundary.py')
    inventory = json.loads(Path(plan['constructorInventory']).read_text())
    resources = runner.Inputs(directories=plan['resourceRoots'])
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
        resource_actual = resources.snapshot()
        unchanged = actual == pins and parser.build_identities(plan['entrypoint']) == inventory and resource_actual == plan['resourceInventory']
        receipt = {'label': label, 'actualPins': actual, 'actualResources': resource_actual, 'unchanged': unchanged}
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
                artifact = generated if label == 'emit' else native
                if label in ('emit', 'build') and (artifact.exists() or artifact.is_symlink()):
                    # Bind partial C/native output before interpreting child failure.
                    pins[str(artifact)] = sha(artifact)
                    record['generatedSHA256' if label == 'emit' else 'nativeSHA256'] = pins[str(artifact)]
                if result['exit'] != 0 or result['failure'] is not None:
                    raise ValueError('Owned child failed: ' + label)
                if label in ('emit', 'build'):
                    if str(artifact) not in pins:
                        raise ValueError('Emit did not produce a regular non-symlink artifact')
                else:
                    if result['stderr']:
                        raise ValueError('Consumer stderr is not empty')
                    actual = parser.normalize(result['stdout'].decode(), inventory, json.loads(Path(plan['join']).read_text()))
                    expected_bytes = Path(plan['oracle']).read_bytes()
                    if hashlib.sha256(expected_bytes).hexdigest() != plan['expectedSHA256']:
                        raise ValueError('Whole oracle changed')
                    parser.BASE.strict_equal(actual, json.loads(expected_bytes))
                    record['wholeOracleSHA256'] = plan['expectedSHA256']
        record['status'] = 'DEVELOPMENT_PASS'


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest='command', required=True)
    preparation = sub.add_parser('prepare')
    preparation.add_argument('output')
    preparation.add_argument('oracle_directory')
    preparation.add_argument('kind', choices=('main', 'resource'))
    execution = sub.add_parser('run')
    execution.add_argument('plan')
    execution.add_argument('admitted_sha256')
    args = parser.parse_args()
    if args.command == 'prepare':
        prepare(args.output, args.oracle_directory, args.kind)
    else:
        run(args.plan, args.admitted_sha256)


if __name__ == '__main__':
    main()
