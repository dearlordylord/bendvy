"""Existing staged Node recipe, prepare/explicit admitted execution only."""
import ast,fcntl,gzip,hashlib,importlib.util,json,os,shutil,sys
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy')
HERE=Path(__file__).resolve().parent
CORE=ROOT/'.references/bevy-ts/packages/core'
EXPECTED='5217231a5fddc3bb8f014bae8468019bf9176e7ea1c37cba5d529b561900ba6a'
NAMES=('reference.mjs','retry.mjs','lifecycle.mjs','mixed.mjs')
def sha(path):
    path=Path(path)
    if path.is_symlink() or not path.is_file():raise ValueError('regular nonsymlink input required')
    return hashlib.sha256(path.read_bytes()).hexdigest()
def load(name,path):
    spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);exec(compile(Path(path).read_bytes(),str(path),"exec"),m.__dict__);return m
def bootstrap(plan):
    # Stdlib-only: validate every file and directory member before repository code.
    pins=plan['inputs'];required={str(Path(__file__).resolve()),str(ROOT/'scripts/task_runner.py'),str(ROOT/'scripts/evidence_boundary.py'),str(ROOT/'scripts/receipt-logs.py'),str(ROOT/'experiments/public-restore/reference-v1/run.py'),plan['tools']['python']}
    assert required.issubset(pins) and set(pins)==set(plan['files'])|set(plan['directories'])
    for filename,expected in pins.items():
        path=Path(filename);assert path.is_absolute()
        if type(expected) is str:assert sha(path)==expected,filename
        else:assert type(expected)is dict and path.is_dir() and not path.is_symlink() and inventory(path)==expected,filename
    sources={filename:Path(filename).read_bytes()for filename in required if filename.endswith('.py')}
    for filename,raw in sources.items():assert hashlib.sha256(raw).hexdigest()==pins[filename]
    return sources

def runtime(sources=None):
    def exact(name,path):
        spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec)
        raw=sources[str(path)] if sources is not None else Path(path).read_bytes()
        exec(compile(raw,str(path),'exec'),m.__dict__);return m
    runner=exact('ts_exact_task_runner',ROOT/'scripts/task_runner.py')
    boundary=exact('ts_exact_boundary',ROOT/'scripts/evidence_boundary.py')
    logs=exact('ts_exact_logs',ROOT/'scripts/receipt-logs.py')
    path=ROOT/'experiments/public-restore/reference-v1/run.py'
    raw=sources[str(path)] if sources is not None else path.read_bytes()
    tree=ast.parse(raw,str(path));function=next(n for n in tree.body if isinstance(n,ast.FunctionDef)and n.name=='strict')
    # Reuse precisely the existing comparator function; unrelated import side effects
    # and sys.modules aliases are not dependencies of this JSON comparison.
    namespace={};exec(compile(ast.Module(body=[function],type_ignores=[]),str(path),'exec'),namespace)
    return runner,boundary.ReceiptBoundary,boundary.GuardBoundary,logs,namespace['strict']
def inventory(path):
    return {p.relative_to(path).as_posix():sha(p) for p in path.rglob('*')if p.is_file()}
def configs(paths):
    names=('package.json','tsconfig.json','jsconfig.json','.npmrc');result={}
    for path in paths:
        for parent in [path,*path.parents]:
            for name in names:
                p=parent/name
                state={'kind':'file','sha256':sha(p.resolve())} if p.is_file() else {'kind':'directory' if p.is_dir() else 'other' if p.exists() else 'absent'}
                if p.is_symlink():state.update(link=os.readlink(p),resolved=str(p.resolve()))
                result[str(p)]=state
    return result
def joins(stage,oracle):
    assert inventory(CORE/'src')==inventory(stage/'reference/src')
    assert sha(CORE/'package.json')==sha(stage/'reference/package.json')
    for name in NAMES:
        original=(HERE/name).read_text();expected=original.replace(str(CORE/'src'),'../reference/src')
        assert (stage/'study'/name).read_text()==expected
    assert sha(stage/'study/expected.json.gz')==sha(oracle/'expected.json.gz')
    assert (stage/'study/package.json').read_text()=='{"type":"module"}\n'
def prepare(out,oracle):
    runner,*_=runtime();out=Path(out).resolve();oracle=Path(oracle).resolve();out.mkdir();stage=out/'stage'
    shutil.copytree(CORE/'src',stage/'reference/src');shutil.copyfile(CORE/'package.json',stage/'reference/package.json');study=stage/'study';study.mkdir()
    for name in NAMES:(study/name).write_text((HERE/name).read_text().replace(str(CORE/'src'),'../reference/src'))
    shutil.copyfile(oracle/'expected.json.gz',study/'expected.json.gz');(study/'package.json').write_text('{"type":"module"}\n')
    joins(stage,oracle)
    digest=hashlib.sha256()
    with gzip.open(oracle/'expected.json.gz','rb')as stream:
        while chunk:=stream.read(1<<20):digest.update(chunk)
    assert digest.hexdigest()==EXPECTED
    node=Path('/home/node/.local/share/mise/installs/node/24.20.0/bin/node').resolve();taskset=Path('/usr/bin/taskset').resolve();python=Path(sys.executable).resolve()
    files=[Path(__file__),HERE/'test-admission.py',HERE/'admission.stdout',HERE/'admission.stderr',HERE/'admission-v2.stdout',HERE/'admission-v2.stderr',HERE/'admission-v3.stdout',HERE/'admission-v3.stderr',HERE/'SOURCE-BASIS.json',*[(HERE/n)for n in NAMES],*[(oracle/n)for n in ('expected.py','expected.json.gz','source-basis.json','REVIEW.md')],node,taskset,python,CORE/'package.json',ROOT/'.references/sources.json',ROOT/'scripts/task_runner.py',ROOT/'scripts/evidence_boundary.py',ROOT/'scripts/receipt-logs.py',ROOT/'experiments/public-restore/reference-v1/run.py',ROOT/'experiments/public-simulation/delivery-v1/installed-config.py',ROOT/'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/reference-cheap.py']
    basis=json.loads((oracle/'source-basis.json').read_text())
    for path,digest in basis['sources'].items():assert sha(path)==digest;files.append(Path(path))
    inputs=runner.Inputs(files=files,directories=[CORE/'src',stage]);env={'HOME':'/home/node','PATH':'/usr/bin:/bin','LANG':'C','LC_ALL':'C','TZ':'UTC','BEND_NO_TELEMETRY':'1'}
    plan={'scope':'Pinned TS complete public runtime development only; no Bend affine/public/performance qualification','oracle':str(oracle),'stage':str(stage),'tools':{'python':str(python),'node':str(node),'taskset':str(taskset)},'executorSHA256':sha(python),'helperSHA256':sha(Path(__file__)),'files':[str(p)for p in files],'directories':[str(CORE/'src'),str(stage)],'inputs':inputs.expected,'configuration':configs([CORE,HERE,out,study,stage/'reference',node.parent]),'argv':[str(taskset),'-c','5',str(node),str(study/'reference.mjs')],'capSeconds':5,'environment':env,'expectedSHA256':EXPECTED,'stageJoins':'Full original/staged core inventory/package and all4 exact import-only fixture rewrites plus compressed oracle; repeated at every guard'}
    (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(sha(out/'plan.json'))
def run(planpath,admitted):
    planpath=Path(planpath).resolve();assert sha(planpath)==admitted;plan=json.loads(planpath.read_text())
    assert str(Path(sys.executable).resolve())==plan['tools']['python'] and sha(Path(sys.executable).resolve())==plan['executorSHA256']
    assert sha(Path(__file__))==plan['helperSHA256']
    verified=bootstrap(plan)
    runner,ReceiptBoundary,GuardBoundary,LOGS,STRICT=runtime(verified);inputs=runner.Inputs(files=plan['files'],directories=plan['directories']);assert inputs.expected==plan['inputs']
    stage=Path(plan['stage']);oracle=Path(plan['oracle']);out=planpath.parent;node=Path(plan['tools']['node']);logs=LOGS.CommandLogs(out,['reference']);execution=runner.Runner(logs,inputs=inputs,env=plan['environment'],cwd=stage)
    assert plan['argv']==[plan['tools']['taskset'],'-c','5',str(node),str(stage/'study/reference.mjs')] and plan['capSeconds']==5
    for name in ['pre.guard.json','acquired.guard.json','post.guard.json','final.guard.json','reference.stdout','reference.stderr','receipt.json']:
        assert not (out/name).exists() and not (out/name).is_symlink(),name
    record={'status':'INCOMPLETE','scope':plan['scope'],'planSHA256':admitted,'command':None,'guards':[]}
    def guard(label):
        assert sha(planpath)==admitted;inputs.guard();joins(stage,oracle);assert configs([CORE,HERE,out,stage/'study',stage/'reference',node.parent])==plan['configuration'];logs.guard()
        snapshot={'label':label,'unchanged':True,'inputs':inputs.expected,'rawHashes':dict(logs.hashes)};target=out/(label+'.guard.json');assert not target.exists();target.write_text(json.dumps(snapshot,indent=2)+'\n');record['guards'].append({'path':str(target),'sha256':sha(target)})
    with ReceiptBoundary(record,out/'receipt.json',[('final boundary',lambda:guard('final'))]):
        guard('pre')
        with GuardBoundary([('post boundary',lambda:guard('post'))]):
            with open('/tmp/bendvy-parity-heavy.lock','a')as lock:
                fcntl.flock(lock,fcntl.LOCK_EX)
                try:
                    guard('acquired')
                    try:result=execution.run('reference',plan['argv'],5)
                    except BaseException as error:
                        value=getattr(error,'result',None)
                        if isinstance(value,dict):record['command']={k:v for k,v in value.items()if k not in ('stdout','stderr')}
                        raise
                    record['command']={k:v for k,v in result.items()if k not in ('stdout','stderr')}
                finally:fcntl.flock(lock,fcntl.LOCK_UN)
        assert result['stderr']==b''
        expected=gzip.decompress((oracle/'expected.json.gz').read_bytes());assert hashlib.sha256(expected).hexdigest()==EXPECTED==plan['expectedSHA256'];STRICT(json.loads(result['stdout']),json.loads(expected));record['comparison']='Complete type-sensitive whole JSON equality';record['wholeOracleSHA256']=EXPECTED;record['status']='DEVELOPMENT_PASS'
    print(record['status'])
if __name__=='__main__':
    if sys.argv[1]=='prepare':prepare(sys.argv[2],sys.argv[3])
    elif sys.argv[1]=='run':run(sys.argv[2],sys.argv[3])
    else:raise ValueError('prepare or admitted run required')
