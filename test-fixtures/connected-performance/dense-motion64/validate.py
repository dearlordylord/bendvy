"""Admit complete Dense64 records and exact raw nanosecond sidecars offline."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import re

sha = lambda b: hashlib.sha256(b).hexdigest()
def admit_clock(declared, position, argv, directory, retained):
    clock = Path(declared['path'])
    assert clock.is_absolute() and clock.parent == directory and not clock.is_symlink()
    assert str(clock.resolve(strict=True)) == str(clock)
    assert argv[position] == str(clock)
    assert declared['units'] == 'ns'
    data = clock.read_bytes()
    assert 0 < len(data) < 128 and re.fullmatch(rb'[0-9]+\n', data)
    value = int(data)
    assert 0 < value <= (1 << 48) - 1
    assert retained == dict(path=str(clock), bytes=len(data), sha256=sha(data), raw=data.decode('ascii'))
    return dict(phase=declared['phase'], path=str(clock), bytes=len(data), sha256=sha(data), raw=data.decode('ascii'), nanoseconds=value)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--index', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    a = parser.parse_args()
    assert not a.output.exists()
    index = json.loads(a.index.read_text())
    roles = []
    for selected in index['plans']:
        path = Path(selected['path']).resolve(strict=True)
        assert sha(path.read_bytes()) == selected['sha256']
        plan = json.loads(path.read_text())
        directory = path.parent
        precheck_path = directory / 'ROOT-FRESHNESS.json'
        precheck = json.loads(precheck_path.read_text())
        assert precheck['planSHA256'] == selected['sha256']
        required = [x['path'] for x in plan['clockSidecars']]
        assert precheck['clockPaths'] == [dict(path=p, exists=False, isSymlink=False) for p in required]
        retained_path = directory / 'ROOT-RAW-CLOCKS.json'
        retained = json.loads(retained_path.read_text())
        assert retained['planSHA256'] == selected['sha256']
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
                data = Path(actual[stream]['path']).read_bytes()
                assert len(data) == actual[stream]['bytes'] and sha(data) == actual[stream]['sha256']
            assert actual['stderr']['bytes'] == 0
        actual = next(c for c in receipt['commands'] if c['label'] == 'consumer')
        prefix = [plan['tools']['taskset'], '-c', '11']
        child = ([plan['native']] if selected['role'] == 'native' else [plan['tools']['node'], plan['generated']])
        expected = prefix + child + plan['runtimeArguments']
        if selected['role'] == 'native':
            expected += ['--threads', '1', '--gpu', 'off']
        assert actual['argv'] == expected
        raw = (directory / 'consumer.stdout').read_bytes()
        oracle = gzip.decompress(Path(plan['oracle']).read_bytes())
        assert len(oracle) == plan['oracleBytes'] and sha(oracle) == plan['oracleSHA256'] and raw == oracle
        tuples = [json.loads(line[6:]) for line in raw.decode().splitlines() if line.startswith('TUPLE:')]
        fixture = json.loads((Path(__file__).parent / 'model/expected-common.json').read_text())
        assert len(tuples) == 2 and all(values == fixture['tuple'] for values in tuples)
        clocks = []
        assert [c['phase'] for c in plan['clockSidecars']] == ['warmup', 'sample']
        indices = [6, 7] if selected['role'] == 'native' else [7, 8]
        for declared, position in zip(plan['clockSidecars'], indices):
            clocks.append(admit_clock(declared, position, actual['argv'], directory, retained['clocks'][len(clocks)]))
        roles.append(dict(role=selected['role'], planSHA256=selected['sha256'], receiptSHA256=sha(receipt_path.read_bytes()),
                          fullBytes=len(raw), fullSHA256=sha(raw), completeActualTuples=len(tuples), clocks=clocks,
                          freshnessSHA256=sha(precheck_path.read_bytes()), rawClocksSHA256=sha(retained_path.read_bytes())))
    assert [r['role'] for r in roles] == ['js', 'native', 'ts']
    result = dict(status='DENSE64_COMMON_CLOCK_FULL_RECORDS_PASS', scope='One full correctness/common-clock bridge with explicit coordinator freshness and raw ns admission; no wall bound, clock accuracy, ratio, uncertainty margin, RSS or product qualification.',
                  units='ns', validatorSHA256=sha(Path(__file__).read_bytes()), indexSHA256=sha(a.index.read_bytes()), roles=roles)
    a.output.write_text(json.dumps(result, indent=2) + '\n')
    print(result['status'])


if __name__ == "__main__":
    main()
