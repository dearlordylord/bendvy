import Base
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/reader-domains.bend as D
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/capabilities.bend as Cap

# Each actual runtime domain retains its own position representation. Removal
# ticks originate in W.clock; ordinary event positions originate in Ev.Runtime.
# No cast equates the two clocks after interleaved system/Inspector operations.
type Frame<-S:Data,-Store:Type,-R:Type,-E:Data,-Logs:Type> is Type:
  Frame{world:W.World<S,Store,R,E>,events:D.Events<S,E>,logs:Logs,cursor:U32,registeredAt:U32,eventCursor:Nat,eventRegisteredAt:Nat}
type Instance<-S:Data> is Type:
  Fresh{}
  Active{cursor:U32,registeredAt:U32,eventCursor:Nat,eventRegisteredAt:Nat}
type Plan<-S:Data,-Store:Type,-R:Type,-E:Data,-Logs:Type,-Ops:Type -> Type> is Type:
  Plan{caps:Ops(Frame<S,Store,R,E,Logs>)}
type Observed<-S:Data,-Store:Type,-R:Type,-E:Data,-Logs:Type,U:Data,Out:Data> is Type:
  Observed{world:W.World<S,Store,R,E>,events:D.Events<S,E>,logs:Logs,instance:Instance<S>,result:Result<&2,&2,U,Out>}
def event_read(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,frame:Frame<S,Store,R,E,Logs>) -> Frame<S,Store,R,E,Logs> & Ev.Reading<E>:
  match frame:
    case Frame{world,D.Events{+ns,+batches,+positions,+next,+tick,+start,+boundary,+capacity,+dropped,+values},logs,+cursor,+registered,+ec,+er}:
      (Frame{world,D.Events{ns,batches,positions,next,tick,start,boundary,capacity,dropped,values},logs,cursor,registered,ec,er},Ev.reading(~E,Ev.Position{0,ec,er},batches,dropped))
def event_grant(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type) -> Cap.ValueRead<Frame<S,Store,R,E,Logs>,Ev.Reading<E>>:
  Cap.ValueRead{frame => event_read(~S,~Store,~R,~E,~Logs,frame)}
def logs_join(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~V:Data,world:W.World<S,Store,R,E>,events:D.Events<S,E>,cursor:U32,registered:U32,ec:Nat,er:Nat,result:Logs & V) -> Frame<S,Store,R,E,Logs> & V:
  (logs,value)=result
  (Frame{world,events,logs,cursor,registered,ec,er},value)
def logs_read(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~V:Data,~read:Logs -> U32 -> U32 -> Logs & V,frame:Frame<S,Store,R,E,Logs>) -> Frame<S,Store,R,E,Logs> & V:
  match frame:
    case Frame{world,events,logs,+cursor,+registered,ec,er}:logs_join(~S,~Store,~R,~E,~Logs,~V,world,events,cursor,registered,ec,er,read(logs,cursor,registered))
def logs_grant(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~V:Data,~read:Logs -> U32 -> U32 -> Logs & V) -> Cap.ValueRead<Frame<S,Store,R,E,Logs>,V>:
  Cap.ValueRead{frame => logs_read(~S,~Store,~R,~E,~Logs,~V,~read,frame)}
def caps(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~Ops:Type -> Type,plan:Plan<S,Store,R,E,Logs,Ops>) -> Ops(Frame<S,Store,R,E,Logs>):
  match plan:
    case Plan{caps}:caps
def success_detached(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~U:Data,~Out:Data,logs:Logs,cursor:U32,registered:U32,eventRegistered:Nat,value:Out,result:D.Detached<S,Store,R,E>) -> Observed<S,Store,R,E,Logs,U,Out>:
  match result:
    case D.Detached{world,D.Events{ns,batches,positions,next,+tick,start,boundary,capacity,dropped,values}}:Observed{world,D.Events{ns,batches,positions,next,tick,start,boundary,capacity,dropped,values},logs,Active{cursor,registered,tick,eventRegistered},Done{value}}
def success_runtime(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~U:Data,~Out:Data,logs:Logs,cursor:U32,registered:U32,eventRegistered:Nat,value:Out,+removals:List<&2,E>,result:Ev.Runtime<S,Store,R,E> & Unit) -> Observed<S,Store,R,E,Logs,U,Out>:
  (runtime,_)=result
  success_detached(~S,~Store,~R,~E,~Logs,~U,~Out,logs,cursor,registered,eventRegistered,value,D.detach(~S,~Store,~R,~E,runtime,removals))
def success_view(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~U:Data,~Out:Data,events:D.Events<S,E>,logs:Logs,cursor:U32,registered:U32,eventRegistered:Nat,value:Out,result:W.World<S,Store,R,E> & List<&2,E>) -> Observed<S,Store,R,E,Logs,U,Out>:
  (world,+removals)=result
  success_runtime(~S,~Store,~R,~E,~Logs,~U,~Out,logs,cursor,registered,eventRegistered,value,removals,Ev.with_world(~S,~Store,~R,~E,~Unit,w => (w,Unit{}),D.attach(~S,~Store,~R,~E,events,world)))
def success_clocked(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~U:Data,~Out:Data,events:D.Events<S,E>,logs:Logs,registered:U32,eventRegistered:Nat,value:Out,result:W.World<S,Store,R,E> & U32) -> Observed<S,Store,R,E,Logs,U,Out>:
  (world,cursor)=result
  success_view(~S,~Store,~R,~E,~Logs,~U,~Out,events,logs,cursor,registered,eventRegistered,value,W.events_view(~S,~Store,~R,~E,world))
def finish(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~U:Data,~Out:Data,+oldCursor:U32,+registered:U32,+oldEventCursor:Nat,+eventRegistered:Nat,result:Frame<S,Store,R,E,Logs> & Result<&2,&2,U,Out>) -> Observed<S,Store,R,E,Logs,U,Out>:
  match result:
    case (Frame{world,events,logs,_,_,_,_},Fail{error}):Observed{world,events,logs,Active{oldCursor,registered,oldEventCursor,eventRegistered},Fail{error}}
    case (Frame{world,events,logs,_,_,_,_},Done{value}):success_clocked(~S,~Store,~R,~E,~Logs,~U,~Out,events,logs,registered,eventRegistered,value,W.advance_clock(~S,~Store,~R,~E,world))
def invoke(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~plan:Plan<S,Store,R,E,Logs,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Result<&2,&2,U,Out>,args:A,+cursor:U32,+registered:U32,+ec:Nat,+er:Nat,world:W.World<S,Store,R,E>,events:D.Events<S,E>,logs:Logs) -> Observed<S,Store,R,E,Logs,U,Out>:
  finish(~S,~Store,~R,~E,~Logs,~U,~Out,cursor,registered,ec,er,Cap.invoke(~Ops,~A,~Result<&2,&2,U,Out>,~body,~Frame<S,Store,R,E,Logs>,~caps(~S,~Store,~R,~E,~Logs,~Ops,plan),args,Frame{world,events,logs,cursor,registered,ec,er}))
def fresh_clocked(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~plan:Plan<S,Store,R,E,Logs,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Result<&2,&2,U,Out>,args:A,events:D.Events<S,E>,logs:Logs,result:W.World<S,Store,R,E> & U32) -> Observed<S,Store,R,E,Logs,U,Out>:
  match events result:
    case D.Events{ns,batches,positions,next,+tick,start,boundary,capacity,dropped,values},(world,registered):invoke(~S,~Store,~R,~E,~Logs,~Ops,~A,~U,~Out,~plan,~body,args,0,registered,0n,tick,world,D.Events{ns,batches,positions,next,tick,start,boundary,capacity,dropped,values},logs)
def run(~S:Data,~Store:Type,~R:Type,~E:Data,~Logs:Type,~Ops:Type -> Type,~A:Data,~U:Data,~Out:Data,~plan:Plan<S,Store,R,E,Logs,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Result<&2,&2,U,Out>,instance:Instance<S>,args:A,world:W.World<S,Store,R,E>,events:D.Events<S,E>,logs:Logs) -> Observed<S,Store,R,E,Logs,U,Out>:
  match instance:
    case Fresh{}:fresh_clocked(~S,~Store,~R,~E,~Logs,~Ops,~A,~U,~Out,~plan,~body,args,events,logs,W.clock(~S,~Store,~R,~E,world))
    case Active{cursor,registered,ec,er}:invoke(~S,~Store,~R,~E,~Logs,~Ops,~A,~U,~Out,~plan,~body,args,cursor,registered,ec,er,world,events,logs)
