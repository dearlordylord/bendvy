"""Use unchanged collector; retain profiler files even when emit/refusal fails."""
import hashlib,json,os,stat,sys,types
from pathlib import Path
root=Path(__file__).resolve().parent
planpath=root/'plan.json'; expected=sys.argv[1]
assert hashlib.sha256(planpath.read_bytes()).hexdigest()==expected
plan=json.loads(planpath.read_text())
assert str(Path(sys.executable).resolve())==plan['tools']['python']
for name,digest in plan['pins'].items():
    p=Path(name);assert p.is_file() and not p.is_symlink() and hashlib.sha256(p.read_bytes()).hexdigest()==digest
profiles=root/'profiles'
if not profiles.exists() and not profiles.is_symlink():profiles.mkdir()
assert profiles.is_dir() and not profiles.is_symlink() and not list(profiles.iterdir())
assert not (root/'receipt.json').exists() and not (root/'receipt.json').is_symlink()
assert not (root/'profile-artifacts.json').exists()
module=types.ModuleType('unchanged_collector');module.__file__=plan['collector']
exec(compile(Path(plan['collector']).read_bytes(),plan['collector'],'exec'),module.__dict__)
try:
    module.run(planpath,expected)
finally:
    # Capture all normal/partial/refusal artifacts; never repair or substitute them.
    rows=[]
    for p in sorted(profiles.iterdir()):
        row={'path':str(p),'regular':p.is_file() and not p.is_symlink()}
        if row['regular']:
            fd=os.open(p,os.O_RDONLY|os.O_NOFOLLOW|os.O_NONBLOCK)
            with os.fdopen(fd,'rb') as stream:
                assert stat.S_ISREG(os.fstat(stream.fileno()).st_mode)
                raw=stream.read()
            row.update(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())
        rows.append(row)
    receipt=json.loads((root/'receipt.json').read_text()) if (root/'receipt.json').is_file() else {}
    capture=receipt.get('profileCapture')
    joins={}
    if capture:
        for key in ('original','snapshot'):
            p=Path(capture[key])
            joins[key]=False
            if p.is_file() and not p.is_symlink():
                fd=os.open(p,os.O_RDONLY|os.O_NOFOLLOW|os.O_NONBLOCK)
                with os.fdopen(fd,'rb') as stream:
                    info=os.fstat(stream.fileno());raw=stream.read()
                now=p.lstat()
                joins[key]=stat.S_ISREG(info.st_mode) and stat.S_ISREG(now.st_mode) and [info.st_dev,info.st_ino]==[now.st_dev,now.st_ino]==capture['identities'][str(p)] and hashlib.sha256(raw).hexdigest()==capture['sha256'] and len(raw)==capture['bytes']
    with (root/'profile-artifacts.json').open('x') as stream:
        json.dump({'scope':'Lossless files remain at paths; preserve all artifacts including malformed/partial, no success inference','files':rows,'profileCapture':capture,'captureJoins':joins,'collectorReceiptSHA256':hashlib.sha256((root/'receipt.json').read_bytes()).hexdigest() if (root/'receipt.json').is_file() else None},stream,indent=2);stream.write('\n')

    if receipt.get('status')=='COMPLETE_CONSUMER_DEVELOPMENT_PASS':
        assert joins=={'original':True,'snapshot':True},'final profile capture joins failed'
