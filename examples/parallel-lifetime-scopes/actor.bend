import Base
import ./setup.bend as Scene
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-relation-command.bend as Relation
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-lifetime-scope-command.bend as ScopeCommands
import ../../src/ecs/lifetime-scope.bend as Scope

type Session is Type:
  Session{value:U32}
def project(value:Session) -> Session & U32:
  match value:
    case Session{+value}:(Session{value},value)
def components() -> Layout.Layout:
  Layout.LayoutPair{Layout.LayoutLeaf{Session,U32,project,"scene-node",Policy.Ordinary{}},Layout.EmptyLayout{}}
def resources(~S:Data) -> Layout.Layout:Scene.resources(~S,~Session,~U32,~project)
def route() -> Layout.Route:Layout.InLeft{Layout.AtLeaf{}}
def scope_route() -> Layout.Route:Layout.InRight{Layout.InLeft{Layout.AtLeaf{}}}
def C(~S:Data) -> Type:Layout.columns(~S,Layout.LayoutLeaf{Session,U32,project,"scene-node",Policy.Ordinary{}})
def R(~S:Data) -> Type:Layout.resources(~S,Scene.graph_layout(~S))
type Caps<-S:Data,-Q:Type> is Type:
  Caps{relations:Relation.HierarchyCommands<Q,S>,scopes:ScopeCommands.Commands<Q,S>}
def Ops(~S:Data,Permit:Data,H:Type,Q:Type) -> Type:Caps<S,Q>
type User<-S:Data> is Type:
  User{child:W.Handle<S>,parent:W.Handle<S>,replacement:W.Handle<S>,session:Session}
def scope_selected(~S:Data,~Q:Type,~B:Type,~K:Type,book:B,relations:Relation.HierarchyCommands<Q,S>,result:K & ScopeCommands.Commands<Q,S>) -> B & (K & Caps<S,Q>):
  match result:
    case (permissions,scopes):(book,(permissions,Caps{relations,scopes}))
def relation_selected(~S:Data,~Q:Type,~B:Type,~K:Type,~scopes:Permission.ScopeGrant(~S,~resources(~S),~Q,~K),book:B,result:K & Relation.HierarchyCommands<Q,S>) -> B & (K & Caps<S,Q>):
  match result:
    case (permissions,relations):scope_selected(~S,~Q,~B,~K,book,relations,scopes(scope_route(),{==},{==},{==},{==},permissions))
def declaration(~S:Data,~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,S,Session>,~B:Type,~builder:Build.Builder(~S,~Layout.columns(~S,components()),~C(~S),~R(~S),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~S,~components(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~S,~resources(~S),~Q,~K),~scopes:Permission.ScopeGrant(~S,~resources(~S),~Q,~K),book:B,permissions:K) -> B & (K & Ops(~S,Permit,H,Q)):
  relation_selected(~S,~Q,~B,~K,~scopes,book,relations(route(),{==},Scene.hierarchy(~S),{==},{==},{==},permissions))
def group(-S:Data,handle:W.Handle<S>) -> Scope.Scope<S>:
  match handle:
    case W.Handle{namespace,_}:Scope.Scope{namespace,"scene"}
def relation_caps(~S:Data,~Q:Type,caps:Caps<S,Q>) -> Relation.HierarchyCommands<Q,S>:
  match caps:
    case Caps{relations,_}:relations
def scope_caps(~S:Data,~Q:Type,caps:Caps<S,Q>) -> ScopeCommands.Commands<Q,S>:
  match caps:
    case Caps{_,scopes}:scopes
def authored(~S:Data,~Permit:Data,~H:Type,~Q:Type,~insert:Q -> W.Handle<S> -> Session -> Q,~relate:Q -> W.Handle<S> -> W.Handle<S> -> Q,~assign:Q -> Scope.Scope<S> -> W.Handle<S> -> Q,~cleanup:Q -> Scope.Scope<S> -> Q,scope:H,queue:Q,user:User<S>) -> Task.Task<S,Permit,H & (Q & (User<S> & Sys.Completion<String,String>))>:
  match user:
    case User{+child,+parent,+replacement,session}:Task.TDone{(scope,(cleanup(cleanup(assign(relate(relate(relate(insert(insert(insert(queue,child,Session{11}),parent,Session{22}),replacement,Session{33}),child,parent),child,replacement),replacement,child),group(S,replacement),replacement),group(S,replacement)),group(S,replacement)),(User{child,parent,replacement,session},Sys.BodyError{"scope body finished with an error","scoped hierarchy queued"})))}
def body(~S:Data,~Permit:Data,~H:Type,~Q:Type,~caps:Ops(~S,Permit,H,Q),~commands:Local.Commands<Q,S,Session>,scope:H,queue:Q,user:User<S>) -> Task.Task<S,Permit,H & (Q & (User<S> & Sys.Completion<String,String>))>:
  authored(~S,~Permit,~H,~Q,~Local.insert_field(~Q,~S,~Session,commands),~Relation.relate_field(~S,~Q,Relation.relations_field(~S,~Q,relation_caps(~S,~Q,caps))),~ScopeCommands.assign_field(~S,~Q,scope_caps(~S,~Q,caps)),~ScopeCommands.cleanup_field(~S,~Q,scope_caps(~S,~Q,caps)),scope,queue,user)
def Owner(~S:Data) -> Type:
  Cmd.Owner<S,C(~S),R(~S),Unit,components(),resources(~S),route(),Ops(~S),User<S>,String,String,declaration(~S),body(~S)>
