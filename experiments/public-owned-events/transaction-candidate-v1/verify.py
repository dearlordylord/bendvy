"""No-child whole development joins; historical failed oracle remains a failure."""
import hashlib
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
revised=HERE/'evidence/expected-v2.stdout'
assert sha(revised)=='4df56e7cd82baf2731d4ef1bedc49ff57872ac34521faa2d856a6eb9d5761ce5'
assert sha(HERE/'evidence/expected-v2.json')=='88a831432428c592da2d3e2029233c22ba31a12b56e5dbb25722868103431faf'
old=HERE/'evidence/js-1/executed-expected.stdout'
assert sha(old)=='1d96981b418539133c65f3216f086411bd5d84dd510d994641a4ed6366dd98dd'
for role in ('js-1','native-1'):
 folder=HERE/'evidence'/role
 plan=json.loads((folder/'plan.json').read_text())
 receipt=json.loads((folder/'receipt.json').read_text())
 assert receipt.get('guardFailures',[])==[]
 assert [r['capSeconds'] for r in receipt['commands']]==([30,5] if role=='js-1' else [30,120,5])
 assert all(r['exit']==0 and r['failure'] is None for r in receipt['commands'])
 assert all(r['argv'][:3]==['/usr/bin/taskset','-c','5'] for r in receipt['commands'])
 for name,digest in receipt['logs'].items():assert sha(folder/'raw'/name)==digest
 actual=(folder/'raw/complete-run.stdout').read_bytes()
 assert actual==revised.read_bytes()
 assert (folder/'raw/complete-run.stderr').read_bytes()==b''
 for name in ('adapter.bend','controls.bend','observation.bend','main.bend'):
  assert [v for k,v in plan['inputs'].items() if k.endswith('/transaction-candidate-v1/'+name)]==[sha(HERE/name)]
 runner=folder/'executed-run.py' if role=='js-1' else HERE/'development-run.py'
 assert [v for k,v in plan['inputs'].items() if k.endswith('/transaction-candidate-v1/development-run.py')]==[sha(runner)]
 if role=='js-1':
  assert actual!=old.read_bytes()
  assert receipt['status']=='INCOMPLETE'
  assert receipt['error']=='AssertionError: complete observation differs from pre-run oracle'
  assert plan['inputs']['/workspace/formal-proofs/bendvy/experiments/public-owned-events/transaction-candidate-v1/oracle-v1/expected.stdout']==sha(old)
 else:
  assert receipt['status']=='DEVELOPMENT_PASS'
  assert plan['inputs']['/workspace/formal-proofs/bendvy/experiments/public-owned-events/transaction-candidate-v1/oracle-v1/expected-v2.stdout']==sha(revised)
  assert receipt['commands'][-1]['argv'][-4:]==['--threads','1','--gpu','off']
# The two executed cohorts pin identical entire source/module closure excluding
# intentional oracle/runner/environment paths and installed-tool/resource members.
a=json.loads((HERE/'evidence/js-1/plan.json').read_text())['inputs']
b=json.loads((HERE/'evidence/native-1/plan.json').read_text())['inputs']
a={k:v for k,v in a.items() if k.endswith('.bend')}
b={k:v for k,v in b.items() if k.endswith('.bend')}
assert a==b
print('PASS: complete JS/Native source/oracle/raw joins; original failed JS oracle preserved')
