import Base
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-composer-layout.bend as L
import ./scene.bend as Observe
import ./generalized-observation.bend as Snapshot
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
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W

def graph_user(owner:Actors.GraphUser<Observe.Schema>) -> Actors.GraphUser<Observe.Schema> & String:
  match owner:
    case Actors.GraphUser{Actor.User{child,parent,replacement,session},authored,+calls}:Snapshot.with_pair(Actor.Session,Actors.GraphUser<Observe.Schema> & String,Snapshot.session(session),session => text => (Actors.GraphUser{Actor.User{child,parent,replacement,session},authored,calls},"graph-calls=" ++ U32.show(calls) ++ ",local=" ++ text))
def removal_user(owner:Actors.RemovalUser<Observe.Schema>) -> Actors.RemovalUser<Observe.Schema> & String:
  match owner:
    case Actors.RemovalUser{+handle,authored,+calls}:(Actors.RemovalUser{handle,authored,calls},"despawn-only=" ++ Observe.handle(handle) ++ ",removal-calls=" ++ U32.show(calls))
def updater_user(owner:Actors.UpdaterUser<Observe.Schema>) -> Actors.UpdaterUser<Observe.Schema> & String:
  match owner:
    case Actors.UpdaterUser{+handle,incoming,following,+calls}:Snapshot.with_pair(Maybe<&1,Actor.Session>,Actors.UpdaterUser<Observe.Schema> & String,Snapshot.maybe(incoming),incoming => a => Snapshot.with_pair(Maybe<&1,Actor.Session>,Actors.UpdaterUser<Observe.Schema> & String,Snapshot.maybe(following),following => b => (Actors.UpdaterUser{handle,incoming,following,calls},"updater=" ++ Observe.handle(handle) ++ ",updater-calls=" ++ U32.show(calls) ++ ",local-next=" ++ a ++ ",local-following=" ++ b)))
def binding(~Ops:Data -> Type -> Type -> Type,~User:Type,~declaration:Cmd.Program(~Observe.Schema,~Actors.C(~Observe.Schema),~Actors.R(~Observe.Schema),~Actor.components(),~Actor.resources(~Observe.Schema),~Actor.route(),~Ops),~body:Cmd.Body(~Observe.Schema,~Actor.components(),~Actor.resources(~Observe.Schema),~Actor.route(),~Ops,~User,~String,~String),~inspect:User -> User & String,value:Scope.CompiledBinding<D.Compilation<Observe.Schema,L.columns(~Observe.Schema,Actor.components()),Actors.C(~Observe.Schema),Actors.R(~Observe.Schema),Cmd.ScopedOps(~Observe.Schema,~Actor.components(),~Actor.resources(~Observe.Schema),~Actor.route(),~Ops)>,Cmd.System(~Observe.Schema,~Actors.C(~Observe.Schema),~Actors.R(~Observe.Schema),~Unit,~Actor.components(),~Actor.resources(~Observe.Schema),~Actor.route(),~Ops,~User,~String,~String,~declaration,~body)>) -> Author.Node(~Observe.Schema,~Actor.components(),~Actor.resources(~Observe.Schema),~Unit,~Actor.route(),~Ops,~User,~String,~String,~declaration,~body) & String:
  match value:
    case Scope.CompiledBinding{actualCompilation,Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,queue,permission}}}:Snapshot.with_pair(User,Author.Node(~Observe.Schema,~Actor.components(),~Actor.resources(~Observe.Schema),~Unit,~Actor.route(),~Ops,~User,~String,~String,~declaration,~body) & String,inspect(user),user => text => Snapshot.with_pair(Buffer.Buffer<Observe.Schema,Actor.Session,Removed.Removed(Actor.components())>,Author.Node(~Observe.Schema,~Actor.components(),~Actor.resources(~Observe.Schema),~Unit,~Actor.route(),~Ops,~User,~String,~String,~declaration,~body) & String,Snapshot.buffer(queue),queue => queued => (Author.retain(~Observe.Schema,~Actor.components(),~Actor.resources(~Observe.Schema),~Unit,~Actor.route(),~Ops,~User,~String,~String,~declaration,~body,Scope.CompiledBinding{actualCompilation,Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,queue,permission}}}}),text ++ "," ++ queued)))
def node(~Ops:Data -> Type -> Type -> Type,~User:Type,~declaration:Cmd.Program(~Observe.Schema,~Actors.C(~Observe.Schema),~Actors.R(~Observe.Schema),~Actor.components(),~Actor.resources(~Observe.Schema),~Actor.route(),~Ops),~body:Cmd.Body(~Observe.Schema,~Actor.components(),~Actor.resources(~Observe.Schema),~Actor.route(),~Ops,~User,~String,~String),~inspect:User -> User & String,value:Author.Node(~Observe.Schema,~Actor.components(),~Actor.resources(~Observe.Schema),~Unit,~Actor.route(),~Ops,~User,~String,~String,~declaration,~body)) -> Author.Node(~Observe.Schema,~Actor.components(),~Actor.resources(~Observe.Schema),~Unit,~Actor.route(),~Ops,~User,~String,~String,~declaration,~body) & String:
  binding(~Ops,~User,~declaration,~body,~inspect,Leaf.registered_binding(D.Compilation<Observe.Schema,L.columns(~Observe.Schema,Actor.components()),Actors.C(~Observe.Schema),Actors.R(~Observe.Schema),Cmd.ScopedOps(~Observe.Schema,~Actor.components(),~Actor.resources(~Observe.Schema),~Actor.route(),~Ops)>,Application.World(~Observe.Schema),Cmd.System(~Observe.Schema,~Actors.C(~Observe.Schema),~Actors.R(~Observe.Schema),~Unit,~Actor.components(),~Actor.resources(~Observe.Schema),~Actor.route(),~Ops,~User,~String,~String,~declaration,~body),Author.AdmissionEvidence(~Observe.Schema,~Actor.components(),~Actor.resources(~Observe.Schema),~Unit,~Actor.route(),~Ops,~User,~String,~String,~declaration,~body),Author.PrepPermit(~Observe.Schema,~Actor.components()),value))
def graph(value:Actors.GraphNode(~Observe.Schema)) -> Actors.GraphNode(~Observe.Schema) & String:
  node(~Actor.Ops(~Observe.Schema),~Actors.GraphUser<Observe.Schema>,~Actors.graph_declaration(~Observe.Schema),~Actors.graph_body(~Observe.Schema),~graph_user,value)
def removal(value:Actors.RemovalNode(~Observe.Schema)) -> Actors.RemovalNode(~Observe.Schema) & String:
  node(~Remover.Ops(~Observe.Schema),~Actors.RemovalUser<Observe.Schema>,~Actors.removal_declaration(~Observe.Schema),~Actors.removal_body(~Observe.Schema),~removal_user,value)
def updater(value:Actors.UpdaterNode(~Observe.Schema)) -> Actors.UpdaterNode(~Observe.Schema) & String:
  node(~Actors.UpdaterOps(~Observe.Schema),~Actors.UpdaterUser<Observe.Schema>,~Actors.updater_declaration(~Observe.Schema),~Actors.updater_body(~Observe.Schema),~updater_user,value)
def application(value:Application.Bound(~Observe.Schema)) -> Application.Bound(~Observe.Schema) & String:
  match value:
    case Provision.Bound{Context.Bound{context,Root.Scheduled{App.State{General.Present{W.World{namespace,allocator,columns,owners,events,registrations,clock,pending,lifecycle,notices},storage},Product.Owner{author,Product.Owner{despawner,writer}},guards,handler,stateBindings},plan,bindings,rules,deferred}}}:Snapshot.with_pair(L.columns(~Observe.Schema,Actor.components()),Application.Bound(~Observe.Schema) & String,Snapshot.components(columns),columns => componentText => Snapshot.with_pair(L.resources(~Observe.Schema,Actor.resources(~Observe.Schema)),Application.Bound(~Observe.Schema) & String,Snapshot.resources(owners),owners => resourceText => Snapshot.with_pair(Actors.GraphNode(~Observe.Schema),Application.Bound(~Observe.Schema) & String,graph(author),author => authorText => Snapshot.with_pair(Actors.RemovalNode(~Observe.Schema),Application.Bound(~Observe.Schema) & String,removal(despawner),despawner => despawnText => Snapshot.with_pair(Actors.UpdaterNode(~Observe.Schema),Application.Bound(~Observe.Schema) & String,updater(writer),writer => writerText => (Provision.Bound{Context.Bound{context,Root.Scheduled{App.State{General.Present{W.World{namespace,allocator,columns,owners,events,registrations,clock,pending,lifecycle,notices},storage},Product.Owner{author,Product.Owner{despawner,writer}},guards,handler,stateBindings},plan,bindings,rules,deferred}}},resourceText ++ "|components=" ++ componentText ++ "|" ++ authorText ++ "|" ++ despawnText ++ "|" ++ writerText))))))
    case value:(value,"retained-inventory-refusal")
def third(result:Application.Bound(~Observe.Schema) & Context.RunReport<App.Report<String,String>>) -> IO(Unit):
  match result:
    case (bound,report):Snapshot.with_pair(Application.Bound(~Observe.Schema),IO(Unit),application(bound),_ => text => IO.print("generalized/third-final/" ++ Observe.report(report) ++ "|" ++ text))
def second_printed(bound:Application.Bound(~Observe.Schema),_:Unit) -> IO(Unit):
  IO.bind(Application.Bound(~Observe.Schema) & Context.RunReport<App.Report<String,String>>,Unit,Application.run(~Observe.Schema,Application.configure(~Observe.Schema,True{},bound)),third)
def second(result:Application.Bound(~Observe.Schema) & Context.RunReport<App.Report<String,String>>) -> IO(Unit):
  match result:
    case (bound,report):Snapshot.with_pair(Application.Bound(~Observe.Schema),IO(Unit),application(bound),bound => text => IO.bind(Unit,Unit,IO.print("generalized/second-retained/" ++ Observe.report(report) ++ "|" ++ text),second_printed(bound)))
def first_printed(bound:Application.Bound(~Observe.Schema),_:Unit) -> IO(Unit):
  IO.bind(Application.Bound(~Observe.Schema) & Context.RunReport<App.Report<String,String>>,Unit,Application.run(~Observe.Schema,Application.configure(~Observe.Schema,False{},bound)),second)
def first(result:Application.Bound(~Observe.Schema) & Context.RunReport<App.Report<String,String>>) -> IO(Unit):
  match result:
    case (bound,report):Snapshot.with_pair(Application.Bound(~Observe.Schema),IO(Unit),application(bound),bound => text => IO.bind(Unit,Unit,IO.print("generalized/first-final/" ++ Observe.report(report) ++ "|" ++ text),first_printed(bound)))
def initialized(value:Initialize.Initialization<Observe.Schema>) -> IO(Unit):
  match value:
    case Initialize.Ready{_,bound}:IO.bind(Application.Bound(~Observe.Schema) & Context.RunReport<App.Report<String,String>>,Unit,Application.run(~Observe.Schema,bound),first)
    case _:IO.print("retained-initialization-refusal")
def main() -> IO(Unit):
  initialized(Initialize.create(~Observe.Schema,W.factory(),Actor.Session{401},Actor.Session{601}))
