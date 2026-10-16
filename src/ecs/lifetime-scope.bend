import Base
import ./world.bend as W
import ./transaction.bend as T
import ./commands.bend as Cmd
import ./relation-commands.bend as A
import ./relation-types.bend as G
import ./relation-cleanup.bend as Cleanup
import ./string-equality.bend as Text

# Lifetime metadata is separate from component owners and never proves liveness.
type Scope<-S:Data> is Data:
  Scope{namespace:U32,name:String}
type Member is Data:
  Member{name:String,id:U32}
type Store<-S:Data,C:Type> is Type:
  Store{components:C,members:List<&2,Member>}
def empty(~S:Data,~C:Type,components:C) -> Store<S,C>:
  Store{components,[]}
def without(members:List<&2,Member>,+id:U32) -> List<&2,Member>:
  match members:
    case []:[]
    case Member{+name,+mid} <> rest:
      +remaining = without(rest,id)
      Bool.pick(List<&2,Member>,U32.is_eq(mid,id),remaining,Member{name,mid} <> remaining)
def select(members:List<&2,Member>,+name:String) -> List<&2,U32>:
  match members:
    case []:[]
    case Member{+key,+id} <> rest:
      +remaining = select(rest,name)
      Bool.pick(List<&2,U32>,Text.equal(key,name),id <> remaining,remaining)
def assigned(~S:Data,~C:Type,store:A.Store<S,Store<S,C>>,name:String,+id:U32) -> A.Store<S,Store<S,C>> & Unit:
  match store:
    case A.Store{Store{components,members},graph}:(A.Store{Store{components,List.append(&2,Member,without(members,id),[Member{name,id}])},graph},Unit{})
def observed(~S:Data,~C:Type,store:A.Store<S,Store<S,C>>,name:String) -> A.Store<S,Store<S,C>> & List<&2,U32>:
  match store:
    case A.Store{Store{components,+members},graph}:(A.Store{Store{components,members},graph},select(members,name))
def scope_returned(~S:Data,~C:Type,~R:Type,~E:Data,name:String,seen:W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>> & U32) -> W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>> & Scope<S>:
  match seen:
    case (world,namespace):(world,Scope{namespace,name})
def scope(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>,name:String) -> W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>> & Scope<S>:
  scope_returned(~S,~C,~R,~E,name,W.namespace(~S,~A.Store<S,Store<S,C>>,~R,~A.Notice<S,E>,world))
def cleared(~S:Data,~C:Type,~E:Data,members:List<&2,Member>,seen:C & List<&2,A.Notice<S,E>>) -> Store<S,C> & List<&2,A.Notice<S,E>>:
  match seen:
    case (components,records):(Store{components,members},records)
def clear_components(~S:Data,~C:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,store:Store<S,C>,handle:W.Handle<S>) -> Store<S,C> & List<&2,A.Notice<S,E>>:
  match store handle:
    case Store{components,members} W.Handle{+namespace,+id}:cleared(~S,~C,~E,without(members,id),clear(components,W.Handle{namespace,id}))
def cleanup_result(~S:Data,~C:Type,~R:Type,~E:Data,result:Cleanup.CleanupResult<S,Store<S,C>,R,E>) -> W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>:
  match result:
    case Cleanup.Complete{world}:world
    case Cleanup.Incomplete{world,frames}:W.event_publish(~S,~A.Store<S,Store<S,C>>,~R,~A.Notice<S,E>,world,[A.CleanupPaused{frames}])
def cleanup_members(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~descriptors:List<&2,G.Descriptor<S>>,members:List<&2,U32>,world:W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>,+namespace:U32) -> W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>:
  match members:
    case []:world
    case id <> rest:cleanup_members(~S,~C,~R,~E,~clear,~record,~descriptors,rest,cleanup_result(~S,~C,~R,~E,Cleanup.automatic(~S,~Store<S,C>,~R,~E,~clear_components(~S,~C,~E,~clear),~record,world,W.Handle{namespace,id},descriptors)),namespace)
def cleanup_observed(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~descriptors:List<&2,G.Descriptor<S>>,namespace:U32,seen:W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>> & List<&2,U32>) -> W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>:
  match seen:
    case (world,members):cleanup_members(~S,~C,~R,~E,~clear,~record,~descriptors,members,world,namespace)
def cleanup_apply(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~descriptors:List<&2,G.Descriptor<S>>,world:W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>,scope:Scope<S>) -> W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>:
  match scope:
    case Scope{namespace,name}:cleanup_observed(~S,~C,~R,~E,~clear,~record,~descriptors,namespace,W.with_store(~S,~A.Store<S,Store<S,C>>,~R,~A.Notice<S,E>,~List<&2,U32>,store => observed(~S,~C,store,name),world))
def cleanup_checked(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~descriptors:List<&2,G.Descriptor<S>>,same:Bool,tx:T.Tx<W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>>,scope:Scope<S>) -> T.Tx<W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & A.QueueStatus:
  match same:
    case False{}:(tx,A.MissingEntity{})
    case True{}:(T.stage(~W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>,~A.Notice<S,E>,tx,world => cleanup_apply(~S,~C,~R,~E,~clear,~record,~descriptors,world,scope)),A.Queued{})
def cleanup_namespaced(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~descriptors:List<&2,G.Descriptor<S>>,seen:W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>> & U32,scope:Scope<S>,undo:List<(W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>)>,commands:List<(W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>)>,events:List<&2,A.Notice<S,E>>) -> T.Tx<W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & A.QueueStatus:
  match seen scope:
    case (world,current) Scope{+namespace,+name}:cleanup_checked(~S,~C,~R,~E,~clear,~record,~descriptors,U32.is_eq(namespace,current),T.Tx{world,undo,commands,events},Scope{namespace,name})
def tx_cleanup(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~descriptors:List<&2,G.Descriptor<S>>,tx:T.Tx<W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>>,scope:Scope<S>) -> T.Tx<W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & A.QueueStatus:
  match tx:
    case T.Tx{world,undo,commands,events}:cleanup_namespaced(~S,~C,~R,~E,~clear,~record,~descriptors,W.namespace(~S,~A.Store<S,Store<S,C>>,~R,~A.Notice<S,E>,world),scope,undo,commands,events)
type SpawnResult<S:Data,P:Type> is Type:
  Spawned{handle:W.Handle<S>}
  SpawnRejected{payload:P,error:W.WorldError}
def populate_store(~S:Data,~C:Type,~P:Type,~populate:C -> W.Handle<S> -> P -> C,store:A.Store<S,Store<S,C>>,handle:W.Handle<S>,payload:P,name:String) -> A.Store<S,Store<S,C>> & Unit:
  match store handle:
    case A.Store{Store{components,members},graph} W.Handle{+ns,+id}:(A.Store{Store{populate(components,W.Handle{ns,id},payload),List.append(&2,Member,without(members,id),[Member{name,id}])},graph},Unit{})
def populate_returned(~S:Data,~C:Type,~R:Type,~E:Data,seen:W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>> & Unit) -> W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>:
  match seen:
    case (world,_):world
def populate_world(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:C -> W.Handle<S> -> P -> C,world:W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>,+handle:W.Handle<S>,payload:P,name:String) -> W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>:
  populate_returned(~S,~C,~R,~E,W.with_store(~S,~A.Store<S,Store<S,C>>,~R,~A.Notice<S,E>,~Unit,store => populate_store(~S,~C,~P,~populate,store,handle,payload,name),world))
def spawn_activated(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:C -> W.Handle<S> -> P -> C,seen:W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>> & W.Status,handle:W.Handle<S>,payload:P,name:String) -> W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>:
  match seen:
    case (world,W.Accepted{}):populate_world(~S,~C,~R,~E,~P,~populate,world,handle,payload,name)
    case (world,W.Rejected{_}):world
def spawn_apply(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:C -> W.Handle<S> -> P -> C,world:W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>,+handle:W.Handle<S>,payload:P,name:String) -> W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>:
  spawn_activated(~S,~C,~R,~E,~P,~populate,W.activate(~S,~A.Store<S,Store<S,C>>,~R,~A.Notice<S,E>,world,handle),handle,payload,name)
def spawn_reserved(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:C -> W.Handle<S> -> P -> C,seen:W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>> & W.Reservation<S>,undo:List<(W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>)>,commands:List<(W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>)>,events:List<&2,A.Notice<S,E>>,payload:P,name:String) -> T.Tx<W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & SpawnResult<S,P>:
  match seen:
    case (world,W.ReservationRejected{error}):(T.Tx{world,undo,commands,events},SpawnRejected{payload,error})
    case (world,W.Reserved{+handle}):(Cmd.track_pending(~S,~A.Store<S,Store<S,C>>,~R,~A.Notice<S,E>,T.Tx{world,undo,(world => spawn_apply(~S,~C,~R,~E,~P,~populate,world,handle,payload,name)) <> commands,events},handle),Spawned{handle})
def spawn_checked(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:C -> W.Handle<S> -> P -> C,same:Bool,world:W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>,undo:List<(W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>)>,commands:List<(W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>)>,events:List<&2,A.Notice<S,E>>,payload:P,name:String) -> T.Tx<W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & SpawnResult<S,P>:
  match same:
    case False{}:(T.Tx{world,undo,commands,events},SpawnRejected{payload,W.MissingEntity{}})
    case True{}:spawn_reserved(~S,~C,~R,~E,~P,~populate,W.reserve_id(~S,~A.Store<S,Store<S,C>>,~R,~A.Notice<S,E>,world),undo,commands,events,payload,name)
def spawn_namespaced(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:C -> W.Handle<S> -> P -> C,seen:W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>> & U32,scope:Scope<S>,undo:List<(W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>)>,commands:List<(W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>)>,events:List<&2,A.Notice<S,E>>,payload:P) -> T.Tx<W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & SpawnResult<S,P>:
  match seen scope:
    case (world,current) Scope{namespace,name}:spawn_checked(~S,~C,~R,~E,~P,~populate,U32.is_eq(current,namespace),world,undo,commands,events,payload,name)
def tx_spawn_in(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:C -> W.Handle<S> -> P -> C,tx:T.Tx<W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>>,scope:Scope<S>,payload:P) -> T.Tx<W.World<S,A.Store<S,Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & SpawnResult<S,P>:
  match tx:
    case T.Tx{world,undo,commands,events}:spawn_namespaced(~S,~C,~R,~E,~P,~populate,W.namespace(~S,~A.Store<S,Store<S,C>>,~R,~A.Notice<S,E>,world),scope,undo,commands,events,payload)
