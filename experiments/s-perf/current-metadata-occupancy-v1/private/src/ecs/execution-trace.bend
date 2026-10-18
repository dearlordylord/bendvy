import Base
import ./trace-facts.bend as Facts

# Detached copied facts. No World, registration, cursor or stream owner is held.
type Identity is Data:
  Identity{namespace:U32,id:U32,name:Maybe<&2,String>}
type Status<Error:Data> is Data:
  SystemOk{}
  SystemError{error:Error}
type Completion<Error:Data> is Data:
  EndOk{}
  EndFailed{error:Error}
  EndRejected{}
  EndMissing{}
type TraceEvent<Error:Data> is Data:
  ScheduleStarted{namespace:U32,name:String}
  PhaseEntered{name:String}
  SystemCompleted{identity:Identity,before:U32,after:U32,status:Status<Error>}
  OperationObserved{identity:Identity,fact:Facts.Fact}
  BarrierOperationObserved{fact:Facts.Fact}
  ExecutionOperationObserved{fact:Facts.Fact}
  SystemSkipped{id:U32}
  DeferredApplied{}
  ScheduleEnded{outcome:Completion<Error>}
  ScheduleAdmissionRefused{namespace:U32,name:String,outcome:Completion<Error>}
type Batch<Error:Data> is Data:
  Disabled{}
  Ready{events:List<&2,TraceEvent<Error>>}

# Each subscription is its actual affine state owner, not a copied callback.
# The erased reusable step is supplied as a top-level definition.
type Subscriber<State:Type,Error:Data,-step:State -> TraceEvent<Error> -> State> is Type:
  Subscriber{state:State}
def subscribe(~State:Type,~Error:Data,~step:State -> TraceEvent<Error> -> State,state:State) -> Subscriber<State,Error,step>:
  Subscriber{state}
def unsubscribe(~State:Type,~Error:Data,~step:State -> TraceEvent<Error> -> State,value:Subscriber<State,Error,step>) -> State:
  match value:
    case Subscriber{state}:state
def reset(~State:Type,~Error:Data,~step:State -> TraceEvent<Error> -> State,value:Subscriber<State,Error,step>,incoming:State) -> Subscriber<State,Error,step> & State:
  match value:
    case Subscriber{state}:(Subscriber{incoming},state)
def delivered(~State:Type,~Error:Data,~step:State -> TraceEvent<Error> -> State,events:List<&2,TraceEvent<Error>>,state:State) -> State:
  match events:
    case []:state
    case event <> rest:delivered(~State,~Error,~step,rest,step(state,event))
def deliver(~State:Type,~Error:Data,~step:State -> TraceEvent<Error> -> State,value:Subscriber<State,Error,step>,batch:Batch<Error>) -> Subscriber<State,Error,step>:
  match value batch:
    case subscriber Disabled{}:subscriber
    case Subscriber{state} Ready{events}:Subscriber{delivered(~State,~Error,~step,events,state)}

# Generic owner composition has no arity or subscriber-count bound. Order is
# left then right; each reusable delivery function can itself be another pair.
def both(~Left:Type,~Right:Type,~Error:Data,~left:Left -> Batch<Error> -> Left,~right:Right -> Batch<Error> -> Right,value:Left & Right,+batch:Batch<Error>) -> Left & Right:
  match value:
    case (first,second):(left(first,batch),right(second,batch))
