#!/usr/bin/env python3
"""Join all three completed partition receipts against the unchanged whole oracle."""
import argparse
import hashlib
import json
from pathlib import Path
import transport

EXPECTED = '129b8b0d876068f9d5b7ba66df69125e9842e791d88d5cb1aa5d248808dc2762'
sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('oracle_directory', type=Path)
    ap.add_argument('output', type=Path)
    ap.add_argument('cohorts', nargs=3, type=Path)
    args = ap.parse_args()
    expected = args.oracle_directory / 'expected.json'
    join = args.oracle_directory / 'CONSTRUCTOR-JOIN.json'
    if sha(expected) != EXPECTED:
        raise ValueError('Whole independent oracle changed')
    raw = {}
    inventories = {}
    records = []
    for category, cohort in zip(transport.CATEGORIES, args.cohorts):
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
        required_guards = {label + '-' + stage for label in ('emit', 'build', 'consumer') for stage in ('pre', 'acquired', 'post')} | {'final'}
        observed_guards = set()
        for guard in receipt['guards']:
            guard_path = Path(guard['path'])
            if sha(guard_path) != guard['sha256']:
                raise ValueError('Category guard receipt drift')
            state = json.loads(guard_path.read_text())
            if state['unchanged'] is not True or state['label'] in observed_guards:
                raise ValueError('Category boundary unchanged flag/identity refused')
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
        records.append({'category': category, 'receiptSHA256': sha(receipt_path), 'stdoutSHA256': sha(stdout)})
    transport.aggregate(raw, inventories, json.loads(join.read_text()), json.loads(expected.read_text()))
    if args.output.exists():
        raise ValueError('Aggregate receipt must start absent')
    args.output.write_text(json.dumps({'status': 'COMPLETE_45_PHASE_PARTITION_EQUALITY', 'scope': 'Native compilation partition development only; no original combined-binary or performance claim', 'wholeOracleSHA256': EXPECTED, 'joinSHA256': sha(join), 'categories': records}, indent=2) + '\n')


if __name__ == '__main__': main()
