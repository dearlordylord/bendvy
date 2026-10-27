import Base
import ../../src/ecs/execution-builder.bend as Build
import ./declarations.bend as D
import ./bodies.bend as Body
import ./registry.bend as Registry
import ./peer.bend as Peer
import ./guard-registry.bend as Guards
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ./conditions.bend as Cond
import ./actor.bend as Actor
import ./exit.bend as Exit
import ./allocation.bend as Alloc
import ./events.bend as Events
import ./observation.bend as Observe
import ./owner-observation.bend as Owners
import ../../src/ecs/execution-command-system.bend as Cmd
import ./reports.bend as Report
import ./initialize.bend as Init
import ../../src/ecs/execution-machine-state.bend as State
import ../../src/ecs/execution-machine-maintenance.bend as Maintenance
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/execution-parallel-app.bend as Pair
import ../../src/ecs/execution-parallel-rootcut.bend as Root
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-registry-program.bend as Prog
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-plan.bend as Plan

def Resources(~S:Data) -> Type:Product.Owner<D.Resources(~S),Unit>
def World(~S:Data) -> Type:W.World<S,D.Store(~S),Resources(~S),Unit>
def PeerOwner(~S:Data) -> Type:Peer.Owner(~S)
def peer_tree(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~D.Store(~S),~D.RightStore(~S),~Unit,~Unit,~D.root_layout(S),~String,~String,~F),~command:Tree.CommandLeaf(~S,~D.Store(~S),~D.RightStore(~S),~Unit,~Unit,~D.root_layout(S),~String,~String,~F),~join:Tree.Join(~F),owner:PeerOwner(~S)) -> F(PeerOwner(~S)):
  leaf(Peer.Ops(~S),Peer.Local<S>,Build.framework_program(~S,~D.Store(~S),~D.RightStore(~S),~Unit,~Peer.Ops(~S),~Peer.declaration(~S)),Peer.body(~S),owner)
def Application(~S:Data) -> Type:Schedule.Scheduled<App.State<World(~S),Product.Owner<Registry.Owners(~S),PeerOwner(~S)>,Guards.Owners(~S),Report.Handler>>
type BuildResult<-S:Data> is Type:
  BuildReady{app:Application(~S)}
  BuildRefused{error:String}
def empty(~S:Data,_:Unit) -> D.Store(~S):Layout.empty_columns(~S,D.component_layout(~S))
def resources(~S:Data) -> Resources(~S):
  Product.Owner{Layout.ResourceSlot{Layout.initialize(D.layout(S),Layout.AtLeaf{},State.empty(~S,~D.Key,~D.Mode)),Layout.unknown_stamp()},Unit{}}
def machine_shape(~S:Data) -> {Layout.payload(Cond.layout(S),Layout.InLeft{Layout.AtLeaf{}}) == State.Cell<S,D.Key,D.Mode> : Type}:{==}
def completed(~S:Data,result:Application(~S) & App.Report<String,String>) -> Application(~S) & App.Report<String,String>:
  Maintenance.completed(~S,~D.Key,~D.Mode,~D.Store(~S),~Resources(~S),~Unit,~Cond.layout(S),~Layout.InLeft{Layout.AtLeaf{}},~{==},~machine_shape(~S),~Product.Owner<Registry.Owners(~S),PeerOwner(~S)>,~Guards.Owners(~S),~Report.Handler,~String,~String,result)
def run_once(~S:Data,app:Application(~S)) -> IO(Application(~S) & App.Report<String,String>):
  IO.bind(Application(~S) & App.Report<String,String>,Application(~S) & App.Report<String,String>,Schedule.run_serial_retained(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.Resources(~S),~Unit,~Unit,~D.root_layout(S),~{==},~String,~String,~Registry.Owners(~S),~PeerOwner(~S),~Registry.handlers(~S),~peer_tree(~S),~Guards.Owners(~S),~Report.Handler,~Guards.dispatch(~S),~Report.handle,app),result => IO.pure(Application(~S) & App.Report<String,String>,completed(~S,result)))
def finished(~S:Data,history:List<&2,String>,app:Application(~S)) -> String:
  match app:
    case Schedule.Scheduled{App.State{world,Product.Owner{left,right},guards,handler,_},_,_,_,_}:"runs=" ++ List.show(&2,String,Observe.text,history) ++ "|world{" ++ Observe.world(~S,world) ++ "}|owners{" ++ Owners.left(~S,left) ++ ";peer{" ++ Owners.peer(~S,right) ++ "}}|guards{" ++ Owners.guards(~S,guards) ++ "}|handler=" ++ Report.handler(handler)
def continued(~S:Data,next:List<&2,String> -> Application(~S) -> IO(String),history:List<&2,String>,result:Application(~S) & App.Report<String,String>) -> IO(String):
  match result:
    case (app,status):next(List.append(&2,String,history,[Report.report(status)]),app)
def updates(~S:Data,fuel:Nat,history:List<&2,String>,app:Application(~S)) -> IO(String):
  match fuel:
    case 0n:IO.pure(String,finished(~S,history,app))
    case 1n++rest:IO.bind(Application(~S) & App.Report<String,String>,String,run_once(~S,app),result => continued(~S,history => app => updates(~S,rest,history,app),history,result))
def guard_running_defined(~S:Data,owners:Registry.Owners(~S),peer:PeerOwner(~S),exit:Guards.Owner(~S),transition:Guards.Owner(~S),enter:Guards.Owner(~S),result:Guards.Compilation(~S) & Sys.Defined<World(~S),Guards.System(~S),Cond.Local>) -> IO(BuildResult<S>):
  match result:
    case (compilation,Sys.Defined{world,running}):IO.pure(BuildResult<S>,BuildReady{Schedule.build_retained(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.Resources(~S),~Unit,~Unit,~D.root_layout(S),~{==},~String,~String,~Registry.Owners(~S),~PeerOwner(~S),~Registry.handlers(~S),~peer_tree(~S),~Guards.Owners(~S),~Report.Handler,~Guards.dispatch(~S),~Guards.selection(~S),~Report.handle,~Report.available,world,Product.Owner{owners,peer},Guards.pack(~S,exit,transition,enter,Scope.CompiledBinding{compilation,running}),Report.Handler{ALeaf{801},0},[Plan.Edge{1,3},Plan.Edge{3,4},Plan.Edge{4,5},Plan.Edge{5,6},Plan.Edge{6,7}],[App.Binding{3,8},App.Binding{4,9},App.Binding{5,10},App.Binding{6,11},App.Binding{7,11}])})
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(BuildResult<S>,BuildRefused{"ERROR:running-guard"})
def guard_enter_defined(~S:Data,owners:Registry.Owners(~S),peer:PeerOwner(~S),exit:Guards.Owner(~S),transition:Guards.Owner(~S),result:Guards.Compilation(~S) & Sys.Defined<World(~S),Guards.System(~S),Cond.Local>) -> IO(BuildResult<S>):
  match result:
    case (compilation,Sys.Defined{world,enter}):guard_running_defined(~S,owners,peer,exit,transition,Scope.CompiledBinding{compilation,enter},Guards.define(~S,world,"running-guard",Cond.Local{ALeaf{902},Cond.Running{}}))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(BuildResult<S>,BuildRefused{"ERROR:enter-guard"})
def guard_transition_defined(~S:Data,owners:Registry.Owners(~S),peer:PeerOwner(~S),exit:Guards.Owner(~S),result:Guards.Compilation(~S) & Sys.Defined<World(~S),Guards.System(~S),Cond.Local>) -> IO(BuildResult<S>):
  match result:
    case (compilation,Sys.Defined{world,transition}):guard_enter_defined(~S,owners,peer,exit,Scope.CompiledBinding{compilation,transition},Guards.define(~S,world,"enter-guard",Cond.Local{ALeaf{901},Cond.Enter{}}))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(BuildResult<S>,BuildRefused{"ERROR:transition-guard"})
def guard_exit_defined(~S:Data,owners:Registry.Owners(~S),peer:PeerOwner(~S),result:Guards.Compilation(~S) & Sys.Defined<World(~S),Guards.System(~S),Cond.Local>) -> IO(BuildResult<S>):
  match result:
    case (compilation,Sys.Defined{world,exit}):guard_transition_defined(~S,owners,peer,Scope.CompiledBinding{compilation,exit},Guards.define(~S,world,"transition-guard",Cond.Local{ALeaf{900},Cond.Transition{}}))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(BuildResult<S>,BuildRefused{"ERROR:exit-guard"})
def events_defined(~S:Data,apply:Registry.ApplyOwner(~S),exit:Registry.ExitOwner(~S),transition:Registry.ReadOwner(~S),enter:Registry.RequestOwner(~S),peer:PeerOwner(~S),read:Registry.ActorOwner(~S),result:Sys.Defined<World(~S),Events.Owner(~S),Events.Local<S>>) -> IO(BuildResult<S>):
  match result:
    case Sys.Defined{world,events}:guard_exit_defined(~S,Registry.pack(~S,apply,exit,transition,enter,read,events),peer,Guards.define(~S,world,"exit-guard",Cond.Local{ALeaf{900},Cond.Exit{}}))
    case Sys.DefinitionRefused{_,_}:IO.pure(BuildResult<S>,BuildRefused{"ERROR:events"})
def read_defined(~S:Data,apply:Registry.ApplyOwner(~S),exit:Registry.ExitOwner(~S),transition:Registry.ReadOwner(~S),enter:Registry.RequestOwner(~S),peer:PeerOwner(~S),result:Sys.Defined<World(~S),Registry.ActorOwner(~S),Actor.Local<S>>) -> IO(BuildResult<S>):
  match result:
    case Sys.Defined{world,read}:events_defined(~S,apply,exit,transition,enter,peer,read,Events.define(~S,~Resources(~S),world,"transition-events",Body.local(701,702)))
    case Sys.DefinitionRefused{_,_}:IO.pure(BuildResult<S>,BuildRefused{"ERROR:read"})
def enter_defined(~S:Data,handle:W.Handle<S>,apply:Registry.ApplyOwner(~S),exit:Registry.ExitOwner(~S),transition:Registry.ReadOwner(~S),peer:PeerOwner(~S),result:Sys.Defined<World(~S),Registry.RequestOwner(~S),Body.Local()>) -> IO(BuildResult<S>):
  match result:
    case Sys.Defined{world,enter}:read_defined(~S,apply,exit,transition,enter,peer,Task.define(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~Unit,~Actor.Ops(~S),~Actor.Local<S>,~String,~String,~Actor.declaration(~S),~Actor.body(~S),~Resources(~S),world,"state-running",Actor.Local{handle,Body.local(601,602)}))
    case Sys.DefinitionRefused{_,_}:IO.pure(BuildResult<S>,BuildRefused{"ERROR:enter"})
def transition_defined(~S:Data,handle:W.Handle<S>,apply:Registry.ApplyOwner(~S),exit:Registry.ExitOwner(~S),peer:PeerOwner(~S),result:Sys.Defined<World(~S),Registry.ReadOwner(~S),Body.Local()>) -> IO(BuildResult<S>):
  match result:
    case Sys.Defined{world,transition}:enter_defined(~S,handle,apply,exit,transition,peer,Task.define(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~Unit,~D.request_ops(~S),~Body.Local(),~String,~String,~D.request(~S),~Body.request(~S),~Resources(~S),world,"enter",Body.local(501,502)))
    case Sys.DefinitionRefused{_,_}:IO.pure(BuildResult<S>,BuildRefused{"ERROR:transition"})
def exit_defined(~S:Data,handle:W.Handle<S>,apply:Registry.ApplyOwner(~S),peer:PeerOwner(~S),result:Sys.Defined<World(~S),Registry.ExitOwner(~S),Exit.Captures(~S)>) -> IO(BuildResult<S>):
  match result:
    case Sys.Defined{world,exit}:transition_defined(~S,handle,apply,exit,peer,Task.define(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~Unit,~D.read_ops(~S),~Body.Local(),~String,~String,~D.read(~S),~Body.read(~S),~Resources(~S),world,"transition",Body.local(401,402)))
    case Sys.DefinitionRefused{_,_}:IO.pure(BuildResult<S>,BuildRefused{"ERROR:exit"})
def registered(~S:Data,+handle:W.Handle<S>,result:Pair.Definition<World(~S),Registry.ApplyOwner(~S),PeerOwner(~S),Body.Local(),Peer.Local<S>>) -> IO(BuildResult<S>):
  match result:
    case Pair.Defined{Pair.ParallelApp{world,apply,peer}}:exit_defined(~S,handle,apply,peer,Cmd.define(~S,~D.LeftStore(~S),~D.Resources(~S),~Unit,~D.component_layout(~S),~D.root_layout(S),~Exit.route(),~{==},~Exit.Ops(~S),~Exit.User<S>,~String,~String,~Exit.declaration(~S),~Exit.body(~S),~Resources(~S),world,"exit",Exit.User{handle,Body.local(301,302)}))
    case Pair.LeftRefused{_,_,_}:IO.pure(BuildResult<S>,BuildRefused{"ERROR:apply"})
    case Pair.RightRefused{_,_,_}:IO.pure(BuildResult<S>,BuildRefused{"ERROR:peer"})
def allocated(~S:Data,result:Alloc.Allocation<S>) -> IO(BuildResult<S>):
  match result:
    case Alloc.AllocationReady{world,+handle}:registered(~S,handle,Pair.define(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.Resources(~S),~Unit,~Unit,~Body.Local(),~Peer.Local<S>,~String,~String,~String,~String,~D.apply_ops(~S),~Peer.Ops(~S),~D.apply(~S),~Peer.declaration(~S),~Body.apply(~S),~Peer.body(~S),world,"state-marker","peer",Body.local(101,102),Peer.Local{handle,Body.local(201,202)}))
    case Alloc.Refused{_,_}:IO.pure(BuildResult<S>,BuildRefused{"ERROR:allocation"})
def initialized(~S:Data,world:World(~S)) -> IO(BuildResult<S>):allocated(~S,Alloc.allocate(~S,world))
def created(~S:Data,result:W.Creation<S,D.Store(~S),Resources(~S),Unit>) -> IO(BuildResult<S>):
  match result:
    case W.Created{_,world}:initialized(~S,Init.setup(~S,world))
    case W.CreateRejected{_,_}:IO.pure(BuildResult<S>,BuildRefused{"ERROR:create"})
def prepare(~S:Data) -> IO(BuildResult<S>):created(~S,W.create(~S,~D.Store(~S),~Resources(~S),~Unit,~empty(~S),W.factory(),resources(~S)))
def execute_prepared(~S:Data,result:BuildResult<S>) -> IO(String):
  match result:
    case BuildReady{app}:updates(~S,4n,[],app)
    case BuildRefused{error}:IO.pure(String,error)
def run(~S:Data) -> IO(String):
  IO.bind(BuildResult<S>,String,prepare(~S),built => execute_prepared(~S,built))
type Schema is Data:
  Schema{}
def main() -> IO(Unit):IO.bind(String,Unit,run(~Schema),IO.print)
