#!/usr/bin/env python3
"""Proposed protected execution boundary. No accepted session is created here."""
import argparse
import ctypes
import math
import hashlib
import json
import os
from pathlib import Path
import re
import signal
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
ARTIFACTS = Path('/tmp/bendvy-autoresearch23-focus')
EDITABLE = ('experiments/s-perf/candidate/storage.bend', 'experiments/s-perf/candidate/query.bend')
ENV = {'PATH': '/home/node/.bend/bin:/home/node/.local/bin:/home/node/.local/share/mise/installs/node/24.20.0/bin:/usr/bin:/bin',
       'HOME': '/home/node', 'LANG': 'C', 'LC_ALL': 'C', 'BENDVY_CPU': '2'}

def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def signatures(text):
    # Pin imports, complete multiline declarations and entire type definitions.
    for line in text.splitlines():
        if line and not line[0].isspace() and not line.startswith(('def ', 'type ', 'import ', '#', '//')):
            raise ValueError('unsupported top-level declaration/annotation')
    if re.search(r'@unsafe\b', text):
        raise ValueError('unsafe annotation outside first segment scope')
    types = re.findall(r'^type [\s\S]*?(?=^def |^type |^import |\Z)', text, re.M)
    definitions = []
    for start in re.finditer(r'^[ \t]*def ', text, re.M):
        depth = 0
        angles = 0
        for index in range(start.start(), len(text)):
            char = text[index]
            if char in '([{': depth += 1
            elif char in ')]}': depth -= 1
            elif char == '<': angles += 1
            elif char == '>' and (index == 0 or text[index-1] != '-') and angles: angles -= 1
            elif char == ':' and depth == 0 and angles == 0:
                definitions.append(text[start.start():index+1])
                break
        else:
            raise ValueError('unterminated Bend declaration')
    return {'imports': re.findall(r'^[ \t]*import [^\n]+', text, re.M),
            'types': types, 'definitions': definitions}

def candidate(deadline=None):
    values = {}
    for name in EDITABLE:
        path = ROOT / name
        if path.is_symlink() or path.resolve() != path.absolute():
            raise ValueError('candidate path escapes checkout')
        original = subprocess.check_output(['git', 'show', '56b72f6:' + name], cwd=ROOT, timeout=min(5, remaining(deadline)) if deadline is not None else 5).decode()
        if signatures(path.read_text()) != signatures(original):
            raise ValueError('first segment declaration/layout scope changed; transition required')
        values[name] = digest(path)
    return values

def confined(path):
    path = Path(path)
    if path.is_symlink() or path.resolve() != path.absolute():
        raise ValueError('artifact symlink escape')
    if not path.resolve().is_relative_to(ARTIFACTS):
        raise ValueError('artifact outside proposed root')
    return path

def remaining(deadline):
    if not isinstance(deadline, (int, float)) or not math.isfinite(deadline):
        raise ValueError('finite deadline required')
    left = deadline - time.monotonic()
    if left <= 0:
        raise TimeoutError('cumulative 3600-second segment budget exhausted')
    return left

def child_pids(pid):
    result = set()
    tasks = Path('/proc') / str(pid) / 'task'
    if tasks.exists():
        for task in tasks.iterdir():
            try:
                result.update(int(x) for x in (task / 'children').read_text().split())
            except FileNotFoundError:
                pass
    return result


def enable_subreaper():
    # Orphans of exited child runners must remain owned by this boundary.
    if ctypes.CDLL(None, use_errno=True).prctl(36, 1, 0, 0, 0) != 0:
        raise OSError(ctypes.get_errno(), 'cannot establish child subreaper')


def validate_start(state, manifest):
    if (str(ROOT) != manifest['checkout'] or str(ARTIFACTS) != manifest['artifactRoot']
            or manifest['environment'] != dict(ENV, TMPDIR='task-owned per invocation under artifactRoot')):
        raise ValueError('execution identity/environment differs from frozen proposal')
    start = state.get('startedMonotonicSeconds')
    if (isinstance(start, bool) or not isinstance(start, (int, float))
            or not math.isfinite(start) or start < 0 or start > time.monotonic()):
        raise ValueError('finite nonfuture monotonic start required')
    return start + 3600


def kill_tree(pid):
    # Child runners create their own sessions. Killing one process group alone
    # would leave checker/compiler/runtime grandchildren alive.
    pending = [pid]
    owned = []
    while pending:
        current = pending.pop()
        try:
            descriptor = os.pidfd_open(current)
            signal.pidfd_send_signal(descriptor, signal.SIGSTOP)
        except ProcessLookupError:
            continue
        owned.append(descriptor)
        pending.extend(child_pids(current))
    for descriptor in reversed(owned):
        try:
            signal.pidfd_send_signal(descriptor, signal.SIGKILL)
        except ProcessLookupError:
            pass
        finally:
            os.close(descriptor)


def reap_dead_children():
    while True:
        try:
            pid, _ = os.waitpid(-1, os.WNOHANG)
            if pid == 0:
                return
        except ChildProcessError:
            return


def run(command, folder, deadline, env):
    remaining(deadline)
    enable_subreaper()
    process = subprocess.Popen(list(map(str, command)), cwd=ROOT, env=env,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True)
    try:
        out, err = process.communicate(timeout=remaining(deadline))
    except subprocess.TimeoutExpired:
        kill_tree(process.pid)
        for orphan in child_pids(os.getpid()):
            kill_tree(orphan)
        out, err = process.communicate()
        reap_dead_children()
        (folder / 'execution.json').write_text(json.dumps({'argv': list(map(str, command)), 'status': 'CUMULATIVE_DEADLINE'}, indent=2)+'\n')
        (folder / 'stdout.txt').write_bytes(out)
        (folder / 'stderr.txt').write_bytes(err)
        raise TimeoutError('cumulative segment deadline killed process group')
    survivors = child_pids(os.getpid())
    active = []
    for pid in survivors:
        try:
            if '\nState:\tZ' not in (Path('/proc') / str(pid) / 'status').read_text():
                active.append(pid)
        except FileNotFoundError:
            pass
        kill_tree(pid)
    reap_dead_children()
    (folder / 'stdout.txt').write_bytes(out)
    (folder / 'stderr.txt').write_bytes(err)
    if active:
        raise RuntimeError('child left owned descendants running; cleaned up, no passing receipt')
    (folder / 'execution.json').write_text(json.dumps({'argv': list(map(str, command)), 'exit': process.returncode}, indent=2)+'\n')
    if process.returncode:
        raise RuntimeError('authoritative child failed; retained diagnostic output')
    return out.decode()

def verify_manifest(manifest, deadline=None):
    for name, value in manifest['protectedSources'].items():
        path = ROOT / name
        if path.is_symlink() or path.resolve() != path.absolute() or digest(path) != value:
            raise ValueError('protected implementation drift: ' + name)
    for name, value in manifest['tools'].items():
        if digest(name) != value:
            raise ValueError('tool drift: ' + name)
    baseline = subprocess.check_output(['git', 'rev-parse', '56b72f6'], cwd=ROOT,
        timeout=min(5, remaining(deadline)) if deadline is not None else 5).decode().strip()
    if baseline != manifest['baseline']:
        raise ValueError('retained baseline commit drift')
    references = json.loads((HERE / 'baseline.json').read_text())['references']
    for name, pin in references.items():
        limit = min(5, remaining(deadline)) if deadline is not None else 5
        actual = subprocess.check_output(['git', '-C', pin['path'], 'rev-parse', 'HEAD'], timeout=limit).decode().strip()
        limit = min(5, remaining(deadline)) if deadline is not None else 5
        dirty = subprocess.check_output(['git', '-C', pin['path'], 'status', '--porcelain', '--untracked-files=no'], timeout=limit).decode()
        if actual != pin['commit'] or dirty:
            raise ValueError('pinned reference commit/working source drift: ' + name)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=('benchmark', 'checks'))
    args = parser.parse_args()
    def interrupted(signum, frame):
        for pid in child_pids(os.getpid()):
            kill_tree(pid)
        reap_dead_children()
        raise SystemExit(128 + signum)
    signal.signal(signal.SIGTERM, interrupted)
    signal.signal(signal.SIGINT, interrupted)
    confined(ARTIFACTS)
    manifest_path = HERE / 'execution-proposal.json'
    manifest = json.loads(manifest_path.read_text())
    state_path = confined(ARTIFACTS / 'accepted-start.json')
    state = json.loads(state_path.read_text())
    if (state.get('accepted') is not True or not re.fullmatch('[0-9a-f]{64}', state.get('contractDigest', ''))
            or state.get('executionManifestSHA256') != digest(manifest_path)
            or state.get('checkout') != str(ROOT) or state.get('allowanceSeconds') != 3600
            or state.get('bootID') != Path('/proc/sys/kernel/random/boot_id').read_text().strip()):
        raise ValueError('missing matching accepted start receipt; cannot execute proposal')
    deadline = validate_start(state, manifest)
    remaining(deadline)
    verify_manifest(manifest, deadline)
    before = candidate(deadline)
    binding = confined(ARTIFACTS / 'measurement-subject.json')
    if args.mode == 'checks' and json.loads(binding.read_text())['candidate'] != before:
        raise ValueError('checks do not match last measured candidate')
    folder = confined(Path(tempfile.mkdtemp(prefix=args.mode+'-', dir=ARTIFACTS)))
    temporary = folder / 'temporary'
    temporary.mkdir()
    env = dict(ENV, TMPDIR=str(temporary))
    env['BENDVY_ARTIFACT_ROOT'] = str(folder)
    overlay = folder / 'overlay'
    setup = folder / 'setup'
    setup.mkdir()
    run([sys.executable, 'experiments/s-perf/overlay.py', overlay], setup, deadline, env)
    sources = json.loads((overlay / 'overlay.json').read_text())['sources']
    for name, value in before.items():
        if sources['experiments/s-integrate/'+Path(name).name] != value:
            raise ValueError('checkout/overlay candidate mismatch')
    (folder / 'candidate.json').write_text(json.dumps(before, indent=2)+'\n')
    commands = ([['experiments/s-prep/paired-run.py', '--overlay', overlay, '--build-dir', folder/'paired', '--repetitions', '7', '--cpu', '2']] if args.mode == 'benchmark' else [
        ['experiments/s-perf/main-run.py', '--overlay', overlay, '--build-dir', folder/'main'],
        ['experiments/s-perf/e11-run.py', overlay, '--evidence', folder/'e11.json'],
        ['experiments/s-perf/access-run.py', overlay, '--evidence', folder/'access.json'],
        ['experiments/s-perf/candidate/owned-storage-run.py'],
        ['experiments/s-perf/main-mutations-run.py', '--overlay', overlay, '--output-dir', folder/'mutants', '--cpu', '2']])
    outputs = []
    for index, command in enumerate(commands):
        target = folder / ('command-'+str(index))
        target.mkdir()
        if candidate(deadline) != before:
            raise ValueError('candidate changed between measurement/check phases')
        outputs.append(run([sys.executable, *command], target, deadline, env))
    verify_manifest(manifest, deadline)
    if candidate(deadline) != before:
        raise ValueError('candidate changed during invocation')
    remaining(deadline)
    metric = None
    if args.mode == 'benchmark':
        values = re.findall(r'^METRIC jsInnerMilliseconds=([0-9.eE+-]+)$', outputs[0], re.M)
        if len(values) != 1 or not math.isfinite(float(values[0])) or float(values[0]) <= 0:
            raise ValueError('missing unique finite qualified evaluator metric')
        metric = values[0]
        binding.write_text(json.dumps({'candidate': before, 'evidence': str(folder / 'paired/paired-evidence.json')}, indent=2)+'\n')
    print(json.dumps({'status': 'PASS', 'candidate': before, 'artifacts': str(folder), 'remainingSeconds': remaining(deadline)}))
    if metric is not None:
        print('METRIC jsInnerMilliseconds='+metric)
    return 0

if __name__ == '__main__':
    sys.exit(main())
