"""Source-derived complete finite full-operation trace lifecycle; no runtime input."""
from pathlib import Path
import hashlib
import json
from base_model import listing, array, Collector

HERE = Path(__file__).resolve().parent
ERROR = 'expected-body-failure'
NAME = 'full-operation-trace'
NAMES = {1:'exit',2:'transition',3:'enter',4:'success',5:'skip',6:'failure',7:'component',8:'machine-queue',9:'relation',10:'publisher'}
KEYS = {i: ('Payload' if i == 7 else 'Mode' if i == 8 else 'Follows' if i == 9 else 'Cargo' if i == 10 else 'Counter') for i in NAMES}
SCHEMA = listing(['Entry{'+kind+';key='+key+';name='+key+'}' for kind,key in [('Resource','Counter'),('Resource','Sibling'),('Component','Payload'),('Relation','Follows'),('Relation','FollowedBy'),('Event','Cargo')]])
STEPS = ['Phase{operations}'] + [f'System{{{i};condition=0}}' for i in (4,7,8,9,10)] + ['Barrier','System{5;condition=1}','System{6;condition=0}','Barrier']
OBSERVATIONS = listing(['Entered{operations}'] + [f'Ran{{{i}}}' for i in (4,7,8,9,10)] + ['Applied','Skipped{5}','Ran{6}'])
DESC = 'Descriptor{key=17;name=Follows;inverse=FollowedBy;kind=Ordinary}'
REL = 'relation{id=17;name=Follows;inverse=FollowedBy;kind=OrdinaryRelation}'


def product(*values):
    return 'Product{' + ','.join(values) + '}'


def sequence(values):
    return ';'.join(values) + (';' if values else '') + '[]'


def plan(values):
    if not values:
        return 'Empty'
    return 'Sequence{Entry{' + values[0] + ';requirements=[]};' + plan(values[1:]) + '}'


def batch(events):
    return 'Disabled' if events is None else 'Ready{events=' + listing(events) + '}'


def fact(category, key, operation, before='OpaqueValue', after='OpaqueValue', result='Applied', subject='None'):
    return f'Fact{{category={category};key={key};operation={operation};subject={subject};before={before};after={after};result={result}}}'


def displayed(value):
    return f'DisplayedValue{{{value}}}'


class Model:
    def __init__(self, namespace):
        self.namespace = namespace
        self.debug = False
        self.counter = 10
        self.payloads = [20,20]
        self.added = [2,3]
        self.changed = [2,3]
        self.clock = 3
        self.pending = ['Raw(opaque)']
        self.cursors = {i:0 for i in NAMES}
        self.mode = 0
        self.queued = None
        self.previous = None
        self.mode_changed = True
        self.revision = 1
        self.transitions = [(1,'Initial{0}')]
        self.log = []
        self.notices = []
        self.related = False
        self.incoming = [70,80,90]
        self.retry = []
        self.publication_calls = 0
        self.relation_calls = 0
        self.outcomes = []
        self.subscriber = Collector(100,200)
        self.returned = []
        self.batches = []
        self.captured = []
        self.status = 'registered'

    def handle(self, index):
        return f'{self.namespace}/{index}:0'

    def fh(self, index):
        return f'handle{{{self.namespace}:{index}:0}}'

    def access(self, ident):
        # Event declaration's canonical Registry access differs from its key.
        return KEYS[ident] + (':write' if ident == 10 else '')

    def identity(self, ident):
        return f'namespace={self.namespace};id={ident};name={NAMES[ident]};access=[{self.access(ident)}];cursor={self.cursors[ident]}'

    def metadata(self, ident, kind=True):
        if ident == 10:
            # Stored Fields retain no clauses; enabled DTO descriptions derive
            # canonical clauses from the retained MixedKind uses instead.
            tail = ';slot=;clauses=' + ('[]' if kind else '[Clause{Cargo;mode=Write}]')
            tag = 'Mixed{[Use{Event;source=Message;key=Cargo;mode=Write}]}'
        else:
            tail = f';slot={KEYS[ident]};clauses=[Clause{{{KEYS[ident]};mode=Write}}]'
            tag = 'Component' if ident == 7 else 'Field'
        return self.identity(ident) + tail + (';kind='+tag if kind else '')

    def owner(self, ident):
        return 'owner{token=Token;fields{' + self.metadata(ident) + '}}'

    def held(self):
        arrays = lambda values: sequence([array(v,v+1) for v in values])
        return ('held{source='+self.handle(1)+';target='+self.handle(2)+';incoming='+arrays(self.incoming)
                + ';retry='+arrays(self.retry)+f';publicationCalls={self.publication_calls};relationCalls={self.relation_calls};outcomes='+listing(self.outcomes)+'}')

    def owners(self):
        previous = 'owners{previous=Unit;first='+self.owner(4)+';second='+self.owner(5)+';third='+self.owner(6)+'}'
        previous = 'owners4{resources='+previous+';component='+self.owner(7)+'}'
        for n,label,ident in [(5,'machine',8),(6,'relation',9),(7,'publisher',10)]:
            previous = f'owners{n}'+'{previous='+previous+';'+label+'='+self.owner(ident)+'}'
        return 'owners{registered='+previous+';'+self.held()+'}'

    def handlers(self):
        parts = []
        for ident in (1,2,3):
            entry = f'handler{{ordinal={ident-1};registry'+'{'+self.identity(ident)+'}}'
            parts.append(NAMES[ident]+'='+entry+';[]')
        return 'handlerOwners{'+';'.join(parts)+'}'

    def mode_state(self):
        pending = 'NoPending' if self.queued is None else f'Queued{{value={self.queued};skipSame=False}}'
        prev = 'None' if self.previous is None else f'Some{{{self.previous}}}'
        slot = f'Present{{current={self.mode};pending={pending};previous={prev};changed={self.mode_changed}}}'
        backs = listing([f'Batch{{tick={tick};count=1;values=[{event}]}}' for tick,event in reversed(self.transitions)])
        return ('State{slot='+slot+';stream=Stream{Queue{front=[];back='+backs+f';size={len(self.transitions)};dropped=0;batchCount={len(self.transitions)}'+'};positions=[];frameStart=0};revision='+str(self.revision)+'}')

    def graph(self):
        edges = ['Edge{'+DESC+';source=1:0;target=2:0}'] if self.related else []
        inverses = ['Inverse{'+DESC+';target=2:0;sources=[1:0]}'] if self.related else []
        return 'Graph{edges='+listing(edges)+';inverses='+listing(inverses)+'}'

    def world(self):
        slots = 'node(node(leaf:0:Consumed,leaf:0:Live),node(leaf:0:Live,leaf:0:Consumed))'
        alloc = 'allocator{next=3;high=2;capacity=4;depth=2;slots='+slots+';free=[];order=[1:0, 2:0]}'
        cells = 'node('+','.join('leaf:some('+array(p,p+1)+')' for p in self.payloads)+')'
        added = array(*self.added)
        changed = array(*self.changed)
        col = 'Indexed{owned(values='+cells+';metadata={added='+added+';changed='+changed+';capacity=2;depth=1;exceptional=[]})}'
        log = 'Log{next='+str(len(self.log)+1)+';rows='+sequence([f'row{{id={i};payload='+array(v,v+1)+'}' for i,v in enumerate(self.log,1)])+'}'
        resources = 'Counter='+array(self.counter,self.counter+1)+';Sibling='+array(900,901)+';Mode='+self.mode_state()+';Cargo='+log
        regs = listing([f'{i}:{NAMES[i]}:[{self.access(i)}]' for i in reversed(NAMES)])
        return (f'world{{namespace={self.namespace};'+alloc+';store=store{column='+col+';'+self.graph()+'};resources={'+resources
                + '};events='+listing(self.notices)+';pending='+','.join(self.pending+['end'])+';registrations='+regs+f';nextSystemId=11;clock={self.clock}'+'}')

    def app(self):
        return ('app{schema='+SCHEMA+f';debug={self.debug};recipe=Recipe;plan='+plan(STEPS)+f';namespace={self.namespace};name={NAME};steps='+listing(STEPS)+';needs=[];'+self.world()+';'+self.owners()+'}')

    def relation_rows(self, rendered=False):
        rows = []
        for i in (1,2):
            outgoing = self.related and i == 1
            incoming = self.related and i == 2
            if rendered:
                a = 'Target:'+f'{self.namespace}:2:0' if outgoing else 'Missing'
                b = 'Sources:['+f'{self.namespace}:1:0'+']' if incoming else 'Missing'
                rows.append(f'{self.namespace}:{i}:0:'+listing(['Follows:Outgoing:'+a,'FollowedBy:Incoming:'+b]))
            else:
                a = 'Target{'+self.handle(2)+'}' if outgoing else 'Missing'
                b = 'Sources{['+self.handle(1)+']}' if incoming else 'Missing'
                cells = listing(['Cell{key=Follows;direction=Outgoing;value='+a+'}','Cell{key=FollowedBy;direction=Incoming;value='+b+'}'])
                rows.append('ProjectedRow{entity='+self.handle(i)+';data=Product{Unit,'+cells+'}}')
        return rows

    def snapshot(self):
        if not self.debug:
            return 'None'
        binds = listing(['binding{'+self.metadata(i,False)+'}' for i in range(4,11)])
        resources = product(product(product('Unit',str(self.counter)),str(self.counter)),str(self.counter))
        components = listing(['ProjectedRow{entity='+self.handle(i)+';data=Found{'+str(self.payloads[i-1])+'}}' for i in (1,2)])
        previous = product(resources,product('Unit',components))
        rows = product(product(previous,f'Current{{{self.mode}}}'),'View{'+DESC+';rows='+listing(self.relation_rows())+'}')
        component_text = listing([f'{self.namespace}:{i}:0:Found({self.payloads[i-1]})' for i in (1,2)])
        rel_text = 'Relation{key=17|name=Follows|inverse=FollowedBy|kind=Ordinary}:'+listing(self.relation_rows(True))
        rendered = listing(['Counter='+str(self.counter)]*3+[component_text,'Mode=Current:'+str(self.mode),'Follows='+rel_text])
        return ('Some{schema='+SCHEMA+';bindings='+binds+';rows='+rows+';rendered='+rendered+f';namespace={self.namespace};name={NAME};steps='+listing(['PlannedStep{'+s+';requirements=[]}' for s in STEPS])+'}')

    def seeds(self):
        return sequence(['seed{reservation=Reserved{'+self.handle(i)+'};activation=Accepted;write=Accepted;recovered=none}' for i in (1,2)])

    def checkpoint(self,label):
        # Single.snapshot folds unchanged metadata and reads Inspector-owned values;
        # unlike Sys.run_tracked it neither invokes registries nor advances cursors.
        before = self.world(),dict(self.cursors)
        snapshot = self.snapshot()
        assert before == (self.world(),self.cursors)
        sub = 'None' if self.subscriber is None else 'Some(subscriber{'+self.subscriber.text()+'})'
        return (label+'\napp='+self.app()+'\nhandlers='+self.handlers()+'\nseeds='+self.seeds()+'\nsubscriber='+sub
                +'\nreturned='+sequence([c.text() for c in self.returned])+'\nbatches='+sequence([batch(b) for b in self.batches])
                +'\ncaptured='+sequence(self.captured)+'\nstatus='+self.status+'\nsnapshot='+snapshot+'\n')

    def event_identity(self,i):
        return f'identity{{namespace={self.namespace};id={i};name=Some{{{NAMES[i]}}}}}'

    def operation(self,i,value):
        return 'OperationObserved{'+self.event_identity(i)+';fact='+value+'}'

    def complete(self,i,before):
        result = 'SystemError{error='+ERROR+'}' if i==6 else 'SystemOk'
        return 'SystemCompleted{'+self.event_identity(i)+f';before={before};after={self.clock};status='+result+'}'

    def relation_fact(self,operation,result,call):
        action = 'UnrelateAction' if call==1 else 'RelateAction{'+self.fh(2 if call==0 else 1)+'}'
        return 'RelationFact{'+REL+';operation='+operation+';source='+self.fh(1)+';action='+action+';result='+result+'}'

    def run(self):
        events = [f'ScheduleStarted{{namespace={self.namespace};name={NAME}}}','PhaseEntered{name=operations}']
        before = self.clock
        old = self.counter
        self.counter += 1
        self.cursors[4] = self.clock
        events += [self.operation(4,fact('ResourceValue','Counter','WriteOperation',displayed(old),displayed(self.counter))),self.complete(4,before)]
        before = self.clock
        for j in range(2):
            old = self.payloads[j]
            self.payloads[j] += 1
            self.clock += 1
            self.changed[j] = self.clock
            events.append(self.operation(7,fact('ComponentValue','Payload','WriteOperation',displayed(old),displayed(old+1),subject=f'Some{{{self.namespace}:{j+1}:0}}')))
        self.cursors[7] = self.clock
        events.append(self.complete(7,before))
        before = self.clock
        self.queued = self.mode+1
        self.cursors[8] = self.clock
        events += [self.operation(8,fact('NextStateValue','Mode','StageOperation')),self.complete(8,before)]
        call = self.relation_calls
        self.relation_calls += 1
        self.cursors[9] = self.clock
        events += [self.operation(9,self.relation_fact('StageOperation','Applied',call)),self.complete(9,self.clock)]
        payload = self.retry.pop(0) if self.retry else self.incoming.pop(0)
        failed = self.publication_calls == 1
        self.publication_calls += 1
        if failed:
            self.retry.insert(0,payload)
            self.outcomes.insert(0,'Failure{ExpectedPublicationFailure}')
        else:
            self.log.append(payload)
            self.notices.append(f'Original{{{len(self.log)}}}')
            self.outcomes.insert(0,'Success')
        self.cursors[10] = self.clock
        events += [self.operation(10,fact('EventValue','Cargo','SendOperation','UnavailableValue','OpaqueValue','RolledBack' if failed else 'Applied')),self.complete(10,self.clock)]
        if self.pending:
            self.clock += 1
            self.pending = []
        if call==0:
            self.related = True
        elif call==1:
            self.related = False
        else:
            self.notices.append('RelationFailed{Failure{'+DESC+';operation=Relate;source=1:0;target=1:0;error=SelfRelationNotAllowed{1:0;Follows}}}')
        refusal = 'Refused{SelfRelationNotAllowed:1:0:Follows}' if call>=2 else 'Applied'
        events += ['BarrierOperationObserved{fact='+self.relation_fact('ApplyOperation',refusal,call)+'}','DeferredApplied','SystemSkipped{id=5}',self.operation(6,fact('ResourceValue','Counter','WriteOperation',displayed(self.counter),displayed(self.counter+1),'RolledBack')),self.complete(6,self.clock),'ScheduleEnded{outcome=EndFailed{error='+ERROR+'}}']
        self.batches = [events if self.debug else None]
        self.status = 'Failed:'+ERROR+':'+OBSERVATIONS
        return 'RunCompleted\n'

    def handler_fact(self,i,result):
        return (f'HandlerFact{{namespace={self.namespace};id={i};name={NAMES[i]};ordinal={i-1};phase='+NAMES[i].title()+'Phase;from=OpaqueValue;to=OpaqueValue;result='+result+'}')

    def handle_run(self):
        target = self.queued
        self.captured.insert(0,f'Scheduled{{value={target};skipSame=False}}')
        self.queued = None
        self.previous = self.mode
        self.mode_changed = False
        events = []
        failure = False
        for i in (1,2,3):
            if i==3:
                previous = self.mode
                self.mode = target
                self.mode_changed = True
                self.revision += 1
                self.clock += 1
                self.transitions.append((self.clock,f'Transition{{from={previous};to={target}}}'))
                events.append('TransitionFact{key=Mode;from=OpaqueValue;to=OpaqueValue;result=Applied}')
            old = self.counter
            fail = i==2 and target==3
            # Field runner settles every Attempted fact in the incoming trace,
            # including the immediately preceding actual HandlerFact.
            events += [self.handler_fact(i,'RolledBack' if fail else 'Applied'),fact('ResourceValue','Counter','WriteOperation',displayed(old),displayed(old+1),'RolledBack' if fail else 'Applied')]
            if fail:
                events.append(self.handler_fact(i,'Refused{'+ERROR+'}'))
                self.queued = target
                failure = True
                break
            self.counter += 1
            self.cursors[i] = self.clock
            events.append(self.handler_fact(i,'Applied'))
        self.batches.append(['ExecutionOperationObserved{fact='+f+'}' for f in events] if self.debug else None)
        self.status = 'Handlers:'+('Some{phase=Transition;error='+ERROR+'}' if failure else 'None')
        return 'HandlersCompleted\n'

    def deliver(self):
        before = self.world(),dict(self.cursors)
        if self.subscriber is not None:
            for events in self.batches:
                if events is not None:
                    self.subscriber.deliver(events)
        assert before == (self.world(),self.cursors)
        return 'DeliveryReturned\n'


def schema(namespace):
    s = Model(namespace)
    out = [s.checkpoint('disabled-before'),s.run(),s.checkpoint('disabled-schedule-completed'),s.handle_run(),s.checkpoint('disabled-handlers-completed'),s.deliver(),s.checkpoint('disabled-delivery-bypassed')]
    assert (s.counter,s.mode,s.clock,s.revision)==(14,1,7,2)
    assert s.subscriber.calls==0 and s.log==[70]
    s.debug = True
    out += ['Enabled\n',s.checkpoint('enabled-before'),s.run(),s.checkpoint('enabled-schedule-completed'),s.handle_run(),s.checkpoint('enabled-handlers-completed'),s.deliver(),s.checkpoint('enabled-delivery-returned')]
    assert (s.counter,s.mode,s.clock,s.revision)==(18,2,10,3)
    assert s.retry==[80] and s.log==[70]
    s.returned.insert(0,s.subscriber)
    s.subscriber = Collector(300,400)
    s.status = 'ResetReturnedOwner'
    out += ['ResetReturned\n',s.checkpoint('reset-returned-owner'),s.run(),s.checkpoint('repeated-schedule-completed'),s.handle_run(),s.checkpoint('repeated-handlers-completed'),s.deliver(),s.checkpoint('repeated-delivery-returned')]
    assert (s.counter,s.mode,s.queued,s.clock,s.revision)==(20,2,3,12,3)
    assert s.retry==[] and s.incoming==[90] and s.log==[70,80]
    s.returned.insert(0,s.subscriber)
    s.subscriber = None
    s.status = 'UnsubscribeReturnedOwner'
    out += ['UnsubscribeReturned\n',s.checkpoint('unsubscribe-returned-owner'),s.checkpoint('terminal-repeat')]
    return ''.join(out)


def render():
    return ('Workshop\n'+schema(1)+'Garden\n'+schema(2)+'\n').encode()


def selftest():
    raw = render()
    assert raw.count(b'\napp=')==28 and raw.count(b'RunCompleted\n')==6
    assert raw.count(b'HandlersCompleted\n')==6 and raw.count(b'snapshot=None')==8
    assert b'UNSUPPORTED_PREPARED_COLUMN' not in raw
    assert all(line.count(b'{')==line.count(b'}') for line in raw.splitlines())
    s=Model(1)
    assert s.cursors=={i:0 for i in NAMES}
    for _ in range(3):
        s.run();s.handle_run()
    assert s.cursors=={1:12,2:9,3:10,4:10,5:0,6:0,7:12,8:12,9:12,10:12}
    assert s.payloads==[23,23] and s.changed==[11,12]
    assert len(s.transitions)==3 and s.notices[-1].startswith('RelationFailed')
    enabled=Model(1)
    enabled.debug=True
    enabled.run(); enabled.handle_run(); enabled.deliver()
    assert enabled.subscriber.calls==29
    assert enabled.subscriber.first==129 and enabled.subscriber.second==200
    assert len(enabled.batches[0])==19 and len(enabled.batches[1])==10
    assert enabled.snapshot().count('ProjectedRow')==4
    assert 'access=[Cargo:write]' in enabled.owner(10)
    assert ';slot=;clauses=[];kind=Mixed{' in enabled.owner(10)
    assert '10:publisher:[Cargo:write]' in enabled.world()
    assert ';slot=;clauses=[Clause{Cargo;mode=Write}]}' in enabled.snapshot()
    assert '10:publisher:[Cargo]' not in enabled.world()


def verify_basis():
    basis=json.loads((HERE/'SOURCE-BASIS.json').read_text())
    assert hashlib.sha256((HERE/'base_model.py').read_bytes()).hexdigest()==basis['reusedBasis']['sha256']
    for name,digest in basis['sourcePins'].items():
        assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==digest,name


if __name__=='__main__':
    import sys
    verify_basis()
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
