#!/usr/bin/env python3
"""Independent source-only V7 real-command, whole-batch overflow and state oracle."""
from collections import deque
import hashlib
import gzip
import json
from pathlib import Path
import sys

HERE=Path(__file__).resolve().parent
j=lambda value:json.dumps(value,separators=(',',':'))
CAPACITY=65536
COUNT=65537
HANDLE={'namespace':1,'id':1}
VALUE={'kind':'value','value':11}
REMOVED={'entity':HANDLE,'component':'value'}
REMOVAL={'kind':'removed','record':REMOVED}
ORIGINALS=[{'kind':'original','event':v} for v in [VALUE,REMOVAL]]

def failure(target,key=1):
    name='Parent' if key==1 else 'OrdinaryParent'
    inverse='Children' if key==1 else 'OrdinaryChildren'
    kind='hierarchy' if key==1 else 'ordinary'
    return {'kind':'relationFailure','failure':{
        'relation':{'key':key,'name':name,'inverse':inverse,'kind':kind},
        'operation':'relate','source':1,'target':target,
        'error':{'kind':'missingTarget','source':1,'target':target,'relation':name}}}

def batch(tick,values):return {'tick':tick,'count':len(values),'values':values}
def position(reader,cursor,registered):return {'id':reader,'cursor':cursor,'registeredAt':registered}

class Model:
    def __init__(self):
        self.clock=self.route=self.failure_tick=0
        self.pending=[]
        self.journal=[]
        self.messages=[]
        self.event_positions=[]
        self.positions=[]
        self.domains=[]
        self.frame_start=self.boundary=0
        self.query={'writer':0,'fast':0,'slow':0}
        self.removal={'fast':0,'slow':0}
        self.next_id=2
        self.inactive=[]

    def world(self):
        allocated=self.next_id-1
        capacity=1
        while capacity<=allocated:capacity*=2
        live=[False]*capacity
        live[1]=True
        access=['value','values:read','values:read','removal','value','Parent:read','OrdinaryParent:read']
        registrations=[{'id':3,'name':'slow','access':access},
                       {'id':2,'name':'fast','access':access},
                       {'id':1,'name':'relation-writer','access':[]}]
        return {'namespace':1,'nextId':self.next_id,'highWater':allocated,'live':live,
                'inactiveReservations':[{'namespace':1,'id':i} for i in self.inactive],
                'capacity':capacity,'depth':capacity.bit_length()-1,
                'components':[{'entity':HANDLE,'value':42,'added':0,'changed':0}],
                'resource':'unit','registrations':registrations,'nextSystemId':4,
                'clock':self.clock,'pending':len(self.pending),
                'graph':{'edges':[],'inverses':[]},'events':ORIGINALS}

    def image(self):
        stream={'domain':'values','batches':self.messages,'positions':[dict(p) for p in self.event_positions],
                'nextReader':5,'frameStart':0,'boundary':0,'capacity':CAPACITY,'dropped':0}
        typed={'stream':stream,'journal':self.journal,'frameStart':0}
        failures={'domains':self.domains,'positions':[dict(p) for p in self.positions],
                  'tick':self.failure_tick,'frameStart':self.frame_start,'boundary':self.boundary,
                  'capacity':CAPACITY,'nextReader':3}
        return {'world':self.world(),'metadata':{'routeTick':self.route,'shared':{
            'typed':typed,'relationFailures':failures}}}

    def ingest(self,epoch):
        if not self.journal:
            self.journal=[{'tick':epoch,'values':[VALUE,REMOVAL]}]
            self.messages=[{'tick':epoch,'values':[ORIGINALS[0]]}]
        self.route=self.failure_tick=epoch

    def before(self):
        self.ingest(max(1,self.route,self.failure_tick,self.clock))
        self.clock+=1
        self.route+=1

    @staticmethod
    def cursor(positions,reader):
        return next((p['cursor'] for p in positions if p['id']==reader),0)

    @staticmethod
    def activate(positions,reader,registered):
        if not any(p['id']==reader for p in positions):
            positions.insert(0,position(reader,0,registered))

    @staticmethod
    def commit(positions,reader,cursor):
        for p in positions:
            if p['id']==reader:p['cursor']=cursor

    def domain(self,key):
        found=next((d for d in self.domains if d['key']==key),None)
        if found is None:
            found={'key':key,'queue':{'front':[],'back':[],'size':0,'dropped':0},'readers':[]}
            self.domains.append(found)
        return found

    def skip(self):
        before=j(self.image());old=(self.query['fast'],self.query['slow'])
        # The actual reached run_if false callback snapshots and returns the same
        # Context and providers. It performs no ordinary run or lifecycle call.
        after=j(self.image())
        assert before==after and old==(0,0) and self.domains==self.positions==self.event_positions==[]
        state='{"context":'+before+',"fastCursor":0,"slowCursor":0}'
        return '{"kind":"skipState","before":'+state+',"after":'+state+'}'

    def read(self,name,reader):
        self.before()
        event_views=[]
        for leaf in [2*reader-1,2*reader]:
            cursor=self.cursor(self.event_positions,leaf)
            event_views.append({'values':[v for b in self.messages if b['tick']>cursor for v in b['values']],
                                'lagged':False})
            self.activate(self.event_positions,leaf,max(0,self.route-2))
        old=self.cursor(self.positions,reader)
        registered=next((p['registeredAt'] for p in self.positions if p['id']==reader),self.failure_tick)
        readings=[]
        for key in [1,2]:
            d=self.domain(key);queue=d['queue']
            readings.append({'key':key,'values':[v for b in queue['front']+list(reversed(queue['back']))
                             if b['tick']>old for v in b['values']],
                             'lagged':max(old,registered)<queue['dropped']})
            if reader not in d['readers']:d['readers'].insert(0,reader)
        self.activate(self.positions,reader,self.failure_tick)
        view={'query':[{'entity':HANDLE}],
              'eventA':event_views[0],'eventB':event_views[1],
              'removals':[REMOVED] if self.removal[name]==0 else [],'relations':readings}
        for leaf in [2*reader-1,2*reader]:self.commit(self.event_positions,leaf,self.route-1)
        self.commit(self.positions,reader,self.failure_tick)
        self.removal[name]=len(ORIGINALS)
        self.ingest(self.route)
        self.query[name]=self.clock
        return j({'kind':'reader','reader':name,'cursor':self.query[name],'view':view,'world':self.world()}),view

    def writer(self):
        self.before()
        self.pending.extend(range(1000,1000+COUNT))
        self.ingest(self.route)
        self.query['writer']=self.clock
        # Actual W.reserve_id calls produce IDs2/3/4; no W.activate is called.
        self.inactive=[self.next_id+i for i in range(3)]
        self.next_id+=3
        self.pending.append(tuple(self.inactive))
        assert self.inactive==[2,3,4] and self.next_id==5
        assert self.clock==3 and self.route==self.failure_tick==4
        assert len(self.pending)==65538
        return j({'kind':'writer','queued':COUNT,'refused':0,'world':self.world()})

    def barrier_frame(self):
        self.clock+=1
        epoch=max(self.route,self.failure_tick,self.clock)
        assert epoch==4
        # Each real ordinary closure produces one failure. One custom closure
        # produces key1 [2,3] and key2 [4], one batch per key from that command.
        chronological={1:[],2:[]}
        for command in self.pending:
            if isinstance(command,int):chronological[1].append(batch(epoch,[failure(command)]))
            else:
                a,b,c=command
                chronological[1].append(batch(epoch,[failure(a),failure(b)]))
                chronological[2].append(batch(epoch,[failure(c,2)]))
        self.pending=[]
        self.route=self.failure_tick=epoch
        assert sum(b['count'] for b in chronological[1])==65539
        assert len(chronological[1])==65538 and chronological[1][-1]['count']==2
        assert chronological[2]==[batch(4,[failure(4,2)])]
        # Source Q.trim normalizes reverse-back to chronological front, then
        # removes whole old batches under boundary0 or while over capacity.
        for key in [1,2]:
            d=self.domain(key);front=deque(chronological[key]);size=sum(b['count'] for b in front);dropped=0
            hold=min([self.frame_start]+[p['cursor'] for p in self.positions if p['id'] in d['readers']])
            while front and (front[0]['tick']<=hold or size>CAPACITY):
                gone=front.popleft();size-=gone['count'];dropped=max(dropped,gone['tick'])
            d['queue']={'front':list(front),'back':[],'size':size,'dropped':dropped}
        self.boundary,self.frame_start=self.frame_start,self.failure_tick
        d1,d2=self.domains
        assert d1['queue']['size']==65536 and d1['queue']['dropped']==4
        assert d2['queue']['size']==1 and d2['queue']['dropped']==0
        targets=[v['failure']['target'] for b in d1['queue']['front'] for v in b['values']]
        assert targets==list(range(1003,66537))+[2,3]
        assert d1['queue']['front'][-1]==batch(4,[failure(2),failure(3)])
        assert all(b['count']==1 for b in d1['queue']['front'][:-1])
        return '{"kind":"barrierFrame","state":'+j(self.image())+'}'

def derive():
    m=Model()
    rows=[m.skip()]
    warm_fast,view_fast=m.read('fast',1);rows.append(warm_fast)
    warm_slow,view_slow=m.read('slow',2);rows.append(warm_slow)
    assert view_fast==view_slow and all(r['values']==[] and not r['lagged'] for r in view_fast['relations'])
    assert view_fast['eventA']['values']==view_fast['eventB']['values']==[ORIGINALS[0]]
    assert view_fast['removals']==[REMOVED]
    assert m.positions==[position(2,2,2),position(1,1,1)]
    assert m.event_positions==[position(4,2,1),position(3,2,1),position(2,1,0),position(1,1,0)]
    rows.append(m.writer())
    rows.append(m.barrier_frame())
    barrier_image=j(m.image())
    post_fast,fast=m.read('fast',1);rows.append(post_fast)
    post_slow,slow=m.read('slow',2);rows.append(post_slow)
    assert fast==slow and fast['eventA']['values']==fast['eventB']['values']==fast['removals']==[]
    assert fast['relations'][0]['lagged'] and not fast['relations'][1]['lagged']
    assert fast['relations'][1]['values']==[failure(4,2)]
    assert [v['failure']['target'] for v in fast['relations'][0]['values']]==list(range(1003,66537))+[2,3]
    assert len(fast['relations'][0]['values'])==65536
    assert m.query=={'writer':3,'fast':5,'slow':6}
    assert m.clock==m.route==m.failure_tick==6 and m.frame_start==4 and m.boundary==0
    assert m.positions==[position(2,5,2),position(1,4,1)]
    assert m.event_positions==[position(4,5,1),position(3,5,1),position(2,4,0),position(1,4,0)]
    assert m.journal==[{'tick':1,'values':[VALUE,REMOVAL]}]
    assert m.messages==[{'tick':1,'values':[ORIGINALS[0]]}]
    assert all(d['readers']==[2,1] and d['queue']['back']==[] for d in m.domains)
    assert m.removal=={'fast':2,'slow':2}
    assert json.loads(barrier_image)['metadata']['shared']['relationFailures']['positions']==[position(2,2,2),position(1,1,1)]
    world=m.world()
    assert world['nextId']==5 and world['highWater']==4 and world['capacity']==8 and world['depth']==3
    assert world['live']==[False,True,False,False,False,False,False,False]
    assert world['inactiveReservations']==[{'namespace':1,'id':i} for i in [2,3,4]]
    assert world['components']==[{'entity':HANDLE,'value':42,'added':0,'changed':0}]
    assert world['resource']=='unit' and world['nextSystemId']==4
    assert [r['id'] for r in world['registrations']]==[3,2,1]
    assert fast['query']==slow['query']==[{'entity':HANDLE}]
    assert json.loads(rows[1])['world']['nextId']==json.loads(rows[2])['world']['nextId']==2
    assert json.loads(rows[3])['world']['nextId']==5 and json.loads(rows[3])['world']['pending']==65538
    steps=[{'kind':'skipped','id':3},{'kind':'ran','id':2},{'kind':'ran','id':4},
           {'kind':'ran','id':1},{'kind':'barrier-applied'},{'kind':'ran','id':5},{'kind':'ran','id':6}]
    # Source quoted() is raw quote wrapping, even for JSON-shaped trace Strings.
    text='{"steps":'+j(steps)+',"trace":['+','.join('"'+r+'"' for r in rows)+'],"final":'+j(m.image())+'}'
    assert text.count('\n')==0 and '\\"' not in text
    return (text+'\n').encode()

def verify_pins():
    pins=json.loads((HERE/'source-pins.json').read_text())
    for path,digest in pins.items():assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==digest,path
    return len(pins)

if __name__=='__main__':
    count=verify_pins();output=derive()
    if '--write' in sys.argv:(HERE/'expected.stdout').write_bytes(output)
    else:
        golden=HERE/'expected.stdout'
        stored=golden.read_bytes() if golden.exists() else gzip.decompress((HERE/'expected.stdout.gz').read_bytes())
        assert stored==output
    print(json.dumps({'sourceFilesVerified':count,'bytes':len(output),'sha256':hashlib.sha256(output).hexdigest(),'stateInvariants':'passed'}))
