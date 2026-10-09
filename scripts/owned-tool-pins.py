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


class PinnedTools:
    """One discovery per stage; immutable declared resolver inputs between commands.

    resolver_inputs must cover the caller's closed resolution boundary (loader,
    cache/preload/config, search directories including RPATH/RUNPATH and env).
    Directory contents and symlink targets are hashed, not metadata-memoized.
    This API never guesses a closed namespace or silently adopts changed inputs.
    Keep verify() for consumers without a reviewed resolver-input inventory.
    """
    def __init__(self, *, resolver_inputs, loader_search_directories=(), **configuration):
        if not resolver_inputs:
            raise ValueError('explicit closed resolver inputs are required')
        self.configuration = dict(configuration)
        self.resolver_inputs = tuple(map(str, resolver_inputs))
        self.loader_search_directories = tuple(map(str, loader_search_directories))
        self.resolver = self._resolver()
        self.expected = snapshot(**configuration)
        self.check()

    def _resolver(self):
        result = {}
        roots = [Path(p).resolve() for p in self.resolver_inputs]
        for name in self.resolver_inputs:
            root = Path(name).absolute()
            paths = [root] + (sorted(root.rglob('*')) if root.is_dir() else [])
            for path in paths:
                entry = {'symlink': str(path.readlink()) if path.is_symlink() else None}
                if path.is_file():
                    entry.update(kind='file', resolved=str(path.resolve()), sha256=_sha(path))
                elif path.is_dir():
                    if path.is_symlink() and not any(path.resolve().is_relative_to(r) for r in roots):
                        raise RuntimeError('directory symlink escapes declared resolver namespace')
                    entry.update(kind='directory', resolved=str(path.resolve()))
                elif not path.exists() and not path.is_symlink():
                    entry.update(kind='absent')
                else:
                    raise RuntimeError('unsupported resolver input')
                result[str(path)] = entry
        if self.loader_search_directories:
            result["loader_search_directories"] = self._loader_directories()
        return result

    def _loader_directories(self):
        """Explicit shallow search scopes; nested directories confer no coverage."""
        recursive = [Path(p).absolute().resolve() for p in self.resolver_inputs]
        searches = [Path(p).absolute() for p in self.loader_search_directories]
        resolved_searches = [p.resolve() for p in searches]

        def covered(path, *, link_target=False):
            path = path.resolve()
            search_roots = (
                [resolved for raw, resolved in zip(searches, resolved_searches)
                 if raw == resolved] if link_target and path.is_dir()
                else resolved_searches)
            return any(path == root or (root.is_dir() and not root.is_symlink()
                       and path.is_relative_to(root)) for root in recursive) or any(
                       path == root or path.parent == root for root in search_roots)

        def chain(path, *, require_coverage, allow_absent=False):
            # Walk every component so intermediate aliases cannot disappear behind
            # Path.resolve(). A repeated link is a cycle, never an absent input.
            remaining = list(path.parts[1:]); current = Path("/"); links = []
            seen = set()
            while remaining:
                component = remaining.pop(0)
                if component == "..":
                    current = current.parent
                    continue
                current /= component
                if current.is_symlink():
                    state = (current, tuple(remaining))
                    if state in seen:
                        raise RuntimeError("cyclic loader-search symlink")
                    seen.add(state)
                    literal = str(current.readlink())
                    target = current.parent / literal
                    if require_coverage and not covered(target, link_target=True):
                        raise RuntimeError("loader-search symlink target outside declared namespace")
                    links.append({"path": str(current), "target": literal})
                    # A symlink itself must resolve, even when the requested
                    # non-link suffix is explicitly declared absent.
                    current.resolve(strict=True)
                    remaining = list(target.parts[1:]) + remaining
                    current = Path("/")
            resolved = path.resolve(strict=not allow_absent)
            return resolved, links

        def entry(path, *, searched=False):
            if not path.exists() and not path.is_symlink():
                resolved, links = chain(path, require_coverage=True, allow_absent=True)
                return {"kind": "absent", "resolved": str(resolved), "links": links}
            is_directory = path.is_dir()
            resolved, links = chain(path, require_coverage=searched or not is_directory)
            stat = resolved.stat()
            value = {"resolved": str(resolved), "links": links}
            if resolved.is_file():
                if not covered(resolved):
                    raise RuntimeError("loader-search file outside declared namespace")
                value.update(kind="file", sha256=_sha(resolved))
            elif resolved.is_dir():
                value.update(kind="directory", identity=[stat.st_dev, stat.st_ino])
            else:
                raise RuntimeError("unsupported loader-search input")
            return value

        result = {}
        for root in searches:
            result[str(root)] = entry(root, searched=True)
            if root.exists() and not root.is_dir():
                raise RuntimeError("loader-search root is not a directory")
            if root.is_dir():
                for child in sorted(root.iterdir()):
                    result[str(child)] = entry(child)
        return result

    def check(self, **configuration):
        cfg = configuration or self.configuration
        view = {'tools': {n: str(_file(p)) for n, p in cfg['tools'].items()},
                'resource_roots': [str(Path(p).resolve(strict=True)) for p in cfg['resource_roots']],
                'skip_ldd': list(cfg.get('skip_ldd', ())), 'ldd': str(_file(cfg['ldd'])),
                'taskset': str(_file(cfg['taskset'])), 'cpu': cfg['cpu'],
                'capture_mode': cfg['capture_mode'],
                'environment_sha256': hashlib.sha256(json.dumps(cfg['env'], sort_keys=True,
                    separators=(',', ':'), ensure_ascii=True).encode()).hexdigest()}
        if any(self.expected[k] != v for k, v in view.items()) or self._resolver() != self.resolver:
            raise RuntimeError('resolver/configuration changed; discard this stage')
        if any(str(_file(p)) != p for p in self.expected['pins']):
            raise RuntimeError('pinned path resolution changed')
        files = {Path(p) for p in self.expected['pins']}
        resources = {_file(p) for root in self.expected['resource_roots']
                     for p in Path(root).rglob('*') if p.is_file()}
        old_resources = {Path(p) for p in self.expected['pins']
                         if any(Path(p).is_relative_to(root) for root in self.expected['resource_roots'])}
        if resources != old_resources or any(_sha(p) != self.expected['pins'][str(p)] for p in files):
            raise RuntimeError('pinned tool/resource/library bytes or membership changed')
        return self.expected

    def boundary(self):
        self.check()
        return verify(self.expected, **self.configuration)
