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

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
TRANSPORT = HERE / 'transport-v1'
ENTRY = HERE / 'main.bend'
CONTROL = False
EXPECTED = '56d0de7ab8d614c5eccd395d3c7cc349fd7ad20d783d302bea6b4ba98a8956c3'



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


def publish_result(command, result, out, pins, record, artifact):
    label = command['label']
    row = dict(command)
    row.update({key: {'retainedRawHex': value.hex()} if isinstance(value, bytes) else value
                for key, value in result.items()})
    record['commands'].append(row)  # Actual completed child survives publication failure.
    primary = None
    try:
        for key, value in result.items():
            if isinstance(value, bytes):
                target = out / (label + '.' + key)
                write_raw(target, value)
                row[key] = {'path': str(target), 'sha256': sha(target), 'bytes': len(value)}
                pins[str(target)] = row[key]['sha256']
    except BaseException as error:
        primary = error
        row['publicationError'] = repr(error)
        raise
    finally:
        try:
            if artifact is not None and (artifact.exists() or artifact.is_symlink()):
                pins[str(artifact)] = sha(artifact)
                record['generatedSHA256' if label == 'emit' else 'buildArtifactSHA256'] = pins[str(artifact)]
        except BaseException as error:
            row['artifactCaptureError'] = repr(error)
            if primary is None:
                raise


VERIFIED_SOURCES = {}

def load(name, path):
    import types
    path = Path(path).resolve(strict=True)
    source = VERIFIED_SOURCES[str(path)] if VERIFIED_SOURCES else path.read_bytes()
    module = types.ModuleType(name)
    module.__file__ = str(path)
    module.__dict__['VERIFIED_SOURCES'] = VERIFIED_SOURCES
    exec(compile(source, str(path), 'exec'), module.__dict__)
    return module

def resource_snapshot(roots):
    return {str(Path(root)): {str(p.relative_to(Path(root))): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in sorted(Path(root).rglob('*')) if p.is_file()} for root in roots}


def prepare(out, oracle, expected_sha):
    out = Path(out).resolve()
    oracle = Path(oracle).resolve()
    parser = load('scenario_parser', TRANSPORT / 'transport.py')
    identities = json.loads((TRANSPORT / 'constructor-identities.json').read_text())
    if parser.Transport(ENTRY).inventory() != identities:
        raise ValueError('Frozen original source/constructor inventory changed')
    if expected_sha != EXPECTED or sha(oracle / 'expected.json') != EXPECTED:
        raise ValueError('Independent whole oracle changed')
    tools = {'bend': '/home/node/.bend/bin/bend-2.0.35', 'node': '/home/node/.local/share/mise/installs/node/24.20.0/bin/node', 'python': str(Path(sys.executable).resolve()), 'taskset': str(Path('/usr/bin/taskset').resolve(strict=True))}
    tools['clangWrapper'] = '/tmp/bendvy-clang19-diagnostic/clang19'
    tools['clangBinary'] = '/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'
    config = ROOT / 'experiments/public-simulation/delivery-v1/installed-config.py'
    extra = [HERE.parent / 'shared-public-join.py', HERE.parent / 'test-shared-public-join.py', HERE / 'SOURCE-DELTA.json', HERE / 'BOUNDARY-CONTROL.json', config, Path(__file__), TRANSPORT / 'transport.py', TRANSPORT / 'constructor-identities.json',
             ROOT / 'scripts/task_runner.py', ROOT / 'scripts/evidence_boundary.py',
             oracle / 'expected.json', oracle / 'expected.stdout', oracle / 'expected.py', oracle / 'REVIEW.md', oracle / 'source-basis.json', oracle / 'observations.json', oracle / 'test_model.py',
             oracle.parents[1] / 'oracle-v1/expected.py', oracle.parents[1] / 'oracle-v1/expected.json', oracle.parents[1] / 'oracle-v1/expected.stdout', oracle.parents[1] / 'oracle-v1/observations.json',
             HERE / 'README.md', HERE / 'test-admission.py', HERE / 'test-publication.py', TRANSPORT / 'test-transport.py', *map(Path, tools.values())]
    pins = dict(identities['sourceSHA256'])
    pins.update({str(path.resolve(strict=True)): sha(path) for path in extra})
    configuration = load('installed_configuration', config)
    env = configuration.environment()
    resources = load('task_runner', ROOT / 'scripts/task_runner.py').Inputs(directories=configuration.RESOURCE_ROOTS)
    generated = out / 'scenario.c'
    native = out / 'scenario.native'
    plan = {'scope': 'direct development only; no complete resolver qualification or #41 completion',
            'expectedSHA256': expected_sha, 'entrypoint': identities['entrypoint'], 'constructorInventory': str(TRANSPORT / 'constructor-identities.json'),
            'resourceRoots': [str(root) for root in resources.directories], 'resourceInventory': resources.expected,
            'pins': pins, 'environment': env, 'cwd': str(HERE), 'oracle': str(oracle / 'expected.json'),
            'generated': str(generated), 'native': str(native),
            'tools': tools, 'commands': [
                {'label': 'emit', 'argv': [tools['taskset'], '-c', '5', tools['bend'], identities['entrypoint'], '-o', str(generated)], 'capSeconds': 30},
                {'label': 'build', 'argv': [tools['taskset'], '-c', '5', tools['clangWrapper'], '-O3', str(generated), '-o', str(native), '-pthread', '-lm'], 'capSeconds': 120},
                {'label': 'consumer', 'argv': [tools['taskset'], '-c', '5', str(native), '--threads', '1', '--gpu', 'off'], 'capSeconds': 5}],
            'postConsumer': 'Exact entire independently authored literal application output; no full41/public/performance claim'}
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
    global VERIFIED_SOURCES
    VERIFIED_SOURCES = {path: Path(path).read_bytes() for path in plan['pins'] if path.endswith('.py')}
    if any(hashlib.sha256(data).hexdigest() != plan['pins'][path] for path, data in VERIFIED_SOURCES.items()):
        raise ValueError('Captured helper bytes changed before import')
    if resource_snapshot(plan.get('resourceRoots', [])) != plan.get('resourceInventory', {}):
        raise ValueError('Resources changed before helper imports')
    out = plan_path.parent
    parser = load('scenario_parser', TRANSPORT / 'transport.py')
    runner = load('task_runner', ROOT / 'scripts/task_runner.py')
    boundary = load('evidence_boundary', ROOT / 'scripts/evidence_boundary.py')
    inventory = json.loads(Path(plan['constructorInventory']).read_text())
    resources = runner.Inputs(directories=plan['resourceRoots'])
    if resources.expected != plan['resourceInventory']:
        raise ValueError('Frozen Native resources changed before launch')
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
        unchanged = actual == pins and parser.Transport(plan['entrypoint']).inventory() == inventory and resource_actual == plan['resourceInventory']
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
                artifact = generated if label == 'emit' else native
                publish_result(command, result, out, pins, record,
                               artifact if label in ('emit', 'build') else None)
                if label != 'consumer' and (result['exit'] != 0 or result['failure'] is not None):
                    raise ValueError('Owned child failed: ' + label)
                if label in ('emit', 'build'):
                    if str(artifact) not in pins:
                        raise ValueError('Child did not produce a regular non-symlink artifact')
                else:
                    expected_bytes = Path(plan['oracle']).read_bytes()
                    if hashlib.sha256(expected_bytes).hexdigest() != plan['expectedSHA256']:
                        raise ValueError('Whole oracle changed')
                    record['timerQualification'] = parser.validate_result(result, json.loads(expected_bytes), CONTROL)
                    record['wholeOracleSHA256'] = plan['expectedSHA256']
        record['status'] = 'DEVELOPMENT_PASS'


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest='command', required=True)
    preparation = sub.add_parser('prepare')
    preparation.add_argument('output')
    preparation.add_argument('oracle_directory')
    preparation.add_argument('expected_sha256')
    execution = sub.add_parser('run')
    execution.add_argument('plan')
    execution.add_argument('admitted_sha256')
    args = parser.parse_args()
    if args.command == 'prepare':
        prepare(args.output, args.oracle_directory, args.expected_sha256)
    else:
        run(args.plan, args.admitted_sha256)


if __name__ == '__main__':
    main()
