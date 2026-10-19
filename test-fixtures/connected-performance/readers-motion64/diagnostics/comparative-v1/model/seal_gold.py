"""Source-only Readers comparator oracle; original operation models remain immutable."""
from pathlib import Path
import argparse,copy,gzip,hashlib,json,sys
SOURCE=Path(__file__).resolve().parent
ORIGINAL=SOURCE.parents[2]/'model'
sys.path.insert(0,str(ORIGINAL))
import common_model as C
import ts_model as T
import ts_observer as TO
sha=lambda b:hashlib.sha256(b).hexdigest()
compact=C.compact

seed_frames=[]
finish_outcomes=[]
OriginalFrame=C.O.Frame
OriginalTransaction=C.O.Transaction
class FrameObserver(OriginalFrame):
    def __init__(self,*args,**kw):
        super().__init__(*args,**kw)
        if self.facts and self.facts[0].startswith('operation=3;'):
            seed_frames.append(copy.deepcopy(self))
class TransactionObserver(OriginalTransaction):
    def finish(self,success=True):
        result=super().finish(success)
        finish_outcomes.append(success)
        return result

class Observer(C.Observer):
    def __init__(self,*args,**kw):
        super().__init__(*args,**kw)
        self.public_locals=[];self.public_reads=[];self.public_schedules=[];self.seed_frame=None
    def frame_value(self,frame):
        return dict(count=frame.count,iteration=frame.iteration,
                    transient=None if frame.transient is None else self.actor(frame.transient),
                    reservations=[self.actor(h) for h in frame.reservations])
    def prime(self):
        # Original report has already finished/applied the seed at this boundary.
        # The original source seed Frame returns these actual reservations unchanged.
        self.actor_keys=list(self.world.main_handles())
        assert len(seed_frames)==1 and len(finish_outcomes)==1
        assert seed_frames[0].reservations==self.actor_keys
        self.seed_frame=self.frame_value(seed_frames[0]);self.seed_success=finish_outcomes[0]
        super().prime()
    def mutation(self,operation):
        super().mutation(operation)
        self.public_locals.append(dict(id=operation+1,operation=operation,status=0,
                                       frame=self.frame_value(self.frame)))
    def read(self,provider):
        super().read(provider)
        record=copy.deepcopy(self.method_reads[-1]);observed=self.audit[-1]
        for name in ['removed','despawned']:
            record[name]['lagged']=observed['events'][name][1]
        self.public_reads.append(record)
    def schedule(self,name,ids,barrier=False):
        super().schedule(name,ids,barrier)
        steps=[dict(kind='System',id=i,condition=0)for i in ids]
        observations=[dict(kind='Ran',id=i)for i in ids]
        if barrier:steps.append(dict(kind='Barrier'));observations.append(dict(kind='Applied'))
        # Actual ordinary App provisioning returns [] and describe returns its namespace.
        self.public_schedules.append(dict(namespace=self.world.namespace,name=name,steps=steps,
                                         requirements=[],status=dict(kind='Complete'),observations=observations))
    def public(self):
        assert len(self.public_locals)==192 and len(self.public_reads)==84 and len(self.public_schedules)==194
        # Final seed field grammar is pinned to the concrete source before sealing.
        return dict(seedCall=dict(frame=self.seed_frame,outcome=dict(kind='Success'if self.seed_success else'Failure')),
                    locals=self.public_locals,reads=self.public_reads,schedules=self.public_schedules)

def assert_ts_observer_delta():
    text=(SOURCE/'ts_observer.py').read_text()
    text=text.replace('def observe(count=64,iterations=64):','def evaluate(count=64,iterations=64):')
    text=text.replace('\n public_updates=[]','')
    text=text.replace("public_updates.append({'iteration':i,'access':copy.deepcopy(live[actor]['main'])});",'')
    text=text.replace(' return records,full,public_updates',' return records,full')
    assert text==(ORIGINAL/'ts_model.py').read_text(),'TS observer must preserve every original operation'

def retained_controls(gold,worlds,ts_full):
    expected=json.loads((ORIGINAL/'EXPECTED.json').read_text())
    controls={}
    for role in ['bend','ts']:
        f=gold/f'{role}-expected.stdout.gz';raw=gzip.decompress(f.read_bytes())
        assert dict(bytes=len(raw),sha256=sha(raw))=={k:expected['oracles'][role][k]for k in ['bytes','sha256']}
        lines=raw.splitlines();tuples=[json.loads(x[6:])for x in lines if x.startswith(b'TUPLE:')]
        maps=[json.loads(x[7:])for x in lines if x.startswith(b'ACTORS:')]
        assert len(tuples)==len(maps)==2
        for w,cells,actors in zip(worlds,tuples,maps):
            assert cells==w['tuple']
            assert actors==(w['rawActorMap']if role=='bend'else ts_full['method']['rawActorMap'])
        if role=='bend':
            chunks=raw.split(b'CANONICAL-BEGIN\n')[1:];assert len(chunks)==2
            for w,chunk in zip(worlds,chunks):assert chunk.split(b'CANONICAL-END\n')[0]==w['canonicalRaw']
        else:
            reports=[json.loads(x[5:])for x in lines if x.startswith(b'FULL:')]
            assert reports==[ts_full,ts_full]
        controls[role]=dict(path=str(f),gzipSHA256=sha(f.read_bytes()),bytes=len(raw),sha256=sha(raw))
    common=json.loads(gzip.decompress((gold/'expected-common.json.gz').read_bytes()))
    assert common==dict(tuple=worlds[0]['tuple'],fold=worlds[0]['fold'])
    return controls

def derive(gold):
    assert_ts_observer_delta()
    ts_records,ts_full=T.evaluate(64,64)
    observed_records,observed_full,updates=TO.observe(64,64)
    assert observed_records==ts_records and observed_full==ts_full
    ts_public=dict(ticks=[copy.deepcopy(x['outcome'])for x in ts_full['method']['rawTickOutcomes']],updates=updates)
    assert len(ts_public['ticks'])==196 and len(updates)==64
    worlds=[];old=C.O.Program;C.O.Program=Observer;C.O.Frame=FrameObserver;C.O.Transaction=TransactionObserver
    try:
        for label,namespace in [('WARMUP',1),('SAMPLE',2)]:
            seed_frames.clear();finish_outcomes.clear()
            raw,program=C.O.report(64,64,namespace)
            records=program.completed();assert records==ts_records
            actors=program.actor_map_raw();assert len(actors)==128
            cells=C.tuple_records(records);assert len(records)==280 and len(cells)==946819 and C.fold(cells)==2526790183
            pub=program.public()
            for full,common in zip(pub['reads'],program.method_reads):
                without=copy.deepcopy(full)
                for name in ['removed','despawned']:without[name].pop('lagged')
                assert without==common
            worlds.append(dict(label=label,namespace=namespace,records=records,tuple=cells,fold=C.fold(cells),rawActorMap=actors,canonicalRaw=raw,publicBend=pub,publicTS=ts_public))
    finally:C.O.Program=old;C.O.Frame=OriginalFrame;C.O.Transaction=OriginalTransaction
    controls=retained_controls(gold,worlds,ts_full)
    streams={}
    for role in ['bend','ts']:
        pieces=[]
        for world in worlds:
            pub=world['publicBend'if role=='bend'else'publicTS'];public_cells=C.tuple_records([pub]);public_fold=C.fold(public_cells)
            actor_map=world['rawActorMap']if role=='bend'else ts_full['method']['rawActorMap']
            show=lambda value:json.dumps(value)if role=='bend'else compact(value)
            pieces.append((world['label']+'\nFORCE:'+str(world['fold'])+'\nPUBLIC-FORCE:'+str(public_fold)+'\nTUPLE:'+show(world['tuple'])+'\nPUBLIC-TUPLE:'+show(public_cells)+'\nACTORS:'+compact(actor_map)+'\n').encode())
            world.setdefault('public',{})[role]=dict(publicTupleValues=len(public_cells),publicFold=public_fold,publicJSONBytes=len(compact(pub).encode()),publicJSONSHA256=sha(compact(pub).encode()))
        streams[role]=b''.join(pieces)
    return worlds,streams,controls

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args();assert not args.output.exists()
    basis=json.loads((SOURCE/'SOURCE-BASIS.json').read_text())
    for path,digest in basis['sourcePins'].items():assert sha(Path(path).read_bytes())==digest,path
    worlds,streams,controls=derive(Path(basis['acceptedGold']))
    args.output.mkdir()
    outputs={}
    for role,raw in streams.items():
        packed=gzip.compress(raw,mtime=0);(args.output/f'{role}-expected.stdout.gz').write_bytes(packed)
        outputs[role]=dict(bytes=len(raw),sha256=sha(raw),gzipBytes=len(packed),gzipSHA256=sha(packed))
    fixture=[{k:v for k,v in w.items()if k!='canonicalRaw'}for w in worlds]
    (args.output/'observer-fixtures.json.gz').write_bytes(gzip.compress(compact(fixture).encode(),mtime=0))
    result=dict(status='PASS',scope='Independent ReadersMotion64 original common carrier plus role-specific public work; no subject execution or performance claim.',sourceBasisSHA256=sha((SOURCE/'SOURCE-BASIS.json').read_bytes()),retainedControls=controls,
                worlds=[dict(label=w['label'],namespace=w['namespace'],records=len(w['records']),tupleValues=len(w['tuple']),fold=w['fold'],actors=len(w['rawActorMap']),public=w['public'])for w in worlds],oracles=outputs)
    (args.output/'PILOT-ORACLE-BASIS.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':main()
