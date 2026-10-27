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

def C(~S:Data) -> Type:Query.Storage<S,Actor.components()>
def R(~S:Data) -> Type:Resource.Storage<S,Actor.resources(~S)>
def graph_declaration(~S:Data,~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,S,Actor.Session>,~B:Type,~builder:Build.Builder(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~S,~Actor.components(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~S,~Actor.resources(~S),~Q,~K),~scopes:Permission.ScopeGrant(~S,~Actor.resources(~S),~Q,~K),book:B,permissions:K) -> B & (K & Actor.Ops(~S,Permit,H,Q)):
  Actor.entity_selected(~S,~Permit,~Q,~B,~K,~relations,~scopes,book,entity(permissions))
def removal_declaration(~S:Data,~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,S,Actor.Session>,~B:Type,~builder:Build.Builder(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~S,~Actor.components(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~S,~Actor.resources(~S),~Q,~K),~scopes:Permission.ScopeGrant(~S,~Actor.resources(~S),~Q,~K),book:B,permissions:K) -> B & (K & Remover.Ops(~S,Permit,H,Q)):
  (book,entity(permissions))
def GraphCompilation(~S:Data) -> Type:D.Compilation<S,L.columns(~S,Actor.components()),C(~S),R(~S),Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actor.Ops(~S))>
def RemovalCompilation(~S:Data) -> Type:D.Compilation<S,L.columns(~S,Actor.components()),C(~S),R(~S),Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Remover.Ops(~S))>
def graph_compilation(~S:Data) -> GraphCompilation(~S):
  Program.compile_framework(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actor.Ops(~S)),~Cmd.program_for_buffer(~S,~C(~S),~R(~S),~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actor.Ops(~S),~graph_declaration(~S)))
def removal_compilation(~S:Data) -> RemovalCompilation(~S):
  Program.compile_framework(~S,~L.columns(~S,Actor.components()),~C(~S),~R(~S),~Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Remover.Ops(~S)),~Cmd.program_for_buffer(~S,~C(~S),~R(~S),~Actor.components(),~Actor.resources(~S),~Actor.route(),~Remover.Ops(~S),~removal_declaration(~S)))
def GraphNode(~S:Data) -> Type:Author.Node(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~Actor.User<S>,~String,~String,~graph_declaration(~S),~Actor.body(~S))
def RemovalNode(~S:Data) -> Type:Author.Node(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Remover.Ops(~S),~W.Handle<S>,~String,~String,~removal_declaration(~S),~Remover.body(~S))
def GraphOwner(~S:Data) -> Type:Cmd.Owner<S,C(~S),R(~S),Unit,Actor.components(),Actor.resources(~S),Actor.route(),Actor.Ops(~S),Actor.User<S>,String,String,graph_declaration(~S),Actor.body(~S)>
def RemovalOwner(~S:Data) -> Type:Cmd.Owner<S,C(~S),R(~S),Unit,Actor.components(),Actor.resources(~S),Actor.route(),Remover.Ops(~S),W.Handle<S>,String,String,removal_declaration(~S),Remover.body(~S)>
def GraphBinding(~S:Data) -> Type:Scope.CompiledBinding<GraphCompilation(~S),GraphOwner(~S)>
def RemovalBinding(~S:Data) -> Type:Scope.CompiledBinding<RemovalCompilation(~S),RemovalOwner(~S)>
