#!/usr/bin/env python3
"""Code-entry sentinel controls for the existing collector; no backend children."""
import builtins,hashlib,importlib.util,json,sys,tempfile
from pathlib import Path
native='--native' in sys.argv
collector=Path(__file__).resolve().parents[2]/('adoption-v1/qualification-v1/spine-report-v1/native-from-c.py' if native else 'adoption-v1/qualification-v1/spine-report-v1/development-run.py')
collector=collector.resolve()
eager=[];original_import=builtins.__import__
def guarded_import(name,*args,**kwargs):
 if name in ('task_runner','evidence_boundary'):
  eager.append(name);raise AssertionError('repository helper executed during module entry')
 return original_import(name,*args,**kwargs)
builtins.__import__=guarded_import
try:
 spec=importlib.util.spec_from_file_location('decode_bootstrap_control',collector);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
finally:builtins.__import__=original_import
assert not eager
with tempfile.TemporaryDirectory() as directory:
 home=Path(directory).resolve();module.ROOT=home;helpers=home/'scripts';helpers.mkdir();marker=home/'helper-executed'
 runner=helpers/'task_runner.py';boundary=helpers/'evidence_boundary.py'
 runner.write_text('from pathlib import Path\nPath('+repr(str(marker))+').write_text("EXECUTED")\nraise RuntimeError("POSITIVE_HELPER_ENTRY_SENTINEL")\n')
 boundary.write_text('raise RuntimeError("boundary entered")\n')
 python=Path(sys.executable).resolve()
 def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
 plan={'native':native,'role':'normal','tools':{'python':str(python)},'inputs':{str(p):sha(p) for p in (collector,runner,boundary,python)}}
 out=home/'out';out.mkdir();path=out/'plan.json'
 def call(value,digest_override=None):
  path.write_text(json.dumps(value));digest=sha(path)
  try:module.main(out,native=native,execute=True,plan_digest=digest_override or digest)
  except (AssertionError,RuntimeError) as error:return str(error)
  raise AssertionError('unexpected collector completion')
 wrong_python=json.loads(json.dumps(plan));wrong_python['tools']['python']='/wrong/python'
 assert 'interpreter path differs' in call(wrong_python) and not marker.exists()
 assert 'prepared-plan digest differs' in call(plan,'0'*64) and not marker.exists()
 original=runner.read_bytes();runner.write_bytes(original+b'# drift\n')
 assert 'pinned file drift' in call(plan) and not marker.exists();runner.write_bytes(original)
 missing=json.loads(json.dumps(plan));del missing['inputs'][str(runner)]
 assert 'helper pins missing' in call(missing) and not marker.exists()
 assert 'POSITIVE_HELPER_ENTRY_SENTINEL' in call(plan) and marker.read_text()=='EXECUTED'
print(json.dumps({'status':'PASS','native':native,'stdlibOnlyModuleEntry':True,'wrongPythonNoHelperEntry':True,'wrongPlanNoHelperEntry':True,'pinDriftNoHelperEntry':True,'missingHelperPinNoHelperEntry':True,'positiveHelperEntryReached':True,'backendChildren':0}))
