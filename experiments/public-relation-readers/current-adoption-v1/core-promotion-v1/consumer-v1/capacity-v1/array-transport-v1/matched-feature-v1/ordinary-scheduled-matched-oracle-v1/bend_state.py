#!/usr/bin/env python3
"""Source-derived reusable state transitions; final entry binding remains unsealed.

No expected stdout is emitted by this module. The consumer-specific call graph,
registration metadata and serializers must be bound after its final source freeze.
"""
from collections import deque
import copy

CAPACITY=65536

def position(identifier,cursor,registered):return {'id':identifier,'cursor':cursor,'registeredAt':registered}
def handle(identifier):return {'namespace':1,'id':identifier}
def value(number):return {'kind':'value','value':number}
def original(publication):return {'kind':'original','event':publication}
def removal(identifier):return {'entity':handle(identifier),'component':'value'}
def batch(tick,values,counted=False):
    result={'tick':tick}
    if counted:result['count']=len(values)
    result['values']=copy.deepcopy(values)
    return result

class State:
    def __init__(self,namespace=1):
        self.namespace=namespace
        self.clock=self.route=self.failure_tick=0
        self.next_id=1;self.live=set();self.components={};self.stamps={}
        self.pending=[];self.events=[];self.graph={'edges':[],'inverses':[]}
        self.journal=[];self.messages=[];self.event_positions=[];self.positions=[];self.domains=[]
        self.frame_start=self.boundary=0
        self.query={'writer':0,'fast':0,'slow':0};self.removal_cursor={'fast':0,'slow':0}
        self.registrations=[];self.next_system=1
        self.timeline=[]
    def advance(self):self.clock+=1;return self.clock
    @staticmethod
    def lookup(positions,identifier):return next((p for p in positions if p['id']==identifier),None)
    @staticmethod
    def activate(positions,identifier,registered):
        if State.lookup(positions,identifier) is None:positions.insert(0,position(identifier,0,registered))
    @staticmethod
    def commit_position(positions,identifier,cursor):
        found=State.lookup(positions,identifier)
        if found is not None:found['cursor']=cursor
    def domain(self,key):
        found=next((d for d in self.domains if d['key']==key),None)
        if found is None:
            found={'key':key,'queue':{'front':[],'back':[],'size':0,'dropped':0},'readers':[]}
            self.domains.append(found)
        return found
    def reserve(self):
        identifier=self.next_id;self.next_id+=1
        return {'namespace':self.namespace,'id':identifier}
    def enqueue_spawn(self,payload=None):
        returned=self.reserve();self.pending.append(('spawn',returned['id'],payload));return returned
    def enqueue_remove(self,target):
        assert target['id'] in self.live
        self.pending.append(('remove',target['id']))
    def enqueue_insert(self,target,payload):
        assert target['id'] in self.live
        self.pending.append(('insert',target['id'],payload))
    def enqueue_despawn(self,target):
        assert target['id'] in self.live
        self.pending.append(('despawn',target['id']))
    def replace(self,identifier,payload):
        # Component.replace owns its own advance beyond a barrier's epoch.
        assert identifier in self.live
        tick=self.advance();old=self.components.get(identifier)
        self.components[identifier]=payload
        self.stamps[identifier]=(0,0) if payload is None else ((self.stamps.get(identifier,(0,0))[0] if old is not None else tick),tick)
        return old
    def ingest(self,tick):
        originals=[e['event'] for e in self.events if e['kind']=='original']
        known=sum(len(b['values']) for b in self.journal)
        published=originals[known:]
        if published:self.journal.append(batch(tick,published))
        typed=[original(p) for p in published if p['kind']=='value']
        if typed:self.messages.append(batch(tick,typed))
        ordinary=[];groups={}
        for event in self.events:
            if event['kind']=='relationFailure':groups.setdefault(event['failure']['relation']['key'],[]).append(event)
            else:ordinary.append(event)
        self.events=ordinary
        for key,records in groups.items():
            q=self.domain(key)['queue'];q['back'].insert(0,batch(tick,records,True));q['size']+=len(records)
        self.route=self.failure_tick=tick
    def before(self):
        self.ingest(max(1,self.clock,self.route,self.failure_tick))
        self.advance();self.route+=1
    def writer_begin(self):self.before()
    def writer_success(self,emitted=()):
        self.events.extend(original(value(number)) for number in emitted)
        self.ingest(self.route);self.query['writer']=self.clock
    def apply(self,command):
        kind,identifier,*args=command
        if kind=='spawn':
            self.live.add(identifier)
            if args[0] is not None:self.replace(identifier,args[0])
        elif kind=='remove':
            previous=self.replace(identifier,None)
            if previous is not None:self.events.append(original({'kind':'removed','record':{'entity':{'namespace':self.namespace,'id':identifier},'component':'value'}}))
        elif kind=='insert':self.replace(identifier,args[0])
        elif kind=='despawn':self.live.discard(identifier)
        elif kind=='relate':
            target=args[0]
            descriptor={'key':1,'name':'Parent','inverse':'Children','kind':'hierarchy'}
            if target==identifier:error={'kind':'self','source':identifier,'relation':'Parent'}
            elif target not in self.live:error={'kind':'missingTarget','source':identifier,'target':target,'relation':'Parent'}
            else:
                self.graph={'edges':[{'relation':descriptor,'source':identifier,'target':target}],
                            'inverses':[{'relation':descriptor,'target':target,'sources':[identifier]}]}
                return
            self.events.append({'kind':'relationFailure','failure':{'relation':descriptor,'operation':'relate','source':identifier,'target':target,'error':error}})
        else:raise AssertionError(command)
    def barrier(self,frame=True):
        actual=self.advance();tick=max(actual,self.route,self.failure_tick)
        commands=self.pending;self.pending=[]
        # FailureBarrier.collect runs after each closure, while typed sync waits
        # until the next ordinary before/after ingestion boundary.
        for command in commands:
            self.apply(command)
            ordinary=[];groups={}
            for event in self.events:
                if event['kind']=='relationFailure':groups.setdefault(event['failure']['relation']['key'],[]).append(event)
                else:ordinary.append(event)
            self.events=ordinary
            for key,records in groups.items():
                q=self.domain(key)['queue'];q['back'].insert(0,batch(tick,records,True));q['size']+=len(records)
        self.route=self.failure_tick=tick
        if frame:
            for domain in self.domains:
                queue=domain['queue'];front=deque(queue['front']+list(reversed(queue['back'])))
                hold=min([self.frame_start]+[p['cursor'] for p in self.positions if p['id'] in domain['readers']])
                size=queue['size'];dropped=queue['dropped']
                while front and (front[0]['tick']<=hold or size>CAPACITY):
                    gone=front.popleft();size-=gone['count'];dropped=max(dropped,gone['tick'])
                domain['queue']={'front':list(front),'back':[],'size':size,'dropped':dropped}
            self.boundary,self.frame_start=self.frame_start,tick
    def read(self,name,event_id,relation_id,relation_keys=(1,),fail=False):
        self.before();cursor=self.query[name]
        present=sorted(i for i in self.live if self.components.get(i) is not None)
        query=[{'entity':{'namespace':self.namespace,'id':i},'data':{'found':self.components[i]}} for i in present]
        added=[{'namespace':self.namespace,'id':i} for i in present if self.stamps[i][0]>cursor]
        changed=[{'namespace':self.namespace,'id':i} for i in present if self.stamps[i][1]>cursor]
        ep=self.lookup(self.event_positions,event_id)
        old=0 if ep is None else ep['cursor']
        event_values=[copy.deepcopy(v) for b in self.messages if b['tick']>old for v in b['values']]
        self.activate(self.event_positions,event_id,max(0,self.route-2))
        rp=self.lookup(self.positions,relation_id);old=0 if rp is None else rp['cursor'];registered=self.failure_tick if rp is None else rp['registeredAt']
        readings=[]
        for key in relation_keys:
            domain=self.domain(key);queue=domain['queue']
            readings.append({'key':key,'values':[copy.deepcopy(v) for b in queue['front']+list(reversed(queue['back'])) if b['tick']>old for v in b['values']], 'lagged':max(old,registered)<queue['dropped']})
            if relation_id not in domain['readers']:domain['readers'].insert(0,relation_id)
        self.activate(self.positions,relation_id,self.failure_tick)
        records=[copy.deepcopy(e['event']['record']) for e in self.events[self.removal_cursor[name]:] if e['kind']=='original' and e['event']['kind']=='removed']
        view={'query':query,'eventA':{'values':event_values,'lagged':False},'added':added,'changed':changed,'removals':records,'relations':readings}
        if not fail:
            self.commit_position(self.event_positions,event_id,self.route-1)
            self.commit_position(self.positions,relation_id,self.failure_tick)
            self.removal_cursor[name]=len(self.events)
            self.ingest(self.route);self.query[name]=self.clock
        # A failure stages Send999 inside the actual transaction, then discards
        # its event buffer. No event999/raw record/journal batch is published.
        return view
    def world(self):
        capacity=1
        while capacity<self.next_id:capacity*=2
        return {'namespace':self.namespace,'nextId':self.next_id,'highWater':self.next_id-1,
                'live':[i in self.live for i in range(capacity)],
                'inactiveReservations':[{'namespace':self.namespace,'id':i} for i in range(1,self.next_id) if i not in self.live],
                'capacity':capacity,'depth':capacity.bit_length()-1,
                'components':[{'entity':{'namespace':self.namespace,'id':i},'value':self.components.get(i),'added':self.stamps.get(i,(0,0))[0],'changed':self.stamps.get(i,(0,0))[1]} for i in sorted(self.live)],
                'resource':'unit','registrations':copy.deepcopy(self.registrations),'nextSystemId':self.next_system,
                'clock':self.clock,'pending':len(self.pending),'graph':copy.deepcopy(self.graph),'events':copy.deepcopy(self.events)}
    def image(self,event_next=3,relation_next=3):
        stream={'domain':'values','batches':copy.deepcopy(self.messages),'positions':copy.deepcopy(self.event_positions),'nextReader':event_next,'frameStart':0,'boundary':0,'capacity':CAPACITY,'dropped':0}
        failures={'domains':copy.deepcopy(self.domains),'positions':copy.deepcopy(self.positions),'tick':self.failure_tick,'frameStart':self.frame_start,'boundary':self.boundary,'capacity':CAPACITY,'nextReader':relation_next}
        return {'world':self.world(),'metadata':{'routeTick':self.route,'shared':{'typed':{'stream':stream,'journal':copy.deepcopy(self.journal),'frameStart':0},'relationFailures':failures}}}

def selftest():
    state=State();state.writer_begin()
    source=state.enqueue_spawn(42);target=state.enqueue_spawn(43)
    state.writer_success()
    assert (source,target)==(handle(1),handle(2)) and not state.live and state.world()['pending']==2
    state.barrier()
    assert state.clock==4 and state.route==state.failure_tick==2
    assert state.stamps=={1:(3,3),2:(4,4)}
    first=state.read('fast',1,1);second=state.read('slow',2,2)
    assert first==second and first['added']==first['changed']==[handle(1),handle(2)]
    state.writer_begin();state.enqueue_remove(target);state.writer_success();state.barrier()
    assert state.clock==9 and state.route==8 and state.components[2] is None and state.stamps[2]==(0,0)
    a=state.read('fast',1,1);b=state.read('slow',2,2)
    assert a==b and a['removals']==[removal(2)] and a['added']==a['changed']==[]
    state.writer_begin();state.enqueue_insert(target,44);state.writer_success();state.barrier()
    assert state.clock==14 and state.stamps[2]==(14,14)
    a=state.read('fast',1,1);b=state.read('slow',2,2)
    assert a==b and a['added']==a['changed']==[handle(2)]
    state.writer_begin();state.pending.append(('relate',1,2));state.writer_success();state.barrier()
    assert state.clock==18 and state.graph['edges'][0]['target']==2
    state.writer_begin();doomed=state.enqueue_spawn();state.writer_success();state.barrier()
    assert doomed==handle(3) and 3 in state.live and state.components.get(3) is None
    state.writer_begin();state.enqueue_despawn(doomed);state.writer_success();state.barrier()
    assert 3 not in state.live and state.world()['inactiveReservations']==[handle(3)]
    state.writer_begin();state.pending.extend([('relate',1,1),('relate',1,3)]);state.writer_success([31,32]);state.barrier()
    assert state.clock==24 and [v['event']['value'] for b in state.messages for v in b['values']]==[31,32]
    before=copy.deepcopy(state.image());assert before==state.image()  # Bevy-preserving active skip.
    cursors=(copy.deepcopy(state.positions),copy.deepcopy(state.event_positions),dict(state.query),dict(state.removal_cursor))
    failed=state.read('slow',2,2,fail=True)
    assert cursors==(state.positions,state.event_positions,state.query,state.removal_cursor)
    retried=state.read('slow',2,2)
    assert failed==retried and [v['event']['value'] for v in retried['eventA']['values']]==[31,32]
    assert all(e.get('event',{}).get('value')!=999 for e in state.events)
    fast=state.read('fast',1,1)
    assert fast==retried
    assert state.read('fast',1,1)['eventA']['values']==state.read('slow',2,2)['eventA']['values']==[]
    return {'transitionInvariants':'passed','finalClock':state.clock,'source':source,'target':target,'doomed':doomed}
if __name__=='__main__':
    import json
    print(json.dumps(selftest()))
