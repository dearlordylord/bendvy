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

if __name__ == "__main__":
    main()
