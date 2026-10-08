"""No-child comparison of retained development observations; not tool qualification."""
import hashlib
import json
from pathlib import Path
HERE = Path(__file__).resolve().parent
sha = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
expected = (HERE/'expected.stdout').read_bytes()
original = (HERE/'expected-1.stdout').read_bytes()
assert expected == original + b'\n', 'only permitted oracle correction is terminal LF'
for role in ('js-1','native-1'):
    folder = HERE/'evidence'/role
    receipt = json.loads((folder/'receipt.json').read_text())
    plan = json.loads((folder/'plan.json').read_text())
    assert receipt.get('guardFailures',[]) == []
    assert len(receipt['commands']) == (2 if role == 'js-1' else 3)
    assert all(row['exit'] == 0 and row['failure'] is None for row in receipt['commands'])
    assert [row['capSeconds'] for row in receipt['commands']] == ([30,5] if role == 'js-1' else [30,120,5])
    for row in receipt['commands']:
        assert row['argv'][:3] == ['/usr/bin/taskset','-c','5']
    for name,digest in receipt['logs'].items():
        assert sha(folder/'raw'/name) == digest
    assert (folder/'raw/complete-run.stdout').read_bytes() == expected
    assert (folder/'raw/complete-run.stderr').read_bytes() == b''
    for name in ('staging.bend','controls.bend','main.bend','development-run.py'):
        candidates = [digest for path,digest in plan['inputs'].items() if path.endswith('/owned-recovery-v1/'+name)]
        assert candidates == [sha(HERE/name)], 'executed source differs: '+name
    expected_source = folder/'executed-expected.stdout' if role == 'js-1' else HERE/'expected.stdout'
    assert [digest for path,digest in plan['inputs'].items() if path.endswith('/owned-recovery-v1/expected.stdout')] == [sha(expected_source)]
    if role == 'js-1':
        assert receipt['status'] == 'INCOMPLETE'
        assert receipt['error'] == 'AssertionError: complete observation differs from pre-run oracle'
        assert (folder/'executed-expected.stdout').read_bytes() == original
        assert (folder/'executed-run.py').read_bytes() == (HERE/'development-run.py').read_bytes()
    else:
        assert receipt['status'] == 'DEVELOPMENT_PASS'
print('PASS: complete JS/Native values, FIFO and LF-only historical repair; retained development scopes')
