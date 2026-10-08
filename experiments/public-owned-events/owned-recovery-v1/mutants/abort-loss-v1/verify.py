"""No-child exact mutation/source/raw/oracle joins for the reached abort-loss child."""
import hashlib
import json
from pathlib import Path
HERE = Path(__file__).resolve().parent
BASE = HERE.parents[1]
sha = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
original = (BASE/'staging.bend').read_text()
before = 'case Stage{newest}: Aborted{List.reverse(&1,Payload,newest)}'
after = 'case Stage{newest}: Aborted{List.tail(&1,Payload,List.reverse(&1,Payload,newest))}'
assert original.count(before) == 1
assert (HERE/'staging.bend').read_text() == original.replace(before,after)
for name in ('controls.bend','main.bend','expected.stdout'):
    assert (HERE/name).read_bytes() == (BASE/name).read_bytes()
folder = HERE/'evidence/js-1'
receipt = json.loads((folder/'receipt.json').read_text())
plan = json.loads((folder/'plan.json').read_text())
assert receipt['status'] == 'MUTANT_DETECTED'
assert receipt.get('guardFailures',[]) == []
assert [row['capSeconds'] for row in receipt['commands']] == [30,5]
assert all(row['exit']==0 and row['failure'] is None for row in receipt['commands'])
assert all(row['argv'][:3]==['/usr/bin/taskset','-c','5'] for row in receipt['commands'])
for name,digest in receipt['logs'].items():
    assert sha(folder/'raw'/name) == digest
actual = (folder/'raw/complete-run.stdout').read_bytes()
assert actual != (BASE/'expected.stdout').read_bytes(), 'unchanged complete oracle did not reject'
assert actual == (HERE/'expected-counterfactual.stdout').read_bytes()
assert (folder/'raw/complete-run.stderr').read_bytes() == b''
for name in ('staging.bend','controls.bend','main.bend','expected.stdout','expected-counterfactual.stdout','development-run.py'):
    candidates = [digest for path,digest in plan['inputs'].items() if path.endswith('/mutants/abort-loss-v1/'+name)]
    assert candidates == [sha(HERE/name)], 'executed mutation source differs: '+name
print('PASS: exact reached compiling abort-loss delta rejects unchanged complete oracle')
