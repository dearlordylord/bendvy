import Base
import ./transaction.bend as T
import ./bundle-install.bend as Install
import ./world.bend as W
import ./bundle-batch.bend as Batch

# Explicit app-owned reversible receipts live outside the World journal.
# Their generated position preserves ordering with ordinary resource/component
# inverses. Recovered affine owners are returned to the Local adapter, never
# placed into a resource that a subsequent inverse could overwrite.
type Receipt<World:Type,P:Type,Q:Type> is Type:
  Receipt{position:Nat,inverse:World -> Install.Restore<World,P,Q>}
type Pending<Q:Type> is Type:Pending{owner:Q,error:W.WorldError}
type Returned<World:Type,P:Type,Q:Type> is Type:
  Returned{world:World,owners:List<P>,pending:List<Pending<Q>>}

def stepped(~World:Type,count:Nat,world:World,undo:List<(World -> World)>) -> World & List<(World -> World)>:
  match count undo:
    case 0n _:(world,undo)
    case 1n+rest Nil{}:(world,[])
    case 1n+rest Con{inverse,tail}:stepped(~World,rest,inverse(world),tail)

def restored(~World:Type,~P:Type,~Q:Type,next:World -> List<P> -> List<Pending<Q>> -> Returned<World,P,Q>,owners:List<P>,pending:List<Pending<Q>>,result:Install.Restore<World,P,Q>) -> Returned<World,P,Q>:
  match result:
    case Install.Restored{world,owner}:next(world,owner <> owners,pending)
    case Install.Pending{world,owner,error}:next(world,owners,Pending{owner,error} <> pending)

def unwound(~World:Type,~P:Type,~Q:Type,inverse:World -> Install.Restore<World,P,Q>,next:List<(World -> World)> -> World -> List<P> -> List<Pending<Q>> -> Returned<World,P,Q>,owners:List<P>,pending:List<Pending<Q>>,result:World & List<(World -> World)>) -> Returned<World,P,Q>:
  match result:
    case (world,undo):restored(~World,~P,~Q,(world => owners => pending => next(undo,world,owners,pending)),owners,pending,inverse(world))

def rollback(~World:Type,~P:Type,~Q:Type,receipts:List<Receipt<World,P,Q>>,undo:List<(World -> World)>,count:Nat,world:World,owners:List<P>,pending:List<Pending<Q>>) -> Returned<World,P,Q>:
  match receipts:
    case []:Returned{T.rollback(~World,undo,world),List.reverse(&1,P,owners),List.reverse(&1,Pending<Q>,pending)}
    case Receipt{+position,inverse} <> rest:unwound(~World,~P,~Q,inverse,(undo => world => owners => pending => rollback(~World,~P,~Q,rest,undo,position,world,owners,pending)),owners,pending,stepped(~World,Nat.sub(count,position),world,undo))

def counted(~World:Type,~P:Type,~Q:Type,receipts:List<Receipt<World,P,Q>>,world:World,result:List<(World -> World)> & Nat) -> Returned<World,P,Q>:
  match result:
    case (undo,count):rollback(~World,~P,~Q,receipts,undo,count,world,[],[])

def abort(~World:Type,~E:Data,~P:Type,~Q:Type,receipts:List<Receipt<World,P,Q>>,tx:T.Tx<World,E>) -> Returned<World,P,Q>:
  match tx:
    case T.Tx{world,undo,_,_}:counted(~World,~P,~Q,receipts,world,Batch.count_commands(~World,undo))
