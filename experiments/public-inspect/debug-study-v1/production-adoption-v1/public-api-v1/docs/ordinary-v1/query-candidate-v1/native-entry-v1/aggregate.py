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
