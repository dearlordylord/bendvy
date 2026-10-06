import Base
import ./world.bend as W
import ./transaction.bend as T

# World pending commands are a reverse accumulator; input here is FIFO.
def enqueue_list(~S: Data,~C: Type,~R: Type,~E: Data,commands: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,world: W.World<S,C,R,E>) -> W.World<S,C,R,E>:
  match commands:
    case []: world
    case command <> rest: enqueue_list(~S,~C,~R,~E,rest,W.enqueue(~S,~C,~R,~E,world,command))

def enqueue(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,C,R,E>,commands: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>) -> W.World<S,C,R,E>:
  enqueue_list(~S,~C,~R,~E,commands,world)

def publish(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,C,R,E>,events: List<&2,E>) -> W.World<S,C,R,E>:
  W.event_publish(~S,~C,~R,~E,world,events)

def tx_finish(~S: Data,~C: Type,~R: Type,~E: Data,~Error: Data,tx: T.Tx<W.World<S,C,R,E>,E>,outcome: T.Outcome<Error>) -> T.Returned<W.World<S,C,R,E>,Error>:
  T.finish(~W.World<S,C,R,E>,~E,~Error,~enqueue(~S,~C,~R,~E),~publish(~S,~C,~R,~E),tx,outcome)

def spawned(~S: Data,~C: Type,~R: Type,~E: Data,~P: Type,~populate: W.World<S,C,R,E> -> W.Handle<S> -> P -> W.World<S,C,R,E>,activated: W.World<S,C,R,E> & W.Status,handle: W.Handle<S>,payload: P) -> W.World<S,C,R,E>:
  match activated:
    case (world,W.Accepted{}): populate(world,handle,payload)
    case (world,W.Rejected{_}): world

def spawn_apply(~S: Data,~C: Type,~R: Type,~E: Data,~P: Type,~populate: W.World<S,C,R,E> -> W.Handle<S> -> P -> W.World<S,C,R,E>,world: W.World<S,C,R,E>,+handle: W.Handle<S>,payload: P) -> W.World<S,C,R,E>:
  spawned(~S,~C,~R,~E,~P,~populate,W.activate(~S,~C,~R,~E,world,handle),handle,payload)

def spawn_reserved(~S: Data,~C: Type,~R: Type,~E: Data,~P: Type,~populate: W.World<S,C,R,E> -> W.Handle<S> -> P -> W.World<S,C,R,E>,reservation: W.Reservation<S>,world: W.World<S,C,R,E>,undo: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,events: List<&2,E>,payload: P) -> T.Tx<W.World<S,C,R,E>,E> & W.Reservation<S>:
  match reservation:
    case W.ReservationRejected{error}: (T.Tx{world,undo,commands,events},W.ReservationRejected{error})
    case W.Reserved{+handle}: (T.Tx{world,undo,(w => spawn_apply(~S,~C,~R,~E,~P,~populate,w,handle,payload)) <> commands,events},W.Reserved{handle})

def spawn_join(~S: Data,~C: Type,~R: Type,~E: Data,~P: Type,~populate: W.World<S,C,R,E> -> W.Handle<S> -> P -> W.World<S,C,R,E>,reserved: W.World<S,C,R,E> & W.Reservation<S>,undo: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,events: List<&2,E>,payload: P) -> T.Tx<W.World<S,C,R,E>,E> & W.Reservation<S>:
  (world,reservation) = reserved
  spawn_reserved(~S,~C,~R,~E,~P,~populate,reservation,world,undo,commands,events,payload)

# IDs stay reserved on failure, matching the historical allocator policy.
def tx_spawn(~S: Data,~C: Type,~R: Type,~E: Data,~P: Type,~populate: W.World<S,C,R,E> -> W.Handle<S> -> P -> W.World<S,C,R,E>,tx: T.Tx<W.World<S,C,R,E>,E>,payload: P) -> T.Tx<W.World<S,C,R,E>,E> & W.Reservation<S>:
  match tx:
    case T.Tx{world,undo,commands,events}: spawn_join(~S,~C,~R,~E,~P,~populate,W.reserve_id(~S,~C,~R,~E,world),undo,commands,events,payload)

def deactivate_join(~S: Data,~C: Type,~R: Type,~E: Data,deactivated: W.World<S,C,R,E> & W.Status) -> W.World<S,C,R,E>:
  (world,status) = deactivated
  world

def despawn_apply(~S: Data,~C: Type,~R: Type,~E: Data,world: W.World<S,C,R,E>,handle: W.Handle<S>) -> W.World<S,C,R,E>:
  deactivate_join(~S,~C,~R,~E,W.deactivate(~S,~C,~R,~E,world,handle))

def despawn_checked(~S: Data,~C: Type,~R: Type,~E: Data,allowed: Bool,world: W.World<S,C,R,E>,undo: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,events: List<&2,E>,handle: W.Handle<S>) -> T.Tx<W.World<S,C,R,E>,E> & W.Status:
  match allowed:
    case False{}: (T.Tx{world,undo,commands,events},W.Rejected{W.MissingEntity{}})
    case True{}: (T.Tx{world,undo,(w => despawn_apply(~S,~C,~R,~E,w,handle)) <> commands,events},W.Accepted{})

def despawn_join(~S: Data,~C: Type,~R: Type,~E: Data,checked: W.World<S,C,R,E> & Bool,undo: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,events: List<&2,E>,handle: W.Handle<S>) -> T.Tx<W.World<S,C,R,E>,E> & W.Status:
  (world,allowed) = checked
  despawn_checked(~S,~C,~R,~E,allowed,world,undo,commands,events,handle)

def tx_despawn(~S: Data,~C: Type,~R: Type,~E: Data,tx: T.Tx<W.World<S,C,R,E>,E>,+handle: W.Handle<S>) -> T.Tx<W.World<S,C,R,E>,E> & W.Status:
  match tx:
    case T.Tx{world,undo,commands,events}: despawn_join(~S,~C,~R,~E,W.valid(~S,~C,~R,~E,world,handle),undo,commands,events,handle)
