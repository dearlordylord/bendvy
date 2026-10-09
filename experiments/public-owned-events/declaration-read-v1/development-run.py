#!/usr/bin/env python3
"""Direct ordinary declaration-bound owned-reader development checks; no delivery/performance gate."""
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


VERIFIED_SOURCES = {}
def load(name,path):
    import types
    path=Path(path).resolve(strict=True)
    source=VERIFIED_SOURCES[str(path)] if VERIFIED_SOURCES else path.read_bytes()
    module=types.ModuleType(name)
    module.__file__=str(path)
    module.__dict__['VERIFIED_SOURCES']=VERIFIED_SOURCES
    exec(compile(source,str(path),'exec'),module.__dict__)
    return module


def interpreter_and_inputs(plan):
    actual=Path(sys.executable).resolve(strict=True)
    assert str(actual)==plan['tools']['python'], 'actual interpreter path differs'
    assert hashlib.sha256(actual.read_bytes()).hexdigest()==plan['inputs'][str(actual)], 'actual interpreter bytes differ'
    required={str(Path(__file__).resolve()),str(ROOT/'scripts/task_runner.py'),str(ROOT/'scripts/evidence_boundary.py'),str(ROOT/'scripts/receipt-logs.py'),str(ROOT/'experiments/public-simulation/delivery-v1/installed-config.py')}
    assert required.issubset(plan['inputs']), 'helper pins missing before imports'
    for name,digest in plan['inputs'].items():
        path=Path(name)
        if isinstance(digest,str):
            assert path.is_file() and not path.is_symlink() and hashlib.sha256(path.read_bytes()).hexdigest()==digest, 'admitted file drift before helper imports'
        else:
            assert path.is_dir() and not path.is_symlink(), 'admitted resource directory differs'
            assert {str(p.relative_to(path)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(path.rglob('*')) if p.is_file()}==digest, 'admitted resources drift before helper imports'


def assembly_binding(path,digest,role):
    if path is None:
        assert digest is None
        return None
    binding=admitted_plan(path,digest)
    assert set(binding)=={'role','entry','sourcePins','oracles','oracleCommit','transport','transportInputs','tools'}, 'exact reader binding fields required'
    assert binding['role']==role and role in ('generic','registered')
    for name,sha in binding['sourcePins'].items():
        p=Path(name);assert p.is_absolute() and p.is_file() and not p.is_symlink() and hashlib.sha256(p.read_bytes()).hexdigest()==sha, 'bound source differs'
    assert set(binding['tools'])=={'bend','node','taskset'}
    assert len(binding['oracles'])==2
    for pin in [binding['entry'],binding['transport'],*binding['oracles'],*binding['transportInputs'],*binding['tools'].values()]:
        p=Path(pin['path']);assert set(pin)=={'path','sha256'} and p.is_absolute() and p.is_file() and not p.is_symlink() and hashlib.sha256(p.read_bytes()).hexdigest()==pin['sha256'], 'bound file differs'
    return binding


def admitted_plan(path,digest):
    assert path.is_file() and not path.is_symlink(), 'prepared plan must be a regular file'
    raw=path.read_bytes()
    assert re.fullmatch('[0-9a-f]{64}',digest or ''), 'explicit prepared-plan digest required'
    assert hashlib.sha256(raw).hexdigest()==digest, 'prepared-plan digest differs'
    return json.loads(raw)


def main(out,native=False,execute=False,plan_digest=None,role="generic",binding_path=None,binding_digest=None):
    assert role in ("generic","registered")
    plan_path = out/'plan.json'
    admitted = admitted_plan(plan_path,plan_digest) if execute else None
    if execute:
        interpreter_and_inputs(admitted)
        global VERIFIED_SOURCES
        VERIFIED_SOURCES={name:Path(name).read_bytes() for name,digest in admitted['inputs'].items() if isinstance(digest,str) and name.endswith('.py')}
        assert all(hashlib.sha256(data).hexdigest()==admitted['inputs'][name] for name,data in VERIFIED_SOURCES.items()), 'captured helper source drift'
        assert admitted['native'] == native, 'backend differs from admitted plan'
        assert not (out/'receipt.json').exists(), 'prepared cohort already executed'
    else:
        out.mkdir()
    raw = out/'raw'
    generated = out/'generated'
    if not execute:
        raw.mkdir()
        generated.mkdir()
    for directory in (raw,generated):
        assert directory.is_dir() and not directory.is_symlink() and not any(directory.iterdir()), 'prepared output must be empty regular directory'
    task_runner=load('declaration_task_runner',ROOT/'scripts/task_runner.py')
    boundary=load('declaration_boundary',ROOT/'scripts/evidence_boundary.py')
    ReceiptBoundary,GuardBoundary=boundary.ReceiptBoundary,boundary.GuardBoundary
    LOGS=load('declaration_logs',ROOT/'scripts/receipt-logs.py')
    CONFIG=load('declaration_config',ROOT/'experiments/public-simulation/delivery-v1/installed-config.py')
    binding=assembly_binding(binding_path,binding_digest,role)
    env = CONFIG.environment()
    private = out/'private-environment.json'
    if not execute:
        private.write_text(json.dumps(env,sort_keys=True)+'\n')
        private.chmod(0o600)
    tools = {n:Path(binding['tools'][n]['path'] if binding else shutil.which(n)).resolve() for n in ('bend','node','taskset')}
    tools['python'] = Path(sys.executable).resolve()
    resource_roots = ['/home/node/.bend/bend2']
    if native:
        env['BENDVY_CLANG19_ROOT'] = '/tmp/bendvy-clang19-diagnostic/root'
        if not execute:
            private.write_text(json.dumps(env,sort_keys=True)+'\n')
        tools['clangWrapper'] = Path('/tmp/bendvy-clang19-diagnostic/clang19')
        tools['clangBinary'] = Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang')
        resource_roots += ['/tmp/bendvy-clang19-diagnostic/root','/home/node/.local/opt/dnd-clang14/usr/lib/aarch64-linux-gnu']
    assert private.is_file() and not private.is_symlink() and private.read_text() == json.dumps(env,sort_keys=True)+'\n', 'prepared environment differs'
    inputs = {Path(__file__).resolve(),Path(CONFIG.__file__),Path(task_runner.__file__),ROOT/'scripts/evidence_boundary.py',ROOT/'scripts/receipt-logs.py',private,*tools.values()}
    entries = [Path(binding['entry']['path'])] if binding else [HERE/('main.bend' if role=='generic' else 'registered-v1/main.bend')]
    source_paths=set()
    if binding:inputs.add(binding_path)
    def visit(path):
        if path in inputs:
            return
        inputs.add(path)
        source_paths.add(path)
        for target in re.findall(r'^import\s+(\S+)',path.read_text(),re.MULTILINE):
            if target == 'Base':
                visit(Path('/home/node/.bend/bend2/base.bend'))
            else:
                visit((path.parent/target).resolve())
    for path in entries:
        visit(path)
    if binding:assert {str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in source_paths}==binding['sourcePins'], 'exact source closure differs'
    oracle_home = Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-owned-events/declaration-read-v1/oracle-v1')
    oracles = [Path(pin['path']) for pin in binding['oracles']] if binding else [oracle_home/(role+'-expected.stdout'),oracle_home/(role+'-expected.json')]
    oracle_hashes = {'generic':('8d7f588ae41e38f41593b60ac164af11ca2e15a060b077b50f665269c5243d3c','5fb9f70d1b9b04623e3e8d02a8737cd9ae13be481057700594932de289fabd45'),'registered':('e13246770caf111e88b4ac799dde38d4dc252138fc36427308dc79d8f16abd69','a3c252aa2776ddfa1aca5f103e29be787cb6e31a7fb83cb66cc33f11ae1d829e')}
    inputs.update({HERE/'transport.py',HERE.parent/'registered-read-v1/transport.py'})
    if binding:
        inputs.update(Path(pin['path']) for pin in [binding['transport'],*binding['transportInputs']])
        oracle_hashes[role]=tuple(pin['sha256'] for pin in binding['oracles'])
    assert hashlib.sha256(oracles[0].read_bytes()).hexdigest() == oracle_hashes[role][0]
    assert hashlib.sha256(oracles[1].read_bytes()).hexdigest() == oracle_hashes[role][1]
    transport = load('registered_transport',Path(binding['transport']['path']) if binding else HERE/'transport.py')
    expected = json.loads(oracles[1].read_text())
    assert transport.parse(role,oracles[0].read_bytes()) == expected
    assert (transport.render(role,expected)+'\n').encode() == oracles[0].read_bytes()
    inputs.update(oracles)
    frozen = task_runner.Inputs(files=inputs,directories=resource_roots)
    commands = []
    for kind,entry in zip(('complete',),entries):
        artifact = generated/(kind+'.js')
        prefix = [str(tools['taskset']),'-c','5']
        commands += [{'label':kind+'-emit','argv':prefix+[str(tools['bend']),str(entry),'-o',str(artifact)],'capSeconds':30,'artifact':str(artifact)},
                     {'label':kind+'-run','argv':prefix+[str(tools['node']),str(artifact)],'capSeconds':5}]
    if native:
        source = generated/'complete.c'
        artifact = generated/'complete.native'
        prefix = [str(tools['taskset']),'-c','5']
        commands = [{'label':'complete-emit','argv':prefix+[str(tools['bend']),str(entries[0]),'-o',str(source)],'capSeconds':30,'artifact':str(source)},
                    {'label':'complete-build','argv':prefix+[str(tools['clangWrapper']),'-O3',str(source),'-o',str(artifact),'-pthread','-lm'],'capSeconds':120,'artifact':str(artifact)},
                    {'label':'complete-run','argv':prefix+[str(artifact),'--threads','1','--gpu','off'],'capSeconds':5}]
    plan = {'scope':__doc__,'native':native,'oracleCommit':binding['oracleCommit'] if binding else '3f6a26c2','role':role,'tools':{n:str(p) for n,p in tools.items()},'commands':commands,'inputs':frozen.expected}
    if binding:plan['assemblyBindingSha256']=binding_digest
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
        assert admitted_plan(plan_path,plan_digest) == admitted, 'admitted plan changed'
        frozen.guard()
        logs.guard()
        record['logs'] = dict(logs.hashes)
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
                    try:
                        result = runner.run(command['label'],command['argv'],command['capSeconds'])
                    except BaseException as error:
                        row['error'] = f'{type(error).__name__}: {error}'
                        failed = getattr(error,'result',None)
                        if isinstance(failed,dict):row.update({k:v for k,v in failed.items() if not isinstance(v,bytes)})
                        raise
                    row.update({k:v for k,v in result.items() if not isinstance(v,bytes)})
        observed = (raw/'complete-run.stdout').read_bytes()
        assert transport.parse(role,observed) == expected, 'full typed observation differs from pre-run oracle'
        assert observed == oracles[0].read_bytes(), 'complete raw observation differs from pre-run oracle'
        assert (raw/'complete-run.stderr').read_bytes() == b'', 'unexpected runtime stderr'
        record['status'] = 'DEVELOPMENT_PASS'
    print(json.dumps({'receipt':str(out/'receipt.json'),'status':record['status']}))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--role',choices=['generic','registered'],default='generic')
    parser.add_argument('--assembly-binding',type=Path)
    parser.add_argument('--assembly-binding-sha256')
    parser.add_argument('--native',action='store_true')
    parser.add_argument('--execute',action='store_true',help='Consume existing --output/plan.json after admission; default prepares without a child')
    parser.add_argument('--plan-sha256',help='Required exact admitted plan digest for --execute')
    parser.add_argument('--output',type=Path,default=HERE/'development'/str(time.time_ns()))
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True,exist_ok=True)
    main(args.output.resolve(),args.native,args.execute,args.plan_sha256,args.role,args.assembly_binding.resolve() if args.assembly_binding else None,args.assembly_binding_sha256)
