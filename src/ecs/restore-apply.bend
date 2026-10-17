import Base
import ./restore-lifecycle.bend as Lifecycle
import ./entity-key.bend as Key
import ./restore-data.bend as R
import ./restore-world.bend as Adapter
import ./world.bend as W
import ./entity-allocator.bend as Alloc
import ./snapshot-data.bend as Snapshot

type ApplyResult<S:Data,C:Type,Resources:Type,E:Data,State:Type,Custom:Data> is Type:
  Applied{world:W.World<S,C,Resources,E>,state:State,bindings:List<&2,R.Binding<S>>}
  Refused{world:W.World<S,C,Resources,E>,state:State,input:Snapshot.Snapshot,error:R.Error<Custom>}
type Spawned<S:Data,C:Type,Resources:Type,E:Data> is Type:
  Spawned{world:W.World<S,C,Resources,E>,bindings:List<&2,R.Binding<S>>}
  Exhausted{world:W.World<S,C,Resources,E>,bindings:List<&2,R.Binding<S>>}
def spawned(~S:Data,~C:Type,~Resources:Type,~E:Data,~emit:R.Change<S> -> E,+saved:Key.Key,+handle:W.Handle<S>,bindings:List<&2,R.Binding<S>>,next:W.World<S,C,Resources,E> -> List<&2,R.Binding<S>> -> Spawned<S,C,Resources,E>,observed:W.World<S,C,Resources,E> & W.Status) -> Spawned<S,C,Resources,E>:
  match observed:
    case (world,W.Rejected{_}):Exhausted{world,List.reverse(&2,R.Binding<S>,bindings)}
    case (world,W.Accepted{}):next(W.event_publish(~S,~C,~Resources,~E,world,[emit(R.Spawned{handle})]),R.Binding{saved,handle} <> bindings)
def reserved(~S:Data,~C:Type,~Resources:Type,~E:Data,~emit:R.Change<S> -> E,saved:Key.Key,bindings:List<&2,R.Binding<S>>,next:W.World<S,C,Resources,E> -> List<&2,R.Binding<S>> -> Spawned<S,C,Resources,E>,observed:W.World<S,C,Resources,E> & W.Reservation<S>) -> Spawned<S,C,Resources,E>:
  match observed:
    case (world,W.ReservationRejected{_}):Exhausted{world,List.reverse(&2,R.Binding<S>,bindings)}
    case (world,W.Reserved{+handle}):spawned(~S,~C,~Resources,~E,~emit,saved,handle,bindings,next,(world,W.Accepted{}))
def spawn(~S:Data,~C:Type,~Resources:Type,~E:Data,~emit:R.Change<S> -> E,entities:List<&2,Snapshot.Entity>,world:W.World<S,C,Resources,E>,bindings:List<&2,R.Binding<S>>) -> Spawned<S,C,Resources,E>:
  match entities:
    case []:Spawned{world,List.reverse(&2,R.Binding<S>,bindings)}
    case Snapshot.Entity{saved,_} <> rest:reserved(~S,~C,~Resources,~E,~emit,saved,bindings,world => bindings => spawn(~S,~C,~Resources,~E,~emit,rest,world,bindings),Lifecycle.spawn(~S,~C,~Resources,~E,world))
def inserted(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,+namespace:U32,allocator:Alloc.Allocator,+oldEvents:List<&2,E>,pending:List<(W.World<S,C,Resources,E> -> W.World<S,C,Resources,E>)>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,bindings:List<&2,R.Binding<S>>,observed:(C & Resources) & State) -> ApplyResult<S,C,Resources,E,State,Custom>:
  match observed:
    case ((store,resource),state):Applied{W.World{namespace,allocator,store,resource,oldEvents,pending,registrations,nextSystem,clock},state,bindings}
def capacity_error(~Custom:Data,input:Snapshot.Snapshot) -> R.Error<Custom>:
  match input:
    case Snapshot.Snapshot{_,floor,_,_}:R.Capacity{floor}
def install(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> U32 -> (C & Resources) & State,state:State,+input:Snapshot.Snapshot,observed:Spawned<S,C,Resources,E>) -> ApplyResult<S,C,Resources,E,State,Custom>:
  match observed:
    case Exhausted{world,_}:Refused{world,state,input,capacity_error(~Custom,input)}
    case Spawned{W.World{namespace,allocator,store,resource,oldEvents,pending,registrations,nextSystem,+clock},+bindings}:inserted(~S,~C,~Resources,~E,~State,~Custom,namespace,allocator,oldEvents,pending,registrations,nextSystem,clock,bindings,insert(store,resource,state,bindings,clock))
def progressed(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> U32 -> (C & Resources) & State,~emit:R.Change<S> -> E,state:State,+input:Snapshot.Snapshot,observed:W.World<S,C,Resources,E> & Bool) -> ApplyResult<S,C,Resources,E,State,Custom>:
  match input observed:
    case Snapshot.Snapshot{version,floor,entities,resources},(world,False{}):Refused{world,state,Snapshot.Snapshot{version,floor,entities,resources},R.Capacity{floor}}
    case Snapshot.Snapshot{+version,+floor,+entities,+resources},(world,True{}):install(~S,~C,~Resources,~E,~State,~Custom,~insert,state,Snapshot.Snapshot{version,floor,entities,resources},spawn(~S,~C,~Resources,~E,~emit,entities,world,[]))
def cleaned(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> U32 -> (C & Resources) & State,~emit:R.Change<S> -> E,+input:Snapshot.Snapshot,floor:U32,observed:W.World<S,C,Resources,E> & State) -> ApplyResult<S,C,Resources,E,State,Custom>:
  match observed:
    case (world,state):progressed(~S,~C,~Resources,~E,~State,~Custom,~insert,~emit,state,input,Adapter.advance_floor(~S,~C,~Resources,~E,world,floor))
def handles(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> U32 -> (C & Resources) & State,~emit:R.Change<S> -> E,state:State,+input:Snapshot.Snapshot,+floor:U32,observed:W.World<S,C,Resources,E> & List<&2,W.Handle<S>>) -> ApplyResult<S,C,Resources,E,State,Custom>:
  match observed:
    case (world,values):cleaned(~S,~C,~Resources,~E,~State,~Custom,~insert,~emit,input,floor,(Lifecycle.clean(~S,~C,~Resources,~E,~clear,~emit,values,world),state))
def advanced(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> U32 -> (C & Resources) & State,~emit:R.Change<S> -> E,state:State,input:Snapshot.Snapshot,floor:U32,observed:W.World<S,C,Resources,E> & U32) -> ApplyResult<S,C,Resources,E,State,Custom>:
  match observed:
    case (world,_):handles(~S,~C,~Resources,~E,~State,~Custom,~clear,~insert,~emit,state,input,floor,W.handles(~S,~C,~Resources,~E,world))
def admitted(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~release:State -> State,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> U32 -> (C & Resources) & State,~emit:R.Change<S> -> E,state:State,+input:Snapshot.Snapshot,+floor:U32,observed:W.World<S,C,Resources,E> & Bool) -> ApplyResult<S,C,Resources,E,State,Custom>:
  match observed:
    case (world,False{}):Refused{world,release(state),input,R.Capacity{floor}}
    case (world,True{}):advanced(~S,~C,~Resources,~E,~State,~Custom,~clear,~insert,~emit,state,input,floor,W.advance_clock(~S,~C,~Resources,~E,W.events_replace(~S,~C,~Resources,~E,world,[])))
def count_entities(values:List<&2,Snapshot.Entity>) -> Nat:
  match values:
    case []:0n
    case _ <> rest:1n+count_entities(rest)
def apply(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~release:State -> State,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> U32 -> (C & Resources) & State,~emit:R.Change<S> -> E,world:W.World<S,C,Resources,E>,prepared:R.Prepared<State,Custom>) -> ApplyResult<S,C,Resources,E,State,Custom>:
  match prepared:
    case R.Refused{state,input,error}:Refused{world,state,input,error}
    case R.Ready{state,Snapshot.Snapshot{+version,+floor,+entities,+resources}}:admitted(~S,~C,~Resources,~E,~State,~Custom,~release,~clear,~insert,~emit,state,Snapshot.Snapshot{version,floor,entities,resources},floor,Adapter.room(~S,~C,~Resources,~E,world,floor,count_entities(entities)))
