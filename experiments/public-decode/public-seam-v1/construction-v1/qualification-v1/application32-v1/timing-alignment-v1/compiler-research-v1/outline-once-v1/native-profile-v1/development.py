#!/usr/bin/env python3
"""Focused direct development: prepare only, then a separately admitted guarded run.

No relocated imports, installed resolver discovery, or performance work.
This does not establish complete installed-tool/resolver qualification.
"""
import argparse
import resource
import time
import fcntl
import hashlib
import types
import stat
import json
import os
import gzip
import re
import sys
from pathlib import Path

ROOT = Path('/workspace/formal-proofs/bendvy')
HERE = Path(__file__).resolve().parent.parent
EXPECTED = '810259f78227f2b3d158c02644978b6c7ecf58b40a4b2fb398a816005b2867e2'


def sha(path):
    path=Path(path)
    if path.is_symlink() or not path.is_file():raise ValueError('regular non-symlink file required')
    fd=os.open(path,os.O_RDONLY|os.O_NOFOLLOW|os.O_NONBLOCK)
    with os.fdopen(fd,'rb') as stream:
        if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode):raise ValueError('regular descriptor required')
        return hashlib.sha256(stream.read()).hexdigest()


VERIFIED_SOURCES={}
def load(name,path):
    path=Path(path).resolve(strict=True)
    source=VERIFIED_SOURCES[str(path)] if VERIFIED_SOURCES else path.read_bytes()
    module=types.ModuleType(name);module.__file__=str(path)
    module.__dict__['VERIFIED_SOURCES']=VERIFIED_SOURCES
    exec(compile(source,str(path),'exec'),module.__dict__)
    return module


def write_raw(target, value):
    target = Path(target)
    if target.exists() or target.is_symlink():
        raise ValueError('Raw output must start absent')
    fd=os.open(target,os.O_WRONLY|os.O_CREAT|os.O_EXCL|os.O_NOFOLLOW,0o600)
    with os.fdopen(fd,'wb') as stream:
        if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode):raise ValueError('regular raw descriptor required')
        stream.write(value);stream.flush();os.fsync(stream.fileno())


def verify_raw(target, expected):
    target = Path(target)
    if target.is_symlink() or not target.is_file():
        raise ValueError('Raw stream must be a regular non-symlink file')
    if sha(target) != expected:
        raise ValueError('Raw stream changed')


def validate_imports(stage, inventory):
    stage = Path(stage).resolve(strict=True)
    reached = set()
    def visit(path):
        path = path.resolve(strict=True)
        if path in reached:
            return
        reached.add(path)
        for target in re.findall(r'^import\s+(\S+)', path.read_text(), re.MULTILINE):
            resolved = Path('/home/node/.bend/bend2/base.bend') if target == 'Base' else (path.parent / target).resolve(strict=True)
            if target != 'Base' and str(resolved.relative_to(stage)) not in inventory:
                raise ValueError('Import escapes frozen stage')
            if target != 'Base':
                visit(resolved)
    visit(stage / 'output-io-main.bend')
    return sorted(str(p.relative_to(stage)) for p in reached)



def accounted_child(execute, *arguments):
    # RUSAGE_CHILDREN covers reaped descendants of this collector, not RSS or
    # throughput. The shared lock excludes other owned children in this window.
    before = resource.getrusage(resource.RUSAGE_CHILDREN)
    started = time.monotonic_ns()
    result = execute(*arguments)
    ended = time.monotonic_ns()
    after = resource.getrusage(resource.RUSAGE_CHILDREN)
    result['childAccounting'] = {
        'scope': 'collector reaped children delta around execute_result; not runtime performance',
        'wallNs': ended - started,
        'userSeconds': after.ru_utime - before.ru_utime,
        'systemSeconds': after.ru_stime - before.ru_stime,
        'before': {'userSeconds': before.ru_utime, 'systemSeconds': before.ru_stime},
        'after': {'userSeconds': after.ru_utime, 'systemSeconds': after.ru_stime}}
    return result


def run(plan_path, expected_sha):
    plan_path = Path(plan_path).resolve(strict=True)
    if sha(plan_path) != expected_sha:
        raise ValueError('Admitted plan digest mismatch')
    plan = json.loads(plan_path.read_text())
    actual=Path(sys.executable).resolve(strict=True)
    if str(actual)!=plan['tools']['python'] or sha(actual)!=plan['pins'][str(actual)]:raise ValueError('actual interpreter differs before helpers')
    if {path: sha(path) for path in plan['pins']} != plan['pins']:
        raise ValueError('Frozen boundary changed before helper import')
    global VERIFIED_SOURCES
    VERIFIED_SOURCES={name:Path(name).read_bytes()for name in plan['pins']if name.endswith('.py')}
    if any(hashlib.sha256(raw).hexdigest()!=plan['pins'][name]for name,raw in VERIFIED_SOURCES.items()):raise ValueError('captured helper source drift')
    out = plan_path.parent
    runner = load('task_runner', ROOT / 'scripts/task_runner.py')
    boundary = load('evidence_boundary', ROOT / 'scripts/evidence_boundary.py')
    pins = dict(plan['pins'])
    pins[str(plan_path)] = expected_sha
    generated = Path(plan['generated'])
    native = Path(plan['native'])
    record = {'scope': plan['scope'], 'planSHA256': expected_sha, 'commands': [], 'guards': []}

    def guard(label):
        for artifact in (generated, native):
            if str(artifact) in pins and (artifact.is_symlink() or not artifact.is_file()):
                raise ValueError('Generated artifact must be a regular non-symlink file')
        for row in record['commands']:
            for key in ('stdout', 'stderr'):
                if key in row and row[key].get('published',False):
                    verify_raw(row[key]['path'],row[key]['sha256'])
                elif key in row and 'partialSHA256' in row[key]:
                    verify_raw(row[key]['path'],row[key]['partialSHA256'])
        if validate_imports(plan['stage'], plan['sourceInventory']) != plan['importClosure']:
            raise ValueError('Import closure changed')
        actual = {path: sha(path) for path in pins}
        unchanged = actual == pins and {str(p.relative_to(plan['stage'])): sha(p) for p in Path(plan['stage']).rglob('*.bend')} == plan['sourceInventory'] and runner.Inputs(directories=plan['resourceRoots']).expected == plan['resourceRoots']
        receipt = {'label': label, 'actualPins': actual, 'unchanged': unchanged}
        target = out / (label + '.guard.json')
        write_raw(target,(json.dumps(receipt,indent=2)+'\n').encode())
        record['guards'].append({'path': str(target), 'sha256': sha(target)})
        if not unchanged:
            raise ValueError('Source/oracle/tool/helper boundary changed: ' + label)

    with boundary.ReceiptBoundary(record, out / 'receipt.json', [('final boundary', lambda: guard('final'))]):
        for command in plan['commands']:
            label = command['label']
            guard(label + '-pre')
            with boundary.GuardBoundary([('post boundary', lambda: guard(label + '-post'))]):
                with open('/tmp/bendvy-parity-heavy.lock', 'a') as lock:
                    fcntl.flock(lock, fcntl.LOCK_EX)
                    try:
                        guard(label + '-acquired')
                        artifact = generated if label == 'emit' else native
                        if label in ('emit', 'build') and (artifact.exists() or artifact.is_symlink()):
                            raise ValueError('Generated output must start absent')
                        if label == 'profile':
                            for name in ('samples.json', 'target.stdout', 'target.stderr'):
                                if (out / name).exists() or (out / name).is_symlink():
                                    raise ValueError('Diagnostic artifact must start absent')
                        # The admitted digest is the externally verified launch
                        # argument, avoiding a circular hash inside plan bytes.
                        actual_argv = command['argv'] + ([expected_sha] if label == 'profile' else [])
                        result = accounted_child(runner.execute_result, actual_argv, command['capSeconds'], plan['environment'], plan['cwd'], 'split')
                    finally:
                        fcntl.flock(lock, fcntl.LOCK_UN)
                row=dict(command)
                row['actualArgv'] = actual_argv
                row.update({key:value for key,value in result.items() if not isinstance(value,bytes)})
                # Retain completed child facts and BOTH captured stream identities first.
                for key in ('stdout','stderr'):
                    value=result[key]
                    row[key]={'path':str(out/(label+'.'+key)),'sha256':hashlib.sha256(value).hexdigest(),'bytes':len(value),'published':False}
                record['commands'].append(row)
                publication_error=None
                diagnostic_capture_error=None
                try:
                    for key in ('stdout','stderr'):
                        target=Path(row[key]['path']);write_raw(target,result[key])
                        verify_raw(target,row[key]['sha256']);row[key]['published']=True
                        pins[str(target)]=row[key]['sha256']
                except BaseException as error:
                    publication_error=error
                    row['captureError']=f'{type(error).__name__}: {error}'
                    for key in ('stdout','stderr'):
                        if not row[key]['published']:
                            # Failure-only complete recovery bytes, not a normalized output.
                            row[key]['unpublishedHex']=result[key].hex()
                            target=Path(row[key]['path'])
                            if target.is_file() and not target.is_symlink():
                                try:
                                    row[key]['partialSHA256']=sha(target);pins[str(target)]=row[key]['partialSHA256']
                                except BaseException as partial_error:
                                    row[key]['partialCaptureError']=f'{type(partial_error).__name__}: {partial_error}'
                                    error.add_note('partial raw capture: '+str(partial_error))
                    raise
                finally:
                    if label == 'profile':
                        row['diagnosticArtifacts'] = {}
                        for name in ('samples.json', 'target.stdout', 'target.stderr'):
                            target = out / name
                            if target.exists() or target.is_symlink():
                                try:
                                    digest = sha(target)
                                    pins[str(target)] = digest
                                    row['diagnosticArtifacts'][name] = {'path': str(target), 'sha256': digest, 'bytes': target.stat().st_size}
                                except BaseException as error:
                                    row['diagnosticArtifacts'][name] = {'captureError': f'{type(error).__name__}: {error}'}
                                    diagnostic_capture_error = error
                                    if publication_error is not None:
                                        publication_error.add_note('diagnostic raw capture: ' + str(error))
                    if label in ('emit','build') and (artifact.exists() or artifact.is_symlink()):
                        try:
                            pins[str(artifact)]=sha(artifact)
                            record[label+'ArtifactSHA256']=pins[str(artifact)]
                        except BaseException as error:
                            record[label+'ArtifactCaptureError']=f'{type(error).__name__}: {error}'
                            if publication_error is not None:publication_error.add_note('artifact capture: '+str(error))
                            else:raise
                if result['exit'] != 0 or result['failure'] is not None:
                    raise ValueError('Owned child failed: ' + label)
                if diagnostic_capture_error is not None:
                    raise diagnostic_capture_error
                if label in ('emit', 'build'):
                    artifact = generated if label == 'emit' else native
                    if artifact.is_symlink() or not artifact.is_file():
                        raise ValueError('Emit did not produce a regular non-symlink artifact')
                    pins[str(artifact)] = sha(artifact)
                    record[label + 'ArtifactSHA256'] = pins[str(artifact)]
                elif label == 'symbols':
                    if result['stderr']:
                        raise ValueError('nm stderr is not empty')
                elif label == 'profile':
                    summary = json.loads(result['stdout'])
                    if summary['status'] != 'DIAGNOSTIC_CAPTURED':
                        raise ValueError('Sampler did not capture bounded diagnostic')
                    required = {'samples.json', 'target.stdout', 'target.stderr'}
                    if set(summary['artifacts']) != required:
                        raise ValueError('Sampler raw artifact membership incomplete')
                    for name, artifact in summary['artifacts'].items():
                        expected_path = out / name
                        if artifact['path'] != str(expected_path):
                            raise ValueError('Sampler artifact escaped planned output')
                        verify_raw(expected_path, artifact['sha256'])
                        if expected_path.stat().st_size != artifact['bytes']:
                            raise ValueError('Sampler artifact length differs')
                        pins[str(expected_path)] = artifact['sha256']
                    samples = json.loads((out / 'samples.json').read_text())
                    if samples.get('cleanupError') or samples['targetSeconds'] != 5:
                        raise ValueError('Sampler cleanup or target budget invalid')
                    if len(samples['samples']) != summary['sampleCount']:
                        raise ValueError('Raw sample count join differs')
                    record['diagnosticSummary'] = summary
                    record['semanticAcceptance'] = False
                else:
                    raise ValueError('Unknown diagnostic stage')
        record['status'] = 'BOUNDED_PC_DIAGNOSTIC_CAPTURED_NOT_SEMANTIC_ACCEPTANCE'


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('plan')
    parser.add_argument('admitted_sha256')
    args=parser.parse_args()
    run(args.plan,args.admitted_sha256)

if __name__=='__main__':main()
