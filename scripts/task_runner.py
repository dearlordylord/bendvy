"""Linux command ownership, raw capture and reusable evidence checks."""
import ctypes
import fcntl
import hashlib
import json
import math
import multiprocessing
import os
from pathlib import Path
import signal
import shutil
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


def kill_descendants(pid, *, deadline=None):
    pending, descriptors, seen = [pid], [], set()
    end = time.monotonic() + 1
    if deadline is not None:
        end = min(end, deadline)
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


def cleanup_owned(pid=None, prior=(), *, process=None):
    prior = set(prior)
    if pid in child_pids(os.getpid()) - prior:
        kill_descendants(pid)
    end = time.monotonic() + 1
    while time.monotonic() < end:
        owned = child_pids(os.getpid()) - prior
        if not owned:
            return
        for child in owned:
            if time.monotonic() >= end:
                break
            kill_descendants(child, deadline=end)
        for child in owned:
            try:
                if process is not None and child == process.pid:
                    process.poll()  # Preserve the actual status for Popen.communicate.
                else:
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
            cleanup_owned(process.pid if process else None, process=process)
        except BaseException as error:
            result['failure'] = (result['failure'] or '') + '; cleanup: ' + str(error)
        if process:
            try:
                stdout, stderr = process.communicate(timeout=1)
                result.update(exit=process.returncode, stdout=stdout, stderr=stderr or b'')
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
    if timeout is not None and (isinstance(timeout, bool) or not isinstance(timeout, (int, float)) or not math.isfinite(timeout) or timeout <= 0):
        raise ValueError('command timeout must be None or positive and finite')
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
    end = None if timeout is None else time.monotonic() + timeout + 5
    result, primary_error = None, None
    try:
        # Polling avoids an indefinite wait after an unexpected worker death.
        while not receiver.poll(.05):
            if end is not None and time.monotonic() >= end:
                raise TimeoutError('command owner exceeded command and cleanup budget')
            if not owner.is_alive():
                # A result may arrive between the earlier poll and owner exit.
                if receiver.poll(0):
                    break
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
    except BaseException as error:
        primary_error = error
        if result is not None:
            error.result = result
            error.stdout, error.stderr = result['stdout'], result['stderr']
        raise
    finally:
        cleanup_error = None
        if owner.is_alive():
            cleanup_end = time.monotonic() + 4
            owner.terminate()
            # A cancelled owner publishes its real terminal result during cleanup.
            # Receive before join: raw output can exceed the pipe's buffer.
            if primary_error is not None and result is None:
                try:
                    while time.monotonic() < cleanup_end:
                        if receiver.poll(min(.05, max(0, cleanup_end - time.monotonic()))):
                            result = receiver.recv()
                            break
                        if not owner.is_alive():
                            break
                except BaseException as recovery_error:
                    primary_error.add_note('terminal result recovery: ' + repr(recovery_error))
            owner.join(max(0, cleanup_end - time.monotonic()))
            if owner.is_alive():
                owner.kill()
                owner.join(max(0, cleanup_end - time.monotonic()))
                if owner.is_alive():
                    cleanup_error = RuntimeError('command owner survived bounded cleanup')
                    cleanup_error.owner = owner
                    if result is not None:
                        cleanup_error.result = result
                        cleanup_error.stdout, cleanup_error.stderr = result['stdout'], result['stderr']
        if primary_error is not None:
            if result is None and not owner.is_alive():
                try:
                    if receiver.poll(0):
                        result = receiver.recv()
                except BaseException as recovery_error:
                    primary_error.add_note('terminal result recovery: ' + repr(recovery_error))
            if result is not None:
                try:
                    _implementation_guard()
                except RuntimeError as error:
                    result['failure'] = (result['failure'] or '') + '; ' + str(error)
                result['runnerSHA256'] = IMPLEMENTATION_SHA256
                primary_error.result = result
                primary_error.stdout, primary_error.stderr = result['stdout'], result['stderr']
        receiver.close()
        if not owner.is_alive():
            owner.close()
        if cleanup_error is not None:
            if primary_error is not None:
                primary_error.cleanup_failure = cleanup_error
                primary_error.owner = owner
                primary_error.add_note(str(cleanup_error))
            else:
                raise cleanup_error


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
        try:
            result = execute_result(command, timeout, self.env, self.cwd, self.capture)
        except BaseException as error:
            result = getattr(error, 'result', None)
            if result is not None:
                # Cancellation remains primary even if evidence publication or a
                # postguard also fails; retain the real result on that exception.
                for name, check in (
                    ('raw logs', lambda: self.logs.record(label, result['stdout'], result['stderr'])),
                    ('inputs', self.inputs.guard),
                ):
                    try:
                        check()
                    except BaseException as secondary:
                        error.add_note(f'{name}: {type(secondary).__name__}: {secondary}')
            raise
        try:
            self.logs.record(label, result['stdout'], result['stderr'])
            self.inputs.guard()
            _raise_failure(result)
            if expected is not None and result['exit'] != expected:
                raise RuntimeError('unexpected command exit: ' + str(result['exit']))
        except BaseException as error:
            # A publication/postguard failure must retain the completed process.
            error.result = result
            raise
        return result


class StageCache:
    """Resume commands from matching inputs and intact successful artifacts.

    Callers declare each stage's full source/tool/input closure. Attempts and
    failures remain immutable; changing an oracle invalidates its comparison,
    not an otherwise unchanged build. This records execution, not acceptance.
    """
    def __init__(self, directory, *, cwd=None, env=None):
        self.directory = Path(directory).resolve()
        self.directory.mkdir(parents=True, exist_ok=True)
        self.cwd = Path(cwd or Path.cwd()).resolve()
        self.env = dict(os.environ if env is None else env)

    def _files(self, names):
        paths = [Path(name) for name in names]
        paths = [p if p.is_absolute() else self.cwd / p for p in paths]
        return {str(p.absolute()): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}

    def run(self, label, command, *, files=(), outputs=(), timeout=None, expected=0):
        if not label or label in ('.', '..') or Path(label).name != label:
            raise ValueError('stage label must be a filename')
        command = list(map(os.fspath, command))
        if not command:
            raise ValueError('empty command')
        search_path = os.pathsep.join(str((self.cwd / p).resolve())
                                     for p in self.env.get('PATH', os.defpath).split(os.pathsep))
        executable = (str(self.cwd / command[0]) if os.sep in command[0]
                      else shutil.which(command[0], path=search_path))
        if executable is None:
            raise FileNotFoundError(command[0])
        if not Path(executable).is_absolute():
            executable = str(self.cwd / executable)
        environment_hash = hashlib.sha256(json.dumps(self.env, sort_keys=True).encode()).hexdigest()
        binding = dict(command=command, cwd=str(self.cwd), environmentSHA256=environment_hash, timeout=timeout,
                       expected=expected, inputs=self._files([*files, executable]),
                       outputs=[str((self.cwd / p).resolve()) for p in map(Path, outputs)],
                       runnerSHA256=IMPLEMENTATION_SHA256)
        key = hashlib.sha256(json.dumps(binding, sort_keys=True).encode()).hexdigest()
        stage = self.directory / label
        stage.mkdir(exist_ok=True)
        with (stage / 'lock').open('a') as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            _implementation_guard()
            if self._files(binding['inputs']) != binding['inputs']:
                raise RuntimeError('stage input changed while waiting for ownership')
            for prior in sorted(stage.glob('attempt-*/receipt.json'), reverse=True):
                try:
                    saved = json.loads(prior.read_text())
                except json.JSONDecodeError:
                    continue
                if saved['key'] != key or saved['status'] != 'PASS':
                    continue
                try:
                    intact = self._files(saved['artifacts']) == saved['artifacts']
                except FileNotFoundError:
                    intact = False
                if intact:
                    return dict(saved, reused=True, receipt=str(prior))
            attempt = stage / ('attempt-' + str(len(list(stage.glob('attempt-*'))) + 1).zfill(6))
            attempt.mkdir()
            receipt = dict(key=key, binding=binding, status='INCOMPLETE')
            started = time.monotonic()
            try:
                result = execute_result(command, timeout, self.env, self.cwd, 'split')
                receipt.update(exit=result['exit'], failure=result['failure'],
                               elapsedSeconds=time.monotonic() - started)
                (attempt / 'stdout').write_bytes(result['stdout'])
                (attempt / 'stderr').write_bytes(result['stderr'])
                if self._files(binding['inputs']) != binding['inputs']:
                    raise RuntimeError('stage input changed during execution')
                _raise_failure(result)
                if result['exit'] != expected:
                    raise RuntimeError('unexpected command exit: ' + str(result['exit']))
                receipt['artifacts'] = self._files([attempt / 'stdout', attempt / 'stderr', *outputs])
                receipt['status'] = 'PASS'
            except BaseException as error:
                receipt['error'] = type(error).__name__ + ': ' + str(error)
                raise
            finally:
                destination = attempt / 'receipt.json'
                temporary = attempt / 'receipt.tmp'
                temporary.write_text(json.dumps(receipt, indent=2, sort_keys=True) + '\n')
                temporary.replace(destination)
            return dict(receipt, reused=False, receipt=str(destination))


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
