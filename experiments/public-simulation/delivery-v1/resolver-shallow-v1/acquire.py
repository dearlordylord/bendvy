"""Existing-helper acquisition; expensive hashing is inside one metadata5 child."""
import fcntl
import hashlib
import json
import os
from pathlib import Path
import stat
import sys
import types
HERE = Path(__file__).resolve().parent
sha = lambda raw: hashlib.sha256(raw).hexdigest()

def regular(path):
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
    try:
        if not stat.S_ISREG(os.fstat(fd).st_mode): raise ValueError('regular acquisition input required')
        with os.fdopen(fd, 'rb', closefd=False) as stream: return stream.read()
    finally: os.close(fd)

def publish(path, raw):
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
    with os.fdopen(fd, 'wb') as stream:
        if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode): raise ValueError('regular acquisition output required')
        stream.write(raw)

def load(name, path, pins):
    raw = regular(path)
    if sha(raw) != pins[str(Path(path).resolve())]: raise ValueError('helper byte drift before import')
    module = types.ModuleType(name); module.__file__ = str(path)
    exec(compile(raw, str(path), 'exec'), module.__dict__)
    return module

def admitted(path, digest):
    raw = regular(path)
    if sha(raw) != digest: raise ValueError('exact acquisition plan required')
    plan = json.loads(raw); pins = dict(plan['sourcePins']); pins[str(Path(path).resolve())] = digest
    actual = str(Path(sys.executable).resolve(strict=True))
    if actual != plan['python'] or sha(regular(actual)) != pins[actual]: raise ValueError('acquisition interpreter drift')
    # Before any helper executes, every source and transitive source is verified.
    if any(sha(regular(name)) != value for name, value in pins.items()): raise ValueError('acquisition source drift')
    if str(Path(__file__).resolve()) not in pins: raise ValueError('collector must be frozen')
    return plan, pins

def encoded(value):
    if isinstance(value, bytes): return {'rawHex': value.hex()}
    if isinstance(value, dict): return {k: encoded(v) for k, v in value.items()}
    if isinstance(value, (list, tuple)): return [encoded(v) for v in value]
    return value

def worker(planpath, digest):
    plan, pins = admitted(planpath, digest)
    modules = {name: load('acquisition_' + name, path, pins) for name, path in plan['helpers'].items()}
    declarations = plan['declaration']
    current_namespace = modules['metadata'].namespace_state(declarations['resolver_inputs'] + declarations['loader_search_directories'])
    if current_namespace != declarations['namespace']: raise ValueError('Declared alias/config namespace drift')
    resources = {root: {str(p): {'resolved': str(p.resolve(strict=True)), 'bytes': p.stat().st_size} for p in sorted(Path(root).rglob('*')) if p.is_file()} for root in plan['resourceMetadata']}
    if resources != plan['resourceMetadata']: raise ValueError('Resource membership/size drift')
    # Historical exact tool bytes must remain; expensive validation stays capped.
    for path, expected in plan['toolPins'].items():
        if sha(regular(path)) != expected: raise ValueError('installed tool drift before acquisition')
    out = Path(plan['outputRoot']) / 'inner'; out.mkdir(mode=0o700)
    rows = []; cfg = dict(plan['declaration']['configuration'])
    cfg.pop('execute'); cfg['env'] = dict(cfg['env'])
    calls = iter(plan['declaration']['discoveryCommands'])
    def execute(argv, timeout, env):
        expected = next(calls)
        if argv != expected['argv'] or timeout != 5 or env != cfg['env']: raise ValueError('unplanned discovery command')
        result = modules['runner'].execute_result(argv, timeout, env, str(HERE), 'split')
        row = encoded(result)
        row.update(name=expected['name'], argv=argv, capSeconds=timeout)
        rows.append(row)
        # Completed process is retained before raw publication, even on second-stream failure.
        publish(out / (expected['name'] + '.result.json'), (json.dumps(row, indent=2) + '\n').encode())
        for stream in ['stdout', 'stderr']:
            raw = result[stream]; target = out / (expected['name'] + '.' + stream)
            row[stream] = {'path': str(target), 'returnedBytes': len(raw), 'returnedSHA256': sha(raw), 'publication': 'PENDING'}
            try: publish(target, raw)
            except BaseException:
                row[stream]['publication'] = 'FAILED'; raise
            row[stream].update(publication='PUBLISHED', bytes=len(raw), sha256=sha(raw))
        return result
    publish(out / 'started.json', (json.dumps({'outerCapSeconds': 5, 'resolverInputs': 893, 'shallowDirectories': 64, 'cost': plan['declaration']['cost']}, indent=2) + '\n').encode())
    session = modules['pins'].PinnedTools(resolver_inputs=plan['declaration']['resolver_inputs'], loader_search_directories=plan['declaration']['loader_search_directories'], execute=execute, **cfg)
    if next(calls, None) is not None: raise ValueError('discovery sequence incomplete')
    publish(out / 'acquired.json', (json.dumps({'resolver': session.resolver, 'installed': encoded(session.expected), 'commands': rows, 'status': 'ACQUIRED_NOT_DELIVERY_QUALIFICATION'}, indent=2) + '\n').encode())

def run(planpath, digest):
    plan, pins = admitted(planpath, digest)
    modules = {name: load('acquisition_' + name, path, pins) for name, path in plan['helpers'].items()}
    out = Path(plan['outputRoot'])
    if out.exists() or out.is_symlink(): raise ValueError('output starts absent')
    out.mkdir(mode=0o700); receiptpath = out / 'receipt.json'; publish(receiptpath, b'')
    record = {'planSHA256': digest, 'commands': [], 'guards': [], 'closedResolverQualified': False}
    expected_artifacts = {'started.json', 'acquired.json'} | {row['name'] + suffix for row in plan['declaration']['discoveryCommands'] for suffix in ['.stdout', '.stderr', '.result.json']}
    def guard(label):
        actual = {p: sha(regular(p)) for p in pins}
        artifacts = {}
        inner = out / 'inner'
        if inner.is_symlink(): raise ValueError('inner output alias refused')
        if inner.exists():
            for file in inner.iterdir():
                if file.name not in expected_artifacts: raise ValueError('unplanned inner artifact')
                artifacts[str(file)] = sha(regular(file))
        value = {'label': label, 'actualPins': actual, 'unchanged': actual == pins, 'retainedArtifacts': artifacts}
        target = out / (label + '.guard.json'); publish(target, (json.dumps(value, indent=2) + '\n').encode())
        record['guards'].append({'path': str(target), 'sha256': sha(regular(target))})
        if actual != pins: raise ValueError('source/plan drift')
    logs = modules['logs'].CommandLogs(out, ['acquisition'])
    inputs = modules['runner'].Inputs(files=list(pins))
    runner = modules['runner'].Runner(logs, inputs=inputs, env=plan['declaration']['configuration']['env'], cwd=str(HERE), capture='split')
    with modules['boundary'].ReceiptBoundary(record, receiptpath, [('final', lambda: guard('final'))]):
        guard('pre')
        with open(plan['lock'], 'a') as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            try:
                guard('acquired')
                with modules['boundary'].GuardBoundary([('post', lambda: guard('post'))]):
                    try: result = runner.run('acquisition', plan['command'] + [digest], 5)
                    except BaseException as error:
                        result = getattr(error, 'result', None)
                        if result is not None: record['commands'].append(encoded(result))
                        raise
                    else: record['commands'].append(encoded(result))
            finally: fcntl.flock(lock, fcntl.LOCK_UN)
        acquired = json.loads(regular(out / 'inner/acquired.json'))
        if acquired['status'] != 'ACQUIRED_NOT_DELIVERY_QUALIFICATION' or len(acquired['commands']) != 8: raise ValueError('whole acquisition not complete')
        record['status'] = 'ACQUIRED_NOT_DELIVERY_QUALIFICATION'

if __name__ == '__main__':
    (worker if sys.argv[1] == '--worker' else run)(sys.argv[2], sys.argv[3])
