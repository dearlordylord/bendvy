#!/usr/bin/env python3
"""One admitted reference emit diagnostic; no installed/backend qualification."""
import fcntl,hashlib,json,os,stat,sys,types
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

VERIFIED_SOURCES={}
def load(name,path):
    path=Path(path).resolve(strict=True)
    raw=VERIFIED_SOURCES[str(path)] if VERIFIED_SOURCES else path.read_bytes()
    m=types.ModuleType(name);m.__file__=str(path);m.__dict__['VERIFIED_SOURCES']=VERIFIED_SOURCES
    exec(compile(raw,str(path),'exec'),m.__dict__);return m

def capture(path,raw):
    if path.exists() or path.is_symlink(): raise ValueError('raw starts absent')
    fd=os.open(path,os.O_WRONLY|os.O_CREAT|os.O_EXCL|os.O_NOFOLLOW,0o600)
    with os.fdopen(fd,'wb') as stream:
        if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode): raise ValueError('regular raw descriptor required')
        stream.write(raw)

def validate_profile(data):
    if not isinstance(data,dict) or not isinstance(data.get('nodes'),list) or not data['nodes']:
        raise ValueError('profile nodes missing')
    ids={node['id']for node in data['nodes']}
    if len(ids)!=len(data['nodes']):raise ValueError('duplicate profile node')
    samples=data.get('samples');deltas=data.get('timeDeltas')
    if not isinstance(samples,list)or not isinstance(deltas,list)or len(samples)!=len(deltas)or not samples:
        raise ValueError('sample/delta mismatch or empty capture')
    if any(sample not in ids for sample in samples):raise ValueError('unknown sampled node')
    if any(type(delta) is not int for delta in deltas):raise ValueError('invalid sample delta')
    if data.get('endTime',-1)<data.get('startTime',0):raise ValueError('invalid profile interval')


def run(plan_path,admitted):
    plan_path=Path(plan_path).resolve(strict=True)
    if sha(plan_path)!=admitted: raise ValueError('plan admission mismatch')
    plan=json.loads(plan_path.read_text());pins=dict(plan['pins']);pins[str(plan_path)]=admitted
    actual=Path(sys.executable).resolve(strict=True)
    if str(actual)!=plan['pythonInterpreter'] or sha(actual)!=pins[str(actual)]:raise ValueError('actual interpreter differs before helpers')
    if {path:sha(path) for path in pins}!=pins: raise ValueError('inputs changed')
    global VERIFIED_SOURCES
    VERIFIED_SOURCES={name:Path(name).read_bytes() for name in pins if name.endswith('.py')}
    if any(hashlib.sha256(raw).hexdigest()!=pins[name] for name,raw in VERIFIED_SOURCES.items()):raise ValueError('captured source drift')
    runner=load('reference_runner',ROOT/'scripts/task_runner.py');boundary=load('reference_boundary',ROOT/'scripts/evidence_boundary.py')
    out=plan_path.parent;artifact=Path(plan['output']);profile=Path(plan['profile']);record={'scope':plan['scope'],'planSHA256':admitted,'commands':[],'guards':[]}
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
                    if any(p.exists() or p.is_symlink() for p in (artifact,profile)): raise ValueError('artifacts start absent')
                    result=runner.execute_result(plan['argv'],30,plan['environment'],str(HERE),'split')
                finally:fcntl.flock(lock,fcntl.LOCK_UN)
            row={'label':'reference-emit','argv':plan['argv'],'capSeconds':30}
            for key,value in result.items():
                if isinstance(value,bytes):
                    target=out/('emit.'+key);capture(target,value);digest=sha(target);row[key]={'path':str(target),'bytes':len(value),'sha256':digest};pins[str(target)]=digest
                else:row[key]=value
            record['commands'].append(row)
            if artifact.exists()or artifact.is_symlink():pins[str(artifact)]=sha(artifact);record['artifactSHA256']=pins[str(artifact)]
            if profile.exists()or profile.is_symlink():
                pins[str(profile)]=sha(profile);record['profileSHA256']=pins[str(profile)]
                data=json.loads(profile.read_text());validate_profile(data);record['profileSamples']=len(data['samples'])
                record['profileCaptured']=True
            record['status']='REFERENCE_CPU_PROFILE_CAPTURED' if record.get('profileCaptured') and result['failure']is None else 'INCOMPLETE'
            record['qualifiesInstalledCompiler']=False
if __name__=='__main__':run(sys.argv[1],sys.argv[2])
