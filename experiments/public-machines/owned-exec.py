"""Raw file-backed capture using the actual reviewed owned cleanup module."""
import importlib.util,os,pathlib,subprocess
ROOT=pathlib.Path(__file__).resolve().parents[2]
PATH=ROOT/'experiments/s-prep/fivehour-connected-gates/supervisor.py'
spec=importlib.util.spec_from_file_location('machine_shared_cleanup',PATH)
cleanup=importlib.util.module_from_spec(spec);spec.loader.exec_module(cleanup)
def execute(command,cap,env,stdout_path,stderr_path):
 assert not stdout_path.exists() and not stderr_path.exists(),'prospective capture absence'
 cleanup.enable_subreaper();prior=cleanup.child_pids(os.getpid());timed_out=False;failure=None;descendants_remained=False
 with stdout_path.open('xb') as stdout,stderr_path.open('xb') as stderr:
  child=subprocess.Popen(command,stdout=stdout,stderr=stderr,start_new_session=True,env=dict(env,BEND_NO_TELEMETRY='1'))
  try:child.wait(timeout=cap)
  except subprocess.TimeoutExpired:
   timed_out=True
   try:cleanup.cleanup_owned(child.pid,prior)
   except Exception as error:failure=repr(error)
   try:child.wait(timeout=1)
   except subprocess.TimeoutExpired:failure='cleanup did not terminate direct child; '+str(failure)
  if cleanup.child_pids(os.getpid())-prior:
   descendants_remained=True
   try:cleanup.cleanup_owned(child.pid,prior)
   except Exception as error:failure=repr(error)
 if failure:raise RuntimeError('owned cleanup failure; raw captures retained: '+failure)
 result=subprocess.CompletedProcess(command,124 if timed_out else 125 if descendants_remained else child.returncode,stdout_path.read_bytes(),stderr_path.read_bytes())
 result.direct_returncode=child.returncode
 result.inconclusive_reason='deadline' if timed_out else 'surviving owned descendants after direct child exit' if descendants_remained else None
 return result
