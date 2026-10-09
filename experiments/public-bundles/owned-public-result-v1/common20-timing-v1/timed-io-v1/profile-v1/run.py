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

ROOT = Path(__file__).resolve().parents[6]
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
    basis = Path('/tmp/bendvy-bundle41-common20-paired03/plan.json')
    if sha(basis) != 'eb624a9f20d5a1c8535e664a50021764b60e73ddb0fb56490d681342bcea861d':
        raise ValueError('Exact qualified feature basis required')
    original = json.loads(basis.read_bytes())
    info = original['roles']['JS']
    out = Path(output).resolve()
    if out.exists() or out.is_symlink():raise ValueError('Fresh diagnostic directory required')
    validator = Path('/workspace/formal-proofs/bendvy/experiments/public-simulation/delivery-v1/optimization-v1/validate-after-profile.py')
    join = HERE.parent.parent / 'shared-public-join.py'
    ts_stdout = Path('/tmp/bendvy-bundle41-io-timed-ts01/consumer.stdout')
    pins = dict(original['pins'])
    for path in [basis,HERE/'run.py',HERE/'README.md',HERE/'test-profile.py',validator,join,ts_stdout]:
        pins[str(path)] = sha(path)
    # Exact JS command is taskset -c 5 Node generated-artifact; no IO/source rewrite.
    argv = info['command']
    if argv[1:3] != ['-c','5'] or len(argv) != 5:raise ValueError('Qualified Node command shape changed')
    commands=[]
    for role,flag,name,interval in [('CPU','--cpu-prof','bundle.cpuprofile','100'),('allocation','--heap-prof','bundle.heapprofile','8192')]:
        commands.append(dict(label=role,role=role,capSeconds=5,profile=str(out/name),argv=argv[:4]+[flag,flag+'-dir='+str(out),flag+'-name='+name,flag+'-interval='+interval,argv[4]]))
    plan=dict(scope='Whole-process CPU/sampled-allocation diagnostic of unchanged qualified bundle IO application; not region-only, total-allocation or comparative timing qualification',
              pins=pins,tools=original['tools'],commands=commands,roles={'JS':info},
              resourceRoots=original['resourceRoots'],resourceInventory=original['resourceInventory'],
              wholeCohortLock=original['wholeCohortLock'],cpu=5,profileValidator=str(validator),
              join=str(join),tsStdout=str(ts_stdout),basis=str(basis))
    if {name:sha(name) for name in pins} != pins:raise ValueError('Qualified source drift')
    if resource_snapshot(plan['resourceRoots']) != plan['resourceInventory']:raise ValueError('Resource drift')
    out.mkdir();(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(sha(out/'plan.json'))


def telemetry():
    data={'loadavg':Path('/proc/loadavg').read_text().strip(),
          'cpuStat':next(line for line in Path('/proc/stat').read_text().splitlines() if line.startswith('cpu5 '))}
    for name,path in [('pressure','/proc/pressure/cpu'),('frequency','/sys/devices/system/cpu/cpu5/cpufreq/scaling_cur_freq')]:
        target=Path(path)
        if target.exists():data[name]=target.read_text().strip()
    return data


def run(plan_path, expected_sha):
    plan_path=Path(plan_path).resolve(strict=True)
    if sha(plan_path)!=expected_sha:raise ValueError('Admitted plan digest mismatch')
    plan=json.loads(plan_path.read_bytes());python=str(Path(sys.executable).resolve(strict=True))
    if python!=plan['tools']['python'] or sha(python)!=plan['pins'][python]:raise ValueError('Actual interpreter differs')
    if {name:sha(name) for name in plan['pins']}!=plan['pins']:raise ValueError('Inputs changed before helper imports')
    if resource_snapshot(plan['resourceRoots'])!=plan['resourceInventory']:raise ValueError('Resources changed before imports')
    global VERIFIED_SOURCES
    VERIFIED_SOURCES={name:Path(name).read_bytes() for name in plan['pins'] if name.endswith('.py')}
    if any(hashlib.sha256(data).hexdigest()!=plan['pins'][name] for name,data in VERIFIED_SOURCES.items()):raise ValueError('Captured source changed')
    runner=load('task_runner',ROOT/'scripts/task_runner.py');boundary=load('evidence_boundary',ROOT/'scripts/evidence_boundary.py')
    validator=load('profile_shape',plan['profileValidator']);join=load('public_join',plan['join'])
    info=plan['roles']['JS'];transport=load('transport',info['transport'])
    inventory=json.loads(Path(info['inventory']).read_bytes());pins=dict(plan['pins']);pins[str(plan_path)]=expected_sha;out=plan_path.parent
    for command in plan['commands']:
        for path in [Path(command['profile']),out/(command['label']+'.stdout'),out/(command['label']+'.stderr')]:
            if path.exists() or path.is_symlink():raise ValueError('Fresh diagnostic artifacts required')
    if (out/'receipt.json').exists():raise ValueError('Existing receipt refuses replay')
    record=dict(scope=plan['scope'],planSHA256=expected_sha,commands=[],guards=[],observations=[])
    def guard(label):
        actual={name:sha(name) for name in pins};resources=resource_snapshot(plan['resourceRoots'])
        unchanged=actual==pins and resources==plan['resourceInventory'] and transport.Transport(info['entrypoint']).inventory()==inventory
        target=out/(label+'.guard.json');write_raw(target,(json.dumps(dict(actualPins=actual,actualResources=resources,unchanged=unchanged),indent=2)+'\n').encode())
        record['guards'].append(dict(path=str(target),sha256=sha(target)))
        if not unchanged:raise ValueError('Diagnostic boundary changed: '+label)
    with boundary.ReceiptBoundary(record,out/'receipt.json',[('final boundary',lambda:guard('final'))]):
        guard('before')
        with open(plan['wholeCohortLock'],'a') as lock:
            fcntl.flock(lock,fcntl.LOCK_EX)
            try:
                guard('acquired')
                for command in plan['commands']:
                    label=command['label'];guard(label+'-pre')
                    with boundary.GuardBoundary([('post boundary',lambda:guard(label+'-post'))]):
                        result=runner.execute_result(command['argv'],5,info['environment'],info['cwd'],'split')
                        publish_result(command,result,out,pins,record,Path(command['profile']))
                        oracle=Path(info['oracle']).read_bytes()
                        if hashlib.sha256(oracle).hexdigest()!=info['expectedSHA256']:raise ValueError('Whole oracle changed')
                        validated=transport.validate_result(result,json.loads(oracle),False)
                        profile=json.loads(Path(command['profile']).read_bytes());validator.validate_shape(command['role'],profile)
                        full=join.compare(result['stdout'].decode('utf8'),Path(plan['tsStdout']).read_text())
                        record['observations'].append(dict(role=command['role'],timer=validated['timer'],profileSHA256=sha(command['profile']),publicJoin=full))
            finally:fcntl.flock(lock,fcntl.LOCK_UN)
        record['status']='COMPLETE_WHOLE_PROCESS_DIAGNOSTIC'


if __name__=='__main__':
    parser=argparse.ArgumentParser();sub=parser.add_subparsers(dest='command',required=True)
    prepare_parser=sub.add_parser('prepare');prepare_parser.add_argument('output')
    run_parser=sub.add_parser('run');run_parser.add_argument('plan');run_parser.add_argument('admitted_sha256');
    args=parser.parse_args()
    if args.command=='prepare':prepare(args.output)
    else:run(args.plan,args.admitted_sha256)
