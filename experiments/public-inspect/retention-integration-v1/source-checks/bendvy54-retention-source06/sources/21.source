import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/reader-domains.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-inspect/bend-candidate/events.bend as I

# Reached corruption: Inspector becomes an ordinary zero-cursor retainer.
def retained(~S:Data,~E:Data,events:D.Events<S,E>) -> D.Events<S,E>:
  match events:
    case D.Events{ns,batches,positions,next,tick,start,boundary,capacity,dropped,values}:D.Events{ns,batches,Ev.activate(positions,0,0n),next,tick,start,boundary,capacity,dropped,values}
# Trusted transport, not a gameplay World grant. Positions remain owned by D.
def joined(~S:Data,~C:Type,~R:Type,~E:Data,~U:Data,~O:Data,observed:I.Observed<S,C,R,E,U,O>) -> Ev.Runtime<S,C,R,E> & I.Instance<S> & Result<&2,&2,U,O>:
  match observed:
    case I.Observed{world,events,instance,result}:(D.attach(~S,~C,~R,~E,retained(~S,~E,events),world),instance,result)
def detached(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~O:Data,~plan:I.Plan<S,C,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Result<&2,&2,U,O>,instance:I.Instance<S>,args:A,detached:D.Detached<S,C,R,E>) -> Ev.Runtime<S,C,R,E> & I.Instance<S> & Result<&2,&2,U,O>:
  match detached:
    case D.Detached{world,events}:joined(~S,~C,~R,~E,~U,~O,I.run(~S,~C,~R,~E,~Ops,~A,~U,~O,~plan,~body,instance,args,world,events))
def observe(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~U:Data,~O:Data,~plan:I.Plan<S,C,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Result<&2,&2,U,O>,runtime:Ev.Runtime<S,C,R,E>,instance:I.Instance<S>,args:A) -> Ev.Runtime<S,C,R,E> & I.Instance<S> & Result<&2,&2,U,O>:
  detached(~S,~C,~R,~E,~Ops,~A,~U,~O,~plan,~body,instance,args,D.detach(~S,~C,~R,~E,runtime,[]))
