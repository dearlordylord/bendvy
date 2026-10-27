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

type Session is Type:
  Session{value:U32}
def project(value:Session) -> Session & U32:
  match value:
    case Session{+value}:(Session{value},value)
def components() -> Layout.Layout:
  Layout.LayoutPair{Layout.LayoutLeaf{Session,U32,project,"scene-node",Policy.Ordinary{}},Layout.EmptyLayout{}}
def resources(~S:Data) -> Layout.Layout:Scene.resources(~S,~Session,~U32,~project)
def route() -> Layout.Route:Layout.InLeft{Layout.AtLeaf{}}
def C(~S:Data) -> Type:Layout.columns(~S,Layout.LayoutLeaf{Session,U32,project,"scene-node",Policy.Ordinary{}})
def R(~S:Data) -> Type:Layout.resources(~S,Scene.graph_layout(~S))
def parent_route() -> Layout.Route:Layout.InLeft{Layout.InLeft{Layout.AtLeaf{}}}
def link_route() -> Layout.Route:Layout.InLeft{Layout.InRight{Layout.AtLeaf{}}}
type Caps<-S:Data,-Q:Type,-Permit:Data> is Type:
  Caps{entity:Permission.EntityCommands<Q,S,components(),Permit>,parent:Relation.HierarchyCommands<Q,S>,link:Relation.Commands<Q,S>}
def Ops(~S:Data,Permit:Data,H:Type,Q:Type) -> Type:Caps<S,Q,Permit>
type User<-S:Data> is Type:
  User{child:W.Handle<S>,parent:W.Handle<S>,replacement:W.Handle<S>,session:Session}
def linked(~S:Data,~Permit:Data,~Q:Type,~B:Type,~K:Type,~scopes:Permission.ScopeGrant(~S,~resources(~S),~Q,~K),book:B,entity:Permission.EntityCommands<Q,S,components(),Permit>,parent:Relation.HierarchyCommands<Q,S>,result:K & Relation.HierarchyCommands<Q,S>) -> B & (K & Caps<S,Q,Permit>):
  match result:
    case (permissions,link):(book,(permissions,Caps{entity,parent,Relation.relations_field(~S,~Q,link)}))
def parent_selected(~S:Data,~Permit:Data,~Q:Type,~B:Type,~K:Type,~relations:Permission.RelationGrant(~S,~resources(~S),~Q,~K),~scopes:Permission.ScopeGrant(~S,~resources(~S),~Q,~K),book:B,entity:Permission.EntityCommands<Q,S,components(),Permit>,result:K & Relation.HierarchyCommands<Q,S>) -> B & (K & Caps<S,Q,Permit>):
  match result:
    case (permissions,parent):linked(~S,~Permit,~Q,~B,~K,~scopes,book,entity,parent,relations(link_route(),{==},Scene.link(~S),{==},{==},{==},permissions))
def entity_selected(~S:Data,~Permit:Data,~Q:Type,~B:Type,~K:Type,~relations:Permission.RelationGrant(~S,~resources(~S),~Q,~K),~scopes:Permission.ScopeGrant(~S,~resources(~S),~Q,~K),book:B,result:K & Permission.EntityCommands<Q,S,components(),Permit>) -> B & (K & Caps<S,Q,Permit>):
  match result:
    case (permissions,entity):parent_selected(~S,~Permit,~Q,~B,~K,~relations,~scopes,book,entity,relations(parent_route(),{==},Scene.hierarchy(~S),{==},{==},{==},permissions))
def declaration(~S:Data,~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,S,Session>,~B:Type,~builder:Build.Builder(~S,~Layout.columns(~S,components()),~C(~S),~R(~S),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~S,~components(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~S,~resources(~S),~Q,~K),~scopes:Permission.ScopeGrant(~S,~resources(~S),~Q,~K),book:B,permissions:K) -> B & (K & Ops(~S,Permit,H,Q)):
  entity_selected(~S,~Permit,~Q,~B,~K,~relations,~scopes,book,entity(permissions))
def entity_caps(~S:Data,~Q:Type,~Permit:Data,caps:Caps<S,Q,Permit>) -> Permission.EntityCommands<Q,S,components(),Permit>:
  match caps:
    case Caps{entity,_,_}:entity
def parent_caps(~S:Data,~Q:Type,~Permit:Data,caps:Caps<S,Q,Permit>) -> Relation.HierarchyCommands<Q,S>:
  match caps:
    case Caps{_,parent,_}:parent
def link_caps(~S:Data,~Q:Type,~Permit:Data,caps:Caps<S,Q,Permit>) -> Relation.Commands<Q,S>:
  match caps:
    case Caps{_,_,link}:link
def authored(~S:Data,~Permit:Data,~H:Type,~Q:Type,~insert:Q -> W.Handle<S> -> Session -> Q,~relate:Q -> W.Handle<S> -> W.Handle<S> -> Q,~link:Q -> W.Handle<S> -> W.Handle<S> -> Q,~despawn:Q -> W.Handle<S> -> Q,scope:H,queue:Q,user:User<S>) -> Task.Task<S,Permit,H & (Q & (User<S> & Sys.Completion<String,String>))>:
  match user:
    case User{+child,+parent,+replacement,session}:Task.TDone{(scope,(relate(link(relate(relate(insert(insert(insert(queue,child,Session{11}),parent,Session{22}),replacement,Session{33}),child,parent),child,replacement),parent,replacement),replacement,child),(User{child,parent,replacement,session},Sys.BodyError{"linked body finished with an error","ordinary linked despawn queued"})))}
def body(~S:Data,~Permit:Data,~H:Type,~Q:Type,~caps:Ops(~S,Permit,H,Q),~commands:Local.Commands<Q,S,Session>,scope:H,queue:Q,user:User<S>) -> Task.Task<S,Permit,H & (Q & (User<S> & Sys.Completion<String,String>))>:
  authored(~S,~Permit,~H,~Q,~Local.insert_field(~Q,~S,~Session,commands),~Relation.relate_field(~S,~Q,Relation.relations_field(~S,~Q,parent_caps(~S,~Q,~Permit,caps))),~Relation.relate_field(~S,~Q,link_caps(~S,~Q,~Permit,caps)),~Permission.despawn_field(~Q,~S,~components(),~Permit,entity_caps(~S,~Q,~Permit,caps)),scope,queue,user)
def Owner(~S:Data) -> Type:
  Cmd.Owner<S,C(~S),R(~S),Unit,components(),resources(~S),route(),Ops(~S),User<S>,String,String,declaration(~S),body(~S)>
