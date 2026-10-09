"""One owned AArch64 PC diagnostic; five-second target, no semantic verdict."""
import ctypes
import errno
import hashlib
import json
import os
from pathlib import Path
import signal
import stat
import struct
import sys
import time
import types

SEIZE, INTERRUPT, GETREGSET, CONT = 0x4206, 0x4207, 0x4204, 7
EXITKILL, TRACEEXEC, WALL = 0x100000, 0x10, 0x40000000
ROOT = Path('/workspace/formal-proofs/bendvy')

def sha(path):
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW)
    with os.fdopen(fd, 'rb') as stream:
        if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode):
            raise ValueError('regular input required')
        return hashlib.sha256(stream.read()).hexdigest()

def publish(path, raw):
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
    with os.fdopen(fd, 'wb') as stream:
        stream.write(raw)
        stream.flush()
        os.fsync(stream.fileno())

def elf_loads(raw):
    if raw[:6] != b'\x7fELF\x02\x01' or struct.unpack_from('<H', raw, 18)[0] != 183:
        raise ValueError('little-endian ELF64 AArch64 required')
    offset = struct.unpack_from('<Q', raw, 32)[0]
    size, count = struct.unpack_from('<HH', raw, 54)
    if size != 56:
        raise ValueError('unexpected program header width')
    loads = []
    for i in range(count):
        kind, flags, fileoff, address, _, filesz, memsz, align = struct.unpack_from('<IIQQQQQQ', raw, offset + i * size)
        if kind == 1:
            loads.append(dict(flags=flags, offset=fileoff, address=address, filesz=filesz, memsz=memsz, align=align))
    return loads

def symbols(raw):
    rows = []
    for line in raw.decode('ascii').splitlines():
        fields = line.split()
        if len(fields) == 4:
            address, width, kind, name = fields
            if kind in ('t', 'T'):
                rows.append(dict(address=int(address, 16), size=int(width, 16), kind=kind, name=name))
        elif len(fields) == 3:
            # Zero-size linker symbols stay in raw nm, cannot locate a PC.
            int(fields[0], 16)
        elif line.strip():
            raise ValueError('unexpected nm row')
    if not rows:
        raise ValueError('no text symbols')
    return rows

def elf_symbols(raw):
    offset = struct.unpack_from('<Q', raw, 40)[0]
    width, count = struct.unpack_from('<HH', raw, 58)
    if width != 64:
        raise ValueError('unexpected section header width')
    sections = [struct.unpack_from('<IIQQQQIIQQ', raw, offset + i * width) for i in range(count)]
    found = set()
    for section in sections:
        if section[1] != 2:
            continue
        strings = sections[section[6]]
        names = raw[strings[4]:strings[4] + strings[5]]
        if section[9] != 24:
            raise ValueError('unexpected symbol width')
        for position in range(section[4], section[4] + section[5], 24):
            name, info, _, shndx, address, size = struct.unpack_from('<IBBHQQ', raw, position)
            if shndx and name:
                end = names.find(b'\0', name)
                if end < 0:
                    raise ValueError('unterminated ELF symbol name')
                found.add((address, size, names[name:end].decode('ascii')))
    return found

class TargetDeadline(Exception):
    pass

def load_bias(text, loads, binary):
    binary = Path(binary).resolve()
    inode = binary.stat().st_ino
    page = os.sysconf('SC_PAGE_SIZE')
    candidates = set()
    for line in text.splitlines():
        fields = line.split(maxsplit=5)
        if len(fields) != 6 or int(fields[4]) != inode or Path(fields[5]) != binary or 'x' not in fields[1]:
            continue
        start = int(fields[0].split('-')[0], 16)
        offset = int(fields[2], 16)
        for segment in loads:
            if segment['flags'] & 1 and segment['offset'] // page * page == offset:
                candidates.add(start - segment['address'] // page * page)
    if len(candidates) != 1:
        raise ValueError('executable PT_LOAD/maps bias ambiguous or absent')
    return candidates.pop()

def join_pc(pc, bias, rows):
    relative = pc - bias
    matches = [row for row in rows if row['size'] > 0 and row['address'] <= relative < row['address'] + row['size']]
    # Aliased/overlapping symbols remain explicit; never strip generated suffixes.
    return dict(relativePC=relative, symbols=matches, matched=bool(matches))

class Iovec(ctypes.Structure):
    _fields_ = [('base', ctypes.c_void_p), ('length', ctypes.c_size_t)]

class Trace:
    def __init__(self):
        self.lib = ctypes.CDLL(None, use_errno=True)
        self.lib.ptrace.restype = ctypes.c_long
        self.lib.ptrace.argtypes = [ctypes.c_uint, ctypes.c_uint, ctypes.c_void_p, ctypes.c_void_p]

    def call(self, request, tid, address=0, data=0):
        ctypes.set_errno(0)
        if self.lib.ptrace(request, tid, address, data) == -1:
            raise OSError(ctypes.get_errno(), os.strerror(ctypes.get_errno()))

    def pc(self, tid):
        regs = (ctypes.c_uint64 * 34)()
        vector = Iovec(ctypes.cast(regs, ctypes.c_void_p), ctypes.sizeof(regs))
        self.call(GETREGSET, tid, 1, ctypes.cast(ctypes.pointer(vector), ctypes.c_void_p))
        if vector.length != 272:
            raise ValueError('unexpected NT_PRSTATUS size')
        return int(regs[32])

def sample_tid(trace, tid, deadline, wait=os.waitpid, clock=time.monotonic_ns):
    started = clock()
    stopped = False
    row = None
    try:
        trace.call(INTERRUPT, tid)
        while clock() < deadline:
            got, status = wait(tid, os.WNOHANG | WALL)
            if got:
                if not os.WIFSTOPPED(status):
                    raise ProcessLookupError('task exited while waiting for interrupt')
                stopped = True
                # PTRACE_EVENT_STOP from SEIZE/INTERRUPT, never swallow a real signal.
                if status >> 16 != 128 or os.WSTOPSIG(status) not in (signal.SIGTRAP, signal.SIGSTOP):
                    raise RuntimeError('unexpected trace stop')
                row = dict(tid=tid, pc=trace.pc(tid), stoppedAtNs=clock())
                return row
            time.sleep(.0001)
        raise TimeoutError('interrupt wait reached target deadline')
    finally:
        if stopped:
            try:
                trace.call(CONT, tid)
            except OSError as error:
                if error.errno != errno.ESRCH or clock() < deadline:
                    raise
                if row is not None:
                    row['resumeRaceAtDeadline'] = True
            if row is not None:
                row['stopOverheadNs'] = clock() - started

def wait_exec(pid, trace, deadline):
    while time.monotonic_ns() < deadline:
        got, status = os.waitpid(pid, os.WNOHANG | WALL)
        if got:
            if not os.WIFSTOPPED(status) or status >> 16 != 4 or os.WSTOPSIG(status) != signal.SIGTRAP:
                raise RuntimeError('expected owned target exec event')
            trace.call(CONT, pid)
            return
        time.sleep(.0001)
    raise TimeoutError('target exec synchronization reached deadline')

def kill_reap(pid, pidfd, runner):
    # EXITKILL additionally handles abrupt sampler death; shared runner owns the
    # entire sampler subtree as a second cleanup boundary.
    if pidfd is not None:
        try:
            signal.pidfd_send_signal(pidfd, signal.SIGKILL)
        except ProcessLookupError:
            pass
    runner.cleanup_owned(pid)
    try:
        os.waitpid(pid, 0)
    except ChildProcessError:
        pass

def run(plan_path, admitted):
    path = Path(plan_path)
    sha(path)  # regular descriptor check before capturing parse bytes
    raw_plan = path.read_bytes()
    if hashlib.sha256(raw_plan).hexdigest() != admitted:
        raise ValueError('plan digest changed')
    plan = json.loads(raw_plan)
    actual = str(Path(sys.executable).resolve())
    if actual != plan['tools']['python'] or sha(actual) != plan['pins'][actual]:
        raise ValueError('actual interpreter differs before helper import')
    if any(sha(name) != digest for name, digest in plan['pins'].items()):
        raise ValueError('input changed before helper import')
    source = (ROOT / 'scripts/task_runner.py').read_bytes()
    if hashlib.sha256(source).hexdigest() != plan['pins'][str(ROOT / 'scripts/task_runner.py')]:
        raise ValueError('captured helper source drift before execution')
    runner = types.ModuleType('task_runner')
    runner.__file__ = str(ROOT / 'scripts/task_runner.py')
    exec(compile(source, runner.__file__, 'exec'), runner.__dict__)
    binary = plan['native']
    if os.uname().machine != 'aarch64' or plan['targetSeconds'] != 5:
        raise ValueError('expected AArch64/five-second diagnostic')
    raw_nm = Path(plan['nmRaw']).read_bytes()
    symbol_rows = symbols(raw_nm)
    elf = Path(binary).read_bytes()
    loads = elf_loads(elf)
    elf_rows = elf_symbols(elf)
    if any((row['address'], row['size'], row['name']) not in elf_rows for row in symbol_rows):
        raise ValueError('nm rows do not match exact ELF symbol table')
    out = path.parent
    handles = []
    record = dict(scope=plan['scope'], samples=[], maps=[], tids=[], enumerations=[], errors=[], targetSeconds=5,
                  intervalSeconds=plan['sampleIntervalSeconds'], symbolRows=symbol_rows, loads=loads,
                  nmSHA256=hashlib.sha256(raw_nm).hexdigest(), targetDeadlineReached=False)
    pid, pidfd = None, None
    gate_read, gate_write = os.pipe()
    started = time.monotonic_ns()
    primary = None
    def target_alarm(signum, frame):
        record['targetDeadlineReached'] = True
        if pidfd is not None:
            signal.pidfd_send_signal(pidfd, signal.SIGKILL)
        elif pid is not None:
            os.kill(pid, signal.SIGKILL)
        raise TargetDeadline('fixed target diagnostic deadline')
    prior_handler = signal.signal(signal.SIGALRM, target_alarm)
    try:
        for name in ('target.stdout', 'target.stderr'):
            handles.append(os.open(out / name, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600))
        pid = os.fork()
        if pid == 0:
            try:
                os.close(gate_write)
                if os.read(gate_read, 1) != b'!':
                    os._exit(126)
                os.close(gate_read)
                os.setsid()
                os.dup2(handles[0], 1)
                os.dup2(handles[1], 2)
                os.execve(binary, [binary, '--threads', '1', '--gpu', 'off'], plan['environment'])
            except BaseException:
                os._exit(127)
        pidfd = os.pidfd_open(pid)
        signal.setitimer(signal.ITIMER_REAL, max(.000001, (started + 5_000_000_000 - time.monotonic_ns()) / 1e9))
        trace = Trace()
        deadline = started + 5_000_000_000
        os.close(gate_read)
        gate_read = None
        trace.call(SEIZE, pid, data=EXITKILL | TRACEEXEC)
        known = {pid}
        record['tids'].append(dict(tid=pid, firstSeenNs=time.monotonic_ns() - started))
        os.write(gate_write, b'!')
        os.close(gate_write)
        gate_write = None
        wait_exec(pid, trace, deadline)
        record['execObservedAtNs'] = time.monotonic_ns() - started
        bias = None
        while time.monotonic_ns() < deadline:
            task_root = Path('/proc') / str(pid) / 'task'
            if not task_root.exists():
                break
            tasks = sorted(task_root.iterdir())
            record['enumerations'].append(dict(atNs=time.monotonic_ns() - started, tids=[int(task.name) for task in tasks]))
            for task in tasks:
                tid = int(task.name)
                try:
                    if tid not in known:
                        trace.call(SEIZE, tid, data=EXITKILL)
                        known.add(tid)
                        record['tids'].append(dict(tid=tid, firstSeenNs=time.monotonic_ns() - started))
                    row = sample_tid(trace, tid, deadline)
                    maps = (Path('/proc') / str(pid) / 'maps').read_text()
                    digest = hashlib.sha256(maps.encode()).hexdigest()
                    if not any(item['sha256'] == digest for item in record['maps']):
                        record['maps'].append(dict(sha256=digest, text=maps, observedAtNs=time.monotonic_ns() - started))
                    if bias is None:
                        bias = load_bias(maps, loads, binary)
                    row.update(join_pc(row['pc'], bias, symbol_rows))
                    row.update(observedAtNs=time.monotonic_ns() - started, mapsSHA256=digest, loadBias=bias)
                    record['samples'].append(row)
                except OSError as error:
                    record['errors'].append(dict(tid=tid, type=type(error).__name__, errno=error.errno, message=str(error)))
                    if error.errno != errno.ESRCH:
                        raise
            time.sleep(min(plan['sampleIntervalSeconds'], max(0, (deadline - time.monotonic_ns()) / 1e9)))
        record['targetDeadlineReached'] = time.monotonic_ns() >= deadline
    except TargetDeadline:
        record['targetDeadlineReached'] = True
    except BaseException as error:
        primary = error
        record['errors'].append(dict(type=type(error).__name__, message=str(error)))
    finally:
        signal.setitimer(signal.ITIMER_REAL, 0)
        signal.signal(signal.SIGALRM, prior_handler)
        if pid is not None:
            try:
                kill_reap(pid, pidfd, runner)
                record['cleanup'] = 'all owned target descendants killed/reaped'
            except BaseException as error:
                record['cleanupError'] = f'{type(error).__name__}: {error}'
                if primary is None:
                    primary = error
        if pidfd is not None:
            os.close(pidfd)
        for fd in (gate_read, gate_write):
            if fd is not None:
                os.close(fd)
        for fd in handles:
            os.close(fd)
        record['elapsedNs'] = time.monotonic_ns() - started
        # Raw samples/maps/stop errors precede any interpretation or status.
        raw = (json.dumps(record, indent=2) + '\n').encode()
        try:
            publish(out / 'samples.json', raw)
        except BaseException as error:
            record['samplePublicationError'] = f'{type(error).__name__}: {error}'
            record['unpublishedSamplesHex'] = raw.hex()
            if primary is None:
                primary = error
        artifacts = {}
        for name in ('samples.json', 'target.stdout', 'target.stderr'):
            target = out / name
            if target.exists() and not target.is_symlink():
                artifacts[name] = dict(path=str(target), sha256=sha(target), bytes=target.stat().st_size)
        print(json.dumps(dict(status='DIAGNOSTIC_CAPTURED' if primary is None else 'INCOMPLETE',
                              artifacts=artifacts, sampleCount=len(record['samples']),
                              deadline=record['targetDeadlineReached'], error=None if primary is None else str(primary),
                              publicationRecovery=record.get('unpublishedSamplesHex'))), flush=True)
    if primary is not None:
        raise primary

if __name__ == '__main__':
    run(sys.argv[1], sys.argv[2])
