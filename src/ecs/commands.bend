import Base
import ./trace-world.bend as TraceWorld
import ./deferred-command.bend as Deferred
import ./trace-facts.bend as TraceFacts
import ./world.bend as W
import ./transaction.bend as T

# World pending commands are a reverse accumulator; input here is FIFO.
def enqueue_list(~S: Data,~C: Type,~R: Type,~E: Data,commands:List<Deferred.Command<W.World<S,C,R,E>>>,world: W.World<S,C,R,E>) -> W.World<S,C,R,E>:
  match commands:
    case []: world
    case command <> rest: enqueue_list(~S,~C,~R,~E,rest,W.enqueue_command(~S,~C,~R,~E,world,command))

# Append the supplied FIFO command list to World pending work, returning World.
# This transfers affine command closures but does not execute them; W.barrier is
# the explicit visibility boundary. Raw command callbacks are trusted adapters.
def enqueue(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,C,R,E>,commands:List<Deferred.Command<W.World<S,C,R,E>>>) -> W.World<S,C,R,E>:
  enqueue_list(~S,~C,~R,~E,commands,world)

# Publish these detached Data events to World in list order. This is immediate
# publication, not transactional staging or synchronization of an event Runtime.
def publish(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,C,R,E>,events: List<&2,E>) -> W.World<S,C,R,E>:
  W.event_publish(~S,~C,~R,~E,world,events)

# Finish with canonical World adapters: success enqueues staged commands and
# publishes staged Data events in authored order; failure replays inverse actions
# and drops staged commands/events. Returns World plus outcome. It does not apply
# the structural barrier or undo arbitrary external effects.
def tx_finish(~S: Data,~C: Type,~R: Type,~E: Data,~Error: Data,tx: T.Tx<W.World<S,C,R,E>,E>,outcome: T.Outcome<Error>) -> T.Returned<W.World<S,C,R,E>,Error>:
  T.finish(~W.World<S,C,R,E>,~E,~Error,~enqueue(~S,~C,~R,~E),~publish(~S,~C,~R,~E),tx,outcome)

def spawned(~S: Data,~C: Type,~R: Type,~E: Data,~P: Type,~populate: W.World<S,C,R,E> -> W.Handle<S> -> P -> W.World<S,C,R,E>,activated: W.World<S,C,R,E> & W.Status,handle: W.Handle<S>,payload: P) -> W.World<S,C,R,E>:
  match activated:
    case (world,W.Accepted{}): populate(world,handle,payload)
    case (world,W.Rejected{_}): world

# Trusted deferred-command application: activate the reserved handle, then call
# populate only on acceptance. Payload is consumed, including when activation
# refuses; this low-level callback does not return an incoming-payload receipt.
def spawn_apply(~S: Data,~C: Type,~R: Type,~E: Data,~P: Type,~populate: W.World<S,C,R,E> -> W.Handle<S> -> P -> W.World<S,C,R,E>,world: W.World<S,C,R,E>,+handle: W.Handle<S>,payload: P) -> W.World<S,C,R,E>:
  spawned(~S,~C,~R,~E,~P,~populate,W.activate(~S,~C,~R,~E,world,handle),handle,payload)

def spawn_applied_traced(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,C,R,E> -> W.Handle<S> -> P -> W.World<S,C,R,E>,trace:TraceFacts.State,+handle:W.Handle<S>,payload:P,result:W.World<S,C,R,E> & W.Status) -> W.World<S,C,R,E> & TraceFacts.State:
  match result:
    case (world,+status):(spawned(~S,~C,~R,~E,~P,~populate,(world,status),handle,payload),TraceWorld.applied(~S,trace,"spawn",handle,status))
# Build a deferred spawn closure owning its actual payload. enabled selects raw
# or operation-fact recording; neither variant activates until command execution.
def spawn_command(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,C,R,E> -> W.Handle<S> -> P -> W.World<S,C,R,E>,enabled:Bool,+handle:W.Handle<S>,payload:P) -> Deferred.Command<W.World<S,C,R,E>>:
  match enabled:
    case False{}:Deferred.Raw{world=>spawn_apply(~S,~C,~R,~E,~P,~populate,world,handle,payload)}
    case True{}:Deferred.Observed{trace=>world=>spawn_applied_traced(~S,~C,~R,~E,~P,~populate,trace,handle,payload,W.activate(~S,~C,~R,~E,world,handle))}
# Only successful actual deferred spawns establish pending authority. The inverse
# clears at the World's current capacity after any intervening growth.
def track_pending(~S:Data,~C:Type,~R:Type,~E:Data,tx:T.Tx<W.World<S,C,R,E>,E>,+handle:W.Handle<S>) -> T.Tx<W.World<S,C,R,E>,E>:
  match tx:
    case T.Tx{world,undo,commands,events,trace}:T.Tx{W.mark_pending(~S,~C,~R,~E,world,handle),(w => W.clear_pending(~S,~C,~R,~E,w,handle)) <> undo,commands,events,trace}

def spawn_reserved(~S: Data,~C: Type,~R: Type,~E: Data,~P: Type,~populate: W.World<S,C,R,E> -> W.Handle<S> -> P -> W.World<S,C,R,E>,reservation: W.Reservation<S>,world: W.World<S,C,R,E>,undo: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<Deferred.Command<W.World<S,C,R,E>>>,events: List<&2,E>,+trace:TraceFacts.State,payload: P) -> T.Tx<W.World<S,C,R,E>,E> & W.Reservation<S>:
  match reservation:
    case W.ReservationRejected{error}: (T.Tx{world,undo,commands,events,trace},W.ReservationRejected{error})
    case W.Reserved{+handle}: (track_pending(~S,~C,~R,~E,T.Tx{world,undo,spawn_command(~S,~C,~R,~E,~P,~populate,TraceFacts.enabled(trace),handle,payload) <> commands,events,TraceWorld.deferred(~S,trace,"spawn",TraceFacts.StageOperation{},handle,TraceFacts.Attempted{})},handle),W.Reserved{handle})

def spawn_join(~S: Data,~C: Type,~R: Type,~E: Data,~P: Type,~populate: W.World<S,C,R,E> -> W.Handle<S> -> P -> W.World<S,C,R,E>,reserved: W.World<S,C,R,E> & W.Reservation<S>,undo: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<Deferred.Command<W.World<S,C,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,payload: P) -> T.Tx<W.World<S,C,R,E>,E> & W.Reservation<S>:
  (world,reservation) = reserved
  spawn_reserved(~S,~C,~R,~E,~P,~populate,reservation,world,undo,commands,events,trace,payload)

# IDs stay reserved on failure, matching the historical allocator policy.
# Reserve an entity handle now and stage activation/population for the barrier.
# Reserved is not yet live: ordinary component reads cannot observe it. The Type
# payload moves into the command; reservation refusal does not return that payload.
# Failure drops staged work and clears pending authority but does not rewind the
# allocator's reserved-ID progress. See examples/captured-query/schema.bend.
def tx_spawn(~S: Data,~C: Type,~R: Type,~E: Data,~P: Type,~populate: W.World<S,C,R,E> -> W.Handle<S> -> P -> W.World<S,C,R,E>,tx: T.Tx<W.World<S,C,R,E>,E>,payload: P) -> T.Tx<W.World<S,C,R,E>,E> & W.Reservation<S>:
  match tx:
    case T.Tx{world,undo,commands,events,trace}: spawn_join(~S,~C,~R,~E,~P,~populate,W.reserve_id(~S,~C,~R,~E,world),undo,commands,events,trace,payload)

def deactivate_join(~S: Data,~C: Type,~R: Type,~E: Data,deactivated: W.World<S,C,R,E> & W.Status) -> W.World<S,C,R,E>:
  (world,status) = deactivated
  world

# Low-level liveness-only command application, discarding its Status. Component
# storage is retained; use the schema-cleanup variant for ordinary entity disposal.
def despawn_apply(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,C,R,E>,handle: W.Handle<S>) -> W.World<S,C,R,E>:
  deactivate_join(~S,~C,~R,~E,W.deactivate(~S,~C,~R,~E,world,handle))

def despawn_applied_traced(~S:Data,~C:Type,~R:Type,~E:Data,trace:TraceFacts.State,handle:W.Handle<S>,result:W.World<S,C,R,E> & W.Status) -> W.World<S,C,R,E> & TraceFacts.State:
  match result:
    case (world,status):(world,TraceWorld.applied(~S,trace,"despawn",handle,status))
# Construct the liveness-only deferred command, optionally recording application
# status as an execution fact. Construction alone does not change liveness.
def despawn_command(~S:Data,~C:Type,~R:Type,~E:Data,enabled:Bool,+handle:W.Handle<S>) -> Deferred.Command<W.World<S,C,R,E>>:
  match enabled:
    case False{}:Deferred.Raw{world=>despawn_apply(~S,~C,~R,~E,world,handle)}
    case True{}:Deferred.Observed{trace=>world=>despawn_applied_traced(~S,~C,~R,~E,trace,handle,W.deactivate(~S,~C,~R,~E,world,handle))}
def despawn_checked(~S: Data,~C: Type,~R: Type,~E: Data,allowed: Bool,world: W.World<S,C,R,E>,undo: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<Deferred.Command<W.World<S,C,R,E>>>,events: List<&2,E>,+trace:TraceFacts.State,+handle: W.Handle<S>) -> T.Tx<W.World<S,C,R,E>,E> & W.Status:
  match allowed:
    case False{}: (T.Tx{world,undo,commands,events,trace},W.Rejected{W.MissingEntity{}})
    case True{}: (T.Tx{world,undo,despawn_command(~S,~C,~R,~E,TraceFacts.enabled(trace),handle) <> commands,events,TraceWorld.deferred(~S,trace,"despawn",TraceFacts.StageOperation{},handle,TraceFacts.Attempted{})},W.Accepted{})

def despawn_join(~S: Data,~C: Type,~R: Type,~E: Data,checked: W.World<S,C,R,E> & Bool,undo: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<Deferred.Command<W.World<S,C,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,handle: W.Handle<S>) -> T.Tx<W.World<S,C,R,E>,E> & W.Status:
  (world,allowed) = checked
  despawn_checked(~S,~C,~R,~E,allowed,world,undo,commands,events,trace,handle)

# Low-level liveness-only operation retains component storage. Gameplay uses tx_despawn_with.
# Stage liveness-only deactivation for a live or legitimately pending handle.
# Foreign/stale/otherwise invalid handles return Rejected(MissingEntity) with Tx.
# Accepted is queue admission, not applied success; storage cleanup is not included.
def tx_despawn(~S: Data,~C: Type,~R: Type,~E: Data,tx: T.Tx<W.World<S,C,R,E>,E>,+handle: W.Handle<S>) -> T.Tx<W.World<S,C,R,E>,E> & W.Status:
  match tx:
    case T.Tx{world,undo,commands,events,trace}: despawn_join(~S,~C,~R,~E,W.command_valid(~S,~C,~R,~E,world,handle),undo,commands,events,trace,handle)

# Schema-owned clear releases every component family after accepted deactivation.
def clear_join(~S: Data,~C: Type,~R: Type,~E: Data,+handle:W.Handle<S>,cleared: W.World<S,C,R,E> & Unit) -> W.World<S,C,R,E>:
  (world,unit) = cleared
  W.release_cleared(~S,~C,~R,~E,world,handle)

def clear_accepted(~S: Data,~C: Type,~R: Type,~E: Data,~clear: C -> W.Handle<S> -> C,activated: W.World<S,C,R,E> & W.Status,+handle: W.Handle<S>) -> W.World<S,C,R,E>:
  match activated:
    case (world,W.Rejected{_}): world
    case (world,W.Accepted{}): clear_join(~S,~C,~R,~E,handle,W.with_store(~S,~C,~R,~E,~Unit,(store => (clear(store,handle),Unit{})),world))

# Trusted schema-cleanup command: after accepted deactivation, clear the component
# store and release the cleared slot. Rejected deactivation skips clear. The clear
# adapter consumes actual payloads; this is not a recovery receipt.
def despawn_apply_with(~S: Data,~C: Type,~R: Type,~E: Data,~clear: C -> W.Handle<S> -> C,world: W.World<S,C,R,E>,+handle: W.Handle<S>) -> W.World<S,C,R,E>:
  clear_accepted(~S,~C,~R,~E,~clear,W.deactivate(~S,~C,~R,~E,world,handle),handle)

def despawn_checked_with(~S: Data,~C: Type,~R: Type,~E: Data,~clear: C -> W.Handle<S> -> C,allowed: Bool,world: W.World<S,C,R,E>,undo: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<Deferred.Command<W.World<S,C,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,handle: W.Handle<S>) -> T.Tx<W.World<S,C,R,E>,E> & W.Status:
  match allowed:
    case False{}: (T.Tx{world,undo,commands,events,trace},W.Rejected{W.MissingEntity{}})
    case True{}: (T.Tx{world,undo,Deferred.Raw{(w => despawn_apply_with(~S,~C,~R,~E,~clear,w,handle))} <> commands,events,trace},W.Accepted{})

def despawn_join_with(~S: Data,~C: Type,~R: Type,~E: Data,~clear: C -> W.Handle<S> -> C,checked: W.World<S,C,R,E> & Bool,undo: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<Deferred.Command<W.World<S,C,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,handle: W.Handle<S>) -> T.Tx<W.World<S,C,R,E>,E> & W.Status:
  (world,allowed) = checked
  despawn_checked_with(~S,~C,~R,~E,~clear,allowed,world,undo,commands,events,trace,handle)

# Stage schema-owned cleanup after command-valid handle admission. Return Tx and
# Status now; liveness/components change at the barrier after successful finish.
# Failure drops the staged closure. clear is trusted complete-schema provisioning.
def tx_despawn_with(~S: Data,~C: Type,~R: Type,~E: Data,~clear: C -> W.Handle<S> -> C,tx: T.Tx<W.World<S,C,R,E>,E>,+handle: W.Handle<S>) -> T.Tx<W.World<S,C,R,E>,E> & W.Status:
  match tx:
    case T.Tx{world,undo,commands,events,trace}: despawn_join_with(~S,~C,~R,~E,~clear,W.command_valid(~S,~C,~R,~E,world,handle),undo,commands,events,trace,handle)

# Cleanup owns actual removed payloads; its typed metadata is published only on success.
def clear_observed_join(~S: Data,~C: Type,~R: Type,~E: Data,~record: W.Handle<S> -> E,+handle: W.Handle<S>,cleared: W.World<S,C,R,E> & List<&2,E>) -> W.World<S,C,R,E>:
  (world,records) = cleared
  W.release_cleared(~S,~C,~R,~E,W.event_publish(~S,~C,~R,~E,world,List.append(&2,E,records,[record(handle)])),handle)

def clear_observed_accepted(~S: Data,~C: Type,~R: Type,~E: Data,~clear: C -> W.Handle<S> -> C & List<&2,E>,~record: W.Handle<S> -> E,activated: W.World<S,C,R,E> & W.Status,+handle: W.Handle<S>) -> W.World<S,C,R,E>:
  match activated:
    case (world,W.Rejected{_}): world
    case (world,W.Accepted{}): clear_observed_join(~S,~C,~R,~E,~record,handle,W.with_store(~S,~C,~R,~E,~List<&2,E>,(store => clear(store,handle)),world))

def despawn_valid_observed(~S: Data,~C: Type,~R: Type,~E: Data,~clear: C -> W.Handle<S> -> C & List<&2,E>,~record: W.Handle<S> -> E,checked: W.World<S,C,R,E> & Bool,+handle: W.Handle<S>) -> W.World<S,C,R,E>:
  match checked:
    case (world,False{}): world
    case (world,True{}): clear_observed_accepted(~S,~C,~R,~E,~clear,~record,W.deactivate(~S,~C,~R,~E,world,handle),handle)

# Apply checked live-entity cleanup, publishing its component removal records
# followed by the entity record only after accepted deactivation. Invalid handles
# leave World unchanged and skip cleanup/publication.
def despawn_apply_observed(~S: Data,~C: Type,~R: Type,~E: Data,~clear: C -> W.Handle<S> -> C & List<&2,E>,~record: W.Handle<S> -> E,world: W.World<S,C,R,E>,+handle: W.Handle<S>) -> W.World<S,C,R,E>:
  despawn_valid_observed(~S,~C,~R,~E,~clear,~record,W.valid(~S,~C,~R,~E,world,handle),handle)

def despawn_checked_observed(~S: Data,~C: Type,~R: Type,~E: Data,~clear: C -> W.Handle<S> -> C & List<&2,E>,~record: W.Handle<S> -> E,allowed: Bool,world: W.World<S,C,R,E>,undo: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<Deferred.Command<W.World<S,C,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,+handle: W.Handle<S>) -> T.Tx<W.World<S,C,R,E>,E> & W.Status:
  match allowed:
    case False{}: (T.Tx{world,undo,commands,events,trace},W.Rejected{W.MissingEntity{}})
    case True{}: (T.Tx{world,undo,Deferred.Raw{(w => despawn_apply_observed(~S,~C,~R,~E,~clear,~record,w,handle))} <> commands,events,trace},W.Accepted{})

def despawn_join_observed(~S: Data,~C: Type,~R: Type,~E: Data,~clear: C -> W.Handle<S> -> C & List<&2,E>,~record: W.Handle<S> -> E,checked: W.World<S,C,R,E> & Bool,undo: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<Deferred.Command<W.World<S,C,R,E>>>,events: List<&2,E>,trace:TraceFacts.State,+handle: W.Handle<S>) -> T.Tx<W.World<S,C,R,E>,E> & W.Status:
  (world,allowed) = checked
  despawn_checked_observed(~S,~C,~R,~E,~clear,~record,allowed,world,undo,commands,events,trace,handle)

# Stage cleanup plus typed lifecycle publication for a command-valid handle.
# Queue admission returns Tx and Status; barrier application rechecks live validity
# before consuming payloads and publishing records. These Data records do not own
# the removed Type payloads or imply automatic recovery.
def tx_despawn_observed(~S: Data,~C: Type,~R: Type,~E: Data,~clear: C -> W.Handle<S> -> C & List<&2,E>,~record: W.Handle<S> -> E,tx: T.Tx<W.World<S,C,R,E>,E>,+handle: W.Handle<S>) -> T.Tx<W.World<S,C,R,E>,E> & W.Status:
  match tx:
    case T.Tx{world,undo,commands,events,trace}: despawn_join_observed(~S,~C,~R,~E,~clear,~record,W.command_valid(~S,~C,~R,~E,world,handle),undo,commands,events,trace,handle)
