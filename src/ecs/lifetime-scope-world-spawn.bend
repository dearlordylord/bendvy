import Base
import ./deferred-command.bend as Deferred
import ./trace-facts.bend as TraceFacts
import ./commands.bend as Cmd
import ./lifetime-scope.bend as Sc
import ./world.bend as W
import ./transaction.bend as T
import ./relation-commands.bend as A

# Ordinary population receives the same full World context as Cmd.tx_spawn.
# Membership is assigned only after successful activation and population.
def assigned(~S:Data,~C:Type,~R:Type,~E:Data,seen:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> & Unit) -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>:
  match seen:
    case (world,_):world
def assign(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,handle:W.Handle<S>,name:String) -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>:
  match handle:
    case W.Handle{_,id}:assigned(~S,~C,~R,~E,W.with_store(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,~Unit,store => Sc.assigned(~S,~C,store,name,id),world))
def activated(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.Handle<S> -> P -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,seen:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> & W.Status,+handle:W.Handle<S>,payload:P,name:String) -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>:
  match seen:
    case (world,W.Accepted{}):assign(~S,~C,~R,~E,populate(world,handle,payload),handle,name)
    case (world,W.Rejected{_}):world
def apply(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.Handle<S> -> P -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,world:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,+handle:W.Handle<S>,payload:P,name:String) -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>:
  activated(~S,~C,~R,~E,~P,~populate,W.activate(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,world,handle),handle,payload,name)
def reserved(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.Handle<S> -> P -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,seen:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> & W.Reservation<S>,undo:List<(W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>)>,commands:List<Deferred.Command<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>>>,events:List<&2,A.Notice<S,E>>,trace:TraceFacts.State,payload:P,name:String) -> T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & Sc.SpawnResult<S,P>:
  match seen:
    case (world,W.ReservationRejected{error}):(T.Tx{world,undo,commands,events,trace},Sc.SpawnRejected{payload,error})
    case (world,W.Reserved{+handle}):(Cmd.track_pending(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,T.Tx{world,undo,Deferred.Raw{(world => apply(~S,~C,~R,~E,~P,~populate,world,handle,payload,name))} <> commands,events,trace},handle),Sc.Spawned{handle})
def checked(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.Handle<S> -> P -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,same:Bool,world:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,undo:List<(W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>)>,commands:List<Deferred.Command<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>>>,events:List<&2,A.Notice<S,E>>,trace:TraceFacts.State,payload:P,name:String) -> T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & Sc.SpawnResult<S,P>:
  match same:
    case False{}:(T.Tx{world,undo,commands,events,trace},Sc.SpawnRejected{payload,W.MissingEntity{}})
    case True{}:reserved(~S,~C,~R,~E,~P,~populate,W.reserve_id(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,world),undo,commands,events,trace,payload,name)
def namespaced(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.Handle<S> -> P -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,seen:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> & U32,scope:Sc.Scope<S>,undo:List<(W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>)>,commands:List<Deferred.Command<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>>>,events:List<&2,A.Notice<S,E>>,trace:TraceFacts.State,payload:P) -> T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & Sc.SpawnResult<S,P>:
  match seen scope:
    case (world,current) Sc.Scope{namespace,name}:checked(~S,~C,~R,~E,~P,~populate,U32.is_eq(current,namespace),world,undo,commands,events,trace,payload,name)
def tx_spawn_in(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.Handle<S> -> P -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,tx:T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>>,scope:Sc.Scope<S>,payload:P) -> T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & Sc.SpawnResult<S,P>:
  match tx:
    case T.Tx{world,undo,commands,events,trace}:namespaced(~S,~C,~R,~E,~P,~populate,W.namespace(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,world),scope,undo,commands,events,trace,payload)
