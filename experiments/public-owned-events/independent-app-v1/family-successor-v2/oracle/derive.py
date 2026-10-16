"""Family successor finite model: separate stream, shared journal and resource log.
Reuses only own formatting/state model after checking successor transitions.
Consumes no runtime, generator, golden, or previous expected-output bytes.
"""
from pathlib import Path
import gzip, hashlib, json
HERE=Path(__file__).resolve().parent

def seq(xs, f=str): return ''.join(f(x)+',' for x in xs)+'[]'
def arr(xs):
    if len(xs)==1:return str(xs[0]).lower()
    n=len(xs)//2
    return '['+arr(xs[:n])+','+arr(xs[n:])+']'
def array(seed): return [seed,seed+3,seed+8,seed+15]
def manifest(p):return f'manifest({p[0]},{arr(p[1])})'
def row(r):return f'row({r[0]},{manifest(r[1])})'
def args(a):return f'args({str(a[0]).lower()},{seq(a[1],lambda xs:"["+seq(xs)+"]")},{arr(a[2])})'

def derive():
    # Registration prepends World metadata; reader registration is lazy.
    metadata=seq([(3,'warehouse','read'),(2,'dock','read'),(1,'dispatch','write')],lambda m:f'registration({m[0]},{m[1]},cargo:manifest:{m[2]},[])')
    registries=[f'registry(1,{i},{name},cargo:manifest:{access},[],0)' for i,name,access in [(1,'dispatch','write'),(2,'dock','read'),(3,'warehouse','read')]]
    owners=[]; batches=[]; journal=[]; positions=[]; next_id=1; tick=frame_start=boundary=dropped=0
    fa=[True,[],array(701)]; sa=[False,[],array(801)]; report=['cargo-manifests-family-v2\n']; snapshots=[]; recovered=[]; retired=[]
    def snap(label):
        assert [r[0] for r in owners]==[k for _,ks in journal for k in ks]
        assert journal == batches
        assert len({r[0] for r in owners})==len(owners)
        world=f'world(1,1,0,false,1,0,unit,{arr(array(901))},log({next_id},{seq(owners,row)}),events({seq([k for _,ks in batches for k in ks])}),pending(0),{metadata},4,0)'
        runtime=f'family(stream(cargo:manifest,{seq(batches,lambda b:f"batch({b[0]},{seq(b[1])})")},{seq(positions,lambda p:f"position({p[0]},{p[1]},{p[2]})")},3,{frame_start},{boundary},8,{dropped}),owners=unit,journal={seq(journal,lambda b:f"batch({b[0]},{seq(b[1])})")},frameStart={frame_start});runtime-tick={tick}'
        report.append(f'{label}:{world};{runtime};{registries[0]};reader(1,1,2);{registries[1]};reader(1,2,3);{registries[2]};fast={args(fa)};slow={args(sa)}\n')
        snapshots.append(dict(label=label,tick=tick,frameStart=frame_start,boundary=boundary,droppedThrough=dropped,owners=[r[0] for r in owners],positions=[list(p) for p in positions],journal=[list(b) for b in journal],familyFrameStart=frame_start,streamDomain="cargo:manifest",familyOwners="unit"))
    def publish(code,seed,fail):
        nonlocal tick,next_id
        tick+=1; p=(code,array(seed))
        if fail: recovered.append(p)
        else:
            owners.append((next_id,p)); batches.append((tick,[next_id])); journal.append((tick,[next_id])); next_id+=1
        report.append(f'publish={"failure(73)" if fail else "success"};recovered={seq([p] if fail else [],manifest)}\n')
    def read(reader,a,name):
        nonlocal tick,positions
        old_tick=tick; tick+=1
        pos=next((p for p in positions if p[0]==reader),None)
        cursor=pos[1] if pos else 0; registered=pos[2] if pos else old_tick
        lag=max(cursor,registered)<dropped
        keys=[k for t,ks in batches if t>cursor for k in ks]
        for key in keys:
            p=next(r[1] for r in owners if r[0]==key)
            a[1].insert(0,[p[0]]+p[1]); a[2][0]=p[0]
            if a[0]:break
        failed=bool(keys) and a[0]
        if pos is None:positions.insert(0,(reader,0,old_tick))
        if not failed:positions=[(i,tick if i==reader else c,r) for i,c,r in positions]
        report.append(f'{name}:read={"body-failure(73)" if failed else "success"};lagged={str(lag).lower()}\n')
    def frame():
        nonlocal frame_start,boundary,dropped,batches,journal,owners
        boundary=frame_start;frame_start=tick
        held=min([boundary]+[p[1] for p in positions])
        removed=[]
        while batches and batches[0][0]<=held:removed.append(batches.pop(0))
        while sum(len(b[1]) for b in batches)>8:removed.append(batches.pop(0))
        dropped=max([dropped]+[b[0] for b in removed])
        journal=[(t,ks) for t,ks in journal if t>dropped]
        ids=[k for _,ks in journal for k in ks]
        receipt=[r for r in owners if r[0] not in ids];owners=[r for r in owners if r[0] in ids];retired.extend(receipt)
        report.append('retired='+seq(receipt,row)+'\n')
    snap('created');publish(11,101,False);snap('commit-a');publish(22,202,True);snap('abort-b')
    read(1,fa,'fast');snap('fast-failed');fa[0]=False;read(1,fa,'fast');snap('fast-retry')
    frame();snap('frame-one');publish(33,303,False);snap('commit-c');read(1,fa,'fast');snap('fast-c')
    read(2,sa,'slow');snap('slow-a-c');frame();snap('frame-two');frame();snap('frame-three')
    publish(44,404,False);snap('commit-d');report.append('shutdown:retired='+seq(owners,row)+'\n');retired.extend(owners);owners=[];batches=[];journal=[];snap('shutdown')
    assert [p[0] for p in recovered]==[22]
    assert [r[1][0] for r in retired]==[11,33,44]
    assert len(snapshots)==13 and next_id==4 and tick==8
    assert fa[1]==[[33,303,306,311,318],[11,101,104,109,116],[11,101,104,109,116]]
    assert sa[1]==[[33,303,306,311,318],[11,101,104,109,116]]
    return (''.join(report)+'\n').encode(),snapshots
if __name__=='__main__':
    raw,snapshots=derive()
    (HERE/'expected.stdout').write_bytes(raw)
    (HERE/'expected.stdout.gz').write_bytes(gzip.compress(raw,mtime=0))
    (HERE/'state-trace.json').write_text(json.dumps(snapshots,indent=2)+'\n')
    print(json.dumps({'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),'gzip_bytes':len(gzip.compress(raw,mtime=0)),'gzip_sha256':hashlib.sha256(gzip.compress(raw,mtime=0)).hexdigest()}))
