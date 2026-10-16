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
        return f'namespace=1|next={2 if self.reserved else 1}|high={1 if self.reserved else 0}|live='+ ('node('+tree('False','True' if self.seeded else 'False')+','+tree('False','False' if self.seeded else 'True')+')' if self.reserved else tree('False'))+f'|capacity={2 if self.reserved else 1}|depth={1 if self.reserved else 0}|store=arrays={{{arrays}}};scalars={{{scalar}}}|resources=Counter={tree(*self.counter)};Sibling={tree(100,101)};receipts=inverses={1 if self.seeded else 0};returned=[];errors=[];quarantines=0|events=[]|pending={2 if self.reserved and not self.seeded else 0}|registrations={regs}|nextSystem={4 if self.registered else 1}|clock={self.clock}'
    def owners(self):
        ident=lambda id,name,access:f'namespace=1;id={id};name={name};access=[{access}]'
        entry=lambda step:'Entry{'+step+';requirements=[]}'
        seq=lambda a,b:'Sequence{'+a+','+b+'}'
        plan=seq(seq(entry('System{3,0}'),entry('Phase{AuditCapturedPipeline}')),seq(entry('System{1,0}'),seq(entry('Barrier'),seq(entry('System{2,0}'),entry('Barrier')))))
        allowed=str(self.allow)
        return 'schedule{name=AuditCapturedPipeline;plan='+plan+'}|query{'+ident(1,'ScalarCaptured','scalar')+f';cursor={self.query_cursor};args=Unit;enabled=True;capture={{calls={tree(self.calls)};values={tree(*self.accumulated)}}}}}|resource{{'+ident(2,'CounterCaptured','WorkshopResources')+f';args=Unit;enabled=True;capture={tree(*self.resource)}}}|field{{'+ident(3,'CounterTransaction','Counter')+f';cursor={self.field_cursor}}}|conditionOwner{{id=1;value={allowed}}};bindings=[systemId=1;condition={{name={allowed};access=[];leaves=[Constant{{{allowed}}}]}}]'
    def selected(self):return f'cursor=0;arrays=Found([7, 9]):added=True:changed=True;scalar=Found({self.scalar}):added=True:changed=True;counter=[21, 22]'
def render():
    s=State();lines=[]
    def snap(label,owners=False):lines.append(label+'|world='+s.world()+ ('|schedule='+s.owners() if owners else '')+'\n')
    snap('created');s.reserved=True;snap('bundle-committed-before-flush');s.seed();snap('explicit-flush');s.registered=True;snap('registered',True)
    for label,allowed in [('first',True),('second',False),('third',True)]:
        s.allow=allowed;snap(label+'-before',True);s.run()
        logs=['ran:3','phase:AuditCapturedPipeline',('ran:1' if allowed else 'skipped:1'),'barrier','ran:2','barrier']
        snap(label+'-after:Finished:'+listing(logs),True)
        for suffix in ['-inspect','-repeated-inspect']:snap(label+suffix+':selected='+s.selected(),True)
    return (''.join(lines)+'\n').encode()
def selftest():
    s=State();s.reserved=True;s.seed();s.registered=True
    assert 'pending=0' in s.world() and 'inverses=1' in s.world()
    s.run();assert (s.scalar,s.clock,s.calls,s.accumulated,s.query_cursor,s.field_cursor,s.resource)==(15,3,1,(41,51),3,2,(144,244))
    s.allow=False;s.run();assert (s.scalar,s.clock,s.calls,s.accumulated,s.query_cursor,s.field_cursor,s.resource)==(15,3,1,(41,51),3,3,(188,288))
    s.allow=True;s.run();assert (s.scalar,s.clock,s.calls,s.accumulated,s.query_cursor,s.field_cursor,s.resource)==(19,4,2,(56,66),4,3,(232,332))
    b=render();assert b.endswith(b'\n\n') and b.count(b'\n')==17
    assert b.count(b':selected=')==6 and b.count(b':Finished:')==3
if __name__=='__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:sys.stdout.buffer.write(render())
