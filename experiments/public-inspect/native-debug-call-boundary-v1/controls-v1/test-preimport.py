"""No child: changed source and alternate interpreter refused before helper import."""
from pathlib import Path
import types,json,tempfile,hashlib,sys
sys.dont_write_bytecode=True
p=Path(__file__).resolve().parent
m=types.ModuleType('execution');m.__file__=str(p/'execution.py');exec(compile(Path(m.__file__).read_bytes(),m.__file__,'exec'),m.__dict__)
def forbidden(*args):raise AssertionError('helper imported before refusal')
m.load=forbidden
with tempfile.TemporaryDirectory(prefix='bendvy-debug56-boundary-preimport-') as d:
 root=Path(d);python=str(Path(sys.executable).resolve());taskset='/usr/bin/taskset';pins={python:m.sha(python),taskset:m.sha(taskset)}
 for name,tools,changed in [('wrong-python',{'python':taskset},False),('wrong-pin',{'python':python},True)]:
  plan={'pins':dict(pins),'tools':tools}
  if changed:plan['pins'][taskset]='0'*64
  path=root/(name+'.json');path.write_text(json.dumps(plan));admitted=m.sha(path)
  try:m.run(path,admitted)
  except ValueError as e:
   expected='preimport pins drift' if changed else 'actual interpreter drift'
   assert str(e)==expected
  else:raise AssertionError('preimport refusal absent')
  assert not (root/'receipt.json').exists()
print('PREIMPORT_REFUSALS_PASS: two controls, no helper import/child')
