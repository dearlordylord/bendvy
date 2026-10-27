import Base
import ./lifetime-scope.bend as Sc
import ./deferred-command.bend as Deferred
import ./trace-facts.bend as TraceFacts
import ./entity-key.bend as Key
import ./world.bend as W
import ./transaction.bend as T
import ./commands.bend as Cmd
import ./relation-commands.bend as A
import ./relation-types.bend as G
import ./relation-cleanup.bend as Cleanup

# Historical transaction operations over the canonical pure scope metadata.
# Ordinary execution resources import lifetime-scope.bend without this module.
def assigned(~S:Data,~C:Type,store:A.Store<S,Sc.Store<S,C>>,name:String,+id:Key.Key) -> A.Store<S,Sc.Store<S,C>> & Unit:
  match store:
    case A.Store{Sc.Store{components,members},graph}:(A.Store{Sc.Store{components,List.append(&2,Sc.Member,Sc.without(members,id),[Sc.Member{name,id}])},graph},Unit{})
def observed(~S:Data,~C:Type,store:A.Store<S,Sc.Store<S,C>>,name:String) -> A.Store<S,Sc.Store<S,C>> & List<&2,Key.Key>:
  match store:
    case A.Store{Sc.Store{components,+members},graph}:(A.Store{Sc.Store{components,members},graph},Sc.select(members,name))
def scope_returned(~S:Data,~C:Type,~R:Type,~E:Data,name:String,seen:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> & U32) -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> & Sc.Scope<S>:
  match seen:
    case (world,namespace):(world,Sc.Scope{namespace,name})
def scope(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,name:String) -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> & Sc.Scope<S>:
  scope_returned(~S,~C,~R,~E,name,W.namespace(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,world))
def cleared(~S:Data,~C:Type,~E:Data,members:List<&2,Sc.Member>,seen:C & List<&2,A.Notice<S,E>>) -> Sc.Store<S,C> & List<&2,A.Notice<S,E>>:
  match seen:
    case (components,records):(Sc.Store{components,members},records)
def clear_components(~S:Data,~C:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,store:Sc.Store<S,C>,handle:W.Handle<S>) -> Sc.Store<S,C> & List<&2,A.Notice<S,E>>:
  match store handle:
    case Sc.Store{components,members} W.Handle{+namespace,+id}:cleared(~S,~C,~E,Sc.without(members,id),clear(components,W.Handle{namespace,id}))
def cleanup_result(~S:Data,~C:Type,~R:Type,~E:Data,result:Cleanup.CleanupResult<S,Sc.Store<S,C>,R,E>) -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>:
  match result:
    case Cleanup.Complete{world}:world
    case Cleanup.Incomplete{world,frames}:W.event_publish(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,world,[A.CleanupPaused{frames}])
def cleanup_members(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~descriptors:List<&2,G.Descriptor<S>>,members:List<&2,Key.Key>,world:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,+namespace:U32) -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>:
  match members:
    case []:world
    case id <> rest:cleanup_members(~S,~C,~R,~E,~clear,~record,~descriptors,rest,cleanup_result(~S,~C,~R,~E,Cleanup.automatic(~S,~Sc.Store<S,C>,~R,~E,~clear_components(~S,~C,~E,~clear),~record,world,W.Handle{namespace,id},descriptors)),namespace)
def cleanup_observed(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~descriptors:List<&2,G.Descriptor<S>>,namespace:U32,seen:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> & List<&2,Key.Key>) -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>:
  match seen:
    case (world,members):cleanup_members(~S,~C,~R,~E,~clear,~record,~descriptors,members,world,namespace)
def cleanup_apply(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~descriptors:List<&2,G.Descriptor<S>>,world:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,scope:Sc.Scope<S>) -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>:
  match scope:
    case Sc.Scope{namespace,name}:cleanup_observed(~S,~C,~R,~E,~clear,~record,~descriptors,namespace,W.with_store(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,~List<&2,Key.Key>,store => observed(~S,~C,store,name),world))
def cleanup_checked(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~descriptors:List<&2,G.Descriptor<S>>,same:Bool,tx:T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>>,scope:Sc.Scope<S>) -> T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & A.QueueStatus:
  match same:
    case False{}:(tx,A.MissingEntity{})
    case True{}:(T.stage(~W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,~A.Notice<S,E>,tx,world => cleanup_apply(~S,~C,~R,~E,~clear,~record,~descriptors,world,scope)),A.Queued{})
def cleanup_namespaced(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~descriptors:List<&2,G.Descriptor<S>>,seen:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> & U32,scope:Sc.Scope<S>,undo:List<(W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>)>,commands:List<Deferred.Command<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>>>,events:List<&2,A.Notice<S,E>>,trace:TraceFacts.State) -> T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & A.QueueStatus:
  match seen scope:
    case (world,current) Sc.Scope{+namespace,+name}:cleanup_checked(~S,~C,~R,~E,~clear,~record,~descriptors,U32.is_eq(namespace,current),T.Tx{world,undo,commands,events,trace},Sc.Scope{namespace,name})
def tx_cleanup(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~descriptors:List<&2,G.Descriptor<S>>,tx:T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>>,scope:Sc.Scope<S>) -> T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & A.QueueStatus:
  match tx:
    case T.Tx{world,undo,commands,events,trace}:cleanup_namespaced(~S,~C,~R,~E,~clear,~record,~descriptors,W.namespace(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,world),scope,undo,commands,events,trace)
def populate_store(~S:Data,~C:Type,~P:Type,~populate:C -> W.Handle<S> -> P -> C,store:A.Store<S,Sc.Store<S,C>>,handle:W.Handle<S>,payload:P,name:String) -> A.Store<S,Sc.Store<S,C>> & Unit:
  match store handle:
    case A.Store{Sc.Store{components,members},graph} W.Handle{+ns,+id}:(A.Store{Sc.Store{populate(components,W.Handle{ns,id},payload),List.append(&2,Sc.Member,Sc.without(members,id),[Sc.Member{name,id}])},graph},Unit{})
def populate_returned(~S:Data,~C:Type,~R:Type,~E:Data,seen:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> & Unit) -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>:
  match seen:
    case (world,_):world
def populate_world(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:C -> W.Handle<S> -> P -> C,world:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,+handle:W.Handle<S>,payload:P,name:String) -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>:
  populate_returned(~S,~C,~R,~E,W.with_store(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,~Unit,store => populate_store(~S,~C,~P,~populate,store,handle,payload,name),world))
def spawn_activated(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:C -> W.Handle<S> -> P -> C,seen:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> & W.Status,handle:W.Handle<S>,payload:P,name:String) -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>:
  match seen:
    case (world,W.Accepted{}):populate_world(~S,~C,~R,~E,~P,~populate,world,handle,payload,name)
    case (world,W.Rejected{_}):world
def spawn_apply(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:C -> W.Handle<S> -> P -> C,world:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,+handle:W.Handle<S>,payload:P,name:String) -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>:
  spawn_activated(~S,~C,~R,~E,~P,~populate,W.activate(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,world,handle),handle,payload,name)
def spawn_reserved(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:C -> W.Handle<S> -> P -> C,seen:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> & W.Reservation<S>,undo:List<(W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>)>,commands:List<Deferred.Command<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>>>,events:List<&2,A.Notice<S,E>>,trace:TraceFacts.State,payload:P,name:String) -> T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & Sc.SpawnResult<S,P>:
  match seen:
    case (world,W.ReservationRejected{error}):(T.Tx{world,undo,commands,events,trace},Sc.SpawnRejected{payload,error})
    case (world,W.Reserved{+handle}):(Cmd.track_pending(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,T.Tx{world,undo,Deferred.Raw{(world => spawn_apply(~S,~C,~R,~E,~P,~populate,world,handle,payload,name))} <> commands,events,trace},handle),Sc.Spawned{handle})
def spawn_checked(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:C -> W.Handle<S> -> P -> C,same:Bool,world:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,undo:List<(W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>)>,commands:List<Deferred.Command<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>>>,events:List<&2,A.Notice<S,E>>,trace:TraceFacts.State,payload:P,name:String) -> T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & Sc.SpawnResult<S,P>:
  match same:
    case False{}:(T.Tx{world,undo,commands,events,trace},Sc.SpawnRejected{payload,W.MissingEntity{}})
    case True{}:spawn_reserved(~S,~C,~R,~E,~P,~populate,W.reserve_id(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,world),undo,commands,events,trace,payload,name)
def spawn_namespaced(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:C -> W.Handle<S> -> P -> C,seen:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> & U32,scope:Sc.Scope<S>,undo:List<(W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>)>,commands:List<Deferred.Command<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>>>,events:List<&2,A.Notice<S,E>>,trace:TraceFacts.State,payload:P) -> T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & Sc.SpawnResult<S,P>:
  match seen scope:
    case (world,current) Sc.Scope{namespace,name}:spawn_checked(~S,~C,~R,~E,~P,~populate,U32.is_eq(current,namespace),world,undo,commands,events,trace,payload,name)
def tx_spawn_in(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:C -> W.Handle<S> -> P -> C,tx:T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>>,scope:Sc.Scope<S>,payload:P) -> T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & Sc.SpawnResult<S,P>:
  match tx:
    case T.Tx{world,undo,commands,events,trace}:spawn_namespaced(~S,~C,~R,~E,~P,~populate,W.namespace(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,world),scope,undo,commands,events,trace,payload)
