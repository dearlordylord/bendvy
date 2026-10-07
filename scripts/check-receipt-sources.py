#!/usr/bin/env python3
"""Check recorded source bytes, not semantic or performance acceptance."""
import argparse
import hashlib
import json
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('receipts', nargs='+', type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
failed = False
for receipt in args.receipts:
    data = json.loads(receipt.read_text())
    sources = data.get('sources', data.get('source'))
    if not isinstance(sources, dict) or not sources:
        print(f'{receipt}: FAIL: no source hash inventory')
        failed = True
        continue
    mismatches = []
    for name, expected in sources.items():
        path = Path(name)
        if not path.is_absolute():
            path = root / path
        if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != expected:
            mismatches.append(name)
    failed |= bool(mismatches)
    print(json.dumps({'receipt': str(receipt), 'sourceCount': len(sources),
                      'mismatches': mismatches, 'sourceBinding': 'FAIL' if mismatches else 'PASS'}))
raise SystemExit(1 if failed else 0)
