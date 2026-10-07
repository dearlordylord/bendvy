#!/usr/bin/env python3
"""Check recorded source bytes, not semantic or performance acceptance."""
import argparse
import hashlib
import json
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('receipts', nargs='+', type=Path)
parser.add_argument('--require-core-inventory', action='store_true',
                    help='Require recorded src/ecs/*.bend paths to equal the current core inventory')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
failed = False
for receipt in args.receipts:
    data = json.loads(receipt.read_text())
    sources = data.get('currentSourceHashes', data.get('sources', data.get('source')))
    if (not isinstance(sources, dict) or not sources
            or not all(isinstance(name, str) and isinstance(value, str)
                       and len(value) == 64 for name, value in sources.items())):
        print(f'{receipt}: FAIL: no source hash inventory')
        failed = True
        continue
    mismatches = []
    recorded_paths = set()
    for name, expected in sources.items():
        path = Path(name)
        if not path.is_absolute():
            path = root / path
        recorded_paths.add(path.resolve())
        if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != expected:
            mismatches.append(name)
    inventory = None
    if args.require_core_inventory:
        core = (root / 'src/ecs').resolve()
        actual = {path.resolve() for path in core.glob('*.bend')}
        recorded = {path for path in recorded_paths
                    if path.parent == core and path.suffix == '.bend'}
        inventory = {'unrecorded': sorted(str(path.relative_to(root)) for path in actual - recorded),
                     'removed': sorted(str(path.relative_to(root)) for path in recorded - actual)}
    invalid = bool(mismatches) or bool(inventory and any(inventory.values()))
    failed |= invalid
    print(json.dumps({'receipt': str(receipt), 'sourceCount': len(sources),
                      'mismatches': mismatches, 'coreInventory': inventory,
                      'sourceBinding': 'FAIL' if invalid else 'PASS'}))
raise SystemExit(1 if failed else 0)
