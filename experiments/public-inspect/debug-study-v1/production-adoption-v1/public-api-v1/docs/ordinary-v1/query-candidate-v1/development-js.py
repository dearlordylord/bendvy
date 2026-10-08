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
from pathlib import Path

ROOT = Path('/workspace/formal-proofs/bendvy')
HERE = Path(__file__).resolve().parent
EXPECTED = 'ddeda9c7cfd8e4ba4563ba7e9e8868a074e9c8001cc8e989eeadf43baef0a8ce'


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def prepare(out, oracle):
    out = Path(out).resolve()
    oracle = Path(oracle).resolve()
    parser = load('scenario_parser', HERE / 'parse-scenario.py')
    identities = json.loads((HERE / 'constructor-identities.json').read_text())
    if parser.build_identities(HERE / 'scenario-main.bend') != identities:
        raise ValueError('Frozen original source/constructor inventory changed')
    if sha(oracle / 'expected.json') != EXPECTED:
        raise ValueError('Independent whole oracle changed')
    tools = {'bend': '/home/node/.bend/bin/bend', 'node': '/home/node/.local/share/mise/installs/node/24.20.0/bin/node', 'python': str(Path(sys.executable).resolve())}
    extra = [Path(__file__), HERE / 'parse-scenario.py', HERE / 'constructor-identities.json',
             ROOT / 'scripts/task_runner.py', ROOT / 'scripts/evidence_boundary.py',
             Path('/home/node/.bend/bend2/base.bend'), oracle / 'expected.json', oracle / 'CONSTRUCTOR-JOIN.json',
             oracle / 'synthetic-complete.stdout', *map(Path, tools.values())]
    pins = dict(identities['sourceSHA256'])
    pins.update({str(path.resolve(strict=True)): sha(path) for path in extra})
    env = {key: os.environ[key] for key in ('HOME', 'PATH', 'LANG', 'LC_ALL', 'TZ') if key in os.environ}
    env['BEND_NO_TELEMETRY'] = '1'
    generated = out / 'scenario.js'
    plan = {'scope': 'direct development only; no complete resolver qualification or #56 completion',
            'entrypoint': identities['entrypoint'], 'constructorInventory': str(HERE / 'constructor-identities.json'),
            'pins': pins, 'environment': env, 'cwd': str(HERE), 'oracle': str(oracle / 'expected.json'),
            'join': str(oracle / 'CONSTRUCTOR-JOIN.json'), 'generated': str(generated),
            'tools': tools, 'commands': [
                {'label': 'emit', 'argv': [tools['bend'], identities['entrypoint'], '-o', str(generated)], 'capSeconds': 30},
                {'label': 'consumer', 'argv': [tools['node'], str(generated)], 'capSeconds': 5}],
            'postConsumer': 'Strict complete parser join against independent ddeda9 oracle; Native waits for JS equality'}
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
    parser = load('scenario_parser', HERE / 'parse-scenario.py')
    runner = load('task_runner', ROOT / 'scripts/task_runner.py')
    boundary = load('evidence_boundary', ROOT / 'scripts/evidence_boundary.py')
    inventory = json.loads(Path(plan['constructorInventory']).read_text())
    pins = dict(plan['pins'])
    pins[str(plan_path)] = expected_sha
    generated = Path(plan['generated'])
    record = {'scope': plan['scope'], 'planSHA256': expected_sha, 'commands': [], 'guards': []}

    def guard(label):
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
                        if label == 'emit' and generated.exists():
                            raise ValueError('Generated output must start absent')
                        result = runner.execute_result(command['argv'], command['capSeconds'], plan['environment'], plan['cwd'], 'split')
                    finally:
                        fcntl.flock(lock, fcntl.LOCK_UN)
                row = dict(command)
                for key, value in result.items():
                    if isinstance(value, bytes):
                        target = out / (label + '.' + key)
                        target.write_bytes(value)
                        row[key] = {'path': str(target), 'sha256': sha(target), 'bytes': len(value)}
                    else:
                        row[key] = value
                record['commands'].append(row)
                if result['exit'] != 0 or result['failure'] is not None:
                    raise ValueError('Owned child failed: ' + label)
                if label == 'emit':
                    pins[str(generated)] = sha(generated)
                    record['generatedSHA256'] = pins[str(generated)]
                else:
                    if result['stderr']:
                        raise ValueError('Consumer stderr is not empty')
                    actual = parser.normalize(parser.parse_term(result['stdout'].decode()), inventory['constructors'], json.loads(Path(plan['join']).read_text()))
                    expected_bytes = Path(plan['oracle']).read_bytes()
                    if hashlib.sha256(expected_bytes).hexdigest() != EXPECTED:
                        raise ValueError('Whole oracle changed')
                    parser.strict_equal(actual, json.loads(expected_bytes))
                    record['wholeOracleSHA256'] = EXPECTED
        record['status'] = 'DEVELOPMENT_PASS'


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest='command', required=True)
    preparation = sub.add_parser('prepare')
    preparation.add_argument('output')
    preparation.add_argument('oracle_directory')
    execution = sub.add_parser('run')
    execution.add_argument('plan')
    execution.add_argument('admitted_sha256')
    args = parser.parse_args()
    if args.command == 'prepare':
        prepare(args.output, args.oracle_directory)
    else:
        run(args.plan, args.admitted_sha256)


if __name__ == '__main__':
    main()
