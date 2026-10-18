#!/usr/bin/env python3
"""Compare the complete failure, retry and unchanged-run observations."""
from pathlib import Path
import sys

expected = (Path(__file__).parent / 'expected.stdout').read_bytes()
actual = Path(sys.argv[1]).read_bytes()
assert actual == expected, 'Captured query observations differ from expected.stdout'
print('PASS captured-query: rollback, retained capture, typed error and outputs')
