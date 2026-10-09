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


def validate_cost(data,plan):
    if set(data)!={'observed','mapping','loaded','templateInstances','bookDefinitions','compilerCompleted','primaryError'}:raise ValueError('cost fields')
    loaded=dict(data['loaded'])
    expected={str(Path(plan['stage'])/name)for name in plan['sourceInventory']}|{'/workspace/formal-proofs/bendvy/.references/bend2/bend2/base.bend'}
    if set(loaded)!=expected:raise ValueError('complete loaded source closure')
    for name in loaded:
        if sha(name)!=plan['pins'][name]:raise ValueError('loaded bytes drift')
    definitions={row['key']:row for row in data['bookDefinitions']};reverse={}
    for row in data['templateInstances']:
        for key in row['instances']:reverse.setdefault(key,[]).append(row['template'])
    observed=data['observed'];keys={row['key']for row in observed['rows']}
    if len(keys)!=len(observed['rows'])or {row['definition']for row in data['mapping']}!=keys:raise ValueError('counter/mapping membership')
    for row in observed['rows']:
        for key,value in row.items():
            if key!='key' and (type(value)not in(int,float)or value<0):raise ValueError('invalid cost counter')
        if row['entries']!=row['completed']+row['aborted']:raise ValueError('completed/aborted interval conservation')
    for row in data['mapping']:
        key=row['definition']
        if key=='':
            if row!={'definition':'','status':'not-declared'}:raise ValueError('outside-definition bucket')
            continue
        origins=reverse.get(key,[])
        if len(origins)>1:raise ValueError('ambiguous template')
        origin=origins[0]if origins else key
        if row.get('originTemplate')!=(origins[0]if origins else None):raise ValueError('unproven template origin')
        definition=definitions[origin];namespace=definition['namespace']
        local=origin if namespace==''else origin[len(namespace)+1:] if origin.startswith(namespace+':')else None
        if row['status']!='mapped' or row['namespace']!=namespace or row['localName']!=local or loaded.get(row['source'])!=namespace:raise ValueError('source namespace join')
        line=Path(row['source']).read_text().splitlines()[row['line']-1]
        if not re.match(r'^def '+re.escape(local)+r'(?:\W|$)',line)or row['sourceSHA256']!=plan['pins'][row['source']]:raise ValueError('lexical join')
    seen=set()
    for entry in observed['suppressedOnce']:
        if set(entry)!={'root','caller','callee','segment','count'}:raise ValueError('suppressed once fields')
        if any(type(entry[k]) is not str for k in ('root','caller','callee','segment')):raise ValueError('suppressed once identifiers')
        key=tuple(entry[k] for k in ('root','caller','callee','segment'))
        if key in seen or type(entry['count']) is not int or entry['count']<1:raise ValueError('suppressed once duplicate/count')
        seen.add(key)
        if any(entry[k] not in keys for k in ('root','caller','callee')):raise ValueError('suppressed once unmapped definition')
    if observed['active']:raise ValueError('unwound diagnostic stack expected')
    return {'definitions':len(keys),'compilerCompleted':data['compilerCompleted'],'cutoffStack':observed['cutoffStack'],'suppressedOnceSites':len(seen),'suppressedOnceCount':sum(row['count'] for row in observed['suppressedOnce'])}


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
        for artifact in (generated, native,Path(plan['costArtifact'])):
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
                        if label in ('emit', 'build') and any(p.exists()or p.is_symlink()for p in (artifact,Path(plan['costArtifact']))):
                            raise ValueError('Generated output must start absent')
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
                    cost=Path(plan['costArtifact'])
                    if cost.exists()or cost.is_symlink():
                        try:
                            pins[str(cost)]=sha(cost);record['costArtifactSHA256']=pins[str(cost)]
                            record['costSummary']=validate_cost(json.loads(cost.read_text()),plan)
                        except BaseException as error:
                            record['costCaptureError']=f'{type(error).__name__}: {error}'
                            if publication_error is not None:publication_error.add_note('cost capture: '+str(error))
                    else:record['costCaptureError']='cost artifact absent'
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
        if 'costSummary' not in record:raise ValueError('complete cost artifact missing')
        record['status']='INSTRUMENTED_C_EMISSION_WITH_COST_CAPTURED'


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('plan')
    parser.add_argument('admitted_sha256')
    args=parser.parse_args()
    run(args.plan,args.admitted_sha256)

if __name__=='__main__':main()
