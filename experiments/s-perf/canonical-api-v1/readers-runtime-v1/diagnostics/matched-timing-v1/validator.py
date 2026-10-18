"""Offline full-record replay and raw-clock capture; never launches measured work."""
import argparse
import gzip
import hashlib
import json
import math
from pathlib import Path
import re

sha = lambda data: hashlib.sha256(data).hexdigest()
parser = argparse.ArgumentParser()
parser.add_argument('--index', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
a = parser.parse_args()
assert not a.output.exists()
index = json.loads(a.index.read_text())
roles = []
for selected in index['plans']:
    path = Path(selected['path'])
    assert sha(path.read_bytes()) == selected['sha256']
    plan = json.loads(path.read_text())
    directory = path.parent
    receipt_path = directory / 'receipt.json'
    receipt = json.loads(receipt_path.read_text())
    assert receipt['planSHA256'] == selected['sha256']
    assert receipt['status'] == 'COMPLETE_CONSUMER_DEVELOPMENT_PASS'
    assert len(receipt['commands']) == len(plan['commands'])
    for actual, declared in zip(receipt['commands'], plan['commands']):
        for key in ['label', 'argv', 'capSeconds']:
            assert actual[key] == declared[key]
        assert actual['exit'] == 0 and actual['failure'] is None
        for stream in ['stdout', 'stderr']:
            raw = Path(actual[stream]['path']).read_bytes()
            assert len(raw) == actual[stream]['bytes'] and sha(raw) == actual[stream]['sha256']
        assert actual['stderr']['bytes'] == 0
    raw = (directory / 'consumer.stdout').read_bytes()
    oracle = gzip.decompress(Path(plan['oracle']).read_bytes())
    assert len(oracle) == plan['oracleBytes'] and sha(oracle) == plan['oracleSHA256']
    assert raw == oracle
    # Full actual arrays survive transport; fold is not an equality oracle.
    tuples = [json.loads(line[6:]) for line in raw.decode().splitlines() if line.startswith('TUPLE:')]
    assert len(tuples) == 2
    fixture = json.loads(gzip.decompress((Path(__file__).parent / 'model/expected-common.json.gz').read_bytes()))
    assert all(values == fixture['tuple'] for values in tuples)
    clocks = []
    for declared in plan['clockSidecars']:
        clock = Path(declared['path'])
        assert clock.parent == directory and not clock.is_symlink() and clock.is_file()
        data = clock.read_bytes()
        assert 0 < len(data) < 128 and data.endswith(b'\n')
        text = data.decode('ascii')
        if selected['role'] != 'ts':
            assert re.fullmatch(r'[0-9]+\n', text)
        value = float(text)
        assert math.isfinite(value) and value >= 0
        clocks.append(dict(phase=declared['phase'], path=str(clock), bytes=len(data),
                           sha256=sha(data), raw=text, milliseconds=value))
    roles.append(dict(role=selected['role'], planSHA256=selected['sha256'],
                      receiptSHA256=sha(receipt_path.read_bytes()), fullBytes=len(raw),
                      fullSHA256=sha(raw), completeActualTuples=len(tuples), clocks=clocks))
assert [r['role'] for r in roles] == ['js', 'native']
result = dict(status='B1_BEND_PAIR_COMPLETE_FULL_RECORDS_PASS',
              scope='Method/correctness feasibility only; raw clocks may be resolution limited. No speed ranking, ratio, uncertainty margin, RSS or product qualification.',
              validatorSHA256=sha(Path(__file__).read_bytes()), indexSHA256=sha(a.index.read_bytes()), roles=roles)
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(result['status'])
