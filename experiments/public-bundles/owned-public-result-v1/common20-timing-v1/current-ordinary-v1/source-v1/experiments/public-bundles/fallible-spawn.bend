import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/prototype.bend as B

# Recovery owns every refused P. This seam does not choose failed-ID retirement.
type Failure<Error:Data> is Data:
  ActivationFailure{error:W.WorldError}
  PopulationFailure{error:Error}
type Population<World:Type,P:Type,Error:Data> is Type:
  Populated{world:World}
  Unpopulated{world:World,payload:P,error:Error}
def deliver(~World:Type,~S:Data,~P:Type,~Error:Data,~recover:World -> W.Handle<S> -> P -> Failure<Error> -> World,handle:W.Handle<S>,observed:Population<World,P,Error>) -> World:
  match observed:
    case Populated{world}: world
    case Unpopulated{world,payload,error}: recover(world,handle,payload,PopulationFailure{error})
def activated(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~Error:Data,~populate:W.World<S,Store,R,E> -> W.Handle<S> -> P -> Population<W.World<S,Store,R,E>,P,Error>,~recover:W.World<S,Store,R,E> -> W.Handle<S> -> P -> Failure<Error> -> W.World<S,Store,R,E>,observed:W.World<S,Store,R,E> & W.Status,+handle:W.Handle<S>,payload:P) -> W.World<S,Store,R,E>:
  match observed:
    case (world,W.Accepted{}): deliver(~W.World<S,Store,R,E>,~S,~P,~Error,~recover,handle,populate(world,handle,payload))
    case (world,W.Rejected{error}): recover(world,handle,payload,ActivationFailure{error})
def apply(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~Error:Data,~populate:W.World<S,Store,R,E> -> W.Handle<S> -> P -> Population<W.World<S,Store,R,E>,P,Error>,~recover:W.World<S,Store,R,E> -> W.Handle<S> -> P -> Failure<Error> -> W.World<S,Store,R,E>,world:W.World<S,Store,R,E>,+handle:W.Handle<S>,payload:P) -> W.World<S,Store,R,E>:
  activated(~S,~Store,~R,~E,~P,~Error,~populate,~recover,W.activate(~S,~Store,~R,~E,world,handle),handle,payload)
def reserved(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~Error:Data,~populate:W.World<S,Store,R,E> -> W.Handle<S> -> P -> Population<W.World<S,Store,R,E>,P,Error>,~recover:W.World<S,Store,R,E> -> W.Handle<S> -> P -> Failure<Error> -> W.World<S,Store,R,E>,observed:W.World<S,Store,R,E> & W.Reservation<S>,undo:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,events:List<&2,E>,payload:P) -> B.SpawnResult<S,Store,R,E,P>:
  match observed:
    case (world,W.ReservationRejected{error}): B.SpawnRefused{T.Tx{world,undo,commands,events},payload,error}
    case (world,W.Reserved{+handle}): B.SpawnQueued{T.Tx{world,undo,(w => apply(~S,~Store,~R,~E,~P,~Error,~populate,~recover,w,handle,payload)) <> commands,events},handle}
def spawn(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~Error:Data,~populate:W.World<S,Store,R,E> -> W.Handle<S> -> P -> Population<W.World<S,Store,R,E>,P,Error>,~recover:W.World<S,Store,R,E> -> W.Handle<S> -> P -> Failure<Error> -> W.World<S,Store,R,E>,tx:T.Tx<W.World<S,Store,R,E>,E>,payload:P) -> B.SpawnResult<S,Store,R,E,P>:
  match tx:
    case T.Tx{world,undo,commands,events}: reserved(~S,~Store,~R,~E,~P,~Error,~populate,~recover,W.reserve_id(~S,~Store,~R,~E,world),undo,commands,events,payload)
