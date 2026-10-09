#!/usr/bin/env python3
"""Focused direct development: prepare only, then a separately admitted guarded run.

No relocated imports, installed resolver discovery, or performance work.
This does not establish complete installed-tool/resolver qualification.
"""
import argparse
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

ROOT = Path('/workspace/formal-proofs/bendvy-worktrees/canonical-native-fanout')
REFERENCE_ROOT = Path('/workspace/formal-proofs/bendvy')
HERE = Path(__file__).resolve().parent
NORMAL_SHA = '810259f78227f2b3d158c02644978b6c7ecf58b40a4b2fb398a816005b2867e2'


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


def validate_imports(stage, inventory, entries=None):
    reached = set()
    def visit(path):
        path = path.resolve(strict=True)
        if str(path) not in inventory:
            raise ValueError('Import escapes exact frozen source inventory')
        if path in reached:
            return
        reached.add(path)
        for target in re.findall(r'^import\s+(\S+)', path.read_text(), re.MULTILINE):
            if target != 'Base':
                visit((path.parent / target).resolve(strict=True))
    for entry in entries or [Path(stage) / 'output-io-main.bend']:
        visit(Path(entry))
    if {str(path) for path in reached} != set(inventory):
        raise ValueError('Full consuming inventory has missing or unused entries')
    return sorted(str(path) for path in reached)


def prepare(out, role, subject):
    out = Path(out).resolve()
    catalogue = json.loads((HERE / 'ORACLES-v2.json').read_text())
    selection = catalogue[subject]
    expected_path = Path(selection['path']).resolve(strict=True)
    expected = gzip.decompress(expected_path.read_bytes())
    if len(expected) != selection['bytes'] or hashlib.sha256(expected).hexdigest() != selection['sha256']:
        raise ValueError('Independent complete oracle changed')
    baseline_path = Path(catalogue['normal']['path']).resolve(strict=True)
    baseline = gzip.decompress(baseline_path.read_bytes())
    if len(baseline) != 5077477 or hashlib.sha256(baseline).hexdigest() != NORMAL_SHA:
        raise ValueError('Original whole baseline changed')
    if subject == 'reader' and expected == baseline:
        raise ValueError('Reader countermodel must reject the complete normal baseline')
    stage = HERE / ('mutant-reader' if subject == 'reader' else 'stage')
    inventory = json.loads((HERE / 'source-inventory-v2.json').read_text())[subject]
    if {path: sha(path) for path in inventory} != inventory:
        raise ValueError('Complete canonical consuming source changed')
    import_closure = validate_imports(stage, inventory)
    source_dir = HERE / 'source-attempt01'
    # Retained direct source observations are inputs, not portable source acceptance.
    source_result = json.loads((source_dir / 'RESULT.json').read_text())
    for case in source_result['cases']:
        if case['exit'] != 1 or sha(HERE / 'negatives' / case['file']) != case['sourceSha256']:
            raise ValueError('Canonical negative source evidence changed')
        for stream in ('stdout', 'stderr'):
            if sha(source_dir / (Path(case['file']).stem + '.' + stream)) != case[stream+'Sha256']:
                raise ValueError('Canonical negative raw evidence changed')
    tools = {'bend': '/home/node/.bend/bin/bend-2.0.35', 'node':'/home/node/.local/share/mise/installs/node/24.20.0/bin/node', 'python': str(Path(sys.executable).resolve()), 'taskset': '/usr/bin/taskset',
             'clangWrapper': '/tmp/bendvy-clang19-diagnostic/clang19',
             'clangBinary': '/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'}
    config = REFERENCE_ROOT / 'experiments/public-simulation/delivery-v1/installed-config.py'
    configuration = load('installed_configuration', config)
    helper = load('preparation_runner', ROOT / 'scripts/task_runner.py')
    pins = dict(inventory)
    extra = [config, Path(__file__), HERE / 'source-inventory-v2.json', HERE / 'ORACLES-v2.json', expected_path, baseline_path,
             HERE / 'MIGRATION.json', HERE / 'READER-MIGRATION.json', HERE / 'test-preparation-v2.py', source_dir / 'RESULT.json',
             ROOT / 'scripts/task_runner.py', ROOT / 'scripts/evidence_boundary.py', *map(Path, tools.values())]
    extra.extend(source_dir / (Path(case['file']).stem + '.' + stream) for case in source_result['cases'] for stream in ('stdout','stderr'))
    extra.extend(HERE / 'negatives' / case['file'] for case in source_result['cases'])
    extra.extend(Path(path) for path in selection['basisInputs'])
    pins.update({str(path.resolve(strict=True)): sha(path) for path in extra})
    resources = helper.Inputs(directories=configuration.RESOURCE_ROOTS).expected
    env = configuration.environment()
    generated = out / ('scenario.c' if role=='native' else 'scenario.js')
    native = out / 'scenario.native'
    entry = str(stage / 'output-io-main.bend')
    plan = {'scope': 'Complete23-grant ordinary binding '+subject+' '+role+' development; no closed resolver/performance/public closure', 'role':role, 'subject':subject,
            'entrypoint': entry, 'stage': str(stage), 'sourceInventory': inventory, 'importClosure': import_closure,
            'pins': pins, 'resourceRoots': resources, 'environment': env, 'cwd': str(HERE),
            'oracle': str(expected_path), 'oracleSHA256': selection['sha256'], 'oracleBytes': selection['bytes'],
            'normalOracle': str(baseline_path), 'normalOracleSHA256': NORMAL_SHA,
            'generated': str(generated), 'native': str(native),
            'tools': tools, 'commands': (
                [{'label':'emit','argv':[tools['taskset'],'-c','5',tools['bend'],entry,'-o',str(generated)],'capSeconds':30},
                 {'label':'build','argv':[tools['taskset'],'-c','5',tools['clangWrapper'],'-O3',str(generated),'-o',str(native),'-pthread','-lm'],'capSeconds':120},
                 {'label':'consumer','argv':[tools['taskset'],'-c','5',str(native),'--threads','1','--gpu','off'],'capSeconds':5}]
                if role=='native' else
                [{'label':'emit','argv':[tools['taskset'],'-c','5',tools['bend'],entry,'-o',str(generated)],'capSeconds':30},
                 {'label':'consumer','argv':[tools['taskset'],'-c','5',tools['node'],str(generated)],'capSeconds':5}]),
            'postConsumer': 'Complete byte equality with independently corrected5057139B reader oracle; reject entire normal baseline; empty runtime stderr' if subject=='reader' else 'Complete byte equality with original5077477B oracle; empty runtime stderr'}
    out.mkdir(parents=True, exist_ok=False)
    (out / 'plan.json').write_text(json.dumps(plan, indent=2) + '\n')
    print(sha(out / 'plan.json'))


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
    profile_identities = {}

    def guard(label):
        for name, identity in profile_identities.items():
            info = Path(name).lstat()
            if not stat.S_ISREG(info.st_mode) or [info.st_dev, info.st_ino] != identity:
                raise ValueError('Profile regular identity changed: ' + name)
        for artifact in (generated, native):
            if str(artifact) in pins and (artifact.is_symlink() or not artifact.is_file()):
                raise ValueError('Generated artifact must be a regular non-symlink file')
        for row in record['commands']:
            for key in ('stdout', 'stderr'):
                if key in row and row[key].get('published',False):
                    verify_raw(row[key]['path'],row[key]['sha256'])
                elif key in row and 'partialSHA256' in row[key]:
                    verify_raw(row[key]['path'],row[key]['partialSHA256'])
        if validate_imports(plan['stage'], plan['sourceInventory'], plan.get('sourceEntries')) != plan['importClosure']:
            raise ValueError('Import closure changed')
        actual = {path: sha(path) for path in pins}
        unchanged = actual == pins and {path: sha(path) for path in plan['sourceInventory']} == plan['sourceInventory'] and runner.Inputs(directories=plan['resourceRoots']).expected == plan['resourceRoots']
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
                        artifact = generated if label in ('emit','source-copy-emit') else native
                        if label in ('emit', 'build', 'source-copy-emit') and (artifact.exists() or artifact.is_symlink()):
                            raise ValueError('Generated output must start absent')
                        result = runner.execute_result(command['argv'], command['capSeconds'], plan['environment'], plan['cwd'], 'split')
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
                    if label in ('emit','build','source-copy-emit') and (artifact.exists() or artifact.is_symlink()):
                        try:
                            pins[str(artifact)]=sha(artifact)
                            record[label+'ArtifactSHA256']=pins[str(artifact)]
                        except BaseException as error:
                            record[label+'ArtifactCaptureError']=f'{type(error).__name__}: {error}'
                            if publication_error is not None:publication_error.add_note('artifact capture: '+str(error))
                            else:raise
                if label in ('emit','source-copy-emit'):
                    profile = Path(plan['profile'])
                    snapshot = Path(plan['capturedProfile'])
                    if profile.is_symlink() or not profile.is_file():
                        raise ValueError('Requested profile absent/nonregular at emit boundary')
                    fd = os.open(profile, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
                    with os.fdopen(fd, 'rb') as stream:
                        before = os.fstat(stream.fileno())
                        if not stat.S_ISREG(before.st_mode):
                            raise ValueError('Profile descriptor not regular')
                        raw = stream.read()
                        after = os.fstat(stream.fileno())
                    if (before.st_size, before.st_mtime_ns, before.st_ctime_ns) != (after.st_size, after.st_mtime_ns, after.st_ctime_ns):
                        raise ValueError('Profile changed while captured')
                    write_raw(snapshot, raw)
                    for artifact in (profile, snapshot):
                        pins[str(artifact)] = hashlib.sha256(raw).hexdigest()
                        verify_raw(artifact, pins[str(artifact)])
                        info = artifact.lstat()
                        profile_identities[str(artifact)] = [info.st_dev, info.st_ino]
                    record['profileCapture'] = {'original': str(profile), 'snapshot': str(snapshot), 'sha256': hashlib.sha256(raw).hexdigest(), 'bytes': len(raw), 'identities': dict(profile_identities)}
                    record['profileCapture']['compilerExit'] = result['exit']
                    record['profileCapture']['compilerFailure'] = result['failure']
                    metadata = Path(plan['profileCaptureMetadata'])
                    write_raw(metadata, (json.dumps(record['profileCapture'], indent=2) + '\n').encode())
                    pins[str(metadata)] = sha(metadata)
                    info = metadata.lstat()
                    profile_identities[str(metadata)] = [info.st_dev, info.st_ino]
                    guard('profile-captured')
                if label.startswith('source-'):
                    if result['failure'] is not None or result['exit'] not in command.get('expectedExits', [command.get('expectedExit')]):
                        raise ValueError('Source control exit differs: ' + label)
                    for token in command.get('stderrContains', []):
                        if token.encode() not in result['stderr']:
                            raise ValueError('Source control missed intended diagnostic: ' + label)
                    row['sourceControlPassed'] = True
                    continue
                if result['exit'] != 0 or result['failure'] is not None:
                    raise ValueError('Owned child failed: ' + label)
                if label in ('emit', 'build', 'source-copy-emit'):
                    artifact = generated if label in ('emit','source-copy-emit') else native
                    if artifact.is_symlink() or not artifact.is_file():
                        raise ValueError('Emit did not produce a regular non-symlink artifact')
                    pins[str(artifact)] = sha(artifact)
                    record[label + 'ArtifactSHA256'] = pins[str(artifact)]
                else:
                    if result['stderr']:
                        raise ValueError('Consumer stderr is not empty')
                    expected_bytes = gzip.decompress(Path(plan['oracle']).read_bytes())
                    if len(expected_bytes) != plan['oracleBytes'] or hashlib.sha256(expected_bytes).hexdigest() != plan['oracleSHA256']:
                        raise ValueError('Whole oracle changed')
                    if result['stdout'] != expected_bytes:
                        raise ValueError('Complete consumer byte output differs from whole independent oracle')
                    record['wholeOracleSHA256'] = plan['oracleSHA256']
                    if plan['subject'] == 'reader':
                        baseline_bytes = gzip.decompress(Path(plan['normalOracle']).read_bytes())
                        if hashlib.sha256(baseline_bytes).hexdigest() != plan['normalOracleSHA256'] or len(baseline_bytes) != 5077477:
                            raise ValueError('Original complete normal baseline changed')
                        if result['stdout'] == baseline_bytes:
                            raise ValueError('Reached reader mutation did not reject normal baseline')
                        record['completeNormalBaselineRejected'] = True
        record['status'] = 'PACKED_COMPILER_DIAGNOSTIC_PASS'
        record['compilerOutcome'] = 'interrupted exit75; not successful emission' if next(row['exit'] for row in record['commands'] if row['label']=='source-copy-emit')==75 else 'normal copied-logic C emission; not stock backend qualification'


def prepare_source(out):
    prepare(out, 'js', 'normal')
    out = Path(out).resolve()
    plan_path = out / 'plan.json'
    plan = json.loads(plan_path.read_text())
    inventories = json.loads((HERE / 'source-inventory-v2.json').read_text())
    inventory = {path:digest for path,digest in inventories['controls'].items() if path not in inventories['reader']}
    entries = [HERE / 'stage/output-io-main.bend', *sorted((HERE / 'negatives').glob('*.bend'))]
    plan['sourceEntries'] = [str(path) for path in entries]
    plan['sourceInventory'] = inventory
    plan['importClosure'] = validate_imports(HERE / 'stage', inventory, entries)
    plan['pins'].update(inventory)
    diagnostic = {
        'cross-schema-grant': ['SOME PROOFS FAIL','- expected : D.DeclaredSelection<Carrier.InspectOwner<F.Garden','- observed : D.DeclaredSelection<Carrier.InspectOwner<F.Workshop'],
        'opaque-owner-escape': ['SOME PROOFS FAIL','- expected : Carrier.InspectOwner<F.Workshop','- observed : bad~H'],
        'owner-duplication': ['SOME PROOFS FAIL','owner (consumed more than once)'],
        'undeclared-selection': ['SOME PROOFS FAIL','- expected : D.DeclaredSelection<bad~H','- observed : Q.ComposedReadQuery<bad~H'],
        'write-through-read': ['SOME PROOFS FAIL','- expected : W.World<F.Workshop','- observed : bad~H'],
    }
    plan['commands'] = [{'label': 'source-' + ('normal' if n==0 else entry.stem),
                         'argv': [plan['tools']['taskset'],'-c','5',plan['tools']['bend'],str(entry),'--check-only'],
                         'capSeconds': 5, 'expectedExit': 0 if n==0 else 1,
                         'stderrContains': [] if n==0 else diagnostic[entry.stem]} for n,entry in enumerate(entries)]
    plan['scope'] = 'Canonical complete23 normal positive source plus five current API intended authority refusals; exact pre/post closure'
    plan['postConsumer'] = 'No runtime claim; six source command exits and intended diagnostics with unchanged52-file closure'
    plan_path.write_text(json.dumps(plan,indent=2)+'\n')
    print('final-source-plan',sha(plan_path))

def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest='command', required=True)
    preparation = sub.add_parser('prepare')
    preparation.add_argument('output')
    preparation.add_argument('role',choices=('js','native'))
    preparation.add_argument('subject',choices=('normal','reader'))
    source_preparation = sub.add_parser('prepare-source')
    source_preparation.add_argument('output')
    execution = sub.add_parser('run')
    execution.add_argument('plan')
    execution.add_argument('admitted_sha256')
    args = parser.parse_args()
    if args.command == 'prepare':
        prepare(args.output,args.role,args.subject)
    elif args.command == 'prepare-source':
        prepare_source(args.output)
    else:
        run(args.plan, args.admitted_sha256)


if __name__ == '__main__':
    main()
