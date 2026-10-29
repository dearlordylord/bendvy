import Base
import ./change-tick.bend as Tick
import ./trace-facts.bend as Facts

# Detached copied facts. No World, registration, cursor or stream owner is held.
# Copied system identity for presentation: namespace/id and optional name.
# It is metadata, not a registration owner or capability for invoking that system.
type Identity is Data:
  Identity{namespace:U32,id:U32,name:Maybe<&2,String>}
# Completion status of one executed system, retaining its detached Data error.
type Status<Error:Data> is Data:
  SystemOk{}
  SystemError{error:Error}
# Schedule-level completion distinguishes failure, admission rejection and missing
# execution from success; it is not a replacement for the retained App run result.
type Completion<Error:Data> is Data:
  EndOk{}
  EndFailed{error:Error}
  EndRejected{}
  EndMissing{}
# Ordered copied execution facts: schedule/phase boundaries, systems, operations
# and admission outcomes. Facts describe the actual run; they grant no mutable
# World access and do not imply that a failed transaction committed its operations.
type TraceEvent<Error:Data> is Data:
  ScheduleStarted{namespace:U32,name:String}
  PhaseEntered{name:String}
  SystemCompleted{identity:Identity,before:Tick.Tick,after:Tick.Tick,status:Status<Error>}
  SystemOutcome{id:U32,status:Status<Error>}
  ConditionOutcome{id:U32,status:Status<Error>}
  InvocationRefused{id:U32}
  ConditionRefused{id:U32}
  DependencyObserved{before:U32,after:U32}
  OperationObserved{identity:Identity,fact:Facts.Fact}
  BarrierOperationObserved{fact:Facts.Fact}
  ExecutionOperationObserved{fact:Facts.Fact}
  SystemSkipped{id:U32}
  DeferredApplied{}
  ScheduleEnded{outcome:Completion<Error>}
  ScheduleAdmissionRefused{namespace:U32,name:String,outcome:Completion<Error>}
# Detached delivery value returned after execution. Disabled differs from an
# enabled Ready batch with no events. No live reader or stream retention is held;
# keeping or dropping a copied batch does not acknowledge an ECS event reader.
type Batch<Error:Data> is Data:
  Disabled{}
  BendvyReady{events:List<&2,TraceEvent<Error>>}

# Each subscription is its actual affine state owner, not a copied callback.
# The erased reusable step is supplied as a top-level definition.
type Subscriber<State:Type,Error:Data,-step:State -> TraceEvent<Error> -> State> is Type:
  Subscriber{state:State}
# Wrap the supplied actual State owner with a reusable erased step definition.
# This creates a local subscriber, not an ECS registration or automatic callback.
def subscribe(~State:Type,~Error:Data,~step:State -> TraceEvent<Error> -> State,state:State) -> Subscriber<State,Error,step>:
  Subscriber{state}
# Consume the subscriber and return its actual State for reuse or explicit
# disposal. No implicit user cleanup/destructor callback is invoked.
def unsubscribe(~State:Type,~Error:Data,~step:State -> TraceEvent<Error> -> State,value:Subscriber<State,Error,step>) -> State:
  match value:
    case Subscriber{state}:state
# Replace subscription state and return the displaced actual owner separately.
# Neither owner is copied or silently restored into ECS storage.
def reset(~State:Type,~Error:Data,~step:State -> TraceEvent<Error> -> State,value:Subscriber<State,Error,step>,incoming:State) -> Subscriber<State,Error,step> & State:
  match value:
    case Subscriber{state}:(Subscriber{incoming},state)
def delivered(~State:Type,~Error:Data,~step:State -> TraceEvent<Error> -> State,events:List<&2,TraceEvent<Error>>,state:State) -> State:
  match events:
    case []:state
    case event <> rest:delivered(~State,~Error,~step,rest,step(state,event))
# Thread subscriber State through Ready events in list order; Disabled returns
# the subscriber unchanged. Delivery is explicitly called after the ECS run.
# Any external printing/file IO performed by a consumer is outside ECS rollback,
# not an in-transaction observer. See examples/scheduled-health/application.bend.
def deliver(~State:Type,~Error:Data,~step:State -> TraceEvent<Error> -> State,value:Subscriber<State,Error,step>,batch:Batch<Error>) -> Subscriber<State,Error,step>:
  match value batch:
    case subscriber Disabled{}:subscriber
    case Subscriber{state} BendvyReady{events}:Subscriber{delivered(~State,~Error,~step,events,state)}

# Generic owner composition has no arity or subscriber-count bound. Order is
# left then right; each reusable delivery function can itself be another pair.
# Deliver the same detached batch to two actual owners, left then right, returning
# both results. Compose this adapter recursively for additional subscribers; this
# is owner composition, not a global subscription registry.
def both(~Left:Type,~Right:Type,~Error:Data,~left:Left -> Batch<Error> -> Left,~right:Right -> Batch<Error> -> Right,value:Left & Right,+batch:Batch<Error>) -> Left & Right:
  match value:
    case (first,second):(left(first,batch),right(second,batch))
