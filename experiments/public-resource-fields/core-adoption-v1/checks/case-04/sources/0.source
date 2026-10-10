import Base
import bundle-delivery.bend as B
import world.bend as W
import transaction.bend as T
import commands.bend as Cmd

# Prepared payload owners remain typed until successful body completion.
# This insert-only journal introduces no reservation/cancellation policy.
type Prepared<S:Data,P:Type> is Type:
  Prepared{target:W.Handle<S>,payload:P,position:Nat}
  ReservationReceipt{target:W.Handle<S>}
type Batch<S:Data,Store:Type,R:Type,E:Data,P:Type> is Type:
  Batch{tx:T.Tx<W.World<S,Store,R,E>,E>,prepared:List<Prepared<S,P>>}
type Inserted<S:Data,Store:Type,R:Type,E:Data,P:Type> is Type:
  Inserted{batch:Batch<S,Store,R,E,P>}
  Refused{batch:Batch<S,Store,R,E,P>,payload:P,error:W.WorldError}
type Spawned<S:Data,Store:Type,R:Type,E:Data,P:Type> is Type:
  Spawned{batch:Batch<S,Store,R,E,P>,target:W.Handle<S>}
  SpawnRefused{batch:Batch<S,Store,R,E,P>,payload:P,error:W.WorldError}
type Finished<S:Data,Store:Type,R:Type,E:Data,P:Type,Error:Data> is Type:
  Committed{world:W.World<S,Store,R,E>}
  Failed{world:W.World<S,Store,R,E>,payloads:List<P>,error:Error}
def begin(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,tx:T.Tx<W.World<S,Store,R,E>,E>) -> Batch<S,Store,R,E,P>:
  Batch{tx,[]}
# Count returns the very same affine closures in the same reverse queue order.
def counted(~World:Type,command:World -> World,result:List<(World -> World)> & Nat) -> List<(World -> World)> & Nat:
  match result:
    case (commands,count): (command <> commands,1n+count)
def count_commands(~World:Type,commands:List<(World -> World)>) -> List<(World -> World)> & Nat:
  match commands:
    case []: ([],0n)
    case command <> tail: counted(~World,command,count_commands(~World,tail))
def positioned(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,prepared:List<Prepared<S,P>>,world:W.World<S,Store,R,E>,undo:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,events:List<&2,E>,target:W.Handle<S>,payload:P,result:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)> & Nat) -> Inserted<S,Store,R,E,P>:
  match result:
    case (commands,position): Inserted{Batch{T.Tx{world,undo,commands,events},Prepared{target,payload,position} <> prepared}}
# Receipt rows are created only from this Batch's actual Cmd.tx_spawn result.
# Public gameplay cannot construct the opaque Batch; raw engine constructors
# and provider callbacks remain explicitly trusted setup boundaries.
def receipt_join(~S:Data,~P:Type,entry:Prepared<S,P>,seen:Bool,result:List<Prepared<S,P>> & Bool) -> List<Prepared<S,P>> & Bool:
  match result:
    case (tail,found): (entry <> tail,Bool.or(seen,found))
def receipt_find(~S:Data,~P:Type,prepared:List<Prepared<S,P>>,+target:W.Handle<S>) -> List<Prepared<S,P>> & Bool:
  match prepared:
    case []: ([],False{})
    case Prepared{handle,payload,position} <> tail: receipt_join(~S,~P,Prepared{handle,payload,position},False{},receipt_find(~S,~P,tail,target))
    case ReservationReceipt{W.Handle{+ns,+id}} <> tail:
      match target:
        case W.Handle{+otherNs,+otherId}: receipt_join(~S,~P,ReservationReceipt{W.Handle{ns,id}},Bool.and(U32.is_eq(ns,otherNs),U32.is_eq(id,otherId)),receipt_find(~S,~P,tail,W.Handle{otherNs,otherId}))
def receipt_checked(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,world:W.World<S,Store,R,E>,undo:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,events:List<&2,E>,target:W.Handle<S>,payload:P,result:List<Prepared<S,P>> & Bool) -> Inserted<S,Store,R,E,P>:
  match result:
    case (prepared,False{}): Refused{Batch{T.Tx{world,undo,commands,events},prepared},payload,W.MissingEntity{}}
    case (prepared,True{}): positioned(~S,~Store,~R,~E,~P,prepared,world,undo,events,target,payload,count_commands(~W.World<S,Store,R,E>,commands))
def checked(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,prepared:List<Prepared<S,P>>,undo:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,commands:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,events:List<&2,E>,+target:W.Handle<S>,payload:P,observed:W.World<S,Store,R,E> & Bool) -> Inserted<S,Store,R,E,P>:
  match observed:
    case (world,False{}): receipt_checked(~S,~Store,~R,~E,~P,world,undo,commands,events,target,payload,receipt_find(~S,~P,prepared,target))
    case (world,True{}): positioned(~S,~Store,~R,~E,~P,prepared,world,undo,events,target,payload,count_commands(~W.World<S,Store,R,E>,commands))
def insert(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,batch:Batch<S,Store,R,E,P>,+target:W.Handle<S>,payload:P) -> Inserted<S,Store,R,E,P>:
  match batch:
    case Batch{T.Tx{world,undo,commands,events},prepared}: checked(~S,~Store,~R,~E,~P,prepared,undo,commands,events,target,payload,W.valid(~S,~Store,~R,~E,world,target))
# Replay only closures preceding this authored insertion. Position is generated
# by count_commands, not supplied by gameplay; raw constructors remain trusted.
def preceding(~World:Type,~E:Data,count:Nat,commands:List<(World -> World)>,tx:T.Tx<World,E>) -> List<(World -> World)> & T.Tx<World,E>:
  match count commands:
    case 0n _: (commands,tx)
    case 1n+rest Nil{}: ([],tx)
    case 1n+rest Con{command,tail}: preceding(~World,~E,rest,tail,T.stage(~World,~E,tx,command))
def remaining(~World:Type,~E:Data,commands:List<(World -> World)>,tx:T.Tx<World,E>) -> T.Tx<World,E>:
  match commands:
    case []: tx
    case command <> tail: remaining(~World,~E,tail,T.stage(~World,~E,tx,command))
def staged_after(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~attempt:W.World<S,Store,R,E> -> W.Handle<S> -> P -> B.Delivery<W.World<S,Store,R,E>,P>,~recover:W.World<S,Store,R,E> -> P -> W.WorldError -> W.World<S,Store,R,E>,target:W.Handle<S>,payload:P,next:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)> -> T.Tx<W.World<S,Store,R,E>,E> -> T.Tx<W.World<S,Store,R,E>,E>,result:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)> & T.Tx<W.World<S,Store,R,E>,E>) -> T.Tx<W.World<S,Store,R,E>,E>:
  match result:
    case (after,before): next(after,B.enqueue(~S,~Store,~R,~E,~P,~attempt,~recover,before,target,payload))
def staged(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~attempt:W.World<S,Store,R,E> -> W.Handle<S> -> P -> B.Delivery<W.World<S,Store,R,E>,P>,~recover:W.World<S,Store,R,E> -> P -> W.WorldError -> W.World<S,Store,R,E>,prepared:List<Prepared<S,P>>,commands:List<(W.World<S,Store,R,E> -> W.World<S,Store,R,E>)>,+current:Nat,tx:T.Tx<W.World<S,Store,R,E>,E>) -> T.Tx<W.World<S,Store,R,E>,E>:
  match prepared:
    case []: remaining(~W.World<S,Store,R,E>,~E,commands,tx)
    case ReservationReceipt{target} <> tail: staged(~S,~Store,~R,~E,~P,~attempt,~recover,tail,commands,current,tx)
    case Prepared{+target,payload,+position} <> tail:
      staged_after(~S,~Store,~R,~E,~P,~attempt,~recover,target,payload,after => before => staged(~S,~Store,~R,~E,~P,~attempt,~recover,tail,after,position,before),preceding(~W.World<S,Store,R,E>,~E,Nat.sub(position,current),commands,tx))
def stage(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~attempt:W.World<S,Store,R,E> -> W.Handle<S> -> P -> B.Delivery<W.World<S,Store,R,E>,P>,~recover:W.World<S,Store,R,E> -> P -> W.WorldError -> W.World<S,Store,R,E>,prepared:List<Prepared<S,P>>,tx:T.Tx<W.World<S,Store,R,E>,E>) -> T.Tx<W.World<S,Store,R,E>,E>:
  match tx:
    case T.Tx{world,undo,commands,events}: staged(~S,~Store,~R,~E,~P,~attempt,~recover,prepared,List.reverse(&1,(W.World<S,Store,R,E> -> W.World<S,Store,R,E>),commands),0n,T.Tx{world,undo,[],events})
def originals(~S:Data,~P:Type,prepared:List<Prepared<S,P>>) -> List<P>:
  match prepared:
    case []: []
    case ReservationReceipt{target} <> tail: originals(~S,~P,tail)
    case Prepared{target,payload,position} <> tail: payload <> originals(~S,~P,tail)
def committed(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~Error:Data,observed:T.Returned<W.World<S,Store,R,E>,Error>) -> Finished<S,Store,R,E,P,Error>:
  match observed:
    case T.Returned{world,outcome}: Committed{world}
def failed(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~Error:Data,payloads:List<P>,error:Error,observed:T.Returned<W.World<S,Store,R,E>,Error>) -> Finished<S,Store,R,E,P,Error>:
  match observed:
    case T.Returned{world,outcome}: Failed{world,payloads,error}
def finish(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,~Error:Data,~attempt:W.World<S,Store,R,E> -> W.Handle<S> -> P -> B.Delivery<W.World<S,Store,R,E>,P>,~recover:W.World<S,Store,R,E> -> P -> W.WorldError -> W.World<S,Store,R,E>,batch:Batch<S,Store,R,E,P>,outcome:T.Outcome<Error>) -> Finished<S,Store,R,E,P,Error>:
  match batch outcome:
    case Batch{tx,prepared} T.Success{}: committed(~S,~Store,~R,~E,~P,~Error,Cmd.tx_finish(~S,~Store,~R,~E,~Error,stage(~S,~Store,~R,~E,~P,~attempt,~recover,List.reverse(&1,Prepared<S,P>,prepared),tx),T.Success{}))
    case Batch{tx,prepared} T.Failure{+error}: failed(~S,~Store,~R,~E,~P,~Error,originals(~S,~P,List.reverse(&1,Prepared<S,P>,prepared)),error,Cmd.tx_finish(~S,~Store,~R,~E,~Error,tx,T.Failure{error}))

def empty_population(~S:Data,~Store:Type,~R:Type,~E:Data,world:W.World<S,Store,R,E>,handle:W.Handle<S>,unit:Unit) -> W.World<S,Store,R,E>:
  world
def spawn_positioned(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,target:W.Handle<S>,result:Inserted<S,Store,R,E,P>) -> Spawned<S,Store,R,E,P>:
  match result:
    case Inserted{batch}: Spawned{batch,target}
    case Refused{batch,payload,error}: SpawnRefused{batch,payload,error}
def spawn_reserved(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,prepared:List<Prepared<S,P>>,payload:P,result:T.Tx<W.World<S,Store,R,E>,E> & W.Reservation<S>) -> Spawned<S,Store,R,E,P>:
  match result:
    case (T.Tx{world,undo,commands,events},W.Reserved{+target}): spawn_positioned(~S,~Store,~R,~E,~P,target,positioned(~S,~Store,~R,~E,~P,ReservationReceipt{target} <> prepared,world,undo,events,target,payload,count_commands(~W.World<S,Store,R,E>,commands)))
    case (tx,W.ReservationRejected{error}): SpawnRefused{Batch{tx,prepared},payload,error}
def spawn(~S:Data,~Store:Type,~R:Type,~E:Data,~P:Type,batch:Batch<S,Store,R,E,P>,payload:P) -> Spawned<S,Store,R,E,P>:
  match batch:
    case Batch{tx,prepared}: spawn_reserved(~S,~Store,~R,~E,~P,prepared,payload,Cmd.tx_spawn(~S,~Store,~R,~E,~Unit,~(world => handle => unit => world),tx,Unit{}))
