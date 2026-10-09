"""No-child complete source-derived DTO and exact-plan admission controls."""
import copy,hashlib,importlib.util,json
from pathlib import Path
import transport
HERE=Path(__file__).resolve().parent
O=Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-owned-events/declaration-read-v1/oracle-v1')
s=importlib.util.spec_from_file_location('declaration_run',HERE/'development-run.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
def nochild(*a,**kw):raise RuntimeError('unexpected child launch')
m.task_runner.Runner.run=nochild
for role in ('generic','registered'):
 expected=json.loads((O/(role+'-expected.json')).read_text());raw=(O/(role+'-expected.stdout')).read_bytes()
 assert transport.parse(role,raw)==expected and (transport.render(role,expected)+'\n').encode()==raw
 for changed in (raw[:-1],raw+b'\n',raw.replace(b'Report{' if role=='generic' else b'Batch{',b'Unknown{',1)):
  try:transport.parse(role,changed)
  except (AssertionError,ValueError):pass
  else:raise AssertionError('malformed DTO accepted')
 altered=copy.deepcopy(expected)
 if role=='generic':altered['observations']['payload']['sentinel'][-1]+=1
 else:altered['standard']['Trace']['snapshots'][-1]['refused'][0]['payload']['sentinel'][-1]+=1
 changed=(transport.render(role,altered)+'\n').encode();assert transport.parse(role,changed)!=expected and changed!=raw
 out=Path('/tmp/bendvy-declaration-'+role+'-js');plan=out/'plan.json';original=plan.read_bytes();digest=hashlib.sha256(original).hexdigest()
 try:m.main(out,False,True,'0'*64,role)
 except AssertionError as e:assert str(e)=='prepared-plan digest differs'
 else:raise AssertionError('wrong digest accepted')
 # A fresh self-authored digest cannot change the frozen interpreter pin.
 data=json.loads(original);data['inputs'][data['tools']['python']]='0'*64;plan.write_text(json.dumps(data,indent=2)+'\n')
 try:
  try:m.main(out,False,True,hashlib.sha256(plan.read_bytes()).hexdigest(),role)
  except AssertionError as e:assert str(e)=='prepared cohort source/tool/environment/commands differ'
  else:raise AssertionError('interpreter drift accepted')
 finally:plan.write_bytes(original)
 assert plan.read_bytes()==original and not (out/'receipt.json').exists() and not any((out/'raw').iterdir()) and not any((out/'generated').iterdir())
print('PASS both full independent generic/registered DTO roundtrips, malformed/owner mutations and digest/interpreter drift refusals; no child')
