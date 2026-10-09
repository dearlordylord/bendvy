#!/usr/bin/env python3
"""Focused direct development: prepare only, then a separately admitted guarded run.

No relocated imports, installed resolver discovery, Native, or performance work.
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
TRANSPORT = HERE.parents[1] / 'transport-v1'
EXPECTED = 'cd83e13f3f37cdeada6e2d7e02e0e716a658b885fc6ec279f4615b325bdd4cf8'
BASELINE = '12ac1a036e525fa92417129364a03b6212dd241bee3b10e664fd9a840861d01a'



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


def prepare(out, oracle, expected_sha):
    out = Path(out).resolve()
    oracle = Path(oracle).resolve()
    parser = load('scenario_parser', TRANSPORT / 'transport.py')
    identities = json.loads((TRANSPORT / 'wrong-reader-advance-identities.json').read_text())
    if parser.Transport(HERE / 'main.bend').inventory() != identities:
        raise ValueError('Frozen original source/constructor inventory changed')
    if expected_sha != EXPECTED or sha(oracle / 'wrong-reader-advance-expected.json') != EXPECTED:
        raise ValueError('Independent whole oracle changed')
    tools = {'bend': '/home/node/.bend/bin/bend', 'node': '/home/node/.local/share/mise/installs/node/24.20.0/bin/node', 'python': str(Path(sys.executable).resolve()), 'taskset': str(Path('/usr/bin/taskset').resolve(strict=True))}
    extra = [parser.TERM_PATH, Path(__file__), TRANSPORT / 'transport.py', TRANSPORT / 'wrong-reader-advance-identities.json',
             ROOT / 'scripts/task_runner.py', ROOT / 'scripts/evidence_boundary.py',
             Path('/home/node/.bend/bend2/base.bend'), oracle / 'wrong-reader-advance-expected.json', oracle / 'expected.py', oracle / 'source-basis.json',
             TRANSPORT / 'wrong-reader-advance-synthetic.stdout', TRANSPORT / 'PREPARATION.json', HERE.parents[1] / 'SOURCE-CLOSURE.json', HERE / 'SOURCE-DELTA.json', oracle / 'expected.json', oracle / 'counterfactuals.py', oracle / 'counterfactual-source-basis.json', *map(Path, tools.values())]
    pins = dict(identities['sourceSHA256'])
    pins.update({str(path.resolve(strict=True)): sha(path) for path in extra})
    env = {'HOME': '/home/node', 'PATH': '/usr/bin:/bin', 'LANG': 'C', 'LC_ALL': 'C', 'TZ': 'UTC'}
    env['BEND_NO_TELEMETRY'] = '1'
    generated = out / 'scenario.js'
    plan = {'scope': 'direct development only; no complete resolver qualification or #43 completion',
            'expectedSHA256': expected_sha, 'entrypoint': identities['entrypoint'], 'constructorInventory': str(TRANSPORT / 'wrong-reader-advance-identities.json'),
            'pins': pins, 'environment': env, 'cwd': str(HERE), 'oracle': str(oracle / 'wrong-reader-advance-expected.json'),
            'baseline': str(oracle / 'expected.json'), 'baselineSHA256': BASELINE, 'generated': str(generated),
            'tools': tools, 'commands': [
                {'label': 'emit', 'argv': [tools['taskset'], '-c', '5', tools['bend'], identities['entrypoint'], '-o', str(generated)], 'capSeconds': 30},
                {'label': 'consumer', 'argv': [tools['taskset'], '-c', '5', tools['node'], str(generated)], 'capSeconds': 5}],
            'postConsumer': 'Strict entire two-schema retry/foreign/lifecycle/mixed complete typed join against independently frozen expected; no full43/public/performance claim'}
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
    parser = load('scenario_parser', TRANSPORT / 'transport.py')
    runner = load('task_runner', ROOT / 'scripts/task_runner.py')
    boundary = load('evidence_boundary', ROOT / 'scripts/evidence_boundary.py')
    inventory = json.loads(Path(plan['constructorInventory']).read_text())
    pins = dict(plan['pins'])
    pins[str(plan_path)] = expected_sha
    generated = Path(plan['generated'])
    record = {'scope': plan['scope'], 'planSHA256': expected_sha, 'commands': [], 'guards': []}

    def guard(label):
        if str(generated) in pins and (generated.is_symlink() or not generated.is_file()):
            raise ValueError('Generated artifact must be a regular non-symlink file')
        actual = {path: sha(path) for path in pins}
        unchanged = actual == pins and parser.Transport(plan['entrypoint']).inventory() == inventory
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
                        if label == 'emit' and (generated.exists() or generated.is_symlink()):
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
                if label == 'emit' and (generated.exists() or generated.is_symlink()):
                    # Failed emits can leave useful partial output: retain it before
                    # evaluating the child's failure so post/final guards cover it.
                    pins[str(generated)] = sha(generated)
                    record['generatedSHA256'] = pins[str(generated)]
                if result['exit'] != 0 or result['failure'] is not None:
                    raise ValueError('Owned child failed: ' + label)
                if label == 'emit':
                    if str(generated) not in pins:
                        raise ValueError('Emit did not produce a regular non-symlink artifact')
                else:
                    if result['stderr']:
                        raise ValueError('Consumer stderr is not empty')
                    actual = parser.Transport(plan['entrypoint']).normalize(result['stdout'].decode())
                    expected_bytes = Path(plan['oracle']).read_bytes()
                    if hashlib.sha256(expected_bytes).hexdigest() != plan['expectedSHA256']:
                        raise ValueError('Whole oracle changed')
                    parser.TERM.strict_equal(actual, json.loads(expected_bytes))
                    baseline_bytes = Path(plan['baseline']).read_bytes()
                    if hashlib.sha256(baseline_bytes).hexdigest() != BASELINE:
                        raise ValueError('Unchanged whole baseline changed')
                    try:
                        parser.TERM.strict_equal(actual, json.loads(baseline_bytes))
                    except ValueError:
                        record['wholeBaselineRejected'] = True
                    else:
                        raise ValueError('Reached mutant did not reject complete baseline')
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
