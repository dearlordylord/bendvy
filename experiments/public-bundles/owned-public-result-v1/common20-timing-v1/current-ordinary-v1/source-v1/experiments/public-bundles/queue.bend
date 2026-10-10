import Base
import /workspace/formal-proofs/bendvy/src/ecs/bundle-delivery.bend as BDelivery
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T

type QueueResult<S:Data,Store:Type,R:Type,E:Data,P:Type> is Type:
  Queued{tx:T.Tx<W.World<S,Store,R,E>,E>}
  Refused{tx:T.Tx<W.World<S,Store,R,E>,E>,payload:P,error:W.WorldError}
def checked(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~attempt:W.World<S,Store,R,E> -> W.Handle<S> -> P -> BDelivery.Delivery<W.World<S,Store,R,E>,P>,~recover:W.World<S,Store,R,E> -> P -> W.WorldError -> W.World<S,Store,R,E>,undo:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,events:List<&2,E>,+handle:W.Handle<S>,payload:P,observed:W.World<S,Store,R,E> & Bool) -> QueueResult<S,Store,R,E,P>:
  match observed:
    case (world,False{}): Refused{T.Tx{world,undo,commands,events},payload,W.MissingEntity{}}
    case (world,True{}): Queued{BDelivery.enqueue(~S,~Store,~R,~E,~P,~attempt,~recover,T.Tx{world,undo,commands,events},handle,payload)}
def enqueue(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~attempt:W.World<S,Store,R,E> -> W.Handle<S> -> P -> BDelivery.Delivery<W.World<S,Store,R,E>,P>,~recover:W.World<S,Store,R,E> -> P -> W.WorldError -> W.World<S,Store,R,E>,tx:T.Tx<W.World<S,Store,R,E>,E>,+handle:W.Handle<S>,payload:P) -> QueueResult<S,Store,R,E,P>:
  match tx:
    case T.Tx{world,undo,commands,events}: checked(~S,~Store,~R,~E,~P,~attempt,~recover,undo,commands,events,handle,payload,W.valid(~S,~Store,~R,~E,world,handle))
