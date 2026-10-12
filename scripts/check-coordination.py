#!/usr/bin/env python3
"""Check the concise coordination table's mechanical structure."""
from pathlib import Path
import sys

def check(text):
    inside = False
    errors = []
    for number, line in enumerate(text.splitlines(), 1):
        if line.startswith('| Task |'):
            inside = True
            continue
        if inside and not line.startswith('|'):
            break
        if inside and not line.startswith('| ---'):
            cells = [cell.strip() for cell in line.strip('|').split('|')]
            if len(cells) != 5 or any(not cell for cell in cells):
                errors.append(f'{number}: expected five nonempty cells')
            if len(line) > 1200:
                errors.append(f'{number}: move historical detail behind a link')
    if not inside:
        errors.append('Coordination table missing')
    return errors

if __name__ == '__main__':
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parents[1] / 'docs/parity/README.md'
    errors = check(path.read_text())
    print('\n'.join(errors) if errors else 'Coordination structure PASS')
    raise SystemExit(bool(errors))
