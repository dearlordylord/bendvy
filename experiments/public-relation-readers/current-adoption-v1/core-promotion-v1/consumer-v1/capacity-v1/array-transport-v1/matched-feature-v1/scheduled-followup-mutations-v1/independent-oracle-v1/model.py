#!/usr/bin/env python3
"""Complete source-only predictions of two current scheduled semantic mutants."""
from collections import deque
import copy
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys
HERE=Path(__file__).resolve().parent
BASE=HERE.parent.parent/'scheduled-followup-oracle-v1'
spec=importlib.util.spec_from_file_location('baseline_model',BASE/'model.py')
model=importlib.util.module_from_spec(spec)
spec.loader.exec_module(model)
Original=model.Model
class WrongReader(Original):
    def commit(self,positions,reader,cursor):
        if positions is self.event_positions:
            reader+=1
            self.activate(positions,reader,max(0,cursor-1))
        Original.commit(positions,reader,cursor)

class Premature(Original):
    def drain(self):
        self.clock+=1
        tick=max(self.route,self.failure_tick,self.clock)
        for source,target in self.pending:
            if target==model.HANDLE:error=model.SELF
            elif target==model.MISSING:error=model.ABSENT
            else:
                assert target==model.TARGET
                self.graph=copy.deepcopy(model.GRAPH)
                continue
            domain=self.domain(1)
            domain['queue']['back'].insert(0,model.base.batch(tick,[error]))
            domain['queue']['size']+=1
        self.pending=[]
        self.route=self.failure_tick=tick
    def write(self,targets):
        super().write(targets)
        self.drain()  # actual extra Mixed.barrier before writer_result observation
        self.timeline.pop()
        self.checkpoint('premature-writer-barrier')
        return {'kind':'writer','queued':len(targets),'refused':0,'world':self.world()}
    def barrier(self):
        self.drain()  # later real Sch.Barrier remains, then frame_failures
        for domain in self.domains:
            q=domain['queue'];front=deque(q['front']+list(reversed(q['back'])))
            hold=min([self.frame_start]+[p['cursor'] for p in self.positions if p['id'] in domain['readers']])
            size=q['size'];dropped=q['dropped']
            while front and (front[0]['tick']<=hold or size>model.base.CAPACITY):
                gone=front.popleft();size-=gone['count'];dropped=max(dropped,gone['tick'])
            domain['queue']={'front':list(front),'back':[],'size':size,'dropped':dropped}
        self.boundary,self.frame_start=self.frame_start,self.failure_tick
        self.checkpoint('explicit-barrier-frame')
        return {'kind':'barrierFrame','state':copy.deepcopy(self.image())}
    def active_skip(self):
        before=copy.deepcopy({'context':self.image(),'fastCursor':self.query['fast'],'slowCursor':self.query['slow']})
        after=copy.deepcopy({'context':self.image(),'fastCursor':self.query['fast'],'slowCursor':self.query['slow']})
        assert before==after and self.query['fast']==1 and self.query['slow']==2 and self.clock==9
        self.checkpoint('active-skip')
        return {'kind':'skipState','before':before,'after':after}

def blocks(source):
    lines=source.splitlines()
    starts=[i for i,line in enumerate(lines) if line.startswith('def ')]
    return {re.match(r'def (\w+)',lines[i])[1]:'\n'.join(line for line in lines[i:end] if line and not line.startswith('#')) for i,end in zip(starts,starts[1:]+[len(lines)])}

def reached(source):
    definitions=blocks(source)
    # Actual successful main/Setup/registration branches, not function-name intent.
    checks={'main':'write_output_chunks(followup_start(setup()))',
            'followup_start':'case Ready{context,entity,target,missing}:followup_writer_defined(entity,target,missing,define_writer(context,"relation-writer"))',
            'followup_writer_defined':'case Ordinary.DefinitionRegistered{context,writer}:followup_fast_defined(source,target,missing,writer,define_all(context,"fast"))',
            'followup_fast_defined':'case Ordinary.DefinitionRegistered{context,fast}:followup_slow_defined(source,target,missing,writer,fast,define_all(context,"slow"))',
            'followup_slow_defined':'case Ordinary.DefinitionRegistered{context,slow}:run_followup(context,writer,fast,slow,source,target,missing)',
            'run_followup':'follow_initial(metadata_after(context,writer,fast,slow,WriteArgs{source,target,missing,[]},[]))',
            'follow_initial':'follow_after_warm(follow_warm(FollowState{world,owners}))'}
    for name,expression in checks.items():assert expression in definitions[name],name
    def reduce(name):
        body=definitions[name]
        if 'follow_final_image(trace,json_context_image(context_from(world,metadata)))' in body:return []
        if 'follow_run(' in body:
            assert name in ['follow_warm','follow_link','follow_failures','follow_fast_failure','follow_active_skip','follow_fast_retry','follow_slow_read','follow_fast_repeat','follow_slow_repeat']
            step_text=body[body.index('[Sch.'):body.rindex(']')+1]
            steps=[]
            for match in re.finditer(r'Sch\.(System\{(\d+),(\d+)\}|Barrier\{\})',step_text):
                steps.append(('system',int(match[2]),int(match[3])) if match[2] else ('barrier',))
            return [(name,steps)]
        expression=body.split('\n',1)[1].strip()
        match=re.fullmatch(r'(follow_\w+)\((follow_\w+)\(state\)\)',expression)
        assert match,(name,expression)
        # Inner invocation executes first; its resulting owners feed outer invocation.
        return reduce(match[2])+reduce(match[1])
    return reduce('follow_warm')+reduce('follow_after_warm')

def derive_actual(source):
    plan=reached(source);m=model.Model();rows=[]
    for name,steps in plan:
        observations=[];status='finished'
        for step in steps:
            if step[0]=='barrier':rows.append(m.barrier());observations.append({'kind':'barrier-applied'});continue
            _,identifier,slot=step
            if slot==2:
                rows.append(m.active_skip());observations.append({'kind':'skipped','id':identifier});continue
            assert slot==0
            if identifier==1:
                assert name in ['follow_link','follow_failures']
                targets=[(model.HANDLE,model.TARGET)] if name=='follow_link' else [(model.HANDLE,model.HANDLE),(model.HANDLE,model.TARGET),(model.HANDLE,model.MISSING)]
                rows.append(m.write(targets))
            elif identifier in [2,3,4]:
                row,_=m.read('slow' if identifier==3 else 'fast',2 if identifier==3 else 1,identifier==4)
                rows.append(row)
                if identifier==4:status='failed'
            else:raise AssertionError(identifier)
            observations.append(model.ran(identifier))
            if status=='failed':break  # Actual Sch.after_outcome returns Failed immediately.
        rows.append(model.outcome(status,*observations))
    wire=('{"scenario":"ordinary-scheduled-failure-retry","trace":['+','.join('"'+model.j(row)+'"' for row in rows)+'],"final":'+model.j(m.image())+'}\n').encode()
    return wire,plan,m,rows

def main():
    pins=json.loads((HERE/'source-pins.json').read_text())
    for path,digest in pins.items():assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==digest,path
    basis=json.loads((HERE/'source-basis.json').read_text())
    baseline_wire,_,_=model.derive()
    assert len(baseline_wire)==26254 and hashlib.sha256(baseline_wire).hexdigest()=='fd4316f0b089ccdd0bec3c06faba92b9096c08e3fd4c4d1d7054e24e505de926'
    results={}
    for name,cls in [('wrong-reader',WrongReader),('premature-publication',Premature)]:
        selected=basis[name];root=Path(selected['sourceRoot']);baseline=Path(selected['baselineSourceRoot'])
        changed=[]
        for path in selected['sourceInventory']:
            path=Path(path);rel=path.relative_to(root)
            current=path.read_text();old=(baseline/rel).read_text()
            if current!=old:
                changed.append(str(rel))
                assert current.count(selected['after'])==1
                assert current.replace(selected['after'],selected['before'])==old
        assert changed==[selected['difference']['path']]
        source=Path(selected['entrypoint']).read_text()
        model.Model=cls
        wire,plan,final,rows=derive_actual(source)
        assert len(plan)==9 and len(rows)==21 and wire!=baseline_wire
        assert [name for name,_ in plan]==['follow_warm','follow_link','follow_failures','follow_fast_failure','follow_active_skip','follow_fast_retry','follow_slow_read','follow_fast_repeat','follow_slow_repeat']
        assert final.graph==model.GRAPH and final.pending==[] and all(d['readers']==[2,1] for d in final.domains)
        assert final.world()['components']==[{'entity':model.HANDLE,'value':42,'added':0,'changed':0},{'entity':model.TARGET,'value':43,'added':0,'changed':0}]
        assert rows[9]['status']=='failed' and rows[10]['status']=='failed'
        assert rows[11]['before']==rows[11]['after']
        if name=='wrong-reader':
            assert rows[0]['view']['eventA']['values']==rows[0]['view']['eventB']['values']==[model.base.ORIGINALS[0]]
            assert rows[1]['view']['eventA']['values']==[] and rows[1]['view']['eventB']['values']==[model.base.ORIGINALS[0]]
            assert final.clock==11 and final.query=={'writer':5,'fast':10,'slow':11}
            assert final.event_positions==[model.base.position(5,10,1),model.base.position(4,10,1),model.base.position(3,9,0),model.base.position(2,9,0),model.base.position(1,0,0)]
            assert rows[17]['view']['eventA']['values']==[model.base.ORIGINALS[0]]
            assert final.image()['metadata']['shared']['typed']['stream']['nextReader']==5
        else:
            assert rows[3]['world']['clock']==4 and rows[3]['world']['pending']==0 and rows[3]['world']['graph']==model.GRAPH
            assert rows[6]['world']['clock']==7 and rows[6]['world']['pending']==0
            assert rows[7]['state']['metadata']['shared']['relationFailures']['domains'][0]['queue']['front']==[model.base.batch(7,[model.SELF]),model.base.batch(7,[model.ABSENT])]
            assert final.clock==13 and final.query=={'writer':6,'fast':12,'slow':13}
            assert final.frame_start==8 and final.boundary==5
            assert final.positions==[model.base.position(2,12,2),model.base.position(1,11,1)]
        io=model.verify_fragment_io(wire,rows)
        path=HERE/(name+'.expected.stdout')
        timeline=final.timeline
        if '--write' in sys.argv:
            path.write_bytes(wire)
            (HERE/(name+'.expected.stdout.gz')).write_bytes(gzip.compress(wire,mtime=0))
            (HERE/(name+'.timeline.json')).write_text(json.dumps(timeline,indent=2)+'\n')
        else:
            assert path.read_bytes()==wire
            assert gzip.decompress((HERE/(name+'.expected.stdout.gz')).read_bytes())==wire
            assert json.loads((HERE/(name+'.timeline.json')).read_text())==timeline
        results[name]={'bytes':len(wire),'sha256':hashlib.sha256(wire).hexdigest(),'finalClock':final.clock,'queryCursors':final.query,'typedPositions':final.event_positions,'keyedPositions':final.positions,'io':io}
    model.Model=Original
    result={'sourcePins':len(pins),'baselineBytes':len(baseline_wire),'predictions':results,'invariants':'passed','runtimeOutputConsulted':False}
    if '--write' in sys.argv:(HERE/'derivation-result.json').write_text(json.dumps(result,indent=2)+'\n')
    else:assert json.loads((HERE/'derivation-result.json').read_text())==result
    print(json.dumps(result))
if __name__=='__main__':main()
