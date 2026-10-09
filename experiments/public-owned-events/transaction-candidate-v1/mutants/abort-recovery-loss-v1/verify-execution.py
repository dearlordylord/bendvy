"""No-child exact reached transaction mutation/source/raw/whole oracle joins."""
import hashlib
import json
import runpy
from pathlib import Path
HERE=Path(__file__).resolve().parent
runpy.run_path(str(HERE/'verify.py'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
folder=HERE/'evidence/js-1'
plan=json.loads((folder/'plan.json').read_text())
receipt=json.loads((folder/'receipt.json').read_text())
join=json.loads((HERE/'SOURCE-JOIN.json').read_text())
assert receipt['status']=='MUTANT_DETECTED'
assert receipt.get('guardFailures',[])==[]
assert [r['capSeconds'] for r in receipt['commands']]==[30,5]
assert all(r['exit']==0 and r['failure'] is None for r in receipt['commands'])
assert all(r['argv'][:3]==['/usr/bin/taskset','-c','5'] for r in receipt['commands'])
assert receipt['commands'][0]['argv'][4]==join['entry']
for name,digest in receipt['logs'].items():assert sha(folder/'raw'/name)==digest
actual=(folder/'raw/complete-run.stdout').read_bytes()
assert actual==(HERE/'counterfactual.stdout').read_bytes()
assert actual!=(HERE/'baseline.stdout').read_bytes()
assert (folder/'raw/complete-run.stderr').read_bytes()==b''
for path,digest in join['files'].items():assert plan['inputs'][path]==digest
for name in ('SOURCE-JOIN.json','verify.py','development-run.py'):
 assert [v for k,v in plan['inputs'].items() if k.endswith('/abort-recovery-loss-v1/'+name)]==[sha(HERE/name)]
print('PASS: actual canonical-transaction abort-loss mutant rejected by complete unchanged oracle and matches whole counterfactual')
