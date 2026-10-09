"""Specific normal-exit packaged-Bun profile acceptance; no compiler invocation."""
import hashlib,json,math,sys,os,stat
from pathlib import Path
root=Path(sys.argv[1]).resolve().parent
plan=json.loads((root/'plan.json').read_text())
assert (root/'source-copy-emit.stdout').read_bytes()==b'', 'emit stdout differs from qualified empty stdout'
stderr=(root/'source-copy-emit.stderr').read_bytes() # preserve profiler messages; never reinterpret this as consumer acceptance
c=Path(plan['generated'])
profile=Path(plan['capturedProfile'])
assert profile.is_file() and not profile.is_symlink(),'requested profile absent/nonregular'
capture=json.loads(Path(plan['profileCaptureMetadata']).read_text())
fd=os.open(profile,os.O_RDONLY|os.O_NOFOLLOW|os.O_NONBLOCK)
with os.fdopen(fd,'rb') as stream:
    info=os.fstat(stream.fileno());raw=stream.read()
assert stat.S_ISREG(info.st_mode) and [info.st_dev,info.st_ino]==capture['identities'][str(profile)]
assert len(raw)==capture['bytes'] and hashlib.sha256(raw).hexdigest()==capture['sha256'],'validator bytes differ from emit capture'
assert capture['compilerFailure'] is None and capture['compilerExit'] in plan['allowedCompilerExits']
if capture['compilerExit']==0:
    assert c.is_file() and not c.is_symlink() and c.stat().st_size>0
    if plan['subject']=='qualified33':
        assert hashlib.sha256(c.read_bytes()).hexdigest()==plan['stockCReferenceSHA256'],'copied leaf C differs from retained stock C'
else:
    assert not c.exists() and not c.is_symlink(),'interrupted compiler unexpectedly wrote complete C; refuse'
data=json.loads(raw)
nodes=data['nodes'];samples=data['samples'];deltas=data['timeDeltas']
assert isinstance(nodes,list) and nodes and isinstance(samples,list) and samples
ids=[n['id'] for n in nodes];assert len(ids)==len(set(ids))
assert all(isinstance(i,int) and i in ids for i in samples)
assert len(samples)==len(deltas) and all(isinstance(x,(int,float)) and math.isfinite(x) for x in deltas)
assert all(isinstance(data[k],(int,float)) and math.isfinite(data[k]) for k in ('startTime','endTime'))
assert data['endTime']>=data['startTime']
for node in nodes:
    assert isinstance(node['callFrame']['functionName'],str) and isinstance(node['callFrame']['url'],str)
    assert all(child in ids for child in node.get('children',[]))
frames=[{'functionName':n['callFrame']['functionName'],'url':n['callFrame']['url']} for n in nodes]
events=[]
for line in stderr.decode().splitlines():
    assert line.startswith('BENDVY_PHASE '),'unexpected diagnostic stderr'
    events.append(json.loads(line[len('BENDVY_PHASE '):]))
assert events and events[0]['event']=='startup'
if capture['compilerExit']==75:
    deadlines=[e for e in events if e['event']=='deadline']
    assert len(deadlines)==1 and deadlines[0]['exit']==75 and deadlines[0]['hook'] in ('memo_gc','emit_body') and deadlines[0]['calls']>0
    assert deadlines[0]['limitMs']==plan['deadlineMs'] and deadlines[0]['elapsedMs']>=plan['deadlineMs']
else:
    assert not any(e['event']=='deadline' for e in events)
    assert any(e['event']=='phase-exit' and e['name']=='compile_book' and e['calls']>0 for e in events)
print(json.dumps({'scope':'Copied packed logic diagnostic CPU-profile and phase checkpoint acceptance; no stock backend/allocation/performance claim','profileSHA256':hashlib.sha256(raw).hexdigest(),'profileBytes':len(raw),'emitStderrBytes':len(stderr),'emitStderrSHA256':hashlib.sha256(stderr).hexdigest(),'samples':len(samples),'nodes':len(nodes),'phaseEvents':events,'generatedCBytes':c.stat().st_size if c.exists() else 0,'generatedCSHA256':hashlib.sha256(c.read_bytes()).hexdigest() if c.exists() else None,'frames':frames},indent=2))
