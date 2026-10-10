#!/usr/bin/env python3
"""Focused direct development: prepare only, then a separately admitted guarded run.

No relocated imports, installed resolver discovery, or performance work.
This does not establish complete installed-tool/resolver qualification.
"""
import argparse
import fcntl
import hashlib
import importlib.util
import json
import os
import sys
import stat
from pathlib import Path

ROOT = Path('/workspace/formal-proofs/bendvy')
HERE = Path(__file__).resolve().parent
TRANSPORT = HERE.parent / 'transport-v1'
ENTRY = HERE.parent / 'main.bend'
CONTROL = False
EXPECTED = '56d0de7ab8d614c5eccd395d3c7cc349fd7ad20d783d302bea6b4ba98a8956c3'



def sha(path):
    path = Path(path)
    if path.is_symlink() or not path.is_file():
        raise ValueError('Pinned/generated/raw file must be regular and non-symlink')
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
    with os.fdopen(fd, 'rb') as source:
        if not stat.S_ISREG(os.fstat(source.fileno()).st_mode):
            raise ValueError('Pinned/generated/raw descriptor must be regular')
        return hashlib.sha256(source.read()).hexdigest()


def write_raw(path, data):
    path = Path(path)
    if path.exists() or path.is_symlink():
        raise ValueError('Raw capture must start absent and non-symlink')
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
    with os.fdopen(fd, 'wb') as output:
        if not stat.S_ISREG(os.fstat(output.fileno()).st_mode):
            raise ValueError('Raw capture descriptor is not regular')
        output.write(data)
    if path.is_symlink() or not path.is_file():
        raise ValueError('Raw capture changed file type')


def publish_result(command, result, out, pins, record, artifact):
    label = command['label']
    row = dict(command)
    row.update({key: {'retainedRawHex': value.hex()} if isinstance(value, bytes) else value
                for key, value in result.items()})
    record['commands'].append(row)  # Actual completed child survives publication failure.
    primary = None
    try:
        for key, value in result.items():
            if isinstance(value, bytes):
                target = out / (label + '.' + key)
                write_raw(target, value)
                row[key] = {'path': str(target), 'sha256': sha(target), 'bytes': len(value)}
                pins[str(target)] = row[key]['sha256']
    except BaseException as error:
        primary = error
        row['publicationError'] = repr(error)
        raise
    finally:
        try:
            if artifact is not None and (artifact.exists() or artifact.is_symlink()):
                pins[str(artifact)] = sha(artifact)
                record['generatedSHA256' if label == 'emit' else 'buildArtifactSHA256'] = pins[str(artifact)]
        except BaseException as error:
            row['artifactCaptureError'] = repr(error)
            if primary is None:
                raise


VERIFIED_SOURCES = {}

def load(name, path):
    import types
    path = Path(path).resolve(strict=True)
    source = VERIFIED_SOURCES[str(path)] if VERIFIED_SOURCES else path.read_bytes()
    module = types.ModuleType(name)
    module.__file__ = str(path)
    module.__dict__['VERIFIED_SOURCES'] = VERIFIED_SOURCES
    exec(compile(source, str(path), 'exec'), module.__dict__)
    return module

def resource_snapshot(roots):
    return {str(Path(root)): {str(p.relative_to(Path(root))): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in sorted(Path(root).rglob('*')) if p.is_file()} for root in roots}


def prepare(output):
    source_index = HERE.parent / 'BACKEND-PREPARED-v1.json'
    index = json.loads(source_index.read_bytes())
    pins = {str(Path(__file__).resolve()): sha(Path(__file__)), str(source_index): sha(source_index),
            str(HERE / 'README.md'): sha(HERE / 'README.md'),
            str(HERE / 'test-admission.py'): sha(HERE / 'test-admission.py'),
            str(HERE / 'test-sampling.py'): sha(HERE / 'test-sampling.py'),
            str(HERE / 'sampling-io.py'): sha(HERE / 'sampling-io.py'),
            str(HERE / 'SAMPLING-SOURCE-DELTA.json'): sha(HERE / 'SAMPLING-SOURCE-DELTA.json'),
            str(Path('/workspace/formal-proofs/bendvy/experiments/public-simulation/delivery-v1/timing-v1/sampling.py')): sha(Path('/workspace/formal-proofs/bendvy/experiments/public-simulation/delivery-v1/timing-v1/sampling.py')),
            str(ROOT / 'benchmarks/contract.json'): sha(ROOT / 'benchmarks/contract.json')}
    roles = {}
    resources = None
    for item in index['plans'][:3]:
        plan_path = Path(item['plan']);plan = json.loads(plan_path.read_bytes())
        if sha(plan_path) != item['sha256']:
            raise ValueError('Qualified semantic plan changed')
        receipt_path = plan_path.parent / 'receipt.json'
        receipt = json.loads(receipt_path.read_bytes())
        if receipt['status'] != 'DEVELOPMENT_PASS' or receipt['planSHA256'] != item['sha256']:
            raise ValueError('Prior entire semantic/protocol qualification required')
        for name, value in plan['pins'].items():
            if sha(name) != value:raise ValueError('Semantic input changed before preparation: ' + name)
            if name in pins and pins[name] != value:raise ValueError('Conflicting source pin')
            pins[name] = value
        pins[str(plan_path)] = item['sha256'];pins[str(receipt_path)] = sha(receipt_path)
        last = receipt['commands'][-1]
        for field in ['stdout', 'stderr']:
            path = Path(last[field]['path']);pins[str(path)] = sha(path)
        role = {'positiveJS':'JS','positiveNative':'Native','positiveTS':'TS'}[item['label']]
        transport = Path(item['helper']).parent / ('ts-transport-v1' if role == 'TS' else 'transport-v1')
        roles[role] = {'command':plan['commands'][-1]['argv'], 'environment':plan['environment'],
                       'cwd':plan['cwd'],'entrypoint':plan['entrypoint'],'transport':str(transport / 'transport.py'),
                       'inventory':plan['constructorInventory'],'oracle':plan['oracle'],
                       'expectedSHA256':plan['expectedSHA256']}
        for artifact in [plan['generated'], plan.get('native')]:
            if artifact is not None:pins[artifact] = sha(artifact)
        if role == 'Native':resources = {k:plan[k] for k in ['resourceRoots','resourceInventory']}
    contract = json.loads((ROOT / 'benchmarks/contract.json').read_bytes())
    if (contract['pairs'],contract['warmups'],contract['seed']) != (20,2,20261007):
        raise ValueError('Existing accepted paired feature schedule changed')
    sampler=load('sampling_io',HERE/'sampling-io.py')
    rows=sampler.schedule(contract,[1])
    commands=[dict(label=row['label'],role=row['role'],capSeconds=5,argv=roles[row['role']]['command']) for row in rows]
    for name in ['ACTUAL-PUBLIC-JOIN.json','EXECUTION-RESULT.json']:
        path=HERE.parent/name;pins[str(path)]=sha(path)
    pins[str(HERE.parent/'verify-evidence.py')]=sha(HERE.parent/'verify-evidence.py')
    plan={'scope':'Complete matched ten-world/twenty-snapshot bundle feature IO regions; descriptive paired evidence, separate unchanged #28 gate',
          'roles':roles,'pins':pins,'tools':{'python':str(Path(sys.executable).resolve())},
          'commands':commands,'samplingRows':rows,'samplingHelper':str(HERE/'sampling-io.py'),'warmups':2,'seed':contract['seed'],
          'quietWindowPrerequisite':'Root must admit exact plan and reserve whole-cohort queue; explicit quiet/context is retained, telemetry alone is not quiet authorization',
          'wholeCohortLock':'/tmp/bendvy-parity-heavy.lock','cpu':5,
          'targets':{'JS':'JS <= TS','Native':'Native <= 0.5 * TS'},
          'observationOverhead':'All actual constructor, owner/undo/teardown and diagnostic string/capture work stays inside IO regions; Bend16012 and TS4606 bytes differ; no subtraction/normalization',
          **resources}
    if resource_snapshot(plan['resourceRoots']) != plan['resourceInventory']:
        raise ValueError('Qualified resources changed')
    out=Path(output).resolve();out.mkdir(parents=True,exist_ok=False)
    (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(sha(out/'plan.json'))


def telemetry():
    data={'loadavg':Path('/proc/loadavg').read_text().strip(),
          'cpuStat':next(line for line in Path('/proc/stat').read_text().splitlines() if line.startswith('cpu5 '))}
    for name,path in [('pressure','/proc/pressure/cpu'),('frequency','/sys/devices/system/cpu/cpu5/cpufreq/scaling_cur_freq')]:
        target=Path(path)
        if target.exists():data[name]=target.read_text().strip()
    return data


def run(plan_path, expected_sha, quiet_context):
    if not quiet_context.strip():raise ValueError('Explicit root-established quiet/window context required')
    plan_path=Path(plan_path).resolve(strict=True)
    if sha(plan_path)!=expected_sha:raise ValueError('Admitted plan digest mismatch')
    plan=json.loads(plan_path.read_bytes());python=str(Path(sys.executable).resolve(strict=True))
    if python!=plan['tools']['python'] or sha(python)!=plan['pins'][python]:
        raise ValueError('Actual executor interpreter differs')
    if {name:sha(name) for name in plan['pins']}!=plan['pins']:
        raise ValueError('Frozen boundary changed before helper import')
    if resource_snapshot(plan['resourceRoots'])!=plan['resourceInventory']:
        raise ValueError('Resources changed before helper imports')
    global VERIFIED_SOURCES
    VERIFIED_SOURCES={name:Path(name).read_bytes() for name in plan['pins'] if name.endswith('.py')}
    if any(hashlib.sha256(data).hexdigest()!=plan['pins'][name] for name,data in VERIFIED_SOURCES.items()):
        raise ValueError('Captured helper bytes changed before import')
    runner=load('task_runner',ROOT/'scripts/task_runner.py')
    boundary=load('evidence_boundary',ROOT/'scripts/evidence_boundary.py')
    sampler=load('sampling_io',plan['samplingHelper'])
    transports={role:load('transport_'+role,info['transport']) for role,info in plan['roles'].items()}
    inventories={role:json.loads(Path(info['inventory']).read_bytes()) for role,info in plan['roles'].items()}
    pins=dict(plan['pins']);pins[str(plan_path)]=expected_sha;out=plan_path.parent
    record={'scope':plan['scope'],'planSHA256':expected_sha,'quietWindowContext':quiet_context,
            'commands':[],'guards':[],'observations':[],'samplingRaw':[],'windowBefore':telemetry()}
    def guard(label):
        actual={name:sha(name) for name in pins};current=resource_snapshot(plan['resourceRoots'])
        unchanged=actual==pins and current==plan['resourceInventory'] and all(transports[role].Transport(info['entrypoint']).inventory()==inventories[role] for role,info in plan['roles'].items())
        target=out/(label+'.guard.json')
        target.write_text(json.dumps({'label':label,'actualPins':actual,'actualResources':current,'unchanged':unchanged},indent=2)+'\n')
        record['guards'].append({'path':str(target),'sha256':sha(target)})
        if not unchanged:raise ValueError('Full timing boundary changed: '+label)
    with boundary.ReceiptBoundary(record,out/'receipt.json',[('final boundary',lambda:guard('final'))]):
        guard('before')
        with open(plan['wholeCohortLock'],'a') as lock:
            fcntl.flock(lock,fcntl.LOCK_EX)
            try:
                guard('acquired')
                for command in plan['commands']:
                    label=command['label'];role=command['role'];role_key=command['roleKey'];info=plan['roles'][role_key]
                    guard(label+'-pre');before=telemetry()
                    with boundary.GuardBoundary([('post boundary',lambda:guard(label+'-post'))]):
                        result=runner.execute_result(command['argv'],command['capSeconds'],info['environment'],info['cwd'],'split')
                        publish_result(command,result,out,pins,record,None)
                        expected=Path(info['oracle']).read_bytes()
                        if hashlib.sha256(expected).hexdigest()!=info['expectedSHA256']:raise ValueError('Whole oracle changed')
                        validated=transports[role_key].validate_result(result,json.loads(expected),False)
                        record['observations'].append({'label':label,'role':role,'samplingRow':next(row for row in plan['samplingRows'] if row['label']==label),'before':before,'after':telemetry(),'region':validated['timer']})
                    record['samplingRaw'].append({'label':label,'stderr':{'rawHex':result['stderr'].hex()}})
                record['windowAfter']=telemetry()
            finally:
                fcntl.flock(lock,fcntl.LOCK_UN)
        summary=sampler.summarize(plan['samplingRows'],record['samplingRaw'])
        record.update(status='COMPLETE_FEATURE_OBSERVATIONS',summary=summary,
                      qualification='Root assesses explicit window evidence and unchanged targets; no new statistical criterion, scaling/full-core/issue closure inferred')


if __name__=='__main__':
    parser=argparse.ArgumentParser();sub=parser.add_subparsers(dest='command',required=True)
    prepare_parser=sub.add_parser('prepare');prepare_parser.add_argument('output')
    run_parser=sub.add_parser('run');run_parser.add_argument('plan');run_parser.add_argument('admitted_sha256');run_parser.add_argument('quiet_window_context')
    args=parser.parse_args()
    if args.command=='prepare':prepare(args.output)
    else:run(args.plan,args.admitted_sha256,args.quiet_window_context)
