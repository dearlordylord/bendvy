"""Independent finite operation model and exact source-defined string projection."""
from dataclasses import dataclass
from pathlib import Path
import gzip, hashlib, json

def tree(*xs):
    return 'leaf:'+str(xs[0]) if len(xs)==1 else 'node('+','.join(tree(x) for x in xs)+')'
def listing(xs):return '['+', '.join(map(str,xs))+']'
@dataclass
class State:
    reserved: bool=False
    seeded: bool=False
    registered: bool=False
    scalar:int=11
    changed:int=2
    clock:int=0
    calls:int=0
    accumulated:tuple=(30,40)
    query_cursor:int=0
    resource:tuple=(100,200)
    counter:tuple=(10,11)
    field_cursor:int=0
    allow:bool=True
    def seed(self):self.seeded=True;self.clock=2
    def run(self):
        self.counter=(21,22);self.field_cursor=self.clock
        if self.allow:
            old=self.scalar;self.scalar+=4;self.calls+=1
            self.accumulated=tuple(x+old for x in self.accumulated)
            self.clock+=1;self.changed=self.clock;self.query_cursor=self.clock
        self.resource=tuple(x+1+sum(self.counter) for x in self.resource)
    def world(self):
        def column(value,added,changed):
            return 'Column{values=leaf:'+('none' if value is None else 'some('+value+')')+';stamps='+('[]' if value is None else f'[1:{added}:{changed}]')+'}'
        arrays=column(tree(7,9) if self.seeded else None,1,1)
        scalar=column(str(self.scalar) if self.seeded else None,2,self.changed)
        regs='[3:CounterTransaction:[Counter], 2:CounterCaptured:[WorkshopResources], 1:ScalarCaptured:[scalar]]' if self.registered else '[]'
        allocator=(f'next={2 if self.reserved else 1};high={1 if self.reserved else 0};capacity={2 if self.reserved else 1};depth={1 if self.reserved else 0};slots='+(tree('0:Consumed','0:Live' if self.seeded else '0:Pending') if self.reserved else tree('0:Consumed'))+';free=[];order='+('[1:0]' if self.reserved else '[]'))
        return f'namespace=1|allocator={{{allocator}}}|store=arrays={{{arrays}}};scalars={{{scalar}}}|resources=Counter={tree(*self.counter)};Sibling={tree(100,101)};receipts=inverses={1 if self.seeded else 0};returned=[];errors=[];quarantines=0|events=[]|pending={2 if self.reserved and not self.seeded else 0}|pendingKinds={"Raw;" * (2 if self.reserved and not self.seeded else 0)}end|registrations={regs}|nextSystem={4 if self.registered else 1}|clock={self.clock}'
    def owners(self):
        ident=lambda id,name,access:f'namespace=1;id={id};name={name};access=[{access}]'
        entry=lambda step:'Entry{'+step+';requirements=[]}'
        seq=lambda a,b:'Sequence{'+a+','+b+'}'
        plan=seq(seq(entry('System{3,0}'),entry('Phase{AuditCapturedPipeline}')),seq(entry('System{1,0}'),seq(entry('Barrier'),seq(entry('System{2,0}'),entry('Barrier')))))
        allowed=str(self.allow)
        return 'schedule{name=AuditCapturedPipeline;plan='+plan+'}|query{'+ident(1,'ScalarCaptured','scalar')+f';cursor={self.query_cursor};args=Unit;enabled=True;capture={{calls={tree(self.calls)};values={tree(*self.accumulated)}}}}}|resource{{'+ident(2,'CounterCaptured','WorkshopResources')+f';args=Unit;enabled=True;capture={tree(*self.resource)}}}|field{{'+ident(3,'CounterTransaction','Counter')+f';cursor={self.field_cursor}}}|conditionOwner{{id=1;value={allowed}}};bindings=[systemId=1;condition={{name={allowed};access=[];leaves=[Constant{{{allowed}}}]}}]'
    def selected(self):return f'cursor=0;arrays=Found([7, 9]):added=True:changed=True;scalar=Found({self.scalar}):added=True:changed=True;counter=[21, 22]'
