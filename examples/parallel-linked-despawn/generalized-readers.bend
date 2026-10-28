import Base
import ./actor.bend as Actor
import ./setup.bend as Setup
import ./generalized-actors.bend as Actors
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-resource-store.bend as Resource
import ../../src/ecs/execution-resource-access.bend as Read
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-lifetime-scope-store.bend as ScopeStore
import ../../src/ecs/execution-relation-failure-selection.bend as Selection
import ../../src/ecs/execution-relation-failure-access.bend as FailureAccess
import ../../src/ecs/execution-relation-failure-local.bend as FailureLocal
import ../../src/ecs/execution-relation-failure-message.bend as Message
import ../../src/ecs/execution-lifecycle-access.bend as Life
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/change-tick.bend as Tick

def Columns(~S:Data) -> Type:L.columns(~S,Actor.components())
type Views<-S:Data> is Data:
  Views{hierarchy:Resource.Lookup<Store.View<S,Setup.hierarchy(~S)>>,link:Resource.Lookup<Store.View<S,Setup.link(~S)>>,scope:Resource.Lookup<ScopeStore.View<S>>}
type FailureUser<-S:Data> is Type:
  FailureUser{session:Actor.Session,calls:Nat,received:Nat,missed:Nat,messages:List<&2,Message.Message<S,Setup.hierarchy(~S)>>,views:List<&2,Views<S>>}
def FailureState(~S:Data) -> Type:FailureLocal.Local<S,Setup.hierarchy(~S),Actor.resources(~S),Actor.parent_route(),FailureUser<S>>
type FailureCaps<-S:Data,-H:Type> is Type:
  FailureCaps{failures:FailureAccess.Read<S,Setup.hierarchy(~S),Actor.resources(~S),Actor.parent_route(),H>,hierarchy:Read.Reader<H,Store.View<S,Setup.hierarchy(~S)>>,link:Read.Reader<H,Store.View<S,Setup.link(~S)>>,scope:Read.Reader<H,ScopeStore.View<S>>}
def FailureOps(~S:Data,Permit:Data,H:Type) -> Type:FailureCaps<S,H>
def RemovalReader(~S:Data) -> Type:Notice.Reader<S,L.origin(Actor.components(),Actor.route()),Notice.Removed{"scene-node"}>
def DespawnReader(~S:Data) -> Type:Notice.Reader<S,L.EmptyLayout{},Notice.Despawned{}>
type LifecycleUser<-S:Data> is Type:
  LifecycleUser{session:Actor.Session,removed:RemovalReader(~S),despawned:DespawnReader(~S),calls:U32,removedRows:List<&2,Notice.Row<S>>,despawnedRows:List<&2,Notice.Row<S>>,removedMissed:Nat,despawnedMissed:Nat,removedEmpty:Bool,despawnedEmpty:Bool}
type LifecycleCaps<-S:Data,-H:Type> is Type:
  LifecycleCaps{removed:Life.Next<S,H,L.origin(Actor.components(),Actor.route()),Notice.Removed{"scene-node"}>,despawned:Life.Next<S,H,L.EmptyLayout{},Notice.Despawned{}>}
def LifecycleOps(~S:Data,Permit:Data,H:Type) -> Type:LifecycleCaps<S,H>
def failures_ops(~S:Data,Permit:Data,H:Type) -> Type:FailureAccess.Read<S,Setup.hierarchy(~S),Actor.resources(~S),Actor.parent_route(),H>
def failures_selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~rr:Build.ResourceRead(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~query:Build.Query(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~H,~B),~life:Build.Lifecycle(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~H,~B),book:B) -> B & FailureAccess.Read<S,Setup.hierarchy(~S),Actor.resources(~S),Actor.parent_route(),H>:
  Selection.general(~S,~Actors.C(~S),~Actors.R(~S),~H,~B,~Actor.resources(~S),~Actor.parent_route(),~{==},~Setup.hierarchy(~S),~{==},~{==},~{==},~Resource.Sparse{},~{==},~rr,book)
def hierarchy_ops(~S:Data,Permit:Data,H:Type) -> Type:Read.Reader<H,Store.View<S,Setup.hierarchy(~S)>>
def hierarchy_selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~rr:Build.ResourceRead(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~query:Build.Query(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~H,~B),~life:Build.Lifecycle(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~H,~B),book:B) -> B & Read.Reader<H,Store.View<S,Setup.hierarchy(~S)>>:
  Build.general_resource_read(~S,~Actors.C(~S),~Actors.R(~S),~H,~B,~Actor.resources(~S),~Actor.parent_route(),~{==},~Resource.Sparse{},~{==},~rr,book)
def link_ops(~S:Data,Permit:Data,H:Type) -> Type:Read.Reader<H,Store.View<S,Setup.link(~S)>>
def link_selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~rr:Build.ResourceRead(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~query:Build.Query(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~H,~B),~life:Build.Lifecycle(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~H,~B),book:B) -> B & Read.Reader<H,Store.View<S,Setup.link(~S)>>:
  Build.general_resource_read(~S,~Actors.C(~S),~Actors.R(~S),~H,~B,~Actor.resources(~S),~Actor.link_route(),~{==},~Resource.Sparse{},~{==},~rr,book)
def scope_ops(~S:Data,Permit:Data,H:Type) -> Type:Read.Reader<H,ScopeStore.View<S>>
def scope_selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~rr:Build.ResourceRead(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~query:Build.Query(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~H,~B),~life:Build.Lifecycle(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~H,~B),book:B) -> B & Read.Reader<H,ScopeStore.View<S>>:
  Build.general_resource_read(~S,~Actors.C(~S),~Actors.R(~S),~H,~B,~Actor.resources(~S),~Actors.scope_route(),~{==},~Resource.Sparse{},~{==},~rr,book)
def removed_ops(~S:Data,Permit:Data,H:Type) -> Type:Life.Next<S,H,L.origin(Actor.components(),Actor.route()),Notice.Removed{"scene-node"}>
def removed_selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~rr:Build.ResourceRead(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~query:Build.Query(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~H,~B),~life:Build.Lifecycle(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~H,~B),book:B) -> B & Life.Next<S,H,L.origin(Actor.components(),Actor.route()),Notice.Removed{"scene-node"}>:
  Build.removed_lifecycle(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~Actor.components(),~Actor.route(),~{==},~{==},~H,~B,~life,book)
def despawned_ops(~S:Data,Permit:Data,H:Type) -> Type:Life.Next<S,H,L.EmptyLayout{},Notice.Despawned{}>
def despawned_selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~rr:Build.ResourceRead(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Actors.C(~S),~Actors.R(~S),~H,~B),~query:Build.Query(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~H,~B),~life:Build.Lifecycle(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~H,~B),book:B) -> B & Life.Next<S,H,L.EmptyLayout{},Notice.Despawned{}>:
  Build.despawn_lifecycle(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~H,~B,~life,book)
def failure_scope_selected(~S:Data,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~Permit,~H,~B),failures:FailureAccess.Read<S,Setup.hierarchy(~S),Actor.resources(~S),Actor.parent_route(),H>,hierarchy:Read.Reader<H,Store.View<S,Setup.hierarchy(~S)>>,link:Read.Reader<H,Store.View<S,Setup.link(~S)>>,result:B & Read.Reader<H,ScopeStore.View<S>>) -> B & FailureOps(~S,Permit,H):
  match result:
    case (book,scope):(book,FailureCaps{failures,hierarchy,link,scope})
def failure_link_selected(~S:Data,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~Permit,~H,~B),failures:FailureAccess.Read<S,Setup.hierarchy(~S),Actor.resources(~S),Actor.parent_route(),H>,hierarchy:Read.Reader<H,Store.View<S,Setup.hierarchy(~S)>>,result:B & Read.Reader<H,Store.View<S,Setup.link(~S)>>) -> B & FailureOps(~S,Permit,H):
  match result:
    case (book,link):failure_scope_selected(~S,~Permit,~H,~B,~builder,failures,hierarchy,link,builder(scope_ops(~S),scope_selection(~S,~Permit,~H,~B),book))
def failure_hierarchy_selected(~S:Data,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~Permit,~H,~B),failures:FailureAccess.Read<S,Setup.hierarchy(~S),Actor.resources(~S),Actor.parent_route(),H>,result:B & Read.Reader<H,Store.View<S,Setup.hierarchy(~S)>>) -> B & FailureOps(~S,Permit,H):
  match result:
    case (book,hierarchy):failure_link_selected(~S,~Permit,~H,~B,~builder,failures,hierarchy,builder(link_ops(~S),link_selection(~S,~Permit,~H,~B),book))
def failure_failures_selected(~S:Data,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~Permit,~H,~B),result:B & FailureAccess.Read<S,Setup.hierarchy(~S),Actor.resources(~S),Actor.parent_route(),H>) -> B & FailureOps(~S,Permit,H):
  match result:
    case (book,failures):failure_hierarchy_selected(~S,~Permit,~H,~B,~builder,failures,builder(hierarchy_ops(~S),hierarchy_selection(~S,~Permit,~H,~B),book))
def failure_declaration(~S:Data,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~Permit,~H,~B),book:B) -> B & FailureOps(~S,Permit,H):
  failure_failures_selected(~S,~Permit,~H,~B,~builder,builder(failures_ops(~S),failures_selection(~S,~Permit,~H,~B),book))
def lifecycle_despawned_selected(~S:Data,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~Permit,~H,~B),removed:Life.Next<S,H,L.origin(Actor.components(),Actor.route()),Notice.Removed{"scene-node"}>,result:B & Life.Next<S,H,L.EmptyLayout{},Notice.Despawned{}>) -> B & LifecycleOps(~S,Permit,H):
  match result:
    case (book,despawned):(book,LifecycleCaps{removed,despawned})
def lifecycle_removed_selected(~S:Data,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~Permit,~H,~B),result:B & Life.Next<S,H,L.origin(Actor.components(),Actor.route()),Notice.Removed{"scene-node"}>) -> B & LifecycleOps(~S,Permit,H):
  match result:
    case (book,removed):lifecycle_despawned_selected(~S,~Permit,~H,~B,~builder,removed,builder(despawned_ops(~S),despawned_selection(~S,~Permit,~H,~B),book))
def lifecycle_declaration(~S:Data,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~Permit,~H,~B),book:B) -> B & LifecycleOps(~S,Permit,H):
  lifecycle_removed_selected(~S,~Permit,~H,~B,~builder,builder(removed_ops(~S),removed_selection(~S,~Permit,~H,~B),book))
def failure_cap(~S:Data,~H:Type,caps:FailureCaps<S,H>) -> FailureAccess.Read<S,Setup.hierarchy(~S),Actor.resources(~S),Actor.parent_route(),H>:
  match caps:
    case FailureCaps{failures,_,_,_}:failures
def hierarchy_cap(~S:Data,~H:Type,caps:FailureCaps<S,H>) -> Read.Reader<H,Store.View<S,Setup.hierarchy(~S)>>:
  match caps:
    case FailureCaps{_,hierarchy,_,_}:hierarchy
def link_cap(~S:Data,~H:Type,caps:FailureCaps<S,H>) -> Read.Reader<H,Store.View<S,Setup.link(~S)>>:
  match caps:
    case FailureCaps{_,_,link,_}:link
def scope_cap(~S:Data,~H:Type,caps:FailureCaps<S,H>) -> Read.Reader<H,ScopeStore.View<S>>:
  match caps:
    case FailureCaps{_,_,_,scope}:scope
def get(~H:Type,~V:Data,cap:Read.Reader<H,V>,scope:H) -> H & Resource.Lookup<V>:
  match cap:
    case Read.Reader{get}:get(scope)
    case Read.UnsupportedReader{}:(scope,Resource.LookupRefused{})
def scope_seen(~S:Data,~H:Type,user:FailureUser<S>,hierarchy:Resource.Lookup<Store.View<S,Setup.hierarchy(~S)>>,link:Resource.Lookup<Store.View<S,Setup.link(~S)>>,result:H & Resource.Lookup<ScopeStore.View<S>>) -> H & (FailureUser<S> & Sys.Completion<String,String>):
  match user result:
    case FailureUser{session,calls,received,missed,messages,views}, (scope,value):(scope,(FailureUser{session,calls,received,missed,messages,List.append(&2,Views<S>,views,[Views{hierarchy,link,value}])},Sys.BodyError{"reader-after-consume","read failures and published scene views"}))
def link_seen(~S:Data,~H:Type,~caps:FailureCaps<S,H>,user:FailureUser<S>,hierarchy:Resource.Lookup<Store.View<S,Setup.hierarchy(~S)>>,result:H & Resource.Lookup<Store.View<S,Setup.link(~S)>>) -> H & (FailureUser<S> & Sys.Completion<String,String>):
  match result:
    case (scope,link):scope_seen(~S,~H,user,hierarchy,link,get(~H,~ScopeStore.View<S>,scope_cap(~S,~H,caps),scope))
def hierarchy_seen(~S:Data,~H:Type,~caps:FailureCaps<S,H>,user:FailureUser<S>,result:H & Resource.Lookup<Store.View<S,Setup.hierarchy(~S)>>) -> H & (FailureUser<S> & Sys.Completion<String,String>):
  match result:
    case (scope,hierarchy):link_seen(~S,~H,~caps,user,hierarchy,get(~H,~Store.View<S,Setup.link(~S)>,link_cap(~S,~H,caps),scope))
def consumed(~S:Data,~H:Type,~caps:FailureCaps<S,H>,scope:H,user:FailureUser<S>,messages:List<&2,Message.Message<S,Setup.hierarchy(~S)>>,missed:Nat,_:Tick.Tick) -> H & (FailureUser<S> & Sys.Completion<String,String>):
  match user messages:
    case FailureUser{session,calls,received,priorMissed,previous,views} +messages:hierarchy_seen(~S,~H,~caps,FailureUser{session,1n+calls,Nat.add(received,List.length(&2,Message.Message<S,Setup.hierarchy(~S)>,messages)),Nat.add(priorMissed,missed),List.append(&2,Message.Message<S,Setup.hierarchy(~S)>,previous,messages),views},get(~H,~Store.View<S,Setup.hierarchy(~S)>,hierarchy_cap(~S,~H,caps),scope))
def failure_returned(~S:Data,~Permit:Data,~H:Type,result:FailureLocal.Invocation<H,FailureState(~S),String,String>) -> Task.Task<S,Permit,H & (FailureState(~S) & Sys.Completion<String,String>)>:
  match result:
    case FailureLocal.Invoked{scope,local,completion}:Task.TDone{(scope,(local,completion))}
    case FailureLocal.Refused{scope,local}:Task.TDone{(scope,(local,Sys.BodyError{"foreign-reader","reader retained"}))}
def failure_body(~S:Data,~Permit:Data,~H:Type,~caps:FailureOps(~S,Permit,H),scope:H,local:FailureState(~S)) -> Task.Task<S,Permit,H & (FailureState(~S) & Sys.Completion<String,String>)>:
  failure_returned(~S,~Permit,~H,FailureLocal.invoke(~S,~Setup.hierarchy(~S),~Actor.resources(~S),~Actor.parent_route(),~H,~FailureUser<S>,~String,~String,~consumed(~S,~H,~caps),failure_cap(~S,~H,caps),scope,local))
def removed_cap(~S:Data,~H:Type,caps:LifecycleCaps<S,H>) -> Life.Next<S,H,L.origin(Actor.components(),Actor.route()),Notice.Removed{"scene-node"}>:
  match caps:
    case LifecycleCaps{removed,_}:removed
def despawned_cap(~S:Data,~H:Type,caps:LifecycleCaps<S,H>) -> Life.Next<S,H,L.EmptyLayout{},Notice.Despawned{}>:
  match caps:
    case LifecycleCaps{_,despawned}:despawned
# The finite scene creates four entities. Five reads include the real Empty
# result after all possible rows, without deriving cursor progress from a count.
def drain(~S:Data,~origin:L.Layout,~selector:Notice.Selector,~H:Type,~cap:Life.Next<S,H,origin,selector>,fuel:Nat,result:H & Notice.Reading<S,origin,selector>,rows:List<&2,Notice.Row<S>>,missed:Nat) -> H & (Notice.Reader<S,origin,selector> & (List<&2,Notice.Row<S>> & (Nat & Bool))):
  match fuel result:
    case _, (scope,Notice.Empty{reader,lost}):(scope,(reader,(rows,(Nat.add(missed,lost),True{}))))
    case _, (scope,Notice.ReadRefused{reader,_}):(scope,(reader,(rows,(missed,False{}))))
    case 0n, (scope,Notice.Item{reader,row,lost}):(scope,(reader,(List.append(&2,Notice.Row<S>,rows,[row]),(Nat.add(missed,lost),False{}))))
    case 1n+rest, (scope,Notice.Item{reader,row,lost}):drain(~S,~origin,~selector,~H,~cap,rest,Life.next(~S,~H,~origin,~selector,cap,scope,reader),List.append(&2,Notice.Row<S>,rows,[row]),Nat.add(missed,lost))
def despawned_seen(~S:Data,~Permit:Data,~H:Type,session:Actor.Session,removed:RemovalReader(~S),calls:U32,removedRows:List<&2,Notice.Row<S>>,removedMissed:Nat,removedEmpty:Bool,result:H & (DespawnReader(~S) & (List<&2,Notice.Row<S>> & (Nat & Bool)))) -> Task.Task<S,Permit,H & (LifecycleUser<S> & Sys.Completion<String,String>)>:
  match result:
    case (scope,(despawned,(rows,(missed,empty)))):Task.TDone{(scope,(LifecycleUser{session,removed,despawned,U32.add(calls,1),removedRows,rows,removedMissed,missed,removedEmpty,empty},Sys.BodyError{"lifecycle-reader-after-consume","removed and despawned streams drained"}))}
def removed_seen(~S:Data,~Permit:Data,~H:Type,~caps:LifecycleCaps<S,H>,session:Actor.Session,despawned:DespawnReader(~S),calls:U32,despawnedRows:List<&2,Notice.Row<S>>,despawnedMissed:Nat,result:H & (RemovalReader(~S) & (List<&2,Notice.Row<S>> & (Nat & Bool)))) -> Task.Task<S,Permit,H & (LifecycleUser<S> & Sys.Completion<String,String>)>:
  match result:
    case (scope,(removed,(rows,(missed,empty)))):despawned_seen(~S,~Permit,~H,session,removed,calls,rows,missed,empty,drain(~S,~L.EmptyLayout{},~Notice.Despawned{},~H,~despawned_cap(~S,~H,caps),4n,Life.next(~S,~H,~L.EmptyLayout{},~Notice.Despawned{},despawned_cap(~S,~H,caps),scope,despawned),despawnedRows,despawnedMissed))
def lifecycle_body(~S:Data,~Permit:Data,~H:Type,~caps:LifecycleOps(~S,Permit,H),scope:H,local:LifecycleUser<S>) -> Task.Task<S,Permit,H & (LifecycleUser<S> & Sys.Completion<String,String>)>:
  match local:
    case LifecycleUser{session,removed,despawned,calls,removedRows,despawnedRows,removedMissed,despawnedMissed,_,_}:removed_seen(~S,~Permit,~H,~caps,session,despawned,calls,despawnedRows,despawnedMissed,drain(~S,~L.origin(Actor.components(),Actor.route()),~(Notice.Removed{"scene-node"}),~H,~removed_cap(~S,~H,caps),4n,Life.next(~S,~H,~L.origin(Actor.components(),Actor.route()),~(Notice.Removed{"scene-node"}),removed_cap(~S,~H,caps),scope,removed),removedRows,removedMissed))
def failure_kernel(~S:Data,~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~Permit,~H,~B),book:B) -> B & FailureOps(~S,Permit,H):
  Build.framework_program(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~FailureOps(~S),~failure_declaration(~S),~Permit,~token,~H,~B,~builder,book)
def FailureCompilation(~S:Data) -> Type:D.Compilation<S,Columns(~S),Actors.C(~S),Actors.R(~S),FailureOps(~S)>
def failure_compilation(~S:Data) -> FailureCompilation(~S):Program.compile_framework(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~FailureOps(~S),~failure_kernel(~S))
def FailureOwner(~S:Data) -> Type:Sys.Owner<S,Columns(~S),Actors.C(~S),Actors.R(~S),Unit,FailureOps(~S),FailureState(~S),String,String,failure_kernel(~S),failure_body(~S)>
def FailureBinding(~S:Data) -> Type:Scope.CompiledBinding<FailureCompilation(~S),FailureOwner(~S)>
def FailureNode(~S:Data) -> Type:Leaf.node_type(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,~FailureOps(~S),~FailureState(~S),~failure_kernel(~S),~failure_body(~S))
def lifecycle_kernel(~S:Data,~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~Permit,~H,~B),book:B) -> B & LifecycleOps(~S,Permit,H):
  Build.framework_program(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~LifecycleOps(~S),~lifecycle_declaration(~S),~Permit,~token,~H,~B,~builder,book)
def LifecycleCompilation(~S:Data) -> Type:D.Compilation<S,Columns(~S),Actors.C(~S),Actors.R(~S),LifecycleOps(~S)>
def lifecycle_compilation(~S:Data) -> LifecycleCompilation(~S):Program.compile_framework(~S,~Columns(~S),~Actors.C(~S),~Actors.R(~S),~LifecycleOps(~S),~lifecycle_kernel(~S))
def LifecycleOwner(~S:Data) -> Type:Sys.Owner<S,Columns(~S),Actors.C(~S),Actors.R(~S),Unit,LifecycleOps(~S),LifecycleUser<S>,String,String,lifecycle_kernel(~S),lifecycle_body(~S)>
def LifecycleBinding(~S:Data) -> Type:Scope.CompiledBinding<LifecycleCompilation(~S),LifecycleOwner(~S)>
def LifecycleNode(~S:Data) -> Type:Leaf.node_type(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,~LifecycleOps(~S),~LifecycleUser<S>,~lifecycle_kernel(~S),~lifecycle_body(~S))
