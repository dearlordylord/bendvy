import Base
import /workspace/formal-proofs/bendvy-worktrees/identity38-native-authority/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy-worktrees/identity38-native-authority/src/ecs/commands.bend as Cmd
import /workspace/formal-proofs/bendvy-worktrees/identity38-native-authority/src/ecs/transaction.bend as T

type State is Data:
  Pending{}
  Live{}
  Retired{}
type Entry<S:Data> is Data:
  Entry{handle:W.Handle<S>,state:State}
type Change<S:Data> is Data:
  Activate{handle:W.Handle<S>}
  Retire{handle:W.Handle<S>}
type Owner<S:Data,C:Type,R:Type,E:Data> is Type:
  Owner{world:W.World<S,C,R,E>,states:List<&2,Entry<S>>,changes:List<&2,Change<S>>}
type Tx<S:Data,C:Type,R:Type,E:Data> is Type:
  Tx{tx:T.Tx<W.World<S,C,R,E>,E>,states:List<&2,Entry<S>>,before:List<&2,Change<S>>,changes:List<&2,Change<S>>,reserved:List<&2,W.Handle<S>>}
def same(~S:Data,a:W.Handle<S>,b:W.Handle<S>) -> Bool:
  match a b:
    case W.Handle{ans,aid} W.Handle{bns,bid}: Bool.and(U32.is_eq(ans,bns),U32.is_eq(aid,bid))
def allowed(state:State) -> Bool:
  match state:
    case Pending{}: True{}
    case Live{}: True{}
    case Retired{}: False{}
def find(~S:Data,+handle:W.Handle<S>,items:List<&2,Entry<S>>) -> Bool:
  match items:
    case []: False{}
    case Entry{candidate,state} <> rest: Bool.or(Bool.and(same(~S,handle,candidate),allowed(state)),find(~S,handle,rest))
def retain_entry(~S:Data,equal:Bool,entry:Entry<S>,rest:List<&2,Entry<S>>) -> List<&2,Entry<S>>:
  match equal:
    case True{}: rest
    case False{}: entry <> rest
def remove(~S:Data,+handle:W.Handle<S>,items:List<&2,Entry<S>>) -> List<&2,Entry<S>>:
  match items:
    case []: []
    case +entry <> rest:
      match entry:
        case Entry{candidate,_}: retain_entry(~S,same(~S,handle,candidate),entry,remove(~S,handle,rest))
def set(~S:Data,+handle:W.Handle<S>,state:State,items:List<&2,Entry<S>>) -> List<&2,Entry<S>>:
  Entry{handle,state} <> remove(~S,handle,items)
def retire(~S:Data,handles:List<&2,W.Handle<S>>,states:List<&2,Entry<S>>) -> List<&2,Entry<S>>:
  match handles:
    case []: states
    case handle <> rest: retire(~S,rest,set(~S,handle,Retired{},states))
def apply(~S:Data,changes:List<&2,Change<S>>,states:List<&2,Entry<S>>) -> List<&2,Entry<S>>:
  match changes:
    case []: states
    case Activate{handle} <> rest: apply(~S,rest,set(~S,handle,Live{},states))
    case Retire{handle} <> rest: apply(~S,rest,set(~S,handle,Retired{},states))
def begin(~S:Data,~C:Type,~R:Type,~E:Data,owner:Owner<S,C,R,E>) -> Tx<S,C,R,E>:
  match owner:
    case Owner{world,states,before}: Tx{T.begin(~W.World<S,C,R,E>,~E,world),states,before,[],[]}
def spawned(~S:Data,~C:Type,~R:Type,~E:Data,states:List<&2,Entry<S>>,before:List<&2,Change<S>>,changes:List<&2,Change<S>>,reserved:List<&2,W.Handle<S>>,result:T.Tx<W.World<S,C,R,E>,E> & W.Reservation<S>) -> Tx<S,C,R,E> & W.Reservation<S>:
  match result:
    case (tx,W.Reserved{+handle}): (Tx{tx,set(~S,handle,Pending{},states),before,Activate{handle} <> changes,handle <> reserved},W.Reserved{handle})
    case (tx,W.ReservationRejected{error}): (Tx{tx,states,before,changes,reserved},W.ReservationRejected{error})
def spawn(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,C,R,E> -> W.Handle<S> -> P -> W.World<S,C,R,E>,tx:Tx<S,C,R,E>,payload:P) -> Tx<S,C,R,E> & W.Reservation<S>:
  match tx:
    case Tx{tx,states,before,changes,reserved}: spawned(~S,~C,~R,~E,states,before,changes,reserved,Cmd.tx_spawn(~S,~C,~R,~E,~P,~populate,tx,payload))
def despawned(~S:Data,~C:Type,~R:Type,~E:Data,+handle:W.Handle<S>,states:List<&2,Entry<S>>,before:List<&2,Change<S>>,changes:List<&2,Change<S>>,reserved:List<&2,W.Handle<S>>,result:T.Tx<W.World<S,C,R,E>,E> & W.Status) -> Tx<S,C,R,E> & W.Status:
  match result:
    case (tx,W.Accepted{}): (Tx{tx,states,before,Retire{handle} <> changes,reserved},W.Accepted{})
    case (tx,W.Rejected{error}): (Tx{tx,states,before,changes,reserved},W.Rejected{error})
def checked(~S:Data,~C:Type,~R:Type,~E:Data,+handle:W.Handle<S>,+states:List<&2,Entry<S>>,before:List<&2,Change<S>>,changes:List<&2,Change<S>>,reserved:List<&2,W.Handle<S>>,undo:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,events:List<&2,E>,result:W.World<S,C,R,E> & Bool) -> Tx<S,C,R,E> & W.Status:
  (world,metadata)=result
  despawned(~S,~C,~R,~E,handle,states,before,changes,reserved,Cmd.despawn_checked(~S,~C,~R,~E,Bool.and(metadata,find(~S,handle,states)),world,undo,commands,events,handle))
def despawn(~S:Data,~C:Type,~R:Type,~E:Data,+handle:W.Handle<S>,tx:Tx<S,C,R,E>) -> Tx<S,C,R,E> & W.Status:
  match tx:
    case Tx{T.Tx{world,undo,commands,events},states,before,changes,reserved}: checked(~S,~C,~R,~E,handle,states,before,changes,reserved,undo,commands,events,W.metadata_valid(~S,~C,~R,~E,world,handle))
def finished(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,states:List<&2,Entry<S>>,before:List<&2,Change<S>>,changes:List<&2,Change<S>>,reserved:List<&2,W.Handle<S>>,result:T.Returned<W.World<S,C,R,E>,Error>) -> Owner<S,C,R,E> & T.Outcome<Error>:
  match result:
    case T.Returned{world,T.Success{}}: (Owner{world,states,List.append(&2,Change<S>,before,List.reverse(&2,Change<S>,changes))},T.Success{})
    case T.Returned{world,T.Failure{error}}: (Owner{world,retire(~S,reserved,states),before},T.Failure{error})
def finish(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,tx:Tx<S,C,R,E>,outcome:T.Outcome<Error>) -> Owner<S,C,R,E> & T.Outcome<Error>:
  match tx:
    case Tx{tx,states,before,changes,reserved}: finished(~S,~C,~R,~E,~Error,states,before,changes,reserved,Cmd.tx_finish(~S,~C,~R,~E,~Error,tx,outcome))
def barrier(~S:Data,~C:Type,~R:Type,~E:Data,owner:Owner<S,C,R,E>) -> Owner<S,C,R,E>:
  match owner:
    case Owner{world,states,changes}: Owner{W.barrier(~S,~C,~R,~E,world),apply(~S,changes,states),[]}

# Typed gameplay cleanup and removal publication; actual closure remains owned
# by the original Cmd transaction/barrier, not by a Data projection.
def checked_observed(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,E>,~record:W.Handle<S> -> E,+handle:W.Handle<S>,+states:List<&2,Entry<S>>,before:List<&2,Change<S>>,changes:List<&2,Change<S>>,reserved:List<&2,W.Handle<S>>,undo:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,events:List<&2,E>,result:W.World<S,C,R,E> & Bool) -> Tx<S,C,R,E> & W.Status:
  (world,metadata)=result
  despawned(~S,~C,~R,~E,handle,states,before,changes,reserved,Cmd.despawn_checked_observed(~S,~C,~R,~E,~clear,~record,Bool.and(metadata,find(~S,handle,states)),world,undo,commands,events,handle))
def despawn_observed(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,E>,~record:W.Handle<S> -> E,+handle:W.Handle<S>,tx:Tx<S,C,R,E>) -> Tx<S,C,R,E> & W.Status:
  match tx:
    case Tx{T.Tx{world,undo,commands,events},states,before,changes,reserved}: checked_observed(~S,~C,~R,~E,~clear,~record,handle,states,before,changes,reserved,undo,commands,events,W.metadata_valid(~S,~C,~R,~E,world,handle))
