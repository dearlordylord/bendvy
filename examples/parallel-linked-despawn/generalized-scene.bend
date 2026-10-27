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
import ../../src/ecs/execution-state.bend as State
import ../../src/ecs/execution-query-schema.bend as QuerySchema
import ../../src/ecs/execution-parallel-registration.bend as Registration
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/execution-owner-continuation.bend as Continuation

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
def Columns() -> Type:L.columns(~Observe.Schema,Actor.components())
def Resources() -> Type:L.resources(~Observe.Schema,Actor.resources(~Observe.Schema))
type Metadata is Type:
  Metadata{context:Initialize.Captured(~Observe.Schema),administration:State.Administration<Observe.Schema,Columns(),Resources(),Unit>,displaced:List<&1,QuerySchema.displacements(~Observe.Schema,Actor.components())>,guards:Unit,handler:Unit,stateBindings:List<&2,App.Binding>,plan:Plan.Build<String>,bindings:List<&2,App.Binding>,rules:Registration.Rules,deferred:Root.Deferred}
type Frame<-C:Type,-R:Type,-N:Type> is Type:
  Frame{metadata:Metadata,columns:C,resources:R,nodes:N,texts:List<&2,String>}
def rendered(texts:List<&2,String>) -> String:
  match texts:
    case writer <> despawn <> author <> resources <> components <> []:resources ++ "|components=" ++ components ++ "|" ++ author ++ "|" ++ despawn ++ "|" ++ writer
    case _:"retained-observation-inventory"
def observed_bound(bound:Application.Bound(~Observe.Schema),texts:List<&2,String>) -> Application.Bound(~Observe.Schema) & String:
  continuation:Continuation.Header<String,(Application.Bound(~Observe.Schema) & String)> = Continuation.Header{Application.Bound(~Observe.Schema),bound,bound => text => (bound,text)}
  Continuation.returned(String,Application.Bound(~Observe.Schema) & String,continuation,rendered(texts))
def assembled(metadata:Metadata,columns:Columns(),resources:Resources(),nodes:Application.Nodes(~Observe.Schema),texts:List<&2,String>) -> Application.Bound(~Observe.Schema) & String:
  match metadata:
    case Metadata{context,State.Administration{namespace,allocator,events,pending,registrations,nextSystemId,clock,lifecycle},displaced,guards,handler,stateBindings,plan,bindings,rules,deferred}:observed_bound(Provision.Bound{Context.Bound{context,Root.Scheduled{App.State{General.Present{W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystemId,clock,lifecycle},displaced},nodes,guards,handler,stateBindings},plan,bindings,rules,deferred}}},texts)
def updater_seen(frame:Frame<Columns(),Resources(),Product.Owner<Actors.GraphNode(~Observe.Schema),Actors.RemovalNode(~Observe.Schema)>>,result:Actors.UpdaterNode(~Observe.Schema) & String) -> Application.Bound(~Observe.Schema) & String:
  match frame result:
    case Frame{metadata,columns,resources,Product.Owner{author,despawner},texts}, (writer,text):assembled(metadata,columns,resources,Product.Owner{author,Product.Owner{despawner,writer}},text <> texts)
def removal_seen(frame:Frame<Columns(),Resources(),Product.Owner<Actors.GraphNode(~Observe.Schema),Actors.UpdaterNode(~Observe.Schema)>>,result:Actors.RemovalNode(~Observe.Schema) & String) -> Application.Bound(~Observe.Schema) & String:
  match frame result:
    case Frame{metadata,columns,resources,Product.Owner{author,writer},texts}, (despawner,text):
      continuation:Continuation.Header<(Actors.UpdaterNode(~Observe.Schema) & String),(Application.Bound(~Observe.Schema) & String)> = Continuation.Header{Frame<Columns(),Resources(),Product.Owner<Actors.GraphNode(~Observe.Schema),Actors.RemovalNode(~Observe.Schema)>>,Frame{metadata,columns,resources,Product.Owner{author,despawner},text <> texts},frame => result => updater_seen(frame,result)}
      Continuation.returned(Actors.UpdaterNode(~Observe.Schema) & String,Application.Bound(~Observe.Schema) & String,continuation,updater(writer))
def graph_seen(frame:Frame<Columns(),Resources(),Application.Tail(~Observe.Schema)>,result:Actors.GraphNode(~Observe.Schema) & String) -> Application.Bound(~Observe.Schema) & String:
  match frame result:
    case Frame{metadata,columns,resources,Product.Owner{despawner,writer},texts}, (author,text):
      continuation:Continuation.Header<(Actors.RemovalNode(~Observe.Schema) & String),(Application.Bound(~Observe.Schema) & String)> = Continuation.Header{Frame<Columns(),Resources(),Product.Owner<Actors.GraphNode(~Observe.Schema),Actors.UpdaterNode(~Observe.Schema)>>,Frame{metadata,columns,resources,Product.Owner{author,writer},text <> texts},frame => result => removal_seen(frame,result)}
      Continuation.returned(Actors.RemovalNode(~Observe.Schema) & String,Application.Bound(~Observe.Schema) & String,continuation,removal(despawner))
def resources_seen(frame:Frame<Columns(),Unit,Application.Nodes(~Observe.Schema)>,result:Resources() & String) -> Application.Bound(~Observe.Schema) & String:
  match frame result:
    case Frame{metadata,columns,_,Product.Owner{author,tail},texts}, (resources,text):
      continuation:Continuation.Header<(Actors.GraphNode(~Observe.Schema) & String),(Application.Bound(~Observe.Schema) & String)> = Continuation.Header{Frame<Columns(),Resources(),Application.Tail(~Observe.Schema)>,Frame{metadata,columns,resources,tail,text <> texts},frame => result => graph_seen(frame,result)}
      Continuation.returned(Actors.GraphNode(~Observe.Schema) & String,Application.Bound(~Observe.Schema) & String,continuation,graph(author))
def columns_seen(frame:Frame<Unit,Resources(),Application.Nodes(~Observe.Schema)>,result:Columns() & String) -> Application.Bound(~Observe.Schema) & String:
  match frame result:
    case Frame{metadata,_,resources,nodes,texts}, (columns,text):
      continuation:Continuation.Header<(Resources() & String),(Application.Bound(~Observe.Schema) & String)> = Continuation.Header{Frame<Columns(),Unit,Application.Nodes(~Observe.Schema)>,Frame{metadata,columns,Unit{},nodes,text <> texts},frame => result => resources_seen(frame,result)}
      Continuation.returned(Resources() & String,Application.Bound(~Observe.Schema) & String,continuation,Snapshot.resources(resources))
def application(value:Application.Bound(~Observe.Schema)) -> Application.Bound(~Observe.Schema) & String:
  match value:
    case Provision.Bound{Context.Bound{context,Root.Scheduled{App.State{General.Present{W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystemId,clock,lifecycle},displaced},nodes,guards,handler,stateBindings},plan,bindings,rules,deferred}}}:
      continuation:Continuation.Header<(Columns() & String),(Application.Bound(~Observe.Schema) & String)> = Continuation.Header{Frame<Unit,Resources(),Application.Nodes(~Observe.Schema)>,Frame{Metadata{context,State.Administration{namespace,allocator,events,pending,registrations,nextSystemId,clock,lifecycle},displaced,guards,handler,stateBindings,plan,bindings,rules,deferred},Unit{},resources,nodes,[]},frame => result => columns_seen(frame,result)}
      Continuation.returned(Columns() & String,Application.Bound(~Observe.Schema) & String,continuation,Snapshot.components(columns))
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
