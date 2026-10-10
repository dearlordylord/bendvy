import Base
import world.bend as W
import transaction.bend as T

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
