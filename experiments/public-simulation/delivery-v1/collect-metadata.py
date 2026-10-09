"""Execute one exact reviewed narrow metadata cohort using existing helpers."""
import fcntl
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import stat
import sys
HERE=Path(__file__).resolve().parent

def regular_bytes(path):
    fd=os.open(path,os.O_RDONLY|os.O_NOFOLLOW|os.O_NONBLOCK)
    with os.fdopen(fd,'rb')as stream:
        if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode):raise ValueError('regular metadata file required')
        return stream.read()
def sha(path):return hashlib.sha256(regular_bytes(path)).hexdigest()
def capture(path,raw):
    fd=os.open(path,os.O_WRONLY|os.O_CREAT|os.O_EXCL|os.O_NOFOLLOW,0o600)
    with os.fdopen(fd,'wb')as stream:
        if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode):raise ValueError('regular metadata output required')
        stream.write(raw)
def load(name,path):
    spec=importlib.util.spec_from_file_location(name,path);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);return module

def admitted(plan_path,digest):
    path=Path(plan_path)
    if sha(path)!=digest:raise ValueError('exact metadata plan digest required')
    plan=json.loads(regular_bytes(path));pins=dict(plan['pins']);pins[str(path.resolve())]=digest
    python=str(Path(sys.executable).resolve(strict=True))
    if python!=plan['python'] or sha(python)!=pins[python]:raise ValueError('metadata interpreter drift')
    if {p:sha(p)for p in pins}!=pins:raise ValueError('metadata input drift before imports')
    if str(Path(__file__).resolve())not in pins:raise ValueError('collector must be pinned')
    return plan,pins

def run(plan_path,digest):
    plan,pins=admitted(plan_path,digest)
    # All transitive modules are exact pinned before their code executes.
    root=Path('/workspace/formal-proofs/bendvy')
    for path in [HERE/'prepare-metadata.py',root/'scripts/task_runner.py',root/'scripts/evidence_boundary.py']:
        if str(path.resolve())not in pins:raise ValueError('missing transitive helper pin')
    metadata=load('simulation_metadata',HERE/'prepare-metadata.py')
    runner=load('simulation_metadata_runner',root/'scripts/task_runner.py')
    boundary=load('simulation_metadata_boundary',root/'scripts/evidence_boundary.py')
    out=Path(plan['outputRoot'])
    if out.exists()or out.is_symlink():raise ValueError('metadata output root starts absent')
    out.mkdir(mode=0o700)
    receipt=out/'receipt.json';capture(receipt,b'')
    record={'scope':plan['scope'],'planSHA256':digest,'commands':[],'guards':[],'closedResolverQualified':False}
    def guard(label):
        actual={p:sha(p)for p in pins};namespace=metadata.namespace_state(plan['namespaceLiterals'])
        unchanged=actual==pins and namespace==plan['namespace']
        target=out/(label+'.guard.json');capture(target,(json.dumps({'label':label,'unchanged':unchanged,'actualPins':actual,'namespace':namespace},indent=2)+'\n').encode())
        record['guards'].append({'path':str(target),'sha256':sha(target)})
        # Reserve/validate the receipt destination before ReceiptBoundary writes.
        regular_bytes(receipt)
        if not unchanged:raise ValueError('metadata boundary drift')
    with boundary.ReceiptBoundary(record,receipt,[('final',lambda:guard('final'))]):
        for command in plan['commands']:
            label=command['label'];guard(label+'-pre')
            with boundary.GuardBoundary([('post',lambda:guard(label+'-post'))]):
                with open(plan['lock'],'a')as lock:
                    fcntl.flock(lock,fcntl.LOCK_EX)
                    try:
                        guard(label+'-acquired')
                        result=runner.execute_result(command['argv'],command['capSeconds'],plan['environment'],str(HERE),'split')
                        row={k:v for k,v in result.items()if not isinstance(v,bytes)}
                        row.update(label=label,argv=command['argv'],capSeconds=command['capSeconds'])
                        # Retain returned process evidence before any publication can fail.
                        record['commands'].append(row)
                        for stream in ['stdout','stderr']:
                            target=Path(command[stream]);raw=result[stream]
                            row[stream]={'path':str(target),'returnedBytes':len(raw),
                              'returnedSHA256':hashlib.sha256(raw).hexdigest(),
                              'publication':'PENDING'}
                            try:
                                capture(target,raw)
                            except BaseException as error:
                                row[stream]['publication']='FAILED_ABSENT'
                                row['captureFailure']={'stream':stream,'type':type(error).__name__}
                                if target.exists() or target.is_symlink():
                                    actual=regular_bytes(target);pins[str(target)]=sha(target)
                                    row[stream].update(publication='FAILED_PARTIAL',
                                      bytes=len(actual),sha256=pins[str(target)])
                                raise
                            pins[str(target)]=sha(target)
                            row[stream].update(publication='PUBLISHED',bytes=len(raw),sha256=pins[str(target)])
                        if result['failure']is not None or result['exit']!=0:raise RuntimeError('metadata command refused: '+label)
                    finally:fcntl.flock(lock,fcntl.LOCK_UN)
        record['status']='METADATA_CAPTURED_NOT_RESOLVER_ADMISSION'
if __name__=='__main__':run(sys.argv[1],sys.argv[2])
