#!/usr/bin/env python3
"""Independent full structural oracle; labels are source-file::constructor.
Derived from source and frozen reference inputs without reading candidate output.
Root may replace labels with compiler literal paths using the source closure.
"""
import copy, json, hashlib
from pathlib import Path

def c(file,name,*fields): return {'constructor':file+'::'+name,'fields':list(fields)}
def n(x): return {'nat':x}
def false(): return c('Base','False')
def cell(v,s): return c('geometry.bend','Cell',v,s)
def full(v,s): return c('owner-view.bend','FullCell',n(2),[v,s])
def some(x): return c('Base','Some',x)
def none(): return c('Base','None')
def hit(i): return c('events.bend','SimulationHit',i,1)
def death(i): return c('events.bend','SimulationDeath',i)
def reading(items): return c('event-runtime.bend','Reading',copy.deepcopy(items),false())
def status(j): return c('pair.bend','Succeeded',copy.deepcopy(j))

def schema(ns):
    tick=0; frameStart=0; boundary=0; dropped=0; batches=[]
    cursors=[0,0]; registered=[0,1]; journals=[[],[]]
    allocated=0; live=[]; values={}; pending=[]; step=0; clock=0; phases=[]
    def frame():
        nonlocal frameStart,boundary,batches,dropped
        boundary=frameStart; frameStart=tick
        hold=min([boundary]+cursors)
        removed=[b for b in batches if b[0]<=hold]
        if removed: dropped=max(dropped,max(b[0] for b in removed))
        batches=[b for b in batches if b[0]>hold]
    def read(index,fail=False):
        nonlocal tick
        items=[e for at,es in batches if at>cursors[index] for e in es]
        journals[index].append(reading(items)); tick+=1
        if fail: return c('pair.bend','Failed',c('readers.bend','ReaderFailed',copy.deepcopy(journals[index])))
        cursors[index]=tick
        return status(journals[index])
    def observe(label,result):
        physical=[]
        for i in range(1,allocated+1):
            slots=[]
            for k in range(3):
                slots.append(some(full(values[i][k],i*100+k)) if i in values else none())
            physical.append(c('store-view.bend','EntityCells',i,*slots))
        events=[e for _,es in batches for e in es]
        world=c('checkpoint.bend','Snapshot',label,c('world-view.bend','Allocation',allocated+1,allocated),full(step,900),physical,events,len(pending),clock,live[:])
        positions=[c('event-runtime.bend','Position',i+1,n(cursors[i]),n(registered[i])) for i in [1,0]]
        runtime=c('runtime-checkpoint.bend','Snapshot',world,ns,[c('event-runtime.bend','Batch',n(at),es) for at,es in batches],positions,3,n(tick),n(frameStart),n(boundary),n(64),n(dropped))
        observation=c('consumer-state.bend','Observation',runtime,copy.deepcopy(journals[0]),copy.deepcopy(journals[1]))
        phases.append(copy.deepcopy(c('scenario.bend','Phase',observation,result)))
    a=read(0); b=read(1)
    observe('register-readers',c('scenario-actions.bend','ReadersResult',c('consumer-state.bend','ReaderResults',a,b)))
    commands=[('queue-spawn','spawn'),('spawn-barrier','barrier'),('step-1-damage','game'),('step-1-readers','read'),('step-1-barrier','barrier'),('step-2-damage','game'),('step-2-reader-failure','fail'),('step-2-reader-retry','retry'),('step-2-barrier','barrier'),('step-3-damage','game'),('step-3-readers','read'),('step-3-barrier','barrier'),('empty-readers','read')]
    for label,op in commands:
        frame()
        if op=='spawn':
            allocated=3; pending=[('spawn',i) for i in [1,2,3]]; tick+=1
            reservations=[c('world.bend','Reserved',c('world.bend','Handle',ns,i)) for i in [1,2,3]]
            result=c('scenario-actions.bend','SpawnResult',c('runtime-spawn.bend','SpawnSucceeded',reservations))
        elif op=='barrier':
            for action,i in pending:
                if action=='spawn': values[i]=[0,[1,2,1][i-1],[2,1,1][i-1]]; live.append(i); clock+=3
                else: live.remove(i); del values[i]
            pending=[]; tick+=1
            result=c('scenario-actions.bend','BarrierResult')
        elif op=='game':
            step+=1; moved=[]; damaged=[]; events=[]
            for i in live:
                values[i][0]+=values[i][1]; clock+=1; moved.append(cell(values[i][0],i*100))
            tick+=1
            for i in live:
                if values[i][0]<2: damaged.append(cell(0,0)); continue
                values[i][2]-=1; clock+=1
                damaged.append(cell(values[i][2],i*100+2)); events.append(hit(i))
                if values[i][2]==0: events.append(death(i)); pending.append(('despawn',i))
            tick+=1
            if events: batches.append((tick,events))
            result=c('scenario-actions.bend','GameplayResult',c('consumer-gameplay.bend','GameplayRan',c('runtime-gameplay.bend','FrameOutput',c('transaction.bend','Success'),moved,damaged)))
        else:
            if op=='retry': a=c('pair.bend','Skipped'); b=read(1)
            else: a=read(0); b=read(1,op=='fail')
            result=c('scenario-actions.bend','ReadersResult',c('consumer-state.bend','ReaderResults',a,b))
        observe(label,result)
    assert len(phases)==14
    return phases
report=c('main.bend','TwoSchemaReport',schema(1),schema(2))
if __name__ == '__main__':
    print(json.dumps(report, indent=2))
