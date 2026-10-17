#!/usr/bin/env python3
"""Independent finite model: two decay factors, six steps, one excluded entity."""
from pathlib import Path
import sys

# Parse numbers so independent Python formatting cannot mask or create a failure.
for name in sys.argv[1:]:
    actual = Path(name).read_text().splitlines()
    assert len(actual) == 8 and actual[0] == 'before-barrier=' and actual[-1] == 'untouched=30', name
    a, b = 10.0, 20.0
    for tick, line in enumerate(actual[1:-1], 1):
        a *= 0.5
        b *= 0.25
        prefix = f'tick={tick} health='
        assert line.startswith(prefix), (name, line)
        assert tuple(map(float, line[len(prefix):].split(','))) == (a, b), (name, line)
    print(f'PASS {name}: all six ticks, deferred visibility and excluded entity')
assert len(sys.argv) > 1, 'usage: python3 verify.py OUTPUT [OUTPUT...]'
