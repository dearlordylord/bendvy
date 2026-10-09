"""No-child full source/independent counterfactual/relocated baseline/admission joins."""
import hashlib
import importlib.util
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent;BASE=HERE.parents[1]
def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
transport=load('retire_transport',BASE/'transport.py');transport.ENTRY=HERE/'main.bend'
O=Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-owned-events/registered-read-v1/oracle-v1/retirement-loss-v1')
expected=json.loads((O/'expected.json').read_text());baseline=json.loads((O/'baseline-relocated.json').read_text())
assert sha(O/'expected.json')=='3251dbc97d93263955074743be03b01b19166593d07dfaae3fc7ecb734aaf6d4'
assert sha(O/'expected.stdout')=='f00d5689f878326dadf13193a99024c74f3a52427469188a55398addba19df57'
assert sha(O/'baseline-relocated.json')=='44c426ff710c81465ab71a0c0dc79a3ddba6ddedffa6b9030761fd5291a411d7'
assert sha(O/'baseline-relocated.stdout')=='3072e802a94edc748b01c84b4d9e8b29857d82447c69863e8b68a2eee52927b4'
for value,file in [(expected,'expected.stdout'),(baseline,'baseline-relocated.stdout')]:
 raw=(O/file).read_bytes();assert transport.parse(raw)==value and (transport.render('Batch',value)+'\n').encode()==raw
count=0
for key in ('standard','capacity'):
 for a,b in zip(expected[key]['Trace']['snapshots'],baseline[key]['Trace']['snapshots']):
  if a!=b:
   assert a['retired']==b['retired'][1:] and {k:v for k,v in a.items() if k!='retired'}=={k:v for k,v in b.items() if k!='retired'}
   count+=1
assert count==6
assert {k:v for k,v in expected.items() if k not in ('standard','capacity')}=={k:v for k,v in baseline.items() if k not in ('standard','capacity')}
delta=json.loads((HERE/'source-delta.json').read_text())
for name,row in delta['files'].items():
 assert sha(BASE/name)==row['baselineSha256'] and sha(HERE/name)==row['mutantSha256']
 if name!='fixture.bend':assert (BASE/name).read_bytes()==(HERE/name).read_bytes()
assert (BASE/'fixture.bend').read_bytes().replace(delta['exactBefore'].encode(),delta['exactAfter'].encode())==(HERE/'fixture.bend').read_bytes()
runner=load('retire_runner',HERE/'development-run.py');plan=HERE/'evidence/prepared-js-plan.json'
assert sha(plan)=='0ba184479007d5bc47587fbcbef229b38fbe3004e25061657eb207156b851d2c'
try:runner.admitted_plan(plan,'0'*64)
except AssertionError:pass
else:raise AssertionError('wrong plan digest accepted')
assert runner.admitted_plan(plan,sha(plan))['oracleCommit']=='af9fcfc2'
print('PASS full independent counterfactual35716/raw and baseline36190/raw, exactly six retirement-owner losses, sole source delta, wrong digest refusal; no child')
