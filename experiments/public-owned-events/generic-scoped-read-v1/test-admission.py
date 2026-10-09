"""No-child execution admission refusals against an existing unexecuted prepared JS cohort."""
import hashlib
import importlib.util
import json
import sys
from pathlib import Path
p=Path(__file__).resolve().parent/'development-run.py'
spec=importlib.util.spec_from_file_location('owned_run',p);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
out=Path(sys.argv[1]).resolve();path=out/'plan.json';original=path.read_bytes();digest=hashlib.sha256(original).hexdigest()
plan=json.loads(original);python=str(Path(sys.executable).resolve())
assert plan['tools']['python']==python and python in plan['inputs']
def no_child(*args,**kwargs):raise RuntimeError('unexpected child launch')
m.task_runner.Runner.run=no_child
try:
 m.main(out,False,True,'0'*64)
except AssertionError as error:assert str(error)=='prepared-plan digest differs'
else:raise AssertionError('wrong digest accepted')
# Self-consistent changed plan digest cannot rebind current interpreter source bytes.
changed=json.loads(original);changed['inputs'][python]='0'*64
path.write_text(json.dumps(changed,indent=2)+'\n')
try:
 try:m.main(out,False,True,hashlib.sha256(path.read_bytes()).hexdigest())
 except AssertionError as error:assert str(error)=='prepared cohort source/tool/environment/commands differ'
 else:raise AssertionError('tool drift accepted')
finally:path.write_bytes(original)
assert path.read_bytes()==original and not (out/'receipt.json').exists()
assert not any((out/'raw').iterdir()) and not any((out/'generated').iterdir())
print('PASS explicit wrong digest and self-consistent interpreter-pin drift refuse before child; exact prepared bytes restored')
