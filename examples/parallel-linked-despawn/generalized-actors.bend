import Base
import ./actor.bend as Actor
import ./remover.bend as Remover
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

type GraphUser<-S:Data> is Type:
  GraphUser{state:Actor.User<S>,authored:Bool,calls:U32}
type RemovalUser<-S:Data> is Type:
  RemovalUser{handle:W.Handle<S>,authored:Bool,calls:U32}
type UpdaterUser<-S:Data> is Type:
  UpdaterUser{handle:W.Handle<S>,incoming:Maybe<&1,Actor.Session>,following:Maybe<&1,Actor.Session>,calls:U32}
def graph_returned(-S:Data,-H:Type,-Q:Type,calls:U32,result:H & (Q & (Actor.User<S> & Sys.Completion<String,String>))) -> H & (Q & (GraphUser<S> & Sys.Completion<String,String>)):
  match result:
    case (scope,(queue,(user,status))):(scope,(queue,(GraphUser{user,True{},calls},status)))
def graph_body(~S:Data,~Permit:Data,~H:Type,~Q:Type,~caps:Actor.Ops(~S,Permit,H,Q),~commands:Local.Commands<Q,S,Actor.Session>,scope:H,queue:Q,user:GraphUser<S>) -> Task.Task<S,Permit,H & (Q & (GraphUser<S> & Sys.Completion<String,String>))>:
  match user:
    case GraphUser{state,False{},calls}:Task.bind(S,Permit,H & (Q & (Actor.User<S> & Sys.Completion<String,String>)),H & (Q & (GraphUser<S> & Sys.Completion<String,String>)),Actor.body(~S,~Permit,~H,~Q,~caps,~commands,scope,queue,state),result => Task.TDone{graph_returned(S,H,Q,U32.add(calls,1),result)})
    case GraphUser{state,True{},calls}:Task.TDone{(scope,(queue,(GraphUser{state,True{},U32.add(calls,1)},Sys.Success{"graph already initialized"})))}
def removal_returned(-S:Data,-H:Type,-Q:Type,calls:U32,result:H & (Q & (W.Handle<S> & Sys.Completion<String,String>))) -> H & (Q & (RemovalUser<S> & Sys.Completion<String,String>)):
  match result:
    case (scope,(queue,(handle,status))):(scope,(queue,(RemovalUser{handle,True{},calls},status)))
def removal_body(~S:Data,~Permit:Data,~H:Type,~Q:Type,~caps:Remover.Ops(~S,Permit,H,Q),~commands:Local.Commands<Q,S,Actor.Session>,scope:H,queue:Q,user:RemovalUser<S>) -> Task.Task<S,Permit,H & (Q & (RemovalUser<S> & Sys.Completion<String,String>))>:
  match user:
    case RemovalUser{handle,False{},calls}:Task.bind(S,Permit,H & (Q & (W.Handle<S> & Sys.Completion<String,String>)),H & (Q & (RemovalUser<S> & Sys.Completion<String,String>)),Remover.body(~S,~Permit,~H,~Q,~caps,~commands,scope,queue,handle),result => Task.TDone{removal_returned(S,H,Q,U32.add(calls,1),result)})
    case RemovalUser{handle,True{},calls}:Task.TDone{(scope,(queue,(RemovalUser{handle,True{},U32.add(calls,1)},Sys.Success{"linked deletion already applied"})))}
def UpdaterOps(~S:Data,Permit:Data,H:Type,Q:Type) -> Type:Unit

def C(~S:Data) -> Type:Query.Storage<S,Actor.components()>
def R(~S:Data) -> Type:Resource.Storage<S,Actor.resources(~S)>
def graph_declaration(~S:Data,~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,S,Actor.Session>,~B:Type,~builder:Build.Builder(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~S,~Actor.components(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~S,~Actor.resources(~S),~Q,~K),~scopes:Permission.ScopeGrant(~S,~Actor.resources(~S),~Q,~K),book:B,permissions:K) -> B & (K & Actor.Ops(~S,Permit,H,Q)):
  Actor.entity_selected(~S,~Permit,~Q,~B,~K,~relations,~scopes,book,Permission.entity(~S,~Actor.components(),~Permit,~Q,~K,~entity,permissions))
def removal_declaration(~S:Data,~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,S,Actor.Session>,~B:Type,~builder:Build.Builder(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~S,~Actor.components(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~S,~Actor.resources(~S),~Q,~K),~scopes:Permission.ScopeGrant(~S,~Actor.resources(~S),~Q,~K),book:B,permissions:K) -> B & (K & Remover.Ops(~S,Permit,H,Q)):
  (book,Permission.entity(~S,~Actor.components(),~Permit,~Q,~K,~entity,permissions))
def GraphCompilation(~S:Data) -> Type:D.Compilation<S,L.columns(~S,Actor.components()),C(~S),R(~S),Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actor.Ops(~S))>
def RemovalCompilation(~S:Data) -> Type:D.Compilation<S,L.columns(~S,Actor.components()),C(~S),R(~S),Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Remover.Ops(~S))>
def graph_compilation(~S:Data) -> GraphCompilation(~S):
  Program.compile_framework(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actor.Ops(~S)),~Cmd.program_for_buffer(~S,~C(~S),~R(~S),~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actor.Ops(~S),~graph_declaration(~S)))
def removal_compilation(~S:Data) -> RemovalCompilation(~S):
  Program.compile_framework(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Remover.Ops(~S)),~Cmd.program_for_buffer(~S,~C(~S),~R(~S),~Actor.components(),~Actor.resources(~S),~Actor.route(),~Remover.Ops(~S),~removal_declaration(~S)))
def GraphNode(~S:Data) -> Type:Author.Node(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~GraphUser<S>,~String,~String,~graph_declaration(~S),~graph_body(~S))
def RemovalNode(~S:Data) -> Type:Author.Node(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Remover.Ops(~S),~RemovalUser<S>,~String,~String,~removal_declaration(~S),~removal_body(~S))
def GraphOwner(~S:Data) -> Type:Cmd.Owner<S,C(~S),R(~S),Unit,Actor.components(),Actor.resources(~S),Actor.route(),Actor.Ops(~S),GraphUser<S>,String,String,graph_declaration(~S),graph_body(~S)>
def RemovalOwner(~S:Data) -> Type:Cmd.Owner<S,C(~S),R(~S),Unit,Actor.components(),Actor.resources(~S),Actor.route(),Remover.Ops(~S),RemovalUser<S>,String,String,removal_declaration(~S),removal_body(~S)>
def GraphBinding(~S:Data) -> Type:Scope.CompiledBinding<GraphCompilation(~S),GraphOwner(~S)>
def RemovalBinding(~S:Data) -> Type:Scope.CompiledBinding<RemovalCompilation(~S),RemovalOwner(~S)>
def updater_declaration(~S:Data,~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,S,Actor.Session>,~B:Type,~builder:Build.Builder(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~S,~Actor.components(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~S,~Actor.resources(~S),~Q,~K),~scopes:Permission.ScopeGrant(~S,~Actor.resources(~S),~Q,~K),book:B,permissions:K) -> B & (K & UpdaterOps(~S,Permit,H,Q)):
  (book,(permissions,Unit{}))
def updater_body(~S:Data,~Permit:Data,~H:Type,~Q:Type,~caps:UpdaterOps(~S,Permit,H,Q),~commands:Local.Commands<Q,S,Actor.Session>,scope:H,queue:Q,user:UpdaterUser<S>) -> Task.Task<S,Permit,H & (Q & (UpdaterUser<S> & Sys.Completion<String,String>))>:
  # Bevy ad678262 schedule/executor/single_threaded.rs retains authored Commands
  # after handled errors. The actual next packet moves from Local into that queue.
  match user:
    case UpdaterUser{+handle,Some{incoming},following,calls}:Task.TDone{(scope,(Local.insert_field(~Q,~S,~Actor.Session,commands)(queue,handle,incoming),(UpdaterUser{handle,following,None{},U32.add(calls,1)},Sys.BodyError{"survivor packet authored","survivor packet retained through ordinary error"})))}
    case UpdaterUser{handle,None{},following,calls}:Task.TDone{(scope,(queue,(UpdaterUser{handle,None{},following,U32.add(calls,1)},Sys.Success{"survivor packets exhausted"})))}
def UpdaterCompilation(~S:Data) -> Type:D.Compilation<S,L.columns(~S,Actor.components()),C(~S),R(~S),Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~UpdaterOps(~S))>
def updater_compilation(~S:Data) -> UpdaterCompilation(~S):
  Program.compile_framework(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~UpdaterOps(~S)),~Cmd.program_for_buffer(~S,~C(~S),~R(~S),~Actor.components(),~Actor.resources(~S),~Actor.route(),~UpdaterOps(~S),~updater_declaration(~S)))
def UpdaterNode(~S:Data) -> Type:Author.Node(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~UpdaterOps(~S),~UpdaterUser<S>,~String,~String,~updater_declaration(~S),~updater_body(~S))
def UpdaterOwner(~S:Data) -> Type:Cmd.Owner<S,C(~S),R(~S),Unit,Actor.components(),Actor.resources(~S),Actor.route(),UpdaterOps(~S),UpdaterUser<S>,String,String,updater_declaration(~S),updater_body(~S)>
def UpdaterBinding(~S:Data) -> Type:Scope.CompiledBinding<UpdaterCompilation(~S),UpdaterOwner(~S)>
