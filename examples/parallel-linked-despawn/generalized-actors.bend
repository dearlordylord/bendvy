import Base
import ./actor.bend as Actor
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-query-store.bend as Query
import ../../src/ecs/execution-resource-store.bend as Resource
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-generalized-command-leaf.bend as Author
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-system.bend as Sys

import ./setup.bend as Setup
import ../../src/ecs/execution-relation-command.bend as Relation
import ../../src/ecs/execution-lifetime-scope-command.bend as ScopeCommands
import ../../src/ecs/lifetime-scope.bend as Lifetime

def C(~S:Data) -> Type:Query.Storage<S,Actor.components()>
def R(~S:Data) -> Type:Resource.Storage<S,Actor.resources(~S)>
def scope_route() -> L.Route:L.InRight{L.InLeft{L.AtLeaf{}}}
def group(-S:Data,handle:W.Handle<S>) -> Lifetime.Scope<S>:
  match handle:
    case W.Handle{namespace,_}:Lifetime.Scope{namespace,"scene"}
type GraphCaps<-S:Data,-Q:Type> is Type:
  GraphCaps{parent:Relation.HierarchyCommands<Q,S>,scopes:ScopeCommands.Commands<Q,S>}
def GraphOps(~S:Data,Permit:Data,H:Type,Q:Type) -> Type:GraphCaps<S,Q>
def LinkOps(~S:Data,Permit:Data,H:Type,Q:Type) -> Type:Relation.Commands<Q,S>
type RemovalCaps<-S:Data,-Q:Type,-Permit:Data> is Type:
  RemovalCaps{entity:Permission.EntityCommands<Q,S,Actor.components(),Permit>,scopes:ScopeCommands.Commands<Q,S>}
def RemovalOps(~S:Data,Permit:Data,H:Type,Q:Type) -> Type:RemovalCaps<S,Q,Permit>
type GraphUser<-S:Data> is Type:
  GraphUser{state:Actor.User<S>,scoped:W.Handle<S>,authored:Bool,calls:U32}
type LinkUser<-S:Data> is Type:
  LinkUser{source:W.Handle<S>,target:W.Handle<S>,session:Actor.Session,authored:Bool,calls:U32}
type RemovalUser<-S:Data> is Type:
  RemovalUser{handle:W.Handle<S>,authored:Bool,calls:U32}
type UpdaterUser<-S:Data> is Type:
  UpdaterUser{handle:W.Handle<S>,incoming:Maybe<&1,Actor.Session>,following:Maybe<&1,Actor.Session>,calls:U32}
def graph_scopes(~S:Data,~Q:Type,~B:Type,~K:Type,book:B,parent:Relation.HierarchyCommands<Q,S>,result:K & ScopeCommands.Commands<Q,S>) -> B & (K & GraphCaps<S,Q>):
  match result:
    case (permissions,scopes):(book,(permissions,GraphCaps{parent,scopes}))
def graph_parent(~S:Data,~Q:Type,~B:Type,~K:Type,~scopes:Permission.ScopeGrant(~S,~Actor.resources(~S),~Q,~K),book:B,result:K & Relation.HierarchyCommands<Q,S>) -> B & (K & GraphCaps<S,Q>):
  match result:
    case (permissions,parent):graph_scopes(~S,~Q,~B,~K,book,parent,scopes(scope_route(),{==},{==},{==},{==},permissions))
def link_selected(~S:Data,~Q:Type,~B:Type,~K:Type,book:B,result:K & Relation.HierarchyCommands<Q,S>) -> B & (K & Relation.Commands<Q,S>):
  match result:
    case (permissions,relations):(book,(permissions,Relation.relations_field(~S,~Q,relations)))
def removal_scopes(~S:Data,~Q:Type,~Permit:Data,~B:Type,~K:Type,book:B,entity:Permission.EntityCommands<Q,S,Actor.components(),Permit>,result:K & ScopeCommands.Commands<Q,S>) -> B & (K & RemovalCaps<S,Q,Permit>):
  match result:
    case (permissions,scopes):(book,(permissions,RemovalCaps{entity,scopes}))
def removal_entity(~S:Data,~Q:Type,~Permit:Data,~B:Type,~K:Type,~scopes:Permission.ScopeGrant(~S,~Actor.resources(~S),~Q,~K),book:B,result:K & Permission.EntityCommands<Q,S,Actor.components(),Permit>) -> B & (K & RemovalCaps<S,Q,Permit>):
  match result:
    case (permissions,entity):removal_scopes(~S,~Q,~Permit,~B,~K,book,entity,scopes(scope_route(),{==},{==},{==},{==},permissions))
def graph_declaration(~S:Data,~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,S,Actor.Session>,~B:Type,~builder:Build.Builder(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~S,~Actor.components(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~S,~Actor.resources(~S),~Q,~K),~scopes:Permission.ScopeGrant(~S,~Actor.resources(~S),~Q,~K),book:B,permissions:K) -> B & (K & GraphOps(~S,Permit,H,Q)):
  graph_parent(~S,~Q,~B,~K,~scopes,book,relations(Actor.parent_route(),{==},Setup.hierarchy(~S),{==},{==},{==},permissions))
def link_declaration(~S:Data,~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,S,Actor.Session>,~B:Type,~builder:Build.Builder(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~S,~Actor.components(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~S,~Actor.resources(~S),~Q,~K),~scopes:Permission.ScopeGrant(~S,~Actor.resources(~S),~Q,~K),book:B,permissions:K) -> B & (K & LinkOps(~S,Permit,H,Q)):
  link_selected(~S,~Q,~B,~K,book,relations(Actor.link_route(),{==},Setup.link(~S),{==},{==},{==},permissions))
def removal_declaration(~S:Data,~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,S,Actor.Session>,~B:Type,~builder:Build.Builder(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~S,~Actor.components(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~S,~Actor.resources(~S),~Q,~K),~scopes:Permission.ScopeGrant(~S,~Actor.resources(~S),~Q,~K),book:B,permissions:K) -> B & (K & RemovalOps(~S,Permit,H,Q)):
  removal_entity(~S,~Q,~Permit,~B,~K,~scopes,book,Permission.entity(~S,~Actor.components(),~Permit,~Q,~K,~entity,permissions))
def graph_parent_cap(~S:Data,~Q:Type,caps:GraphCaps<S,Q>) -> Relation.HierarchyCommands<Q,S>:
  match caps:
    case GraphCaps{parent,_}:parent
def graph_scope_cap(~S:Data,~Q:Type,caps:GraphCaps<S,Q>) -> ScopeCommands.Commands<Q,S>:
  match caps:
    case GraphCaps{_,scopes}:scopes
def removal_entity_cap(~S:Data,~Q:Type,~Permit:Data,caps:RemovalCaps<S,Q,Permit>) -> Permission.EntityCommands<Q,S,Actor.components(),Permit>:
  match caps:
    case RemovalCaps{entity,_}:entity
def removal_scope_cap(~S:Data,~Q:Type,~Permit:Data,caps:RemovalCaps<S,Q,Permit>) -> ScopeCommands.Commands<Q,S>:
  match caps:
    case RemovalCaps{_,scopes}:scopes
def graph_authored(~S:Data,~Permit:Data,~H:Type,~Q:Type,~insert:Q -> W.Handle<S> -> Actor.Session -> Q,~relate:Q -> W.Handle<S> -> W.Handle<S> -> Q,~assign:Q -> Lifetime.Scope<S> -> W.Handle<S> -> Q,scope:H,queue:Q,user:GraphUser<S>) -> Task.Task<S,Permit,H & (Q & (GraphUser<S> & Sys.Completion<String,String>))>:
  match user:
    case GraphUser{Actor.User{+child,+parent,+replacement,session},+scoped,False{},calls}:Task.TDone{(scope,(assign(relate(relate(relate(insert(insert(insert(insert(queue,child,Actor.Session{11}),parent,Actor.Session{22}),replacement,Actor.Session{33}),scoped,Actor.Session{44}),child,parent),child,replacement),replacement,child),group(S,scoped),scoped),(GraphUser{Actor.User{child,parent,replacement,session},scoped,True{},U32.add(calls,1)},Sys.BodyError{"hierarchy author error","hierarchy and scope queued"})))}
    case GraphUser{state,scoped,True{},calls}:Task.TDone{(scope,(queue,(GraphUser{state,scoped,True{},U32.add(calls,1)},Sys.Success{"hierarchy already authored"})))}
def graph_body(~S:Data,~Permit:Data,~H:Type,~Q:Type,~caps:GraphOps(~S,Permit,H,Q),~commands:Local.Commands<Q,S,Actor.Session>,scope:H,queue:Q,user:GraphUser<S>) -> Task.Task<S,Permit,H & (Q & (GraphUser<S> & Sys.Completion<String,String>))>:
  graph_authored(~S,~Permit,~H,~Q,~Local.insert_field(~Q,~S,~Actor.Session,commands),~Relation.relate_field(~S,~Q,Relation.relations_field(~S,~Q,graph_parent_cap(~S,~Q,caps))),~ScopeCommands.assign_field(~S,~Q,graph_scope_cap(~S,~Q,caps)),scope,queue,user)
def link_body(~S:Data,~Permit:Data,~H:Type,~Q:Type,~caps:LinkOps(~S,Permit,H,Q),~commands:Local.Commands<Q,S,Actor.Session>,scope:H,queue:Q,user:LinkUser<S>) -> Task.Task<S,Permit,H & (Q & (LinkUser<S> & Sys.Completion<String,String>))>:
  match user:
    case LinkUser{+source,+target,session,False{},calls}:Task.TDone{(scope,(Relation.relate_field(~S,~Q,caps)(queue,source,target),(LinkUser{source,target,session,True{},U32.add(calls,1)},Sys.BodyError{"link author error","ordinary link queued"})))}
    case LinkUser{source,target,session,True{},calls}:Task.TDone{(scope,(queue,(LinkUser{source,target,session,True{},U32.add(calls,1)},Sys.Success{"link already authored"})))}
def editor_body(~S:Data,~Permit:Data,~H:Type,~Q:Type,~caps:LinkOps(~S,Permit,H,Q),~commands:Local.Commands<Q,S,Actor.Session>,scope:H,queue:Q,user:LinkUser<S>) -> Task.Task<S,Permit,H & (Q & (LinkUser<S> & Sys.Completion<String,String>))>:
  match user:
    case LinkUser{+source,+target,session,False{},calls}:Task.TDone{(scope,(Relation.relate_field(~S,~Q,caps)(Relation.unrelate_field(~S,~Q,caps)(queue,source),source,target),(LinkUser{source,target,session,True{},U32.add(calls,1)},Sys.BodyError{"link editor error","unrelate and relate queued"})))}
    case LinkUser{source,target,session,True{},calls}:Task.TDone{(scope,(queue,(LinkUser{source,target,session,True{},U32.add(calls,1)},Sys.Success{"link already edited"})))}
def removal_authored(~S:Data,~Permit:Data,~H:Type,~Q:Type,~despawn:Q -> W.Handle<S> -> Q,~cleanup:Q -> Lifetime.Scope<S> -> Q,scope:H,queue:Q,user:RemovalUser<S>) -> Task.Task<S,Permit,H & (Q & (RemovalUser<S> & Sys.Completion<String,String>))>:
  match user:
    case RemovalUser{+handle,False{},calls}:Task.TDone{(scope,(cleanup(cleanup(despawn(despawn(queue,handle),handle),group(S,handle)),group(S,handle)),(RemovalUser{handle,True{},U32.add(calls,1)},Sys.BodyError{"cleanup author error","linked and scope cleanup queued"})))}
    case RemovalUser{handle,True{},calls}:Task.TDone{(scope,(queue,(RemovalUser{handle,True{},U32.add(calls,1)},Sys.Success{"cleanup already authored"})))}
def removal_body(~S:Data,~Permit:Data,~H:Type,~Q:Type,~caps:RemovalOps(~S,Permit,H,Q),~commands:Local.Commands<Q,S,Actor.Session>,scope:H,queue:Q,user:RemovalUser<S>) -> Task.Task<S,Permit,H & (Q & (RemovalUser<S> & Sys.Completion<String,String>))>:
  removal_authored(~S,~Permit,~H,~Q,~Permission.despawn_field(~Q,~S,~Actor.components(),~Permit,removal_entity_cap(~S,~Q,~Permit,caps)),~ScopeCommands.cleanup_field(~S,~Q,removal_scope_cap(~S,~Q,~Permit,caps)),scope,queue,user)
def UpdaterOps(~S:Data,Permit:Data,H:Type,Q:Type) -> Type:Unit
def updater_declaration(~S:Data,~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,S,Actor.Session>,~B:Type,~builder:Build.Builder(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~S,~Actor.components(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~S,~Actor.resources(~S),~Q,~K),~scopes:Permission.ScopeGrant(~S,~Actor.resources(~S),~Q,~K),book:B,permissions:K) -> B & (K & UpdaterOps(~S,Permit,H,Q)):
  (book,(permissions,Unit{}))
def updater_body(~S:Data,~Permit:Data,~H:Type,~Q:Type,~caps:UpdaterOps(~S,Permit,H,Q),~commands:Local.Commands<Q,S,Actor.Session>,scope:H,queue:Q,user:UpdaterUser<S>) -> Task.Task<S,Permit,H & (Q & (UpdaterUser<S> & Sys.Completion<String,String>))>:
  # Bevy ad678262 schedule/executor/single_threaded.rs retains authored Commands
  # after handled errors. The actual next packet moves from Local into that queue.
  match user:
    case UpdaterUser{+handle,Some{incoming},following,calls}:Task.TDone{(scope,(Local.insert_field(~Q,~S,~Actor.Session,commands)(queue,handle,incoming),(UpdaterUser{handle,following,None{},U32.add(calls,1)},Sys.BodyError{"survivor packet authored","survivor packet retained through ordinary error"})))}
    case UpdaterUser{handle,None{},following,calls}:Task.TDone{(scope,(queue,(UpdaterUser{handle,None{},following,U32.add(calls,1)},Sys.Success{"survivor packets exhausted"})))}
def GraphCompilation(~S:Data) -> Type:D.Compilation<S,L.columns(~S,Actor.components()),C(~S),R(~S),Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~GraphOps(~S))>
def graph_compilation(~S:Data) -> GraphCompilation(~S):
  Program.compile_framework(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~GraphOps(~S)),~Cmd.program_for_buffer(~S,~C(~S),~R(~S),~Actor.components(),~Actor.resources(~S),~Actor.route(),~GraphOps(~S),~graph_declaration(~S)))
def GraphNode(~S:Data) -> Type:Author.Node(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~GraphOps(~S),~GraphUser<S>,~String,~String,~graph_declaration(~S),~graph_body(~S))
def GraphOwner(~S:Data) -> Type:Cmd.Owner<S,C(~S),R(~S),Unit,Actor.components(),Actor.resources(~S),Actor.route(),GraphOps(~S),GraphUser<S>,String,String,graph_declaration(~S),graph_body(~S)>
def GraphBinding(~S:Data) -> Type:Scope.CompiledBinding<GraphCompilation(~S),GraphOwner(~S)>
def LinkCompilation(~S:Data) -> Type:D.Compilation<S,L.columns(~S,Actor.components()),C(~S),R(~S),Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~LinkOps(~S))>
def link_compilation(~S:Data) -> LinkCompilation(~S):
  Program.compile_framework(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~LinkOps(~S)),~Cmd.program_for_buffer(~S,~C(~S),~R(~S),~Actor.components(),~Actor.resources(~S),~Actor.route(),~LinkOps(~S),~link_declaration(~S)))
def LinkNode(~S:Data) -> Type:Author.Node(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~LinkOps(~S),~LinkUser<S>,~String,~String,~link_declaration(~S),~link_body(~S))
def LinkOwner(~S:Data) -> Type:Cmd.Owner<S,C(~S),R(~S),Unit,Actor.components(),Actor.resources(~S),Actor.route(),LinkOps(~S),LinkUser<S>,String,String,link_declaration(~S),link_body(~S)>
def LinkBinding(~S:Data) -> Type:Scope.CompiledBinding<LinkCompilation(~S),LinkOwner(~S)>
def EditorCompilation(~S:Data) -> Type:D.Compilation<S,L.columns(~S,Actor.components()),C(~S),R(~S),Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~LinkOps(~S))>
def editor_compilation(~S:Data) -> EditorCompilation(~S):
  Program.compile_framework(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~LinkOps(~S)),~Cmd.program_for_buffer(~S,~C(~S),~R(~S),~Actor.components(),~Actor.resources(~S),~Actor.route(),~LinkOps(~S),~link_declaration(~S)))
def EditorNode(~S:Data) -> Type:Author.Node(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~LinkOps(~S),~LinkUser<S>,~String,~String,~link_declaration(~S),~editor_body(~S))
def EditorOwner(~S:Data) -> Type:Cmd.Owner<S,C(~S),R(~S),Unit,Actor.components(),Actor.resources(~S),Actor.route(),LinkOps(~S),LinkUser<S>,String,String,link_declaration(~S),editor_body(~S)>
def EditorBinding(~S:Data) -> Type:Scope.CompiledBinding<EditorCompilation(~S),EditorOwner(~S)>
def RemovalCompilation(~S:Data) -> Type:D.Compilation<S,L.columns(~S,Actor.components()),C(~S),R(~S),Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~RemovalOps(~S))>
def removal_compilation(~S:Data) -> RemovalCompilation(~S):
  Program.compile_framework(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~RemovalOps(~S)),~Cmd.program_for_buffer(~S,~C(~S),~R(~S),~Actor.components(),~Actor.resources(~S),~Actor.route(),~RemovalOps(~S),~removal_declaration(~S)))
def RemovalNode(~S:Data) -> Type:Author.Node(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~RemovalOps(~S),~RemovalUser<S>,~String,~String,~removal_declaration(~S),~removal_body(~S))
def RemovalOwner(~S:Data) -> Type:Cmd.Owner<S,C(~S),R(~S),Unit,Actor.components(),Actor.resources(~S),Actor.route(),RemovalOps(~S),RemovalUser<S>,String,String,removal_declaration(~S),removal_body(~S)>
def RemovalBinding(~S:Data) -> Type:Scope.CompiledBinding<RemovalCompilation(~S),RemovalOwner(~S)>
def UpdaterCompilation(~S:Data) -> Type:D.Compilation<S,L.columns(~S,Actor.components()),C(~S),R(~S),Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~UpdaterOps(~S))>
def updater_compilation(~S:Data) -> UpdaterCompilation(~S):
  Program.compile_framework(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~UpdaterOps(~S)),~Cmd.program_for_buffer(~S,~C(~S),~R(~S),~Actor.components(),~Actor.resources(~S),~Actor.route(),~UpdaterOps(~S),~updater_declaration(~S)))
def UpdaterNode(~S:Data) -> Type:Author.Node(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~UpdaterOps(~S),~UpdaterUser<S>,~String,~String,~updater_declaration(~S),~updater_body(~S))
def UpdaterOwner(~S:Data) -> Type:Cmd.Owner<S,C(~S),R(~S),Unit,Actor.components(),Actor.resources(~S),Actor.route(),UpdaterOps(~S),UpdaterUser<S>,String,String,updater_declaration(~S),updater_body(~S)>
def UpdaterBinding(~S:Data) -> Type:Scope.CompiledBinding<UpdaterCompilation(~S),UpdaterOwner(~S)>
