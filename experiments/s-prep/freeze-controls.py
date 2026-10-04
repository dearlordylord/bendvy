#!/usr/bin/env python3
"""Exercise retained-source/reference drift guards in independent temporary repos."""
import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile

spec = importlib.util.spec_from_file_location('freeze', Path(__file__).with_name('freeze.py'))
F = importlib.util.module_from_spec(spec)
spec.loader.exec_module(F)


def git(path, *args):
    return subprocess.check_output(['git', '-C', str(path), *args], stderr=subprocess.DEVNULL).decode().strip()


def commit(path):
    git(path, 'add', '.')
    git(path, '-c', 'user.name=Preparation control', '-c', 'user.email=control@example.invalid', 'commit', '-qm', 'control')
    return git(path, 'rev-parse', 'HEAD')


def rejected(label):
    try:
        F.snapshot()
    except ValueError:
        return {'control': label, 'status': 'DETECTED'}
    raise AssertionError(f'guard accepted {label}')


with tempfile.TemporaryDirectory(prefix='bendvy-prep22-freeze-controls-') as folder:
    base = Path(folder)
    F.ROOT = base / 'project'
    F.REFERENCE_ROOT = base / 'references'
    ref = F.REFERENCE_ROOT / 'bevy-ts'
    ref.mkdir(parents=True)
    git(ref, 'init', '-q')
    reference_file = ref / 'subject.txt'
    reference_file.write_text('retained reference\n')
    reference_commit = commit(ref)
    historical = F.ROOT / 'experiments/s-perf'
    historical.mkdir(parents=True)
    git(F.ROOT, 'init', '-q')
    source = historical / 'subject.txt'
    source.write_text('retained candidate\n')
    (historical / 'baseline.json').write_text(json.dumps({'references': {'bevy-ts': {'commit': reference_commit}}}))
    F.BASELINE = commit(F.ROOT)
    original = F.snapshot()
    results = [{'control': 'unchanged positive', 'status': 'PASS'}]
    source.write_text('changed candidate\n')
    results.append(rejected('source bytes changed'))
    source.write_text('retained candidate\n')
    source.unlink()
    results.append(rejected('source missing'))
    target = base / 'replacement.txt'
    target.write_text('retained candidate\n')
    source.symlink_to(target)
    results.append(rejected('same-byte source symlink'))
    source.unlink()
    source.write_text('retained candidate\n')
    reference_file.write_text('changed tracked reference\n')
    results.append(rejected('tracked reference drift'))
    commit(ref)
    results.append(rejected('reference commit drift'))
    git(ref, 'reset', '--hard', reference_commit)
    assert F.snapshot() == original
    results.append({'control': 'restored positive', 'status': 'PASS'})
    print(json.dumps({'status': 'PASS', 'controls': results}, indent=2))
