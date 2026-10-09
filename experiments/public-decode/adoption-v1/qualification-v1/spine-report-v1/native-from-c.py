#!/usr/bin/env python3
"""Complete list-spine Native build/runtime from exact previously emitted C; no re-emission/delivery/performance gate."""
import argparse
import fcntl
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = Path('/workspace/formal-proofs/bendvy')


def load(name,path):
    spec = importlib.util.spec_from_file_location(name,path)
    module = importlib.util.module_from_spec(spec)
    exec(compile(Path(path).read_bytes(),str(path),"exec"),module.__dict__)
    return module


ORACLE_FILES = {'normal':{'name':'expected.json','sha256':'26e965901c73e89804b69c1d3d13d10e512478955cb0541f6ccbe8e49693766d'}}
ORACLE_COMMIT = '220251bc'



def admitted_plan(path,digest):
    assert path.is_file() and not path.is_symlink(), 'prepared plan must be a regular file'
    raw=path.read_bytes()
    assert re.fullmatch('[0-9a-f]{64}',digest or ''), 'explicit prepared-plan digest required'
    assert hashlib.sha256(raw).hexdigest()==digest, 'prepared-plan digest differs'
    return json.loads(raw)


def pinned_file(pin):
    assert type(pin) is dict and set(pin)=={'path','sha256'}, 'exact file pin required'
    path=Path(pin['path'])
    assert path.is_absolute() and path.is_file() and not path.is_symlink(), 'pinned file must be absolute regular file'
    assert str(path.resolve())==str(path), 'pinned path must be canonical'
    assert re.fullmatch('[0-9a-f]{64}',pin['sha256'] or ''), 'file digest required'
    assert hashlib.sha256(path.read_bytes()).hexdigest()==pin['sha256'], 'pinned file drift'
    return path


def assembly_binding(path,digest):
    if path is None:
        assert digest is None, 'assembly digest without binding'
        return None
    assert path.is_absolute() and str(path.resolve())==str(path), 'binding path must be canonical'
    binding=admitted_plan(path,digest)
    assert set(binding) in ({'mode','entry','sourcePins','oracle','cEmission'},{'mode','entry','sourcePins','oracle','role','cEmission'}), 'exact assembly binding fields required'
    assert binding['mode'] in ('registered-decode-assembly-v1','generic-spine-decode-assembly-v1','deferred-spine-decode-assembly-v1','construction-spine-decode-assembly-v1','custom-spine-decode-assembly-v1','completion-spine-decode-assembly-v1','input-codec-spine-decode-assembly-v1','native-consuming-decode-assembly-v1'), 'unknown assembly mode'
    entry=pinned_file(binding['entry'])
    role=binding.get('role','normal')
    assert role in ('normal','generic-spine','deferred-spine','construction-spine','custom-spine','completion-spine','input-codec-spine','native-consuming'), 'Native positive complete role only'
    assert binding['mode']==({'generic-spine':'generic-spine-decode-assembly-v1','deferred-spine':'deferred-spine-decode-assembly-v1','construction-spine':'construction-spine-decode-assembly-v1','custom-spine':'custom-spine-decode-assembly-v1','completion-spine':'completion-spine-decode-assembly-v1','input-codec-spine':'input-codec-spine-decode-assembly-v1','native-consuming':'native-consuming-decode-assembly-v1'}.get(role,'registered-decode-assembly-v1')), 'Native mode/role mismatch'
    assert role=='native-consuming' and entry.name=='sequential-spine.bend' or entry.name==('complete-spine.bend' if role in ('construction-spine','custom-spine','completion-spine','input-codec-spine') else ('spine.bend' if role=='normal' else role+'.bend')), 'complete role entry required'
    if role=='native-consuming':assert entry.name=='sequential-spine.bend' and entry.parent.name=='native-consuming-v1', 'closed Native consuming source differs'
    if role in ('construction-spine','custom-spine','completion-spine','input-codec-spine'):assert entry.parent.name=={'construction-spine':'qualification-v1','custom-spine':'fallible-composition-v1','completion-spine':'completion-addon-v1','input-codec-spine':'input-codec-v1'}[role], 'closed construction role/source differs'
    assert type(binding['sourcePins']) is dict and binding['sourcePins'], 'complete source pins required'
    for filename,sha in binding['sourcePins'].items():pinned_file({'path':filename,'sha256':sha})
    oracle=binding['oracle']
    assert set(oracle)=={'commit','expected','whole','basis','authoring'}, 'exact independent oracle binding required'
    assert re.fullmatch('[0-9a-f]{40}',oracle['commit'] or ''), 'full independent oracle commit required'
    for key in ('expected','whole','basis'):pinned_file(oracle[key])
    assert type(oracle['authoring']) is list and oracle['authoring'], 'independent oracle authoring files required'
    for pin in oracle['authoring']:pinned_file(pin)
    emission=binding['cEmission']
    assert set(emission)=={'artifact','receipt','plan'}, 'exact prior C emission pins required'
    for pin in emission.values():pinned_file(pin)
    return binding


def assert_source_pins(binding,source_paths):
    observed={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in source_paths}
    assert observed==binding['sourcePins'], 'source closure differs from explicit assembly pins'


def admit_interpreter(plan):
    actual=Path(sys.executable).resolve(strict=True)
    assert actual.is_file() and not actual.is_symlink(), 'actual interpreter must resolve to regular file'
    expected=plan['tools']['python']
    assert str(actual)==expected, 'actual interpreter path differs from admitted plan'
    assert hashlib.sha256(actual.read_bytes()).hexdigest()==plan['inputs'][expected], 'actual interpreter bytes differ from admitted plan'


def admit_file_pins(plan):
    # Stdlib-only entry barrier: no repository code may execute before these.
    pins=plan['inputs']
    assert type(pins) is dict and pins, 'admitted input pins required'
    required={str(Path(__file__).resolve()),str(ROOT/'scripts/task_runner.py'),str(ROOT/'scripts/evidence_boundary.py')}
    assert required.issubset(pins), 'collector/helper pins missing before import'
    for filename,expected in pins.items():
        path=Path(filename)
        assert path.is_absolute(), 'admitted input path must be absolute'
        if isinstance(expected,str):
            pinned_file({'path':filename,'sha256':expected})
        else:
            assert type(expected) is dict and path.is_dir() and not path.is_symlink(), 'invalid admitted resource pin'
            actual={str(p.relative_to(path)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(path.rglob('*')) if p.is_file()}
            assert actual==expected, 'admitted resource bytes/membership drift before import'


def repository_helpers():
    # Exact files, never an already-cached sys.modules helper or sys.path alias.
    runner=load('decode_task_runner',ROOT/'scripts/task_runner.py')
    boundary=load('decode_evidence_boundary',ROOT/'scripts/evidence_boundary.py')
    return runner,boundary.ReceiptBoundary,boundary.GuardBoundary


def run_recorded(row,runner,command):
    try:
        result=runner.run(command['label'],command['argv'],command['capSeconds'])
    except BaseException as error:
        row['error']=f'{type(error).__name__}: {error}'
        failed=getattr(error,'result',None)
        if isinstance(failed,dict):row.update({k:v for k,v in failed.items() if not isinstance(v,bytes)})
        raise
    row.update({k:v for k,v in result.items() if not isinstance(v,bytes)})


def main(out,native=False,execute=False,plan_digest=None,role="normal",binding_path=None,binding_digest=None):
    assert role in ("normal","generic-spine","deferred-spine","construction-spine","custom-spine","completion-spine","input-codec-spine","native-consuming") and native, "Native-from-C only"
    assert binding_path is not None or role=="normal", "new Native roles require explicit binding"
    binding=assembly_binding(binding_path,binding_digest)
    assembly=binding is not None
    assert role==(binding.get('role','normal') if assembly else 'normal'), 'Native role requires matching binding'
    plan_path = out/'plan.json'
    admitted = admitted_plan(plan_path,plan_digest) if execute else None
    if execute:
        admit_interpreter(admitted)
        admit_file_pins(admitted)
        assert admitted['native'] == native and admitted['role'] == role, 'backend/role differs from admitted plan'
        assert not (out/'receipt.json').exists(), 'prepared cohort already executed'
    else:
        out.mkdir()
    task_runner,ReceiptBoundary,GuardBoundary=repository_helpers()
    LOGS = load('decode_logs', ROOT/'scripts/receipt-logs.py')
    CONFIG = load('staging_config', ROOT/'experiments/public-simulation/delivery-v1/installed-config.py')
    raw = out/'raw'
    generated = out/'generated'
    if not execute:
        raw.mkdir()
        generated.mkdir()
    for directory in (raw,generated):
        assert directory.is_dir() and not directory.is_symlink() and not any(directory.iterdir()), 'prepared output must be empty regular directory'
    env = CONFIG.environment()
    private = out/'private-environment.json'
    if not execute:
        private.write_text(json.dumps(env,sort_keys=True)+'\n')
        private.chmod(0o600)
    tools = {n:Path(CONFIG.TOOL_PATHS[n]).resolve(strict=True) for n in ('bend','node','taskset')}
    tools['python'] = Path(sys.executable).resolve()
    tools['clangWrapper']=Path(CONFIG.TOOL_PATHS['clangWrapper']).resolve(strict=True)
    tools['clangBinary']=Path(CONFIG.TOOL_PATHS['clang']).resolve(strict=True)
    resource_roots = list(CONFIG.RESOURCE_ROOTS)
    assert private.is_file() and not private.is_symlink() and private.read_text() == json.dumps(env,sort_keys=True)+'\n', 'prepared environment differs'
    inputs = {Path(__file__).resolve(),Path(CONFIG.__file__),Path(task_runner.__file__),ROOT/'scripts/evidence_boundary.py',ROOT/'scripts/receipt-logs.py',private,*tools.values()}
    c_source=pinned_file(binding['cEmission']['artifact']) if assembly else Path('/tmp/bendvy-decode46-spine-cemit-v2/generated/complete.c')
    c_receipt=pinned_file(binding['cEmission']['receipt']) if assembly else c_source.parent.parent/'receipt.json'
    c_plan=pinned_file(binding['cEmission']['plan']) if assembly else c_source.parent.parent/'plan.json'
    c_sha=binding['cEmission']['artifact']['sha256'] if assembly else '2425399baea9e3461b5b281c1ae77c1b5a250dbb02ce60878ad644a1dec7dc7d'
    assert c_source.is_file() and not c_source.is_symlink() and hashlib.sha256(c_source.read_bytes()).hexdigest()==c_sha, 'successful C bytes differ'
    previous=json.loads(c_receipt.read_text())
    c_plan_sha=binding['cEmission']['plan']['sha256'] if assembly else '0c2fef8f89a7efcac2bde87b2545695bee7158d9793de57d830943ce2d0d0bf4'
    assert previous['status']=='DEVELOPMENT_C_EMIT_PASS' and previous['preparedPlanSha256']==c_plan_sha
    assert hashlib.sha256(c_plan.read_bytes()).hexdigest()==previous['preparedPlanSha256']
    assert previous['generated']=={str(c_source):hashlib.sha256(c_source.read_bytes()).hexdigest()}
    inputs.update({c_source,c_receipt,c_plan,HERE/'development-run.py'})
    entries = [pinned_file(binding['entry'])] if assembly else [HERE/'main.bend']
    source_paths=set()
    if assembly:inputs.add(binding_path)
    def visit(path):
        source_paths.add(path)
        if path in inputs:
            return
        inputs.add(path)
        for target in re.findall(r'^import\s+(\S+)',path.read_text(),re.MULTILINE):
            if target == 'Base':
                visit(Path('/home/node/.bend/bend2/base.bend'))
            else:
                visit((path.parent/target).resolve())
    for path in entries:
        visit(path)
    if assembly:
        assert_source_pins(binding,source_paths)
        prior_plan=json.loads(c_plan.read_text())
        assert all(prior_plan['inputs'].get(filename)==sha for filename,sha in binding['sourcePins'].items()), 'C emission/source closure differs'
        assert prior_plan['commands'][0]['artifact']==str(c_source) and previous.get('guardFailures',[])==[] and 'error' not in previous, 'unqualified prior C emission'
        assert len(previous['commands'])==1 and previous['commands'][0]['exit']==0 and previous['commands'][0]['failure'] is None, 'prior C command failed'
        assert all(previous['commands'][0][key]==value for key,value in prior_plan['commands'][0].items()), 'prior C command/plan differs'
        assert prior_plan['native'] is True and prior_plan['role']==role and prior_plan['commands'][0]['capSeconds']==30, 'prior C emission role differs'
    oracle_home = Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-decode/adoption-v1/qualification-v1/oracle-v1/spine-report-v1')
    oracle=pinned_file(binding['oracle']['expected']) if assembly else oracle_home/ORACLE_FILES[role]['name']
    oracle_sha=binding['oracle']['expected']['sha256'] if assembly else ORACLE_FILES[role]['sha256']
    oracle_commit=binding['oracle']['commit'] if assembly else ORACLE_COMMIT
    assert hashlib.sha256(oracle.read_bytes()).hexdigest()==oracle_sha
    basis_file=pinned_file(binding['oracle']['basis']) if assembly else oracle_home/'source-basis.json'
    basis=json.loads(basis_file.read_text())
    for filename,digest in basis['sources'].items():
        path=Path(filename)
        assert path.is_file() and not path.is_symlink() and hashlib.sha256(path.read_bytes()).hexdigest()==digest, 'independent source basis drift'
        inputs.add(path)
    authoring={pinned_file(pin) for pin in binding['oracle']['authoring']} if assembly else {oracle_home/'expected.py',oracle_home/'REVIEW.md'}
    if role in ('generic-spine','deferred-spine'):inputs.update({entries[0].parent/'transport-inventory.py',entries[0].parent.parent/'generic-assembly-v1/transport-inventory.py'})
    if role in ('construction-spine','custom-spine','completion-spine','input-codec-spine'):inputs.add((entries[0].parent if role=='construction-spine' else entries[0].parent.parent/'qualification-v1')/'transport-inventory.py')
    if role=='native-consuming':inputs.update({entries[0].parent/'transport-inventory.py',entries[0].parent.parent/'transport-inventory.py'})
    inputs.update({*authoring,basis_file,HERE/'transport.py',HERE.parent/'transport.py',ROOT/'experiments/public-simulation/bend-v1/parse-report.py',oracle})
    transport=load('decode_transport',HERE/'transport.py')
    expected=json.loads(oracle.read_text())
    expected_raw=transport.render(expected,entries[0],assembly,role)
    assert transport.parse(expected_raw,entries[0],assembly,role)==expected
    raw_oracle=out/'expected.stdout'
    if not execute:raw_oracle.write_bytes(expected_raw)
    assert raw_oracle.is_file() and not raw_oracle.is_symlink() and raw_oracle.read_bytes()==expected_raw,'prepared raw oracle differs'
    inputs.add(raw_oracle)
    baseline_oracle=pinned_file(binding['oracle']['whole']) if assembly else oracle_home.parent/'normal-expected.json'
    baseline_sha=binding['oracle']['whole']['sha256'] if assembly else 'ca88bdec56290ba3b5460463f59c4ddda389d2dcc7ecfa58d6d633c35016e075'
    assert hashlib.sha256(baseline_oracle.read_bytes()).hexdigest()==baseline_sha
    inputs.add(baseline_oracle)
    assert transport.whole(expected,role)==json.loads(baseline_oracle.read_text()), 'complete Candidate must preserve unchanged whole baseline'

    frozen = task_runner.Inputs(files=inputs,directories=resource_roots)
    artifact=generated/'complete.native'
    prefix=[str(tools['taskset']),'-c','5']
    commands=[{'label':'complete-build','argv':prefix+[str(tools['clangWrapper']),'-O3',str(c_source),'-o',str(artifact),'-pthread','-lm'],'capSeconds':120,'artifact':str(artifact)},
              {'label':'complete-run','argv':prefix+[str(artifact),'--threads','1','--gpu','off'],'capSeconds':5}]
    plan = {'scope':__doc__,'native':native,'oracleCommit':oracle_commit,'oracleSha256':oracle_sha,'role':role,'tools':{n:str(p) for n,p in tools.items()},'commands':commands,'inputs':frozen.expected}
    if assembly:plan['assemblyBindingSha256']=binding_digest
    if execute:
        assert plan == admitted, 'prepared cohort source/tool/environment/commands differ'
    else:
        plan_path.write_text(json.dumps(plan,indent=2)+'\n')
    frozen = task_runner.Inputs(files=(*inputs,plan_path),directories=resource_roots)
    if not execute:
        frozen.guard()
        print(json.dumps({'plan':str(plan_path),'planSha256':hashlib.sha256(plan_path.read_bytes()).hexdigest(),'status':'PREPARED_NO_CHILD'}))
        return
    logs = LOGS.CommandLogs(raw,[c['label'] for c in commands])
    record = {'preparedPlanSha256':plan_digest,'status':'INCOMPLETE','scope':__doc__,'commands':[],'generated':{},'logs':{}}
    def guard():
        # Preserve every completed raw join even when a later guard fails.
        record['logs'] = dict(logs.hashes)
        assert admitted_plan(plan_path,plan_digest) == admitted, 'admitted plan changed'
        frozen.guard()
        logs.guard()
        assert {str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in generated.iterdir() if p.is_file()} == record['generated']
        assert not any(p.is_symlink() or not p.is_file() for p in generated.iterdir())
    with ReceiptBoundary(record,out/'receipt.json',[('source/tools/environment/raw/generated',guard)]):
        for command in commands:
            row = dict(command)
            record['commands'].append(row)
            def capture_generated():
                if 'artifact' in command:
                    p = Path(command['artifact'])
                    if p.is_file() and not p.is_symlink():
                        record['generated'][str(p)] = hashlib.sha256(p.read_bytes()).hexdigest()
            guard()
            with GuardBoundary([('generated result capture',capture_generated),('source/tools/environment/raw/generated',guard)]):
                with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
                    fcntl.flock(lock,fcntl.LOCK_EX)
                    guard()
                    current = task_runner.Inputs(files=(*inputs,plan_path,*record['generated']),directories=resource_roots)
                    assert current.expected == {**frozen.expected,**record['generated']}
                    runner = task_runner.Runner(logs,inputs=current,env=env,cwd=HERE)
                    run_recorded(row,runner,command)
        observed=(raw/'complete-run.stdout').read_bytes()
        assert transport.parse(observed,entries[0],assembly,role)==expected, 'full typed Native Candidate differs from pre-run oracle'
        assert observed==expected_raw, 'complete raw Native Candidate differs from pre-run oracle'
        assert (raw/'complete-run.stderr').read_bytes()==b'', 'unexpected runtime stderr'
        assert transport.whole(expected,role)==json.loads(baseline_oracle.read_text())
        record['status']='DEVELOPMENT_NATIVE_PASS'
    print(json.dumps({'receipt':str(out/'receipt.json'),'status':record['status']}))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--assembly-binding',type=Path,help='Explicit current assembly source/oracle/previous C bindings')
    parser.add_argument('--assembly-binding-sha256')
    parser.add_argument('--role',choices=['normal','generic-spine','deferred-spine','construction-spine','custom-spine','completion-spine','input-codec-spine','native-consuming'],default='normal')
    parser.add_argument('--native',action='store_true')
    parser.add_argument('--execute',action='store_true',help='Consume existing --output/plan.json after admission; default prepares without a child')
    parser.add_argument('--plan-sha256',help='Required exact admitted plan digest for --execute')
    parser.add_argument('--output',type=Path,default=HERE/'development'/str(time.time_ns()))
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True,exist_ok=True)
    main(args.output.resolve(),args.native,args.execute,args.plan_sha256,args.role,args.assembly_binding.absolute() if args.assembly_binding else None,args.assembly_binding_sha256)
