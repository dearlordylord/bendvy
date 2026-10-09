"""No-child complete registered-reader development evidence joins, not delivery qualification."""
import hashlib
import json
from pathlib import Path
import transport
HERE=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
expected=HERE/'evidence/executed-expected.json'
expected_raw=HERE/'evidence/executed-expected.stdout'
assert sha(expected)=='44c426ff710c81465ab71a0c0dc79a3ddba6ddedffa6b9030761fd5291a411d7'
assert sha(expected_raw)=='c718208ce87fb64e844f8ae0687e1d7cbd82fbc4cf9b2e47228635f8811f03a4'
executed_js=json.loads((HERE/'evidence/js-1/plan.json').read_text())
transport.ENTRY=Path(executed_js['commands'][0]['argv'][4]) # preserve original executed namespace after integration
full=json.loads(expected.read_text());assert transport.parse(expected_raw.read_bytes())==full
closures=[]
for role,digest in [('js-1','5d7501d142f499c4576352c63a1a148928d84d8416397b9c872795c983ac0134'),('native-1','1ca94ffc2ae6013195c9a28d05af335b8055efd25e7afd245d69738cf0327a86')]:
 folder=HERE/'evidence'/role;plan_file=folder/'plan.json'
 assert sha(plan_file)==digest
 plan=json.loads(plan_file.read_text());receipt=json.loads((folder/'receipt.json').read_text())
 assert receipt['preparedPlanSha256']==digest and receipt['status']=='DEVELOPMENT_PASS'
 assert receipt.get('guardFailures',[])==[] and 'error' not in receipt
 assert [r['capSeconds'] for r in receipt['commands']]==([30,5] if role=='js-1' else [30,120,5])
 assert len(receipt['commands'])==len(plan['commands'])
 for command,declared in zip(receipt['commands'],plan['commands']):
  assert command['exit']==0 and command['failure'] is None
  assert all(command[k]==declared[k] for k in declared)
  assert command['argv'][:3]==['/usr/bin/taskset','-c','5']
 assert plan['tools']['python'] in plan['inputs']
 for name,digest in receipt['logs'].items():
  path=folder/'raw'/name;assert path.is_file() and not path.is_symlink() and sha(path)==digest
 assert {p.name for p in (folder/'raw').iterdir()}==set(receipt['logs'])
 assert all((folder/'raw'/r['label']).with_suffix('.stderr').read_bytes()==b'' for r in receipt['commands'])
 actual=(folder/'raw/complete-run.stdout').read_bytes()
 assert len(actual)==35254 and actual==expected_raw.read_bytes() and transport.parse(actual)==full
 for name in ('main.bend','fixture.bend','log.bend','observation.bend','direct-controls.bend','transport.py','development-run.py'):
  assert [v for k,v in plan['inputs'].items() if k.endswith('/registered-read-v1/'+name)]==[sha(HERE/name)]
 assert [v for k,v in plan['inputs'].items() if k.endswith('/registered-read-v1/oracle-v1/expected.json')]==[sha(expected)]
 assert [v for k,v in plan['inputs'].items() if k.endswith('/registered-read-v1/oracle-v1/expected.stdout')]==[sha(expected_raw)]
 if role=='native-1':assert receipt['commands'][-1]['argv'][-4:]==['--threads','1','--gpu','off']
 closures.append({k:v for k,v in plan['inputs'].items() if k.endswith('.bend')})
assert closures[0]==closures[1]
print('PASS exact admitted plans, complete identical JS/Native35254-byte observations, source/transport/oracle/raw joins; no child')
