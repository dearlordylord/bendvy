"""No-child actual reached retirement-loss whole observations and source/plan joins."""
import hashlib
import importlib.util
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent;BASE=HERE.parents[1];E=HERE/'evidence';F=E/'js-1'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
plan_file=F/'plan.json';plan=json.loads(plan_file.read_text());receipt=json.loads((F/'receipt.json').read_text())
assert sha(plan_file)=='0ba184479007d5bc47587fbcbef229b38fbe3004e25061657eb207156b851d2c'
assert receipt['preparedPlanSha256']==sha(plan_file) and receipt['status']=='DEVELOPMENT_PASS'
assert receipt.get('guardFailures',[])==[] and 'error' not in receipt
s=importlib.util.spec_from_file_location('retired_transport',BASE/'transport.py');t=importlib.util.module_from_spec(s);s.loader.exec_module(t)
t.ENTRY=Path(plan['commands'][0]['argv'][4]) # retain executed entry namespace; no rebinding
hashes={'expected.json':'3251dbc97d93263955074743be03b01b19166593d07dfaae3fc7ecb734aaf6d4','expected.stdout':'f00d5689f878326dadf13193a99024c74f3a52427469188a55398addba19df57','baseline-relocated.json':'44c426ff710c81465ab71a0c0dc79a3ddba6ddedffa6b9030761fd5291a411d7','baseline-relocated.stdout':'3072e802a94edc748b01c84b4d9e8b29857d82447c69863e8b68a2eee52927b4'}
for name,digest in hashes.items():
 assert sha(E/name)==digest
 assert [v for k,v in plan['inputs'].items() if k.endswith('/oracle-v1/retirement-loss-v1/'+name)]==[digest]
expected=json.loads((E/'expected.json').read_text());baseline=json.loads((E/'baseline-relocated.json').read_text())
for name,value in [('expected.stdout',expected),('baseline-relocated.stdout',baseline)]:
 assert t.parse((E/name).read_bytes())==value and (t.render('Batch',value)+'\n').encode()==(E/name).read_bytes()
actual=(F/'raw/complete-run.stdout').read_bytes()
assert len(actual)==35716 and actual==(E/'expected.stdout').read_bytes() and t.parse(actual)==expected
assert actual!=(E/'baseline-relocated.stdout').read_bytes() and t.parse(actual)!=baseline
assert [r['capSeconds'] for r in receipt['commands']]==[30,5]
for row,command in zip(receipt['commands'],plan['commands']):
 assert row['exit']==0 and row['failure'] is None and all(row[k]==v for k,v in command.items())
 assert row['argv'][:3]==['/usr/bin/taskset','-c','5']
 assert (F/'raw'/(row['label']+'.stderr')).read_bytes()==b''
assert len(receipt['commands'])==len(plan['commands'])==2
assert {p.name for p in (F/'raw').iterdir()}==set(receipt['logs'])
for name,digest in receipt['logs'].items():
 p=F/'raw'/name;assert p.is_file() and not p.is_symlink() and sha(p)==digest
for name in ('main.bend','fixture.bend','observation.bend','direct-controls.bend','log.bend','development-run.py'):
 assert [v for k,v in plan['inputs'].items() if k.endswith('/mutants/retirement-loss-v1/'+name)]==[sha(HERE/name)]
assert [v for k,v in plan['inputs'].items() if k.endswith('/registered-read-v1/transport.py')]==[sha(BASE/'transport.py')]
delta=json.loads((HERE/'source-delta.json').read_text())
for name,row in delta['files'].items():assert sha(BASE/name)==row['baselineSha256'] and sha(HERE/name)==row['mutantSha256']
assert (BASE/'fixture.bend').read_bytes().replace(delta['exactBefore'].encode(),delta['exactAfter'].encode())==(HERE/'fixture.bend').read_bytes()
print('PASS reached actual JS retirement-loss35716 full counterfactual, full unchanged baseline rejected, exact source/plan/oracle/raw joins; no child')
