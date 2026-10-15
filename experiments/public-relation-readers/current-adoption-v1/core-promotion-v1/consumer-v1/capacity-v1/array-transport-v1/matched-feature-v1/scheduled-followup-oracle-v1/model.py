#!/usr/bin/env python3
"""Independent source-only small scheduled mutation/failure/active-skip oracle."""
from collections import deque
import copy
import gzip
import hashlib
import importlib.util
import json
import re
from pathlib import Path
import sys
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('prior_source_model',HERE.parent/'fullcapacity-scheduled-oracle-v7/derive.py')
base=importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)
j=base.j
HANDLE=base.HANDLE
TARGET={'namespace':1,'id':2}
MISSING={'namespace':1,'id':3}
DESCRIPTOR={'key':1,'name':'Parent','inverse':'Children','kind':'hierarchy'}
GRAPH={'edges':[{'relation':DESCRIPTOR,'source':1,'target':2}],
       'inverses':[{'relation':DESCRIPTOR,'target':2,'sources':[1]}]}
SELF=base.failure(1)
SELF['failure']['error']={'kind':'self','source':1,'relation':'Parent'}
ABSENT=base.failure(3)
ERRORS=[SELF,ABSENT]

class Model(base.Model):
    def __init__(self):
        super().__init__()
        self.next_id=4
        self.inactive=[3]
        self.graph={'edges':[],'inverses':[]}
        self.timeline=[]

    def world(self):
        result=super().world()
        result['live']=[False,True,True,False]
        result['components'].append({'entity':TARGET,'value':43,'added':0,'changed':0})
        result['graph']=copy.deepcopy(self.graph)
        return result

    def checkpoint(self,label):
        self.timeline.append({'label':label,'clock':self.clock,'routeTick':self.route,
                              'failureTick':self.failure_tick,'query':dict(self.query),
                              'positions':copy.deepcopy(self.positions),
                              'typedPositions':copy.deepcopy(self.event_positions)})

    def read(self,name,reader,fail=False):
        previous=(copy.deepcopy(self.positions),copy.deepcopy(self.event_positions),dict(self.query),dict(self.removal))
        self.before()
        event_views=[]
        for leaf in [2*reader-1,2*reader]:
            cursor=self.cursor(self.event_positions,leaf)
            event_views.append({'values':[v for b in self.messages if b['tick']>cursor for v in b['values']], 'lagged':False})
            self.activate(self.event_positions,leaf,max(0,self.route-2))
        old=self.cursor(self.positions,reader)
        registered=next((p['registeredAt'] for p in self.positions if p['id']==reader),self.failure_tick)
        readings=[]
        for key in [1,2]:
            d=self.domain(key);q=d['queue']
            readings.append({'key':key,'values':[v for b in q['front']+list(reversed(q['back'])) if b['tick']>old for v in b['values']], 'lagged':max(old,registered)<q['dropped']})
            if reader not in d['readers']:d['readers'].insert(0,reader)
        self.activate(self.positions,reader,self.failure_tick)
        view={'query':[{'entity':HANDLE},{'entity':TARGET}], 'eventA':event_views[0], 'eventB':event_views[1],
              'removals':[base.REMOVED] if self.removal[name]==0 else [],'relations':readings}
        if not fail:
            for leaf in [2*reader-1,2*reader]:self.commit(self.event_positions,leaf,self.route-1)
            self.commit(self.positions,reader,self.failure_tick)
            self.removal[name]=len(base.ORIGINALS)
            self.ingest(self.route)
            self.query[name]=self.clock
        else:
            assert previous==(self.positions,self.event_positions,self.query,self.removal)
        row={'kind':'reader','reader':name}
        if fail:row.update(status='failed',error=7)
        row.update(cursor=self.query[name],view=view,world=self.world())
        self.checkpoint(name+('-failure' if fail else '-success'))
        return row,view

    def write(self,targets):
        # Actual source/target/reserved handle values flow from Setup.Ready.
        assert all(source==HANDLE and target in [HANDLE,TARGET,MISSING] for source,target in targets)
        self.before()
        self.pending.extend(copy.deepcopy(targets))
        self.ingest(self.route)
        self.query['writer']=self.clock
        self.checkpoint('writer')
        return {'kind':'writer','queued':len(targets),'refused':0,'world':self.world()}

    def barrier(self):
        self.clock+=1
        tick=max(self.route,self.failure_tick,self.clock)
        for source,target in self.pending:
            if target==HANDLE:error=SELF
            elif target==MISSING:error=ABSENT
            else:
                assert target==TARGET
                self.graph=copy.deepcopy(GRAPH)
                continue
            d=self.domain(1)
            d['queue']['back'].insert(0,base.batch(tick,[error]))
            d['queue']['size']+=1
        self.pending=[]
        self.route=self.failure_tick=tick
        for d in self.domains:
            q=d['queue'];front=deque(q['front']+list(reversed(q['back'])))
            hold=min([self.frame_start]+[p['cursor'] for p in self.positions if p['id'] in d['readers']])
            size=q['size'];dropped=q['dropped']
            while front and (front[0]['tick']<=hold or size>base.CAPACITY):
                gone=front.popleft();size-=gone['count'];dropped=max(dropped,gone['tick'])
            d['queue']={'front':list(front),'back':[],'size':size,'dropped':dropped}
        self.boundary,self.frame_start=self.frame_start,tick
        self.checkpoint('barrier-frame')
        return {'kind':'barrierFrame','state':copy.deepcopy(self.image())}

    def active_skip(self):
        before=copy.deepcopy({'context':self.image(),'fastCursor':self.query['fast'],'slowCursor':self.query['slow']})
        after=copy.deepcopy({'context':self.image(),'fastCursor':self.query['fast'],'slowCursor':self.query['slow']})
        assert before==after and self.query['fast']==1 and self.query['slow']==2
        assert self.positions==[base.position(2,2,2),base.position(1,1,1)]
        assert self.domains[0]['queue']['size']==2 and self.clock==7
        self.checkpoint('active-skip')
        return {'kind':'skipState','before':before,'after':after}

def outcome(status,*observations):return {'kind':'scheduleOutcome','status':status,'observations':list(observations)}
def ran(identifier):return {'kind':'ran','id':identifier}
def derive():
    m=Model();rows=[]
    fast,warm_fast=m.read('fast',1);slow,warm_slow=m.read('slow',2)
    assert warm_fast==warm_slow and warm_fast['eventA']['values']==[base.ORIGINALS[0]]
    assert warm_fast['removals']==[base.REMOVED]
    rows.extend([fast,slow,outcome('finished',ran(2),ran(3))])
    rows.append(m.write([(HANDLE,TARGET)]))
    assert m.pending==[(HANDLE,TARGET)] and m.graph=={'edges':[],'inverses':[]}
    rows.append(m.barrier());rows.append(outcome('finished',ran(1),{'kind':'barrier-applied'}))
    assert m.graph==GRAPH and m.domains[0]['queue']['size']==0 and m.frame_start==4
    rows.append(m.write([(HANDLE,HANDLE),(HANDLE,TARGET),(HANDLE,MISSING)]))
    assert m.world()['pending']==3
    rows.append(m.barrier());rows.append(outcome('finished',ran(1),{'kind':'barrier-applied'}))
    expected_queue={'front':[base.batch(6,[SELF]),base.batch(6,[ABSENT])],'back':[],'size':2,'dropped':0}
    assert m.domains[0]['queue']==expected_queue and m.graph==GRAPH
    failed,failed_view=m.read('fast',1,True);rows.extend([failed,outcome('failed',ran(4))])
    assert m.clock==m.route==7 and m.failure_tick==6
    rows.extend([m.active_skip(),outcome('finished',{'kind':'skipped','id':2})])
    retried,retry_view=m.read('fast',1);rows.extend([retried,outcome('finished',ran(2))])
    assert failed_view==retry_view and retry_view['relations'][0]['values']==ERRORS
    slow,slow_view=m.read('slow',2);rows.extend([slow,outcome('finished',ran(3))])
    assert retry_view==slow_view and not any(x['lagged'] for x in retry_view['relations'])
    for name,identifier,reader in [('fast',2,1),('slow',3,2)]:
        repeated,repeated_view=m.read(name,reader)
        assert all(r['values']==[] and not r['lagged'] for r in repeated_view['relations'])
        assert repeated_view['eventA']['values']==repeated_view['eventB']['values']==repeated_view['removals']==[]
        rows.extend([repeated,outcome('finished',ran(identifier))])
    assert m.clock==m.route==m.failure_tick==11
    assert m.query=={'writer':5,'fast':10,'slow':11}
    assert m.positions==[base.position(2,10,2),base.position(1,9,1)]
    assert m.event_positions==[base.position(4,10,1),base.position(3,10,1),base.position(2,9,0),base.position(1,9,0)]
    assert m.removal=={'fast':2,'slow':2} and m.pending==[]
    assert m.frame_start==6 and m.boundary==4
    assert m.domains[0]['queue']==expected_queue and m.domains[1]['queue']=={'front':[],'back':[],'size':0,'dropped':0}
    assert all(d['readers']==[2,1] for d in m.domains)
    assert m.journal==[{'tick':1,'values':[base.VALUE,base.REMOVAL]}]
    assert m.messages==[{'tick':1,'values':[base.ORIGINALS[0]]}]
    assert m.world()['events']==base.ORIGINALS and m.graph==GRAPH
    assert m.world()['components']==[{'entity':HANDLE,'value':42,'added':0,'changed':0},{'entity':TARGET,'value':43,'added':0,'changed':0}]
    assert len(rows)==21 and sum(r['kind']=='scheduleOutcome' for r in rows)==9
    # Source JsonTraceEntry wraps literal quotes, without JSON escaping.
    text='{"scenario":"ordinary-scheduled-failure-retry","trace":['+','.join('"'+j(row)+'"' for row in rows)+'],"final":'+j(m.image())+'}'
    wire=(text+'\n').encode()
    assert wire.count(b'\n')==1 and b'\\"' not in wire
    return wire,m.timeline,rows

def verify_fragment_io(wire,rows):
    spec=importlib.util.spec_from_file_location('prior_fragment_model',HERE.parent/'fullcapacity-scheduled-oracle-v7/successor-v9/verify.py')
    doc=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(doc)
    def graph(value):
        def inverse(v):return doc.O([('relation',doc.scalar(v['relation'])),('target',doc.scalar(v['target'])),('sources',doc.flatarray(v['sources']))])
        return doc.O([('edges',doc.flatarray(value['edges'])),('inverses',doc.A(value['inverses'],inverse))])
    doc.graph=graph
    oldrow=doc.row
    def row(value):
        if value['kind']=='scheduleOutcome':return doc.P([doc.T('{"kind":"scheduleOutcome","status":'),doc.scalar(value['status']),doc.T(',"observations":'),doc.T(j(value['observations'])),doc.T('}')])
        if value.get('status')=='failed':return doc.P([doc.T('{"kind":"reader","reader":"fast","status":"failed","error":'),doc.scalar(value['error']),doc.T(',"cursor":'),doc.scalar(value['cursor']),doc.T(',"view":'),doc.view(value['view']),doc.T(',"world":'),doc.world(value['world']),doc.T('}')])
        return oldrow(value)
    doc.row=row
    final=json.loads(wire.decode().rsplit(',"final":',1)[1][:-2])
    root=doc.P([doc.T('{"scenario":"ordinary-scheduled-failure-retry","trace":'),doc.A([j(r) for r in rows],doc.trace_entry),doc.T(',"final":'),doc.image(final),doc.T('}')])
    budget=visits=0;fragments=[];chunks=[];count=0
    def flush():
        nonlocal fragments,count
        if count:chunks.append(''.join(fragments));fragments=[];count=0
    for kind,text in root:
        if kind=='parts':budget+=2;visits+=2
        elif kind=='child':budget+=1;visits+=1
        else:
            budget+=3;visits+=2;length=len(text)
            assert length<=4096 and text.isascii()
            if not length:continue
            if count+length>4096:flush();visits+=1
            fragments.append(text);count+=length
    flush();visits+=1
    assert visits<=budget
    assert ''.join(chunks).encode()+b'\n'==wire
    assert all(0<len(c)<=4096 for c in chunks)
    return {'fuel':budget,'loopVisits':visits,'chunks':len(chunks),'terminalLfWrites':1}

def check_sources():
    pins=json.loads((HERE/'source-pins.json').read_text())
    for path,digest in pins.items():assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==digest,path
    join=json.loads((HERE/'serializer-source-join.json').read_text())
    previous=Path(join['priorEntry'])
    assert hashlib.sha256(previous.read_bytes()).hexdigest()==join['priorEntrySHA256']
    freeze=json.loads((HERE/'source-freeze.json').read_text())
    relative=Path(freeze['entrypoint']).relative_to('/workspace/formal-proofs/bendvy-worktrees/parity43-ordinary-full-lifecycle-sparse')
    current=Path(freeze['immutableRoot'])/relative
    def blocks(path):
        lines=path.read_text().splitlines()
        starts=[i for i,line in enumerate(lines) if re.match(r'^(def|type) ',line)]
        return {re.match(r'(?:def|type) ([\w]+)',lines[i])[1]:'\n'.join(line for line in lines[i:end] if line and not line.startswith('#')) for i,end in zip(starts,starts[1:]+[len(lines)])}
    old,new=blocks(previous),blocks(current)
    assert all(old[name]==new[name] for name in join['identicalDefinitions'])
    return len(pins)

if __name__=='__main__':
    pins=check_sources();wire,timeline,rows=derive();io=verify_fragment_io(wire,rows)
    if '--write' in sys.argv:
        (HERE/'expected.stdout').write_bytes(wire)
        (HERE/'expected.stdout.gz').write_bytes(gzip.compress(wire,mtime=0))
        (HERE/'expected.sha256').write_text(hashlib.sha256(wire).hexdigest()+'  expected.stdout\n')
        (HERE/'timeline.json').write_text(json.dumps(timeline,indent=2)+'\n')
    else:
        assert (HERE/'expected.stdout').read_bytes()==wire
        assert gzip.decompress((HERE/'expected.stdout.gz').read_bytes())==wire
        assert json.loads((HERE/'timeline.json').read_text())==timeline
    print(json.dumps({'sourcePins':pins,'bytes':len(wire),'sha256':hashlib.sha256(wire).hexdigest(),'traceRows':len(rows),'scheduleOutcomes':9,'invariants':'passed','io':io}))
