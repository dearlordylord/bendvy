#!/usr/bin/env python3
"""Direct paired application development checks; no delivery/performance gate."""
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
COMPARE = load('decode_compare', HERE/'check-observation.py')


def main(out,native=False,mutant=False):
    assert not (native and mutant)
    out.mkdir()
    raw = out/'raw'
    raw.mkdir()
    generated = out/'generated'
    generated.mkdir()
    env = {**os.environ,'BEND_NO_TELEMETRY':'1'}
    private = out/'private-environment.json'
    private.write_text(json.dumps(env,sort_keys=True)+'\n')
    private.chmod(0o600)
    tools = {n:Path(shutil.which(n)).resolve() for n in ('bend','node','taskset')}
    resource_roots = ['/home/node/.bend/bend2']
    if native:
        env['BENDVY_CLANG19_ROOT'] = '/tmp/bendvy-clang19-diagnostic/root'
        private.write_text(json.dumps(env,sort_keys=True)+'\n')
        tools['clangWrapper'] = Path('/tmp/bendvy-clang19-diagnostic/clang19')
        tools['clangBinary'] = Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang')
        resource_roots += ['/tmp/bendvy-clang19-diagnostic/root','/home/node/.local/opt/dnd-clang14/usr/lib/aarch64-linux-gnu']
    inputs = {Path(__file__).resolve(),Path(COMPARE.__file__),COMPARE.PARSER,Path(task_runner.__file__),ROOT/'scripts/evidence_boundary.py',ROOT/'scripts/receipt-logs.py',private,*tools.values()}
    entries = [HERE/'mutants/budget128-v1/stage/controls.bend'] if mutant else ([HERE/'controls.bend'] if native else [HERE/'controls.bend',HERE/'bounded-controls.bend'])
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
    oracles = [HERE/'oracle-v1/expected-complete.json'] if native or mutant else [HERE/'oracle-v1/expected-complete.json',HERE/'oracle-v1/expected-bounded-v2.json']
    hashes = ['13607718be581d8b76de1db1cc0e6439e0c60a7f5641a9dfd1eb4f7578cc83c2']
    if not native and not mutant:hashes.append('09983234541bba0c32b230bfca75f63a4ff2131068d97fdd21f3cb8be6f77be0')
    assert [hashlib.sha256(p.read_bytes()).hexdigest() for p in oracles] == hashes
    inputs.update(oracles)
    frozen = task_runner.Inputs(files=inputs,directories=resource_roots)
    commands = []
    for kind,entry in zip(('complete','bounded'),entries):
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
    plan = {'scope':__doc__,'native':native,'mutant':mutant,'commands':commands,'inputs':frozen.expected}
    plan_path = out/'plan.json'
    plan_path.write_text(json.dumps(plan,indent=2)+'\n')
    frozen = task_runner.Inputs(files=(*inputs,plan_path),directories=resource_roots)
    logs = LOGS.CommandLogs(raw,[c['label'] for c in commands])
    record = {'status':'INCOMPLETE','scope':__doc__,'commands':[],'generated':{},'logs':{}}
    def guard():
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
        for kind,entry,oracle in zip(('complete','bounded'),entries,oracles):
            try:
                actual = COMPARE.compare(raw/(kind+'-run.stdout'),oracle,entry)
            except AssertionError as error:
                if not mutant:raise
                actual = error.actual
                assert actual != json.loads(oracle.read_text())
                assert actual['array128']['checked'] == {'Rejected':{'FuelExhausted':{'path':'$[127]'}}}
                assert all(actual[name]['sentinel'] == [111,222] for name in actual)
                record['mutantDifference'] = str(error)
                record['status'] = 'MUTANT_DETECTED'
            else:
                assert not mutant, 'Semantic mutant escaped complete oracle'
                record['status'] = 'DEVELOPMENT_PASS'
            (out/(kind+'-actual.json')).write_text(json.dumps(actual,indent=2)+'\n')
    print(json.dumps({'receipt':str(out/'receipt.json'),'status':record['status']}))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--native',action='store_true')
    parser.add_argument('--mutant',action='store_true')
    parser.add_argument('--output',type=Path,default=HERE/'development'/str(time.time_ns()))
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True,exist_ok=True)
    main(args.output.resolve(),args.native,args.mutant)
