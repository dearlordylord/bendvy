#!/usr/bin/env python3
"""Direct reached owned-reader retirement-loss development falsifier; no delivery/performance gate."""
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
sys.path.insert(0,str(ROOT/'scripts'))
import task_runner
from evidence_boundary import ReceiptBoundary, GuardBoundary


def load(name,path):
    spec = importlib.util.spec_from_file_location(name,path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


LOGS = load('decode_logs', ROOT/'scripts/receipt-logs.py')
CONFIG = load('staging_config', ROOT/'experiments/public-simulation/delivery-v1/installed-config.py')


def admitted_plan(path,digest):
    assert path.is_file() and not path.is_symlink(), 'prepared plan must be a regular file'
    raw=path.read_bytes()
    assert re.fullmatch('[0-9a-f]{64}',digest or ''), 'explicit prepared-plan digest required'
    assert hashlib.sha256(raw).hexdigest()==digest, 'prepared-plan digest differs'
    return json.loads(raw)


def main(out,native=False,execute=False,plan_digest=None):
    assert not native, 'this admitted falsifier scope is JS only'
    plan_path = out/'plan.json'
    admitted = admitted_plan(plan_path,plan_digest) if execute else None
    if execute:
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
    env = CONFIG.environment()
    private = out/'private-environment.json'
    if not execute:
        private.write_text(json.dumps(env,sort_keys=True)+'\n')
        private.chmod(0o600)
    tools = {n:Path(shutil.which(n)).resolve() for n in ('bend','node','taskset')}
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
    entries = [HERE/'main.bend']
    def visit(path):
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
    oracle_home = Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-owned-events/registered-read-v1/oracle-v1/retirement-loss-v1')
    oracles = [oracle_home/'expected.stdout',oracle_home/'expected.json',oracle_home/'baseline-relocated.stdout',oracle_home/'baseline-relocated.json']
    inputs.add(HERE.parents[1]/'transport.py')
    assert hashlib.sha256(oracles[0].read_bytes()).hexdigest() == 'f00d5689f878326dadf13193a99024c74f3a52427469188a55398addba19df57'
    assert hashlib.sha256(oracles[1].read_bytes()).hexdigest() == '3251dbc97d93263955074743be03b01b19166593d07dfaae3fc7ecb734aaf6d4'
    transport = load('registered_transport',HERE.parents[1]/'transport.py')
    transport.ENTRY = HERE/'main.bend'
    expected = json.loads(oracles[1].read_text())
    assert transport.parse(oracles[0].read_bytes()) == expected
    assert (transport.render('Batch',expected)+'\n').encode() == oracles[0].read_bytes()
    assert hashlib.sha256(oracles[2].read_bytes()).hexdigest() == '3072e802a94edc748b01c84b4d9e8b29857d82447c69863e8b68a2eee52927b4'
    assert hashlib.sha256(oracles[3].read_bytes()).hexdigest() == '44c426ff710c81465ab71a0c0dc79a3ddba6ddedffa6b9030761fd5291a411d7'
    baseline = json.loads(oracles[3].read_text())
    assert transport.parse(oracles[2].read_bytes()) == baseline
    assert (transport.render('Batch',baseline)+'\n').encode() == oracles[2].read_bytes()
    assert expected != baseline and oracles[0].read_bytes() != oracles[2].read_bytes()
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
    plan = {'scope':__doc__,'native':native,'oracleCommit':'af9fcfc2','tools':{n:str(p) for n,p in tools.items()},'commands':commands,'inputs':frozen.expected}
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
        assert transport.parse(observed) == expected, 'full typed observation differs from pre-run oracle'
        assert observed == oracles[0].read_bytes(), 'complete raw observation differs from pre-run oracle'
        assert transport.parse(observed) != baseline, 'unchanged complete baseline was not rejected'
        assert observed != oracles[2].read_bytes(), 'relocated complete baseline was not rejected'
        assert (raw/'complete-run.stderr').read_bytes() == b'', 'unexpected runtime stderr'
        record['status'] = 'DEVELOPMENT_PASS'
    print(json.dumps({'receipt':str(out/'receipt.json'),'status':record['status']}))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--native',action='store_true')
    parser.add_argument('--execute',action='store_true',help='Consume existing --output/plan.json after admission; default prepares without a child')
    parser.add_argument('--plan-sha256',help='Required exact admitted plan digest for --execute')
    parser.add_argument('--output',type=Path,default=HERE/'development'/str(time.time_ns()))
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True,exist_ok=True)
    main(args.output.resolve(),args.native,args.execute,args.plan_sha256)
