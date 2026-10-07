"""Separate raw streams using the reviewed owned-descendant supervisor cleanup."""
import pathlib, os, subprocess, sys
ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'experiments/s-prep/fivehour-connected-gates'))
import supervisor

def execute(command, timeout, env):
    env=dict(env,BEND_NO_TELEMETRY='1')
    supervisor.enable_subreaper()
    prior = supervisor.child_pids(os.getpid())
    child = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True, env=env)
    try:
        stdout, stderr = child.communicate(timeout=timeout)
    except subprocess.TimeoutExpired:
        failure = None
        try:
            supervisor.cleanup_owned(child.pid, prior)
        except Exception as error:
            failure = repr(error)
        try:
            stdout, stderr = child.communicate(timeout=1)
        except subprocess.TimeoutExpired:
            stdout, stderr = b'', b'finite cleanup did not close pipes'
        raise TimeoutError('deadline; cleanup=' + str(failure) + '; stderr=' + repr(stderr[-2000:]))
    if supervisor.child_pids(os.getpid()) - prior:
        supervisor.cleanup_owned(child.pid, prior)
        raise RuntimeError('child left owned descendants; no passing result')
    return subprocess.CompletedProcess(command, child.returncode, stdout, stderr)
