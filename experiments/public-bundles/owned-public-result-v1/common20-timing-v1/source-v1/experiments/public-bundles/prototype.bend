import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/commands.bend as Cmd
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/transaction.bend as T

# Arbitrarily nested heterogeneous actual Type owners; no fixed family arity.
type Pack<Head:Type,Tail:Type> is Type:
  Pack{head:Head,tail:Tail}
type SpawnResult<S:Data,Store:Type,R:Type,E:Data,P:Type> is Type:
  SpawnQueued{tx:T.Tx<W.World<S,Store,R,E>,E>,handle:W.Handle<S>}
  SpawnRefused{tx:T.Tx<W.World<S,Store,R,E>,E>,payload:P,error:W.WorldError}
def spawn_reserved(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,Store,R,E> -> W.Handle<S> -> P -> W.World<S,Store,R,E>,observed:W.World<S,Store,R,E> & W.Reservation<S>,undo:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,events:List<&2,E>,payload:P) -> SpawnResult<S,Store,R,E,P>:
  match observed:
    case (world,W.ReservationRejected{error}): SpawnRefused{T.Tx{world,undo,commands,events},payload,error}
    case (world,W.Reserved{+handle}): SpawnQueued{T.Tx{world,undo,(w => Cmd.spawn_apply(~S,~Store,~R,~E,~P,~populate,w,handle,payload)) <> commands,events},handle}
def spawn(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,Store,R,E> -> W.Handle<S> -> P -> W.World<S,Store,R,E>,tx:T.Tx<W.World<S,Store,R,E>,E>,payload:P) -> SpawnResult<S,Store,R,E,P>:
  match tx:
    case T.Tx{world,undo,commands,events}: spawn_reserved(~S,~Store,~R,~E,~P,~populate,W.reserve_id(~S,~Store,~R,~E,world),undo,commands,events,payload)

type Delivery<W:Type,P:Type> is Type:
  Delivered{world:W}
  Undelivered{world:W,payload:P,error:W.WorldError}
def deliver(~World:Type,~P:Type,~recover:World -> P -> W.WorldError -> World,result:Delivery<World,P>) -> World:
  match result:
    case Delivered{world}: world
    case Undelivered{world,payload,error}: recover(world,payload,error)
def apply_checked(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~attempt:W.World<S,Store,R,E> -> W.Handle<S> -> P -> Delivery<W.World<S,Store,R,E>,P>,~recover:W.World<S,Store,R,E> -> P -> W.WorldError -> W.World<S,Store,R,E>,observed:W.World<S,Store,R,E> & Bool,handle:W.Handle<S>,payload:P) -> W.World<S,Store,R,E>:
  match observed:
    case (world,False{}): recover(world,payload,W.MissingEntity{})
    case (world,True{}): deliver(~W.World<S,Store,R,E>,~P,~recover,attempt(world,handle,payload))
def apply(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~attempt:W.World<S,Store,R,E> -> W.Handle<S> -> P -> Delivery<W.World<S,Store,R,E>,P>,~recover:W.World<S,Store,R,E> -> P -> W.WorldError -> W.World<S,Store,R,E>,world:W.World<S,Store,R,E>,+handle:W.Handle<S>,payload:P) -> W.World<S,Store,R,E>:
  apply_checked(~S,~Store,~R,~E,~P,~attempt,~recover,W.valid(~S,~Store,~R,~E,world,handle),handle,payload)
def enqueue(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~attempt:W.World<S,Store,R,E> -> W.Handle<S> -> P -> Delivery<W.World<S,Store,R,E>,P>,~recover:W.World<S,Store,R,E> -> P -> W.WorldError -> W.World<S,Store,R,E>,tx:T.Tx<W.World<S,Store,R,E>,E>,+handle:W.Handle<S>,payload:P) -> T.Tx<W.World<S,Store,R,E>,E>:
  T.stage(~W.World<S,Store,R,E>,~E,tx,w => apply(~S,~Store,~R,~E,~P,~attempt,~recover,w,handle,payload))
