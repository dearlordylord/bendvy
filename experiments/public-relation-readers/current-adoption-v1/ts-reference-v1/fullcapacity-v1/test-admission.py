"""Portable no-child controls: isolated metadata only, never admitted cohorts."""
import copy,hashlib,importlib.util,json,sys,tempfile,types
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('candidate',HERE/'run.py')
R=importlib.util.module_from_spec(spec)
exec(compile((HERE/'run.py').read_bytes(),str(HERE/'run.py'),'exec'),R.__dict__)
class RuntimeReached(RuntimeError):pass
count=0
with tempfile.TemporaryDirectory(prefix='rel43-admission-')as directory:
    root=Path(directory);R.ROOT=root
    helpers={
      root/'scripts/task_runner.py':'marker="verified runner source"\n',
      root/'scripts/evidence_boundary.py':'class ReceiptBoundary:pass\nclass GuardBoundary:pass\n',
      root/'scripts/receipt-logs.py':'marker="verified logs source"\n',
      root/'experiments/public-restore/reference-v1/run.py': 'def strict(a,b):\n    assert type(a)is type(b)\n    assert a==b\n'}
    for path,raw in helpers.items():path.parent.mkdir(parents=True,exist_ok=True);path.write_text(raw)
    resources=root/'resource';resources.mkdir();(resources/'member').write_text('frozen\n')
    python=Path(sys.executable).resolve();files=[HERE/'run.py',python,*helpers]
    plan={'tools':{'python':str(python)},'executorSHA256':R.sha(python),'helperSHA256':R.sha(HERE/'run.py'),'files':[str(p)for p in files],'directories':[str(resources)],'inputs':{str(p):R.sha(p)for p in files}}
    plan['inputs'][str(resources)]=R.inventory(resources)
    def admitted(value):
        path=root/'plan.json';path.write_text(json.dumps(value));return path,R.sha(path)
    def sentinel(*args):raise RuntimeReached('Repository runtime reached')
    exact_runtime=R.runtime;R.runtime=sentinel
    path,digest=admitted(plan)
    try:R.run(path,digest)
    except RuntimeReached:count+=1
    else:raise AssertionError('Valid metadata did not reach runtime sentinel')
    def refuse(value,digest_override=None):
        global count
        path,digest=admitted(value)
        try:R.run(path,digest_override or digest)
        except AssertionError:count+=1
        else:raise AssertionError('Invalid metadata accepted')
        # RuntimeReached deliberately escapes: testing bootstrap alone is insufficient.
    refuse(plan,'0'*64)
    for key in ['executorSHA256','helperSHA256']:
        changed=copy.deepcopy(plan);changed[key]='0'*64;refuse(changed)
    for filename in list(helpers)[:3]:
        changed=copy.deepcopy(plan);changed['inputs'][str(filename)]='0'*64;refuse(changed)
    extra=resources/'added';extra.write_text('unplanned\n')
    try:refuse(plan)
    finally:extra.unlink()
    helper=next(iter(helpers));original=helper.read_bytes();helper.write_bytes(original+b'changed=True\n')
    try:refuse(plan)
    finally:helper.write_bytes(original)
    R.runtime=exact_runtime
    verified=R.bootstrap(plan)
    names=['task_runner','evidence_boundary','ts_exact_task_runner','ts_exact_boundary','ts_exact_logs']
    previous={name:sys.modules.get(name)for name in names}
    try:
        for name in names:
            alternate=types.ModuleType(name);alternate.marker='unverified cached module';sys.modules[name]=alternate
        runner,boundary,_,logs,strict=R.runtime(verified)
        assert runner.marker=='verified runner source' and logs.marker=='verified logs source'
        assert boundary.__module__=='ts_exact_boundary'
        strict(1,1)
        try:strict(False,0)
        except AssertionError:pass
        else:raise AssertionError('Comparator type boundary lost')
        count+=1
    finally:
        for name,value in previous.items():
            if value is None:sys.modules.pop(name,None)
            else:sys.modules[name]=value
assert count==10,count
print('Ten portable no-child real-run bootstrap and exact-source cached-module controls PASS')
