"""No-child complete source-derived DTO and exact-plan admission controls."""
import copy,hashlib,importlib.util,json
from pathlib import Path
import transport
HERE=Path(__file__).resolve().parent
O=Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-owned-events/system-event-v1/generic-v1/oracle-v1')
s=importlib.util.spec_from_file_location('declaration_run',HERE/'development-run.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
def nochild(*a,**kw):raise RuntimeError('unexpected child launch')
m.task_runner.Runner.run=nochild
for role in ('full','second'):
 expected=json.loads((O/(role+'-expected.json')).read_text());raw=(O/(role+'-expected.stdout')).read_bytes()
 assert transport.parse(role,raw)==expected and (transport.render(role,expected)+'\n').encode()==raw
 for changed in (raw[:-1],raw+b'\n',raw.replace(b'Batch{' if role=='full' else b'Report{',b'Unknown{',1)):
  try:transport.parse(role,changed)
  except (AssertionError,ValueError):pass
  else:raise AssertionError('malformed DTO accepted')
 altered=copy.deepcopy(expected)
 if role=='full':altered['standard']['Trace']['snapshots'][-1]['state']['refused'][0]['payload']['sentinel'][-1]+=1
 else:altered['refused']['Refused']['args'][-1]+=1
 changed=(transport.render(role,altered)+'\n').encode();assert transport.parse(role,changed)!=expected and changed!=raw
 out=Path('/tmp/bendvy-generic-system-'+role+'-js');plan=out/'plan.json';original=plan.read_bytes();digest=hashlib.sha256(original).hexdigest()
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
print('PASS full independent generic full/second System-owner DTO roundtrips, malformed/owner mutations and digest/interpreter drift refusals; no child')
