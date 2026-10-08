"""Linux command ownership, raw capture and reusable evidence checks."""
import ctypes
import hashlib
import math
import multiprocessing
import os
from pathlib import Path
import signal
import subprocess
import time


IMPLEMENTATION = Path(__file__).resolve()
IMPLEMENTATION_SHA256 = hashlib.sha256(IMPLEMENTATION.read_bytes()).hexdigest()

def _implementation_guard():
    if hashlib.sha256(IMPLEMENTATION.read_bytes()).hexdigest() != IMPLEMENTATION_SHA256:
        raise RuntimeError('runner implementation changed after import')


def child_pids(pid):
    result = set()
    tasks = Path('/proc') / str(pid) / 'task'
    if tasks.exists():
        for task in tasks.iterdir():
            try:
                result.update(map(int, (task / 'children').read_text().split()))
            except FileNotFoundError:
                pass
    return result


def enable_subreaper():
    if ctypes.CDLL(None, use_errno=True).prctl(36, 1, 0, 0, 0) != 0:
        raise OSError(ctypes.get_errno(), 'cannot establish command subreaper')


def kill_descendants(pid):
    pending, descriptors, seen = [pid], [], set()
    end = time.monotonic() + 1
    try:
        while pending and time.monotonic() < end:
            current = pending.pop()
            if current in seen:
                continue
            seen.add(current)
            try:
                fd = os.pidfd_open(current)
            except ProcessLookupError:
                continue
            descriptors.append(fd)
            try:
                signal.pidfd_send_signal(fd, signal.SIGSTOP)
            except ProcessLookupError:
                continue
            while time.monotonic() < end:
                try:
                    state = (Path('/proc') / str(current) / 'stat').read_text().rsplit(')', 1)[1].split()[0]
                except FileNotFoundError:
                    break
                if state in ('T', 't', 'Z', 'X'):
                    break
                time.sleep(.001)
            pending.extend(child_pids(current))
    finally:
        for fd in reversed(descriptors):
            try:
                signal.pidfd_send_signal(fd, signal.SIGKILL)
            except ProcessLookupError:
                pass
            finally:
                os.close(fd)


def cleanup_owned(pid=None, prior=()):
    prior = set(prior)
    if pid in child_pids(os.getpid()) - prior:
        kill_descendants(pid)
    end = time.monotonic() + 1
    while time.monotonic() < end:
        owned = child_pids(os.getpid()) - prior
        if not owned:
            return
        for child in owned:
            kill_descendants(child)
        for child in owned:
            try:
                os.waitpid(child, os.WNOHANG)
            except ChildProcessError:
                pass
        time.sleep(.001)
    if child_pids(os.getpid()) - prior:
        raise TimeoutError('owned descendants did not terminate')


class _Cancelled(BaseException):
    pass


def _worker(connection, command, timeout, env, cwd, capture):
    # Only this worker adopts command orphans. Sibling commands and the caller's
    # children never enter its ownership set, including concurrently born ones.
    def cancelled(signum, frame):
        raise _Cancelled('command owner cancelled')
    signal.signal(signal.SIGTERM, cancelled)
    result = dict(exit=None, failure=None, stdout=b'', stderr=b'', capture=capture)
    process = None
    try:
        enable_subreaper()
        process = subprocess.Popen(command, stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE if capture == 'split' else subprocess.STDOUT,
                                   start_new_session=True, env=env, cwd=cwd)
        try:
            stdout, stderr = process.communicate(timeout=timeout)
            result.update(exit=process.returncode, stdout=stdout, stderr=stderr or b'')
            if child_pids(os.getpid()):
                result['failure'] = 'child left owned descendants; no passing result'
        except subprocess.TimeoutExpired as error:
            result.update(failure='child deadline', stdout=error.output or b'', stderr=error.stderr or b'')
    except BaseException as error:
        result['failure'] = type(error).__name__ + ': ' + str(error)
    finally:
        # Ignore repeated cancellation during the bounded cleanup operation.
        signal.signal(signal.SIGTERM, signal.SIG_IGN)
        try:
            cleanup_owned(process.pid if process else None)
        except BaseException as error:
            result['failure'] = (result['failure'] or '') + '; cleanup: ' + str(error)
        if process:
            try:
                stdout, stderr = process.communicate(timeout=1)
                result.update(stdout=stdout, stderr=stderr or b'')
            except subprocess.TimeoutExpired as error:
                result.update(stdout=error.output or result['stdout'], stderr=error.stderr or result['stderr'])
                result['failure'] = (result['failure'] or '') + '; child pipes did not close'
            process.stdout.close()
            if process.stderr:
                process.stderr.close()
        try:
            connection.send(result)
        finally:
            connection.close()


def execute_result(command, timeout, env=None, cwd=None, capture='merged-stdout'):
    """Return raw streams and failure metadata; nonzero exit is not supervisor failure.

    The deadline limits the command, separately from worker setup and bounded
    cleanup. Linux /proc, pidfds and fork are required; no unsafe fallback.
    """
    if isinstance(timeout, bool) or not isinstance(timeout, (int, float)) or not math.isfinite(timeout) or timeout <= 0:
        raise ValueError('positive finite command timeout required')
    if capture not in ('split', 'merged-stdout'):
        raise ValueError('unknown capture mode')
    command = list(map(os.fspath, command))
    if not command:
        raise ValueError('empty command')
    _implementation_guard()
    context = multiprocessing.get_context('fork')
    receiver, sender = context.Pipe(duplex=False)
    owner = context.Process(target=_worker, args=(sender, command, timeout, env, cwd, capture))
    owner.start()
    sender.close()
    end = time.monotonic() + timeout + 5
    try:
        # Polling avoids an indefinite wait after an unexpected worker death.
        while not receiver.poll(.05):
            if time.monotonic() >= end:
                raise TimeoutError('command owner exceeded command and cleanup budget')
            if not owner.is_alive():
                raise RuntimeError('command owner exited without a result')
        result = receiver.recv()
        owner.join(4)
        if owner.is_alive():
            raise RuntimeError('command owner failed to exit')
        try:
            _implementation_guard()
        except RuntimeError as error:
            result['failure'] = (result['failure'] or '') + '; ' + str(error)
        result['runnerSHA256'] = IMPLEMENTATION_SHA256
        return result
    finally:
        if owner.is_alive():
            owner.terminate()
            owner.join(4)
            if owner.is_alive():
                owner.kill()
                owner.join()
        receiver.close()
        owner.close()


def _raise_failure(result):
    if result['failure']:
        error = TimeoutError(result['failure']) if result['failure'].startswith('child deadline') else RuntimeError(result['failure'])
        error.stdout, error.stderr, error.result = result['stdout'], result['stderr'], result
        raise error


def execute(command, timeout, env=None, cwd=None):
    result = execute_result(command, timeout, env, cwd)
    _raise_failure(result)
    return result['exit'], result['stdout'].decode()


def execute_split(command, timeout, env=None, cwd=None):
    result = execute_result(command, timeout, env, cwd, 'split')
    _raise_failure(result)
    return result['exit'], result['stdout'], result['stderr']


class Inputs:
    """Explicit files and directory membership, checked before and after commands."""
    def __init__(self, files=(), directories=()):
        self.files = tuple(Path(p).resolve() for p in files)
        self.directories = tuple(Path(p).resolve() for p in directories)
        self.expected = self.snapshot()

    def snapshot(self):
        entries = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in self.files}
        for root in self.directories:
            if not root.is_dir():
                raise FileNotFoundError(root)
            entries[str(root)] = {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
                                  for p in sorted(root.rglob('*')) if p.is_file()}
        return entries

    def guard(self):
        if self.snapshot() != self.expected:
            raise RuntimeError('command input bytes or membership changed')


class Runner:
    """Task configuration stays explicit; logs and input checks are reusable."""
    def __init__(self, logs, *, inputs, env=None, cwd=None, capture='split'):
        self.logs, self.inputs = logs, inputs
        self.env = dict(env) if env is not None else None
        self.cwd, self.capture = cwd, capture

    def run(self, label, command, timeout, expected=0):
        self.inputs.guard()
        self.logs.guard()
        if label not in self.logs.labels or label + '.stdout' in self.logs.hashes:
            raise ValueError('unplanned or already executed command')
        result = execute_result(command, timeout, self.env, self.cwd, self.capture)
        self.logs.record(label, result['stdout'], result['stderr'])
        self.inputs.guard()
        _raise_failure(result)
        if expected is not None and result['exit'] != expected:
            error = RuntimeError('unexpected command exit: ' + str(result['exit']))
            error.result = result
            raise error
        return result


def run(command, *, timeout, capture_output=False, text=False, env=None,
        cwd=None, stdout=None, stderr=None, check=False):
    """Captured subprocess.run adapter with explicit ownership and deadline.

    Unsupported streaming/shell/input modes are deliberately not inferred.
    CompletedProcess carries runner_result with raw bytes and implementation pin.
    """
    if capture_output:
        if stdout is not None or stderr is not None:
            raise ValueError('capture_output conflicts with explicit streams')
        stdout = stderr = subprocess.PIPE
    if stdout != subprocess.PIPE or stderr not in (subprocess.PIPE, subprocess.STDOUT):
        raise ValueError('declare split pipes or merged stdout capture')
    result = execute_result(command, timeout, env, cwd,
                            'split' if stderr == subprocess.PIPE else 'merged-stdout')
    if result['failure'] and result['failure'].startswith('child deadline'):
        error = subprocess.TimeoutExpired(command, timeout, output=result['stdout'], stderr=result['stderr'])
        error.result = result
        raise error
    _raise_failure(result)
    out, err = result['stdout'], result['stderr'] if stderr == subprocess.PIPE else None
    if text:
        import locale
        def decode(value):
            return value.decode(locale.getpreferredencoding(False)).replace('\r\n', '\n').replace('\r', '\n')
        out, err = decode(out), decode(err) if err is not None else None
    completed = subprocess.CompletedProcess(command, result['exit'], out, err)
    completed.runner_result = result
    if check:
        completed.check_returncode()
    return completed


def execute_completed(command, timeout, env=None, cwd=None):
    result = execute_result(command, timeout, env, cwd, 'split')
    _raise_failure(result)
    completed = subprocess.CompletedProcess(command, result['exit'], result['stdout'], result['stderr'])
    completed.runner_result = result
    return completed


def check_output(command, *, timeout, text=False, env=None, cwd=None):
    return run(command, timeout=timeout, text=text, env=env, cwd=cwd,
               capture_output=True, check=True).stdout
