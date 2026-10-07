"""Installed binary/resource/library pins; execution is caller-owned and supervised."""
from pathlib import Path
import hashlib
import re
import json


class ProbeFailure(RuntimeError):
    """Structured raw evidence; exception text contains no child/env content."""
    def __init__(self, reason, *, probe, captures):
        super().__init__(reason)
        self.probe = dict(probe)
        self.captures = dict(captures)


CAP_SECONDS = 5


def _file(path):
    path = Path(path).resolve(strict=True)
    if not path.is_file():
        raise ValueError(f"not a file: {path}")
    return path


def _sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def snapshot(*, execute, tools, resource_roots, ldd, taskset, cpu, env,
             skip_ldd=(), capture_mode):
    """execute(argv, 5, env=...) must implement reviewed owned-descendant cleanup.

    No executor is selected/imported here. tools maps names to actual paths;
    resources are recursively pinned, and skip_ldd names explicitly mark scripts.
    capture_mode is 'split' or 'merged-stdout'; raw bytes are returned unchanged.
    """
    if not callable(execute):
        raise TypeError("a reviewed owned-descendant execute callable is required")
    if capture_mode not in ('split', 'merged-stdout'):
        raise ValueError("capture mode must describe actual executor streams")
    if not isinstance(cpu, int) or isinstance(cpu, bool) or cpu < 0:
        raise ValueError("explicit nonnegative CPU required")
    if not tools or not isinstance(env, dict):
        raise ValueError("explicit tools and complete execution environment required")
    if set(skip_ldd) - set(tools):
        raise ValueError("skip_ldd contains unknown tools")
    binaries = {name: _file(path) for name, path in tools.items()}
    ldd, taskset = _file(ldd), _file(taskset)
    roots = [Path(p).resolve(strict=True) for p in resource_roots]
    files = set(binaries.values()) | {ldd, taskset}
    for root in roots:
        if not root.is_dir():
            raise ValueError(f"resource root is not a directory: {root}")
        files.update(_file(p) for p in root.rglob('*') if p.is_file())
    # Freeze prerequisites BEFORE invoking ldd, then reject in-flight drift.
    resource_files = {_file(p) for root in roots for p in root.rglob('*') if p.is_file()}
    before = {str(p): _sha(p) for p in sorted(files)}
    logs = {}
    for name, binary in binaries.items():
        if name in skip_ldd:
            continue
        result = execute([str(taskset), '-c', str(cpu), str(ldd), str(binary)],
                         CAP_SECONDS, env=dict(env))
        stdout, stderr = result['stdout'], result['stderr']
        if not isinstance(stdout, bytes) or not isinstance(stderr, bytes):
            raise TypeError("executor must return raw byte streams")
        if capture_mode == 'merged-stdout' and stderr:
            raise ValueError("merged capture must expose no synthetic raw stderr")
        logs[name] = {'stdout': stdout, 'stderr': stderr,
                      'exit': result['exit'], 'failure': result['failure']}
        probe = {'name': name, 'binary': str(binary), 'ldd': str(ldd),
                 'taskset': str(taskset), 'cpu': cpu, 'cap_seconds': CAP_SECONDS,
                 'capture_mode': capture_mode}
        if result['failure'] is not None or result['exit'] != 0:
            raise ProbeFailure("ldd command refused", probe=probe, captures=logs)
        text = (stdout + b'\n' + stderr).decode('utf-8', errors='surrogateescape')
        if 'not found' in text:
            raise ProbeFailure("unresolved library", probe=probe, captures=logs)
        for line in text.splitlines():
            if 'warning: setlocale:' in line:
                continue
            try:
                files.update(_file(p) for p in re.findall(r'(/[^\s()]+)', line))
            except (OSError, ValueError) as error:
                raise ProbeFailure('resolved library path unavailable',
                                   probe=probe, captures=logs) from error
    after_resources = {_file(p) for root in roots for p in root.rglob('*') if p.is_file()}
    if after_resources != resource_files:
        raise RuntimeError('resource file membership changed during library discovery')
    if any(_sha(Path(p)) != digest for p, digest in before.items()):
        raise RuntimeError("tool/resource bytes changed during library discovery")
    return {'pins': {str(p): _sha(p) for p in sorted(files)},
            'resolved_libraries': logs, 'capture_mode': capture_mode,
            'tools': {n: str(p) for n, p in binaries.items()},
            'resource_roots': list(map(str, roots)), 'skip_ldd': list(skip_ldd),
            'ldd': str(ldd), 'taskset': str(taskset), 'cpu': cpu,
            'cap_seconds': CAP_SECONDS,
            'environment_sha256': hashlib.sha256(json.dumps(env, sort_keys=True,
                separators=(',', ':'), ensure_ascii=True).encode()).hexdigest(),
            'scope': 'Installed binaries/resources and discovered ELF libraries; '
                     'no separate compiler source or physical-memory claim'}


def _verification_view(snapshot):
    # ldd's terminal load-address annotation varies with ASLR. Preserve every
    # other byte, exit/failure, path and pin; raw captures remain in snapshots.
    result = dict(snapshot)
    result['resolved_libraries'] = {
        name: {key: (re.sub(rb'(?m)^([ \t]*(?:[^\s]+[ \t]+=>[ \t]+/[^\r\n]+?|/[^\r\n]+?|linux-vdso[^\s]*))[ \t]+\(0x[0-9a-fA-F]+\)(?=\r?$)', rb'\1', value)
                     if key == 'stdout' else value)
               for key, value in capture.items()}
        for name, capture in snapshot['resolved_libraries'].items()
    }
    return result


def verify(expected, **configuration):
    current = snapshot(**configuration)
    if _verification_view(current) != _verification_view(expected):
        raise RuntimeError("installed tool/resource/library set, bytes, logs or configuration changed")
    return current
