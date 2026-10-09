#!/usr/bin/env python3
"""Join all three completed partition receipts against the unchanged whole oracle."""
import argparse
import hashlib
import json
import os
import stat
from pathlib import Path
import importlib.util
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('app_parser_aggregate', HERE / 'parse-native.py')
transport = importlib.util.module_from_spec(spec)
spec.loader.exec_module(transport)
CATEGORIES = ('plain', 'transient', 'constructed')

EXPECTED = '52f3a174f01f8ee1f4746a8887be0579dd70b724366575a5aa5337e5a22b2a82'
def sha(path):
    path = Path(path)
    if path.is_symlink() or not path.is_file():
        raise ValueError('Aggregate file must be regular and non-symlink')
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
    with os.fdopen(fd, 'rb') as source:
        if not stat.S_ISREG(os.fstat(source.fileno()).st_mode):
            raise ValueError('Aggregate descriptor must be regular')
        return hashlib.sha256(source.read()).hexdigest()


def expected_guard_pins(plan_path, plan, receipt):
    pins = {**plan['pins'], str(Path(plan_path).resolve(strict=True)): receipt['planSHA256']}
    stages = {}
    for command in receipt['commands']:
        label = command['label']
        stages[label + '-pre'] = dict(pins)
        stages[label + '-acquired'] = dict(pins)
        for stream in ('stdout', 'stderr'):
            raw = command[stream]
            pins[raw['path']] = raw['sha256']
        if label in ('emit', 'build'):
            artifact = plan['generated'] if label == 'emit' else plan['native']
            digest = receipt[label + 'ArtifactSHA256']
            if sha(artifact) != digest:
                raise ValueError('Category generated artifact drift')
            pins[artifact] = digest
        stages[label + '-post'] = dict(pins)
    stages['final'] = dict(pins)
    return stages


def verify_guard_state(state, expected):
    label = state['label']
    if label not in expected or state['actualPins'] != expected[label]:
        raise ValueError('Exact per-stage guard pin set/digests refused')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('oracle_directory', type=Path)
    ap.add_argument('output', type=Path)
    ap.add_argument('cohorts', nargs=3, type=Path)
    args = ap.parse_args()
    expected = args.oracle_directory / 'expected.json'
    join = args.oracle_directory / 'CONSTRUCTOR-JOIN.json'
    if sha(expected) != EXPECTED or json.loads(join.read_text())['expectedSHA256'] != EXPECTED:
        raise ValueError('Whole independent oracle changed')
    raw = {}
    inventories = {}
    records = []
    for category, cohort in zip(CATEGORIES, args.cohorts):
        receipt_path = cohort / 'receipt.json'
        receipt = json.loads(receipt_path.read_text())
        plan_path = cohort / 'plan.json'
        plan = json.loads(plan_path.read_text())
        if receipt['status'] != 'CATEGORY_DEVELOPMENT_PASS' or receipt['category'] != category or plan['category'] != category:
            raise ValueError('All ordered successful category receipts required')
        if sha(plan_path) != receipt['planSHA256'] or receipt['wholeOracleSHA256'] != EXPECTED:
            raise ValueError('Category receipt binding changed')
        for path, digest in plan['pins'].items():
            if sha(path) != digest:
                raise ValueError('Category frozen input drift')
        if receipt.get('guardFailures'):
            raise ValueError('Category boundary guard failed')
        commands = receipt['commands']
        if len(commands) != 3 or len(plan['commands']) != 3:
            raise ValueError('All three owned stages required')
        for command, planned, label, cap in zip(commands, plan['commands'], ('emit', 'build', 'consumer'), (30, 120, 5)):
            if command['label'] != label or command['exit'] != 0 or command['failure'] is not None or command['capSeconds'] != cap:
                raise ValueError('Category owned stage refused')
            if command['argv'] != planned['argv'] or command['argv'][:3] != ['/usr/bin/taskset', '-c', '5']:
                raise ValueError('Category stage command/CPU binding changed')
            for stream in ('stdout', 'stderr'):
                if sha(command[stream]['path']) != command[stream]['sha256']:
                    raise ValueError('Category stage raw drift')
        if commands[-1]['argv'] != ['/usr/bin/taskset', '-c', '5', plan['native'], '--threads', '1', '--gpu', 'off']:
            raise ValueError('Exact native threads1/GPUoff runtime required')
        stage_pins = expected_guard_pins(plan_path, plan, receipt)
        required_guards = {label + '-' + stage for label in ('emit', 'build', 'consumer') for stage in ('pre', 'acquired', 'post')} | {'final'}
        observed_guards = set()
        for guard in receipt['guards']:
            guard_path = Path(guard['path'])
            if sha(guard_path) != guard['sha256']:
                raise ValueError('Category guard receipt drift')
            state = json.loads(guard_path.read_text())
            if state['unchanged'] is not True or state['label'] in observed_guards:
                raise ValueError('Category boundary unchanged flag/identity refused')
            verify_guard_state(state, stage_pins)
            observed_guards.add(state['label'])
        if observed_guards != required_guards:
            raise ValueError('All exact boundary guards required')
        row = receipt['commands'][-1]
        if row['label'] != 'consumer' or row['exit'] != 0 or row['failure'] is not None:
            raise ValueError('Consumer did not succeed')
        stdout = Path(row['stdout']['path'])
        stderr = Path(row['stderr']['path'])
        if sha(stdout) != row['stdout']['sha256'] or sha(stderr) != row['stderr']['sha256'] or stderr.read_bytes():
            raise ValueError('Consumer raw drift')
        raw[category] = stdout.read_text()
        inventories[category] = json.loads(Path(plan['constructorInventory']).read_text())
        if transport.build_identities(Path(plan['entrypoint'])) != inventories[category]:
            raise ValueError('Exact native category source/constructor identities drift')
        records.append({'category': category, 'receiptSHA256': sha(receipt_path), 'stdoutSHA256': sha(stdout)})
    actual = {category: transport.normalize(raw[category], inventories[category], json.loads(join.read_text()), category) for category in CATEGORIES}
    transport.BASE.strict_equal(actual, json.loads(expected.read_text()))
    if args.output.exists() or args.output.is_symlink():
        raise ValueError('Aggregate receipt must start absent')
    with args.output.open('x') as target:
        target.write(json.dumps({'status': 'COMPLETE_54_SNAPSHOT_12_POPULATION_DUMP_PARTITION_EQUALITY', 'scope': 'Actual ordinary dump Native compilation partition development only; no combined-binary/public56/performance claim', 'wholeOracleSHA256': EXPECTED, 'joinSHA256': sha(join), 'categories': records}, indent=2) + '\n')


if __name__ == '__main__': main()
