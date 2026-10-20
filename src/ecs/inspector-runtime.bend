import Base
import ./change-tick.bend as Tick
import ./world.bend as W
import ./event-runtime.bend as Ev
import ./relation-commands.bend as A
import ./inspector.bend as I
import ./inspector-stream-frame.bend as F
import ./capabilities.bend as Cap

# A run plan grants capabilities over one stream-backed frame. The frame owns
# the actual event runtime; callers do not receive a detached or reconstructed
# event log.
type Plan<-S:Data,-C:Type,-R:Type,-E:Data,-Ops:Type -> Type> is Type:
  Plan{caps:Ops(F.Frame<S,C,R,E>)}

# The result returns the exact runtime owner produced by the callback, with the
# inspector's single successful clock advance applied to its World.
type RunResult<S:Data,C:Type,R:Type,E:Data,U:Data,Out:Data> is Type:
  RunResult{runtime:Ev.Runtime<S,C,R,A.Notice<S,E>>,instance:I.Instance<S>,result:Result<&2,&2,U,Out>}

def plan_caps(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,plan:Plan<S,C,R,E,Ops>) -> Ops(F.Frame<S,C,R,E>):
  match plan:
    case Plan{caps}:caps

def fresh_join(~S:Data,~C:Type,~R:Type,~E:Data,clocked:W.World<S,C,R,A.Notice<S,E>> & Tick.Tick,namespace:U32,batches:List<&2,Ev.Batch<A.Notice<S,E>>>,positions:List<&2,Ev.Position>,nextReader:U32,tick:Nat,frameStart:Nat,boundary:Nat,capacity:Nat,dropped:Nat) -> Ev.Runtime<S,C,R,A.Notice<S,E>> & Tick.Tick:
  (world,registeredAt)=clocked
  (Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},registeredAt)

def fresh_runtime(~S:Data,~C:Type,~R:Type,~E:Data,runtime:Ev.Runtime<S,C,R,A.Notice<S,E>>) -> Ev.Runtime<S,C,R,A.Notice<S,E>> & Tick.Tick:
  match runtime:
    case Ev.Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped}:
      fresh_join(~S,~C,~R,~E,W.clock(~S,~C,~R,~A.Notice<S,E>,world),namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

def bumped_runtime(~S:Data,~C:Type,~R:Type,~E:Data,advanced:W.World<S,C,R,A.Notice<S,E>> & Tick.Tick,namespace:U32,batches:List<&2,Ev.Batch<A.Notice<S,E>>>,positions:List<&2,Ev.Position>,nextReader:U32,tick:Nat,frameStart:Nat,boundary:Nat,capacity:Nat,dropped:Nat) -> Ev.Runtime<S,C,R,A.Notice<S,E>> & Tick.Tick:
  (world,cursor)=advanced
  (Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},cursor)

def advance_runtime(~S:Data,~C:Type,~R:Type,~E:Data,runtime:Ev.Runtime<S,C,R,A.Notice<S,E>>) -> Ev.Runtime<S,C,R,A.Notice<S,E>> & Tick.Tick:
  match runtime:
    case Ev.Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped}:
      bumped_runtime(~S,~C,~R,~E,W.advance_clock(~S,~C,~R,~A.Notice<S,E>,world),namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

def succeeded(~S:Data,~C:Type,~R:Type,~E:Data,~U:Data,~Out:Data,registeredAt:Tick.Tick,value:Out,observed:Ev.Runtime<S,C,R,A.Notice<S,E>> & Tick.Tick) -> RunResult<S,C,R,E,U,Out>:
  (runtime,cursor)=observed
  RunResult{runtime,I.Active{Some{cursor},registeredAt},Done{value}}

def finished(~S:Data,~C:Type,~R:Type,~E:Data,~U:Data,~Out:Data,cursor:Maybe<&2,Tick.Tick>,registeredAt:Tick.Tick,observed:F.Frame<S,C,R,E> & Result<&2,&2,U,Out>) -> RunResult<S,C,R,E,U,Out>:
  match observed:
    case (F.Frame{runtime,_},Fail{error}):RunResult{runtime,I.Active{cursor,registeredAt},Fail{error}}
    case (F.Frame{runtime,_},Done{value}):succeeded(~S,~C,~R,~E,~U,~Out,registeredAt,value,advance_runtime(~S,~C,~R,~E,runtime))

def invoked(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A0:Data,~U:Data,~Out:Data,~plan:Plan<S,C,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A0 -> H -> H & Result<&2,&2,U,Out>,args:A0,+cursor:Maybe<&2,Tick.Tick>,+registeredAt:Tick.Tick,runtime:Ev.Runtime<S,C,R,A.Notice<S,E>>) -> RunResult<S,C,R,E,U,Out>:
  finished(~S,~C,~R,~E,~U,~Out,cursor,registeredAt,Cap.invoke(~Ops,~A0,~Result<&2,&2,U,Out>,~body,~F.Frame<S,C,R,E>,~plan_caps(~S,~C,~R,~E,~Ops,plan),args,F.Frame{runtime,cursor}))

def begin_fresh(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A0:Data,~U:Data,~Out:Data,~plan:Plan<S,C,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A0 -> H -> H & Result<&2,&2,U,Out>,args:A0,runtime:Ev.Runtime<S,C,R,A.Notice<S,E>> & Tick.Tick) -> RunResult<S,C,R,E,U,Out>:
  (runtime,registeredAt)=runtime
  invoked(~S,~C,~R,~E,~Ops,~A0,~U,~Out,~plan,~body,args,None{},registeredAt,runtime)

def run(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A0:Data,~U:Data,~Out:Data,~plan:Plan<S,C,R,E,Ops>,~body:@-H:Type -> @-caps:Ops(H) -> A0 -> H -> H & Result<&2,&2,U,Out>,instance:I.Instance<S>,args:A0,runtime:Ev.Runtime<S,C,R,A.Notice<S,E>>) -> RunResult<S,C,R,E,U,Out>:
  match instance:
    case I.Fresh{}:begin_fresh(~S,~C,~R,~E,~Ops,~A0,~U,~Out,~plan,~body,args,fresh_runtime(~S,~C,~R,~E,runtime))
    case I.Active{cursor,registeredAt}:invoked(~S,~C,~R,~E,~Ops,~A0,~U,~Out,~plan,~body,args,cursor,registeredAt,runtime)

# Lift a trusted World-backed capability without detaching or duplicating the
# event runtime. This preserves the supplied grant exactly; it is not a sandbox
# or a type-enforced read-only boundary for caller-constructed capabilities.
# As with I.Plan, grant construction is part of the trusted setup boundary.
# Every Event Runtime field except its World is preserved.
def restored_read(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,observed:I.Frame<S,C,R,A.Notice<S,E>> & V,namespace:U32,batches:List<&2,Ev.Batch<A.Notice<S,E>>>,positions:List<&2,Ev.Position>,nextReader:U32,tick:Nat,frameStart:Nat,boundary:Nat,capacity:Nat,dropped:Nat) -> F.Frame<S,C,R,E> & V:
  match observed:
    case (I.Frame{world,cursor},value): (F.Frame{Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},cursor},value)

def read_runtime(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~cap:Cap.ValueRead<I.Frame<S,C,R,A.Notice<S,E>>,V>,cursor:Maybe<&2,Tick.Tick>,runtime:Ev.Runtime<S,C,R,A.Notice<S,E>>) -> F.Frame<S,C,R,E> & V:
  match runtime:
    case Ev.Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped}:
      restored_read(~S,~C,~R,~E,~V,Cap.value_read(~I.Frame<S,C,R,A.Notice<S,E>>,~V,~cap,I.Frame{world,cursor}),namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

def read_frame(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~cap:Cap.ValueRead<I.Frame<S,C,R,A.Notice<S,E>>,V>,frame:F.Frame<S,C,R,E>) -> F.Frame<S,C,R,E> & V:
  match frame:
    case F.Frame{runtime,cursor}:read_runtime(~S,~C,~R,~E,~V,~cap,cursor,runtime)

def lift_world_read(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~cap:Cap.ValueRead<I.Frame<S,C,R,A.Notice<S,E>>,V>) -> Cap.ValueRead<F.Frame<S,C,R,E>,V>:
  Cap.ValueRead{read_frame(~S,~C,~R,~E,~V,~cap)}

# A handle lookup remains an ordinary runtime argument. This lift restores the
# event owner around the existing Inspector lookup without capturing a handle
# or detaching any of the runtime's reader/event metadata. It preserves the
# supplied trusted grant and does not make an arbitrary Lookup closure safe.
def restored_lookup(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,observed:I.Frame<S,C,R,A.Notice<S,E>> & I.Value<V>,namespace:U32,batches:List<&2,Ev.Batch<A.Notice<S,E>>>,positions:List<&2,Ev.Position>,nextReader:U32,tick:Nat,frameStart:Nat,boundary:Nat,capacity:Nat,dropped:Nat) -> F.Frame<S,C,R,E> & I.Value<V>:
  match observed:
    case (I.Frame{world,cursor},value):(F.Frame{Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},cursor},value)

def lookup_runtime(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~cap:I.Lookup<I.Frame<S,C,R,A.Notice<S,E>>,S,V>,cursor:Maybe<&2,Tick.Tick>,runtime:Ev.Runtime<S,C,R,A.Notice<S,E>>,target:W.Handle<S>) -> F.Frame<S,C,R,E> & I.Value<V>:
  match runtime:
    case Ev.Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped}:
      restored_lookup(~S,~C,~R,~E,~V,I.lookup(~I.Frame<S,C,R,A.Notice<S,E>>,~S,~V,~cap,I.Frame{world,cursor},target),namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped)

def lookup_frame(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~cap:I.Lookup<I.Frame<S,C,R,A.Notice<S,E>>,S,V>,frame:F.Frame<S,C,R,E>,target:W.Handle<S>) -> F.Frame<S,C,R,E> & I.Value<V>:
  match frame:
    case F.Frame{runtime,cursor}:lookup_runtime(~S,~C,~R,~E,~V,~cap,cursor,runtime,target)

def lift_world_lookup(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~cap:I.Lookup<I.Frame<S,C,R,A.Notice<S,E>>,S,V>) -> I.Lookup<F.Frame<S,C,R,E>,S,V>:
  I.Lookup{frame => target => lookup_frame(~S,~C,~R,~E,~V,~cap,frame,target)}
