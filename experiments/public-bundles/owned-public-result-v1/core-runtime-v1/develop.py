"""Bounded development controls only; not delivery/proof/performance gates."""
from pathlib import Path
import fcntl,tempfile,zipfile,json,sys,os,hashlib
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'scripts'));import task_runner as R
mode,label=sys.argv[1:];assert mode in ['source','js'];out=HERE/label;assert not out.exists();out.mkdir()
sha=lambda b:hashlib.sha256(b).hexdigest()
with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
 fcntl.flock(lock,fcntl.LOCK_EX)
 archive=(HERE/'source-stage.zip').read_bytes();(out/'source-stage.zip').write_bytes(archive)
 with tempfile.TemporaryDirectory(prefix='bendvy-core-runtime-dev-') as t:
  stage=Path(t)
  with zipfile.ZipFile(HERE/'source-stage.zip') as z:
   names=set(z.namelist());assert len(names)==len(z.namelist())
   for n in names:
    p=stage/n;assert p.is_relative_to(stage) and '..' not in Path(n).parts;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(z.read(n))
  inventory={str(p.relative_to(stage)):sha(p.read_bytes()) for p in stage.rglob('*') if p.is_file()}
  main=stage/HERE.relative_to(ROOT)/'main.bend';env=dict(os.environ,BEND_NO_TELEMETRY='1')
  commands=[([str(ROOT/'scripts/bend-check'),str(main)],5)] if mode=='source' else [(['bend',str(main),'-o',str(out/'main.js')],30),(['node',str(out/'main.js')],5)]
  results=[]
  for i,(argv,seconds) in enumerate(commands):
   result=R.execute_result(argv,seconds,cwd=stage,env=env,capture='split');results.append(result)
   for stream in ['stdout','stderr']:(out/f'{i}.{stream}').write_bytes(result[stream])
   (out/'results.json').write_text(json.dumps(results,indent=2,default=lambda b:{'rawHex':b.hex()})+'\n')
   assert inventory=={str(p.relative_to(stage)):sha(p.read_bytes()) for p in stage.rglob('*') if p.is_file()}
   print(result['exit'],result['failure']);print(result['stderr'].decode())
   if result['exit']!=0 or result['failure'] is not None:break
  if mode=='js' and len(results)==2 and results[-1]['exit']==0:
   assert results[-1]['stdout']==(HERE/'expected.stdout').read_bytes(),'complete independent literal oracle mismatch'
