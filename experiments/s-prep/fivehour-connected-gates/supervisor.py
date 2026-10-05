"""Bounded owned-descendant supervision, copied from reviewed measurement guard.
No compiler, measurement or approval behavior is imported.
"""
import pathlib,os,signal,subprocess
def child_pids(pid):
    result=set();tasks=pathlib.Path('/proc')/str(pid)/'task'
    if tasks.exists():
        for task in tasks.iterdir():
            try:result.update(int(x) for x in (task/'children').read_text().split())
            except FileNotFoundError:pass
    return result

def enable_subreaper():
    import ctypes
    if ctypes.CDLL(None,use_errno=True).prctl(36,1,0,0,0)!=0:raise OSError('cannot establish owned child subreaper')

def kill_descendants(pid):
    """Stop each parent before enumerating children; pin process identities."""
    import os,signal,time
    pending=[pid];owned=[];seen=set();end=time.monotonic()+1
    while pending and time.monotonic()<end:
        current=pending.pop()
        if current in seen:continue
        seen.add(current)
        try:
            descriptor=os.pidfd_open(current);signal.pidfd_send_signal(descriptor,signal.SIGSTOP)
        except ProcessLookupError:continue
        owned.append(descriptor)
        # Confirm the parent stopped before reading its child set.
        while time.monotonic()<end:
            try:state=(pathlib.Path('/proc')/str(current)/'stat').read_text().rsplit(')',1)[1].split()[0]
            except FileNotFoundError:break
            if state in ('T','t','Z','X'):break
            time.sleep(.001)
        pending.extend(child_pids(current))
    for descriptor in reversed(owned):
        try:signal.pidfd_send_signal(descriptor,signal.SIGKILL)
        except ProcessLookupError:pass
        finally:os.close(descriptor)

def cleanup_owned(pid,prior=()):
    """Subreaper-owned orphans are included; unrelated prior children spared."""
    import os,time
    if pid in child_pids(os.getpid())-set(prior):kill_descendants(pid)
    end=time.monotonic()+1
    while time.monotonic()<end:
        owned=child_pids(os.getpid())-set(prior)
        if not owned:return
        for child in owned:kill_descendants(child)
        for child in owned:
            try:os.waitpid(child,os.WNOHANG)
            except ChildProcessError:pass
        time.sleep(.001)
    if child_pids(os.getpid())-set(prior):raise TimeoutError('owned descendants did not terminate within finite cleanup')

def execute(command,timeout,env=None):
 enable_subreaper();prior=child_pids(os.getpid());process=subprocess.Popen(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env)
 try:output,_=process.communicate(timeout=timeout)
 except subprocess.TimeoutExpired:
  failure=None
  try:cleanup_owned(process.pid,prior)
  except Exception as error:failure=repr(error)
  try:output,_=process.communicate(timeout=1)
  except subprocess.TimeoutExpired:output='finite cleanup did not close child pipes'
  raise TimeoutError('child deadline; cleanup='+str(failure)+'; output='+output[-2000:])
 if child_pids(os.getpid())-prior:
  cleanup_owned(process.pid,prior);raise RuntimeError('child left owned descendants; no passing result')
 return process.returncode,output
