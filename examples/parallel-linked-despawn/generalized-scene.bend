import Base
import ./scene.bend as Observe
import ./actor.bend as Actor
import ./remover.bend as Remover
import ./generalized-actors.bend as Actors
import ./generalized-application.bend as Application
import ./generalized-initialize.bend as Initialize
import ../../src/ecs/execution-generalized-command-leaf.bend as Author
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-schema-provisioning.bend as Provision
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-parallel-root-application.bend as Root
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W

def graph_binding(value:Scope.CompiledBinding<Actors.GraphCompilation(~Observe.Schema),Cmd.System(~Observe.Schema,~Actors.C(~Observe.Schema),~Actors.R(~Observe.Schema),~Unit,~Actor.components(),~Actor.resources(~Observe.Schema),~Actor.route(),~Actor.Ops(~Observe.Schema),~Actor.User<Observe.Schema>,~String,~String,~Actors.graph_declaration(~Observe.Schema),~Actor.body(~Observe.Schema))>) -> String:
  match value:
    case Scope.CompiledBinding{_,Sys.Owner{_,_,_,_,_,Local.Local{Actor.User{_,_,_,Actor.Session{session}},Buffer.Buffer{pending,receipts},_}}}:"local=" ++ U32.show(session) ++ ",pending=" ++ Nat.show(List.length(&1,Buffer.Entry<Observe.Schema,Actor.Session,Removed.Removed(Actor.components())>,pending)) ++ ",receipts=[" ++ Observe.receipts(List.reverse(&1,Buffer.Receipt<Observe.Schema,Actor.Session,Removed.Removed(Actor.components())>,receipts)) ++ "]"
def graph(value:Actors.GraphNode(~Observe.Schema)) -> String:
  graph_binding(Leaf.registered_binding(Actors.GraphCompilation(~Observe.Schema),Application.World(~Observe.Schema),Cmd.System(~Observe.Schema,~Actors.C(~Observe.Schema),~Actors.R(~Observe.Schema),~Unit,~Actor.components(),~Actor.resources(~Observe.Schema),~Actor.route(),~Actor.Ops(~Observe.Schema),~Actor.User<Observe.Schema>,~String,~String,~Actors.graph_declaration(~Observe.Schema),~Actor.body(~Observe.Schema)),Author.AdmissionEvidence(~Observe.Schema,~Actor.components(),~Actor.resources(~Observe.Schema),~Unit,~Actor.route(),~Actor.Ops(~Observe.Schema),~Actor.User<Observe.Schema>,~String,~String,~Actors.graph_declaration(~Observe.Schema),~Actor.body(~Observe.Schema)),Author.PrepPermit(~Observe.Schema,~Actor.components()),value))
def removal_binding(value:Scope.CompiledBinding<Actors.RemovalCompilation(~Observe.Schema),Cmd.System(~Observe.Schema,~Actors.C(~Observe.Schema),~Actors.R(~Observe.Schema),~Unit,~Actor.components(),~Actor.resources(~Observe.Schema),~Actor.route(),~Remover.Ops(~Observe.Schema),~W.Handle<Observe.Schema>,~String,~String,~Actors.removal_declaration(~Observe.Schema),~Remover.body(~Observe.Schema))>) -> String:
  match value:
    case Scope.CompiledBinding{_,Sys.Owner{_,_,_,_,_,Local.Local{handle,Buffer.Buffer{pending,receipts},_}}}:"despawn-only=" ++ Observe.handle(handle) ++ ",pending=" ++ Nat.show(List.length(&1,Buffer.Entry<Observe.Schema,Actor.Session,Removed.Removed(Actor.components())>,pending)) ++ ",receipts=[" ++ Observe.receipts(List.reverse(&1,Buffer.Receipt<Observe.Schema,Actor.Session,Removed.Removed(Actor.components())>,receipts)) ++ "]"
def removal(value:Actors.RemovalNode(~Observe.Schema)) -> String:
  removal_binding(Leaf.registered_binding(Actors.RemovalCompilation(~Observe.Schema),Application.World(~Observe.Schema),Cmd.System(~Observe.Schema,~Actors.C(~Observe.Schema),~Actors.R(~Observe.Schema),~Unit,~Actor.components(),~Actor.resources(~Observe.Schema),~Actor.route(),~Remover.Ops(~Observe.Schema),~W.Handle<Observe.Schema>,~String,~String,~Actors.removal_declaration(~Observe.Schema),~Remover.body(~Observe.Schema)),Author.AdmissionEvidence(~Observe.Schema,~Actor.components(),~Actor.resources(~Observe.Schema),~Unit,~Actor.route(),~Remover.Ops(~Observe.Schema),~W.Handle<Observe.Schema>,~String,~String,~Actors.removal_declaration(~Observe.Schema),~Remover.body(~Observe.Schema)),Author.PrepPermit(~Observe.Schema,~Actor.components()),value))
def application(value:Application.Bound(~Observe.Schema)) -> String:
  match value:
    case Provision.Bound{Context.Bound{_,Root.Scheduled{App.State{General.Present{W.World{_,_,columns,owners,_,_,_,_,_,_},_},Product.Owner{author,despawner},_,_,_},_,_,_,_}}}:Observe.resources(owners) ++ "|components=" ++ Observe.components(columns) ++ "|" ++ graph(author) ++ "|" ++ removal(despawner)
    case _:"retained-inventory-refusal"
def finished(result:Application.Bound(~Observe.Schema) & Context.RunReport<App.Report<String,String>>) -> IO(Unit):
  match result:
    case (bound,report):IO.print("generalized/" ++ Observe.report(report) ++ "|" ++ application(bound))
def initialized(value:Initialize.Initialization<Observe.Schema>) -> IO(Unit):
  match value:
    case Initialize.Ready{_,bound}:IO.bind(Application.Bound(~Observe.Schema) & Context.RunReport<App.Report<String,String>>,Unit,Application.run(~Observe.Schema,bound),finished)
    case _:IO.print("retained-initialization-refusal")
def main() -> IO(Unit):
  initialized(Initialize.create(~Observe.Schema,W.factory(),Actor.Session{401},Actor.Session{601}))
