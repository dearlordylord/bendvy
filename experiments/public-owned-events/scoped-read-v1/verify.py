"""No-child complete scoped-read source/dependency/raw/oracle development join."""
import hashlib
import json
from pathlib import Path
HERE = Path(__file__).resolve().parent
sha = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
expected = (HERE/'expected.stdout').read_bytes()
assert expected == b'first:11,12,13,14,|second:11,12,13,14,|returned:11,12,13,14,|sentinel:111,222,|owned:13,\n'
for role in ('js-1','native-1'):
    folder = HERE/'evidence'/role
    receipt = json.loads((folder/'receipt.json').read_text())
    plan = json.loads((folder/'plan.json').read_text())
    assert receipt['status'] == 'DEVELOPMENT_PASS'
    assert receipt.get('guardFailures',[]) == []
    assert [row['capSeconds'] for row in receipt['commands']] == ([30,5] if role=='js-1' else [30,120,5])
    assert all(row['exit']==0 and row['failure'] is None for row in receipt['commands'])
    assert all(row['argv'][:3]==['/usr/bin/taskset','-c','5'] for row in receipt['commands'])
    for name,digest in receipt['logs'].items():
        assert sha(folder/'raw'/name)==digest
    assert (folder/'raw/complete-run.stdout').read_bytes()==expected
    assert (folder/'raw/complete-run.stderr').read_bytes()==b''
    for name in ('read.bend','controls.bend','main.bend','expected.stdout','development-run.py'):
        candidates=[digest for path,digest in plan['inputs'].items() if path.endswith('/scoped-read-v1/'+name)]
        assert candidates==[sha(HERE/name)], 'executed source differs: '+name
    canonical='/workspace/formal-proofs/bendvy/src/ecs/capabilities.bend'
    assert plan['inputs'][canonical]==sha(HERE/'evidence/canonical-capabilities.bend.snapshot')
    if role=='native-1':
        assert receipt['commands'][-1]['argv'][-4:]==['--threads','1','--gpu','off']
print('PASS: both full reader observations, complete returned owner/sentinel and independent owned output in JS/Native')
