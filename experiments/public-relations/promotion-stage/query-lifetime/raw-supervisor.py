"""Raw merged pipe capture with the reviewed owned-descendant policy.

stdout contains raw combined stdout/stderr; stderr is explicitly empty. This
preserves merged child bytes rather than claiming separated stream capture.
"""
import os,subprocess
import supervisor

def execute(command,timeout,env=None):
 supervisor.enable_subreaper();prior=supervisor.child_pids(os.getpid())
 process=subprocess.Popen(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,start_new_session=True,env=env)
 try:output,_=process.communicate(timeout=timeout)
 except subprocess.TimeoutExpired:
  failure=None
  try:supervisor.cleanup_owned(process.pid,prior)
  except Exception as error:failure=repr(error)
  try:output,_=process.communicate(timeout=1)
  except subprocess.TimeoutExpired:output=b'finite cleanup did not close child pipes'
  return {'exit':None,'failure':'child deadline; cleanup='+str(failure),'stdout':output,'stderr':b''}
 if supervisor.child_pids(os.getpid())-prior:
  supervisor.cleanup_owned(process.pid,prior)
  return {'exit':process.returncode,'failure':'child left owned descendants; no passing result','stdout':output,'stderr':b''}
 return {'exit':process.returncode,'failure':None,'stdout':output,'stderr':b''}
