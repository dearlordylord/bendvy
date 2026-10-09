"""Specific normal-exit packaged-Bun profile acceptance; no compiler invocation."""
import hashlib,json,math,sys
from pathlib import Path
root=Path(__file__).resolve().parent
plan=json.loads((root/'plan.json').read_text())
assert (root/'emit.stdout').read_bytes()==b'', 'emit stdout differs from qualified empty stdout'
stderr=(root/'emit.stderr').read_bytes() # preserve profiler messages; never reinterpret this as consumer acceptance
c=Path(plan['generated']);assert c.is_file() and not c.is_symlink() and c.stat().st_size>0
profile=root/'profiles/compiler.cpuprofile'
assert profile.is_file() and not profile.is_symlink(),'requested profile absent/nonregular'
raw=profile.read_bytes();data=json.loads(raw)
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
print(json.dumps({'scope':'Actual packaged ELF CPU-profile normal-exit acceptance only; no deadline survival/allocation/performance claim','profileSHA256':hashlib.sha256(raw).hexdigest(),'profileBytes':len(raw),'emitStderrBytes':len(stderr),'emitStderrSHA256':hashlib.sha256(stderr).hexdigest(),'samples':len(samples),'nodes':len(nodes),'generatedCBytes':c.stat().st_size,'generatedCSHA256':hashlib.sha256(c.read_bytes()).hexdigest(),'frames':frames},indent=2))
