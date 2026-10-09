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
        'before': {'userSeconds': before.ru_utime, 'systemSeconds': before.ru_stime, 'subtreeMaxRSSKiB': before.ru_maxrss},
        'after': {'userSeconds': after.ru_utime, 'systemSeconds': after.ru_stime, 'subtreeMaxRSSKiB': after.ru_maxrss},
        'RSSScope': 'Linux KiB peak across reaped subprocess subtree, including supervisor owner and Node; not Node-only, live heap or timed-region RSS'}
    return result


def validate_profile(kind, profile):
    if type(profile) is not dict:
        raise ValueError('complete profile object required')
    if kind == 'CPU':
        nodes = profile.get('nodes')
        samples = profile.get('samples')
        deltas = profile.get('timeDeltas')
        if type(nodes) is not list or not nodes or type(samples) is not list or type(deltas) is not list or len(samples) != len(deltas):
            raise ValueError('complete CPU profile required')
        ids = set()
        for node in nodes:
            if type(node) is not dict or type(node.get('id')) is not int or node['id'] in ids or type(node.get('callFrame')) is not dict:
                raise ValueError('CPU node identity/frame invalid')
            ids.add(node['id'])
        if any(type(value) is not int or value not in ids for value in samples) or any(type(value) is not int or value < 0 for value in deltas):
            raise ValueError('CPU sample identity/duration invalid')
        if any(type(child) is not int or child not in ids for node in nodes for child in node.get('children', [])):
            raise ValueError('CPU child identity invalid')
    elif kind == 'allocation':
        head = profile.get('head')
        samples = profile.get('samples')
        if type(head) is not dict or type(samples) is not list:
            raise ValueError('complete sampled heap profile required')
        pending = [head];ids = set()
        while pending:
            node = pending.pop()
            if type(node) is not dict or type(node.get('id')) is not int or node['id'] in ids or type(node.get('callFrame')) is not dict or type(node.get('selfSize')) is not int or node['selfSize'] < 0 or type(node.get('children')) is not list:
                raise ValueError('sampled heap node invalid')
            ids.add(node['id']);pending.extend(node['children'])
        if any(type(sample) is not dict or type(sample.get('nodeId')) is not int or sample['nodeId'] not in ids or type(sample.get('size')) is not int or sample['size'] < 0 for sample in samples):
            raise ValueError('sampled heap sample identity/size invalid')
    else:
        raise ValueError('unknown profile mode')


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
                        profile = Path(plan['profileArtifact'])
                        if profile.exists() or profile.is_symlink():
                            raise ValueError('Profile output must start absent')
                        result = accounted_child(runner.execute_result, command['argv'], command['capSeconds'], plan['environment'], plan['cwd'], 'split')
                    finally:
                        fcntl.flock(lock, fcntl.LOCK_UN)
                row=dict(command)
                row.update({key:value for key,value in result.items() if not isinstance(value,bytes)})
                # Retain completed child facts and BOTH captured stream identities first.
                for key in ('stdout','stderr'):
                    value=result[key]
                    row[key]={'path':str(out/(label+'.'+key)),'sha256':hashlib.sha256(value).hexdigest(),'bytes':len(value),'published':False}
                record['commands'].append(row)
                publication_error=None
                profile_capture_error=None
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
                    profile = Path(plan['profileArtifact'])
                    if profile.exists() or profile.is_symlink():
                        try:
                            digest = sha(profile);pins[str(profile)] = digest
                            row['profileArtifact'] = {'path': str(profile), 'sha256': digest, 'bytes': profile.stat().st_size}
                        except BaseException as error:
                            row['profileArtifactCaptureError'] = f'{type(error).__name__}: {error}'
                            profile_capture_error = error
                            if publication_error is not None:
                                publication_error.add_note('profile capture: ' + str(error))
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
                if profile_capture_error is not None:
                    raise profile_capture_error
                if label in ('emit', 'build'):
                    artifact = generated if label == 'emit' else native
                    if artifact.is_symlink() or not artifact.is_file():
                        raise ValueError('Emit did not produce a regular non-symlink artifact')
                    pins[str(artifact)] = sha(artifact)
                    record[label + 'ArtifactSHA256'] = pins[str(artifact)]
                else:
                    if result['stderr']:
                        raise ValueError('Consumer stderr is not empty')
                    expected_bytes = gzip.decompress(Path(plan['oracle']).read_bytes())
                    if len(expected_bytes) != plan['oracleBytes'] or hashlib.sha256(expected_bytes).hexdigest() != EXPECTED:
                        raise ValueError('Whole oracle changed')
                    if result['stdout'] != expected_bytes:
                        raise ValueError('Complete consumer byte output differs from whole independent oracle')
                    record['wholeOracleSHA256'] = EXPECTED
                    profile = Path(plan['profileArtifact'])
                    if not profile.is_file() or profile.is_symlink():
                        raise ValueError('No regular complete profile produced')
                    validate_profile(plan['profileKind'], json.loads(profile.read_bytes()))
                    record['profileSHA256'] = sha(profile)
                    record['profileKind'] = plan['profileKind']
        record['status'] = 'WHOLE_OUTPUT_WITH_JS_PROFILE_CAPTURED_NOT_BENCHMARK'


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('plan')
    parser.add_argument('admitted_sha256')
    args=parser.parse_args()
    run(args.plan,args.admitted_sha256)

if __name__=='__main__':main()
