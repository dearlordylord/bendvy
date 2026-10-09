#!/usr/bin/env python3
"""One admitted reference emit diagnostic; no installed/backend qualification."""
import fcntl,hashlib,importlib.util,json,os,stat,sys
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy')
HERE=Path(__file__).resolve().parent

def sha(path):
    path=Path(path)
    if path.is_symlink() or not path.is_file(): raise ValueError('regular non-symlink input required')
    fd=os.open(path,os.O_RDONLY|os.O_NOFOLLOW|os.O_NONBLOCK)
    with os.fdopen(fd,'rb') as stream:
        if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode): raise ValueError('regular descriptor required')
        return hashlib.sha256(stream.read()).hexdigest()

def load(name,path):
    spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m

def capture(path,raw):
    if path.exists() or path.is_symlink(): raise ValueError('raw starts absent')
    fd=os.open(path,os.O_WRONLY|os.O_CREAT|os.O_EXCL|os.O_NOFOLLOW,0o600)
    with os.fdopen(fd,'wb') as stream:
        if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode): raise ValueError('regular raw descriptor required')
        stream.write(raw)

def run(plan_path,admitted):
    plan_path=Path(plan_path).resolve(strict=True)
    if sha(plan_path)!=admitted: raise ValueError('plan admission mismatch')
    plan=json.loads(plan_path.read_text());pins=dict(plan['pins']);pins[str(plan_path)]=admitted
    if {path:sha(path) for path in pins}!=pins: raise ValueError('inputs changed')
    actual_python=str(Path(sys.executable).resolve(strict=True))
    if actual_python!=plan['tools']['python'] or sha(actual_python)!=pins[actual_python]: raise ValueError('actual executor interpreter drift')
    runner=load('reference_runner',ROOT/'scripts/task_runner.py');boundary=load('reference_boundary',ROOT/'scripts/evidence_boundary.py')
    out=plan_path.parent;artifact=Path(plan['output']);record={'scope':plan['scope'],'planSHA256':admitted,'commands':[],'guards':[]}
    def guard(label):
        actual={path:sha(path)for path in pins};unchanged=actual==pins
        target=out/(label+'.guard.json');capture(target,(json.dumps({'label':label,'unchanged':unchanged,'actualPins':actual},indent=2)+'\n').encode());record['guards'].append({'path':str(target),'sha256':sha(target)})
        if not unchanged: raise ValueError('boundary drift')
    with boundary.ReceiptBoundary(record,out/'receipt.json',[('final boundary',lambda:guard('final'))]):
        guard('emit-pre')
        with boundary.GuardBoundary([('post boundary',lambda:guard('emit-post'))]):
            with open('/tmp/bendvy-parity-heavy.lock','a')as lock:
                fcntl.flock(lock,fcntl.LOCK_EX)
                try:
                    guard('emit-acquired')
                    if artifact.exists() or artifact.is_symlink(): raise ValueError('artifact starts absent')
                    result=runner.execute_result(plan['argv'],30,json.loads(Path(plan['environmentFile']).read_text()),str(HERE),'split')
                finally:fcntl.flock(lock,fcntl.LOCK_UN)
            row={'label':'reference-emit','argv':plan['argv'],'capSeconds':30}
            for key,value in result.items():
                if isinstance(value,bytes):
                    target=out/('emit.'+key);capture(target,value);digest=sha(target);row[key]={'path':str(target),'bytes':len(value),'sha256':digest};pins[str(target)]=digest
                else:row[key]=value
            record['commands'].append(row)
            if artifact.exists()or artifact.is_symlink():pins[str(artifact)]=sha(artifact);record['artifactSHA256']=pins[str(artifact)]
            record['status']='REFERENCE_DIAGNOSTIC_TERMINAL' if result['failure']is None else 'INCOMPLETE'
            record['qualifiesInstalledCompiler']=False
if __name__=='__main__':run(sys.argv[1],sys.argv[2])
