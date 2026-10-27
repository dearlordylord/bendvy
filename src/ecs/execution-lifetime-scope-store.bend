import Base
import ./lifetime-scope.bend as Scope
import ./world.bend as W
import ./entity-allocator.bend as Allocator
import ./entity-key.bend as Key

# Canonical resource ownership is separate from component owners and liveness.
# Bevy ad678262ce53b5d142fe49ee5e08caff6f00ab60 state_scoped.rs queues
# despawns on state exit. Named namespace-bound scopes are Bend metadata.
type Store<-S:Data> is Type:
  Store{namespace:U32,members:List<&2,Scope.Member>}
type View<-S:Data> is Data:
  View{namespace:U32,members:List<&2,Scope.Member>}
type Refusal is Data:
  NamespaceMismatch{}
  MissingEntity{}
type Assignment<-S:Data> is Data:
  Assigned{scope:Scope.Scope<S>,handle:W.Handle<S>}
  AssignmentRefused{scope:Scope.Scope<S>,handle:W.Handle<S>,reason:Refusal}
def fresh(~S:Data,namespace:U32) -> Store<S>:
  Store{namespace,[]}
def project(~S:Data,store:Store<S>) -> Store<S> & View<S>:
  match store:
    case Store{+namespace,+members}:(Store{namespace,members},View{namespace,members})
def assigned(~S:Data,scope:Scope.Scope<S>,handle:W.Handle<S>,namespace:U32,members:List<&2,Scope.Member>,result:Allocator.Allocator & Bool) -> Allocator.Allocator & (Store<S> & Assignment<S>):
  match scope handle result:
    case scope handle, (allocator,False{}):(allocator,(Store{namespace,members},AssignmentRefused{scope,handle,MissingEntity{}}))
    case Scope.Scope{+scopeNamespace,+name} W.Handle{+handleNamespace,+key}, (allocator,True{}):(allocator,(Store{namespace,List.append(&2,Scope.Member,Scope.without(members,key),[Scope.Member{name,key}])},Assigned{Scope.Scope{scopeNamespace,name},W.Handle{handleNamespace,key}}))
def assign_checked(~S:Data,allowed:Bool,allocator:Allocator.Allocator,store:Store<S>,scope:Scope.Scope<S>,handle:W.Handle<S>) -> Allocator.Allocator & (Store<S> & Assignment<S>):
  match allowed store handle:
    case False{} store handle:(allocator,(store,AssignmentRefused{scope,handle,NamespaceMismatch{}}))
    case True{} Store{namespace,members} W.Handle{+handleNamespace,+key}:assigned(~S,scope,W.Handle{handleNamespace,key},namespace,members,Allocator.checked(allocator,key,1))
def assign(~S:Data,+actual:U32,allocator:Allocator.Allocator,store:Store<S>,scope:Scope.Scope<S>,handle:W.Handle<S>) -> Allocator.Allocator & (Store<S> & Assignment<S>):
  match store scope handle:
    case Store{+namespace,members} Scope.Scope{+scopeNamespace,+name} W.Handle{+handleNamespace,+key}:assign_checked(~S,Bool.and(U32.is_eq(actual,namespace),Bool.and(U32.is_eq(actual,scopeNamespace),U32.is_eq(actual,handleNamespace))),allocator,Store{namespace,members},Scope.Scope{scopeNamespace,name},W.Handle{handleNamespace,key})
type Snapshot<-S:Data> is Data:
  Selected{scope:Scope.Scope<S>,members:List<&2,Key.Key>}
  SnapshotRefused{scope:Scope.Scope<S>}
def snapshot_checked(~S:Data,allowed:Bool,store:Store<S>,scope:Scope.Scope<S>) -> Store<S> & Snapshot<S>:
  match allowed store scope:
    case False{} store scope:(store,SnapshotRefused{scope})
    case True{} Store{namespace,+members} Scope.Scope{+scopeNamespace,+name}:(Store{namespace,members},Selected{Scope.Scope{scopeNamespace,name},Scope.select(members,name)})
def snapshot(~S:Data,+actual:U32,store:Store<S>,scope:Scope.Scope<S>) -> Store<S> & Snapshot<S>:
  match store scope:
    case Store{+namespace,members} Scope.Scope{+scopeNamespace,+name}:snapshot_checked(~S,Bool.and(U32.is_eq(actual,namespace),U32.is_eq(actual,scopeNamespace)),Store{namespace,members},Scope.Scope{scopeNamespace,name})
# Called only after canonical despawn succeeds, using the complete generation key.
def removed(~S:Data,store:Store<S>,key:Key.Key) -> Store<S>:
  match store:
    case Store{namespace,members}:Store{namespace,Scope.without(members,key)}
