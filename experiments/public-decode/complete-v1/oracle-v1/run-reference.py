"""Direct development TS observation; no complete resolver qualification."""
import fcntl, hashlib, json, os, shutil, sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
sys.path.insert(0,str(ROOT/'scripts'))

def sha(path): return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def main():
    import task_runner
    out=HERE/'actual-reference-v1';out.mkdir(exist_ok=False)
    node=Path(shutil.which('node')).resolve();taskset=Path(shutil.which('taskset')).resolve()
    sources=list((ROOT/'.references/bevy-ts/packages/core/src').glob('*.ts'))
    sources += [HERE/'reference.mjs',HERE/'expected-reference.json',HERE/'expected-reference.py',Path(__file__),ROOT/'scripts/task_runner.py',node,taskset]
    pins={str(p):sha(p) for p in sources}
    def guard(): assert {p:sha(p) for p in pins}==pins
    env={k:os.environ[k] for k in ('HOME','PATH','LANG','LC_ALL','TZ') if k in os.environ}
    command=[str(taskset),'-c','5',str(node),str(HERE/'reference.mjs')]
    receipt={'scope':'direct development TS only; no full tool/resolver qualification','pins':pins,'environment':env,'argv':command,'capSeconds':5}
    (out/'plan.json').write_text(json.dumps(receipt,indent=2)+'\n')
    try:
        guard()
        with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
            fcntl.flock(lock,fcntl.LOCK_EX)
            try:
                guard(); result=task_runner.execute_result(command,5,env,str(HERE),'split')
            finally: fcntl.flock(lock,fcntl.LOCK_UN)
        receipt['result']={}
        for key,value in result.items():
            if isinstance(value,bytes):
                path=out/key;path.write_bytes(value);receipt['result'][key]={'path':str(path),'sha256':sha(path),'bytes':len(value)}
            else: receipt['result'][key]=value
        guard();assert result['exit']==0 and not result['failure'] and not result['stderr']
        assert json.loads(result['stdout'])==json.loads((HERE/'expected-reference.json').read_bytes())
        receipt['status']='DEVELOPMENT_PASS'
    except BaseException as error:
        receipt['status']='INCOMPLETE';receipt['error']=repr(error);raise
    finally:
        try:guard()
        except BaseException as error:receipt['status']='INCOMPLETE';receipt['guardFailure']=repr(error)
        (out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print(receipt['status'])

def strict_equal(a,b,path='$'):
    assert type(a) is type(b), ('Type mismatch',path,type(a),type(b))
    if isinstance(a,dict):
        assert set(a) == set(b), ('Object membership mismatch',path)
        for key in a:strict_equal(a[key],b[key],path+'.'+key)
    elif isinstance(a,list):
        assert len(a) == len(b), ('List length mismatch',path,len(a),len(b))
        for index,(x,y) in enumerate(zip(a,b)):strict_equal(x,y,path+'['+str(index)+']')
    else:
        assert a == b, ('Value mismatch',path,a,b)

def host_main():
    # Closed additive role; no helper executes before admitted input checks.
    import argparse, types
    parser=argparse.ArgumentParser()
    parser.add_argument('--standard-schema-host',action='store_true')
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--execute',action='store_true')
    parser.add_argument('--plan-sha256')
    args=parser.parse_args()
    out=args.output.resolve();planfile=out/'plan.json'
    subject=Path('/workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/standard-schema-v1')
    oracle=Path('/workspace/formal-proofs/bendvy-worktrees/parity-46-construction-oracle/experiments/public-decode/public-seam-v1/construction-v1/oracle-v1')
    def inventory(directory):
        return {str(p):sha(p) for p in sorted(directory.rglob('*')) if p.is_file() and p.suffix in ('.ts','.mjs','.json','.py','.md')}
    if not args.execute:
        assert args.plan_sha256 is None and not out.exists()
        node=Path(shutil.which('node')).resolve();taskset=Path(shutil.which('taskset')).resolve()
        files=[Path(__file__).resolve(),Path(sys.executable).resolve(),ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',node,taskset,
               subject/'fixture.mjs',subject/'adapter.mjs',oracle/'host-expected.json',oracle/'host-expected.py',oracle/'source-basis.json',oracle/'REVIEW.md']
        pins={str(p):sha(p) for p in files};references=inventory(ROOT/'.references/bevy-ts/packages/core/src')
        pins.update(references)
        env={k:os.environ[k] for k in ('HOME','PATH','LANG','LC_ALL','TZ') if k in os.environ}
        env.update(OMP_NUM_THREADS='1',BEND_GPU='0')
        plan={'scope':'host Standard Schema conversion vs pinned TS Descriptor; no generated ECS callback interoperability',
              'python':str(Path(sys.executable).resolve()),'inputs':pins,'referenceDirectory':str(ROOT/'.references/bevy-ts/packages/core/src'),
              'referenceMembership':references,'argv':[str(taskset),'-c','5',str(node),str(subject/'fixture.mjs')],
              'environment':env,'cwd':str(subject),'capSeconds':5,'expected':str(oracle/'host-expected.json')}
        out.mkdir();planfile.write_text(json.dumps(plan,indent=2)+'\n')
        print(json.dumps({'status':'PREPARED_NO_CHILD','plan':str(planfile),'sha256':sha(planfile)}));return
    assert args.plan_sha256 and sha(planfile)==args.plan_sha256,'admitted plan digest required'
    plan=json.loads(planfile.read_bytes())
    assert plan['python']==str(Path(sys.executable).resolve()),'actual Python mismatch'
    def guard():
        assert {p:sha(p) for p in plan['inputs']}==plan['inputs'],'input drift'
        assert inventory(Path(plan['referenceDirectory']))==plan['referenceMembership'],'reference membership drift'
        assert sha(planfile)==args.plan_sha256,'plan drift'
    guard()
    helper=Path(ROOT/'scripts/task_runner.py');module=types.ModuleType('host_task_runner');module.__file__=str(helper)
    helperbytes=helper.read_bytes();assert hashlib.sha256(helperbytes).hexdigest()==plan['inputs'][str(helper)]
    exec(compile(helperbytes,str(helper),'exec'),module.__dict__)
    assert not (out/'receipt.json').exists() and not (out/'receipt.json').is_symlink(),'terminal attempt already exists'
    logpath=ROOT/'scripts/receipt-logs.py';logmodule=types.ModuleType('host_receipt_logs');logmodule.__file__=str(logpath)
    logbytes=logpath.read_bytes();assert hashlib.sha256(logbytes).hexdigest()==plan['inputs'][str(logpath)]
    exec(compile(logbytes,str(logpath),'exec'),logmodule.__dict__)
    raw=out/'raw';logs=None
    receipt={'preparedPlanSha256':args.plan_sha256,'status':'INCOMPLETE','scope':plan['scope']}
    try:
        raw.mkdir(exist_ok=False)
        logs=logmodule.CommandLogs(raw,['host'])
        runner=module.Runner(logs,inputs=types.SimpleNamespace(guard=guard),env=plan['environment'],cwd=plan['cwd'])
        with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
            fcntl.flock(lock,fcntl.LOCK_EX)
            try:
                guard()
                receipt['result']={}
                try:
                    result=runner.run('host',plan['argv'],5)
                except BaseException as error:
                    failed=getattr(error,'result',None)
                    if isinstance(failed,dict):
                        receipt['result'].update({k:v for k,v in failed.items() if not isinstance(v,bytes)})
                        receipt['captureError']=f'{type(error).__name__}: {error}'
                        receipt['failedCaptureRaw']={k:bytes(v).hex() for k,v in failed.items() if isinstance(v,bytes)}
                    raise
                receipt['result'].update({k:v for k,v in result.items() if not isinstance(v,bytes)})
                receipt['logs']=dict(logs.hashes)
                logs.guard();guard()
                assert result['exit']==0 and not result['failure'] and not result['stderr']
                strict_equal(json.loads(result['stdout']),json.loads(Path(plan['expected']).read_bytes()))
                receipt['status']='DEVELOPMENT_HOST_PASS'
            finally:fcntl.flock(lock,fcntl.LOCK_UN)
    except BaseException as error:
        receipt['error']=repr(error)
        raise
    finally:
        receipt['logs']=dict(logs.hashes) if logs is not None else {}
        try:
            if logs is not None:logs.guard()
            guard()
        except BaseException as error:receipt['status']='INCOMPLETE';receipt['guardFailure']=repr(error)
        with (out/'receipt.json').open('x') as stream:stream.write(json.dumps(receipt,indent=2)+'\n')
    print(receipt['status'])

if __name__=='__main__':
    host_main() if '--standard-schema-host' in sys.argv else main()
