import Base
import ./execution-lifecycle-notices.bend as Notice
import ./clock-state.bend as Clock
import entity-key.bend as Key
import entity-allocator.bend as Alloc
import ./world.bend as W
import ./decode-data.bend as D
import ./deferred-command.bend as Deferred

# Basic detached Data only; runtime checkpoint state is intentionally not encoded.
type Entity is Data:
  Entity{key:Key.Key,components:List<&2,D.Field>}
type Snapshot is Data:
  Snapshot{version:U32,nextEntity:U32,entities:List<&2,Entity>,resources:List<&2,D.Field>}

# Ordinary save either exports detached Data or refuses pending structural work.
# Refusal returns the same World separately; it does not execute or discard work.
type Outcome<A:Data> is Data:
  Saved{snapshot:A}
  RefusedPending{}

def pending_ready(~World:Type,pending:List<Deferred.Command<World>>) -> List<Deferred.Command<World>> & Bool:
  match pending:
    case []:([],True{})
    case command <> rest:(command <> rest,False{})
def ready_joined(~S:Data,~C:Type,~R:Type,~E:Data,namespace:U32,allocator:Alloc.Allocator,store:C,resource:R,events:List<&2,E>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,result:List<Deferred.Command<W.World<S,C,R,E>>> & Bool,lifecycle:Notice.Journal<S>) -> W.World<S,C,R,E> & Bool:
  match result:
    case (pending,ready):(W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle},ready)
# Internal constant-time structural admission, before any trusted projection.
def ready(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Bool:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle}:ready_joined(~S,~C,~R,~E,namespace,allocator,store,resource,events,registrations,nextSystemId,clock,pending_ready(~W.World<S,C,R,E>,pending),lifecycle)

# Internal experimental accessor: exact actual allocator, no inferred live count.
# Rebuild the SAME owner with every field returned unchanged.
def allocator(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & U32:
  match world:
    case W.World{+namespace,Alloc.Allocator{+nextId,+high,slots,+capacity,+depth,+free,+order},store,resource,+events,pending,+registrations,+nextSystemId,+clock,lifecycle}:
      (W.World{namespace,Alloc.Allocator{nextId,high,slots,capacity,depth,free,order},store,resource,events,pending,registrations,nextSystemId,clock,lifecycle},nextId)

# Closed schema providers must return the actual store/resource owners. Their
# projections, transient omission and name bindings are trusted author inputs.
# This is NOT the still-missing public constructed-descriptor validation gate.
def finish(~S:Data,~C:Type,~R:Type,~E:Data,nextEntity:U32,entities:List<&2,Entity>,observed:W.World<S,C,R,E> & List<&2,D.Field>) -> W.World<S,C,R,E> & Snapshot:
  match observed:
    case (world,fields):(world,Snapshot{1,nextEntity,entities,fields})
def with_entities(~S:Data,~C:Type,~R:Type,~E:Data,~resources:R -> R & List<&2,D.Field>,nextEntity:U32,observed:W.World<S,C,R,E> & List<&2,Entity>) -> W.World<S,C,R,E> & Snapshot:
  match observed:
    case (world,entities):finish(~S,~C,~R,~E,nextEntity,entities,W.observe_resource(~S,~C,~R,~E,~List<&2,D.Field>,~resources,world))
def with_handles(~S:Data,~C:Type,~R:Type,~E:Data,~rows:List<&2,W.Handle<S>> -> C -> C & List<&2,Entity>,~resources:R -> R & List<&2,D.Field>,nextEntity:U32,observed:W.World<S,C,R,E> & List<&2,W.Handle<S>>) -> W.World<S,C,R,E> & Snapshot:
  match observed:
    case (world,handles):with_entities(~S,~C,~R,~E,~resources,nextEntity,W.with_store(~S,~C,~R,~E,~List<&2,Entity>,rows(handles),world))
def with_allocator(~S:Data,~C:Type,~R:Type,~E:Data,~rows:List<&2,W.Handle<S>> -> C -> C & List<&2,Entity>,~resources:R -> R & List<&2,D.Field>,observed:W.World<S,C,R,E> & U32) -> W.World<S,C,R,E> & Snapshot:
  match observed:
    case (world,nextEntity):with_handles(~S,~C,~R,~E,~rows,~resources,nextEntity,W.handles(~S,~C,~R,~E,world))
def saved(~S:Data,~C:Type,~R:Type,~E:Data,result:W.World<S,C,R,E> & Snapshot) -> W.World<S,C,R,E> & Outcome<Snapshot>:
  match result:
    case (world,snapshot):(world,Saved{snapshot})
def basic_ready(~S:Data,~C:Type,~R:Type,~E:Data,~rows:List<&2,W.Handle<S>> -> C -> C & List<&2,Entity>,~resources:R -> R & List<&2,D.Field>,result:W.World<S,C,R,E> & Bool) -> W.World<S,C,R,E> & Outcome<Snapshot>:
  match result:
    case (world,False{}):(world,RefusedPending{})
    case (world,True{}):saved(~S,~C,~R,~E,with_allocator(~S,~C,~R,~E,~rows,~resources,allocator(~S,~C,~R,~E,world)))
def basic(~S:Data,~C:Type,~R:Type,~E:Data,~rows:List<&2,W.Handle<S>> -> C -> C & List<&2,Entity>,~resources:R -> R & List<&2,D.Field>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Outcome<Snapshot>:
  basic_ready(~S,~C,~R,~E,~rows,~resources,ready(~S,~C,~R,~E,world))
