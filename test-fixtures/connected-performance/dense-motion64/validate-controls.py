"""Finite negative controls for the exact clock-path/numeric admission boundary."""
import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile

path = Path(__file__).with_name('validate.py')
spec = importlib.util.spec_from_file_location('clock_admission', path)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
results = []
with tempfile.TemporaryDirectory(prefix='dense64-clock-admission-') as scratch:
    directory = Path(scratch).resolve()
    clock = directory / 'sample.ns'
    declared = dict(path=str(clock), phase='sample', units='ns')
    def observed(raw):
        return dict(path=str(clock), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), raw=raw.decode('ascii'))
    clock.write_bytes(b'20000000\n')
    assert m.admit_clock(declared, 0, [str(clock)], directory, observed(clock.read_bytes()))['nanoseconds'] == 20000000
    results.append('valid raw integer accepted')
    def rejects(name, action):
        try:
            action()
        except (AssertionError, FileNotFoundError):
            results.append(name)
        else:
            raise AssertionError('control unexpectedly accepted: ' + name)
    rejects('same basename at different actual argv path rejected', lambda: m.admit_clock(declared, 0, [str(directory / 'other' / clock.name)], directory, observed(clock.read_bytes())))
    for raw in [b'20.0\n', b'0\n', str(1 << 48).encode() + b'\n']:
        clock.write_bytes(raw)
        rejects('invalid numeric ' + repr(raw), lambda: m.admit_clock(declared, 0, [str(clock)], directory, observed(raw)))
    clock.unlink()
    rejects('missing clock rejected', lambda: m.admit_clock(declared, 0, [str(clock)], directory, {}))
print(json.dumps(dict(status='CLOCK_ADMISSION_FINITE_CONTROLS_PASS', validatorSHA256=hashlib.sha256(path.read_bytes()).hexdigest(), checks=results), indent=2))
