import Base
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ./declarations.bend as D
import ./bodies.bend as Body
import ./exit.bend as Exit
import ./peer.bend as Peer
import ./registry.bend as Registry
import ./scheduled.bend as Main
import ./initialize.bend as Init
import ./allocation.bend as Allocation
import ./observation.bend as Observe
import ./owner-observation.bend as Owners
import ./reports.bend as Report
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-parallel-rootcut.bend as Root
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/execution-machine-maintenance.bend as Maintenance
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-registry-program.bend as Prog
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W

type Schema is Data:
  Schema{}
type Handler is Type:
  Handler{stop:Bool,token:Array<U32>,errors:U32}
def handling(stop:Bool) -> Exec.Handling:
  match stop:
    case True{}:Exec.Escalate{}
    case False{}:Exec.Continue{}
def handle(owner:Handler,_:String) -> Handler & Exec.Handling:
  match owner:
    case Handler{+stop,token,errors}:(Handler{stop,token,U32.add(errors,1)},handling(stop))
def handler_observed(stop:Bool,errors:U32,result:Array<U32> & U32) -> String:
  match result:
    case (_,token):Observe.bool(stop) ++ "/" ++ U32.show(token) ++ "/errors=" ++ U32.show(errors)
def handler_text(owner:Handler) -> String:
  match owner:
    case Handler{stop,token,errors}:handler_observed(stop,errors,Array.get(U32,token,0))
def Left() -> Type:Product.Owner<Registry.RequestOwner(~Schema),Product.Owner<Registry.ApplyOwner(~Schema),Exit.Owner(~Schema)>>
def left(~F:Tree.Family(),~leaf:Tree.Leaf(~Schema,~D.Store(~Schema),~D.LeftStore(~Schema),~D.Resources(~Schema),~Unit,~D.root_layout(~Schema),~String,~String,~F),~command:Tree.CommandLeaf(~Schema,~D.Store(~Schema),~D.LeftStore(~Schema),~D.Resources(~Schema),~Unit,~D.root_layout(~Schema),~String,~String,~F),~join:Tree.Join(~F),owners:Left()) -> F(Left()):
  match owners:
    case Product.Owner{request,Product.Owner{marker,exit}}:join(Registry.RequestOwner(~Schema),Product.Owner<Registry.ApplyOwner(~Schema),Exit.Owner(~Schema)>,leaf(D.request_ops(~Schema),Body.Local(),Build.framework_program(~Schema,~D.Store(~Schema),~D.LeftStore(~Schema),~D.Resources(~Schema),~D.request_ops(~Schema),~D.request(~Schema)),Body.request(~Schema),request),join(Registry.ApplyOwner(~Schema),Exit.Owner(~Schema),leaf(D.apply_ops(~Schema),Body.Local(),Build.framework_program(~Schema,~D.Store(~Schema),~D.LeftStore(~Schema),~D.Resources(~Schema),~D.apply_ops(~Schema),~D.apply(~Schema)),Body.apply(~Schema),marker),command(D.component_layout(~Schema),Exit.route(),{==},{==},Exit.Ops(~Schema),Exit.User<Schema>,Exit.declaration(~Schema),Exit.body(~Schema),exit)))
def Right() -> Type:Peer.Owner(~Schema)
def right(~F:Tree.Family(),~leaf:Tree.Leaf(~Schema,~D.Store(~Schema),~D.RightStore(~Schema),~Unit,~Unit,~D.root_layout(~Schema),~String,~String,~F),~command:Tree.CommandLeaf(~Schema,~D.Store(~Schema),~D.RightStore(~Schema),~Unit,~Unit,~D.root_layout(~Schema),~String,~String,~F),~join:Tree.Join(~F),owner:Right()) -> F(Right()):
  leaf(Peer.Ops(~Schema),Peer.Local<Schema>,Build.framework_program(~Schema,~D.Store(~Schema),~D.RightStore(~Schema),~Unit,~Peer.Ops(~Schema),~Peer.declaration(~Schema)),Peer.body(~Schema),owner)
def World() -> Type:Main.World(~Schema)
def Inner() -> Type:App.State<World(),Product.Owner<Left(),Right()>,Unit,Handler>
def Application() -> Type:Schedule.Scheduled<Inner()>
# Root chooses deferred application before this machine hook. A completed run
# rotates messages even with final application disabled; escalation preserves
# the generations and every authored command for the caller's next decision.
def completed(result:Application() & App.Report<String,String>) -> Application() & App.Report<String,String>:
  Maintenance.completed(~Schema,~D.Key,~D.Mode,~D.Store(~Schema),~Main.Resources(~Schema),~Unit,~Layout.LayoutPair{D.layout(~Schema),Layout.EmptyLayout{}},~Layout.InLeft{Layout.AtLeaf{}},~{==},~Main.machine_shape(~Schema),~Product.Owner<Left(),Right()>,~Unit,~Handler,~String,~String,result)
def pending(app:Application()) -> Application() & Bool:
  Schedule.pending(~Schema,~D.LeftStore(~Schema),~D.RightStore(~Schema),~D.Resources(~Schema),~Unit,~Unit,~D.root_layout(~Schema),~{==},~String,~String,~Left(),~Right(),~left,~right,~Unit,~Handler,~Conditions.empty_dispatch(~World(),~String),~Conditions.empty(~World(),~String),~handle,app)
def final(result:Application() & (App.Report<String,String> & Bool)) -> String:
  match result:
    case (Schedule.Scheduled{App.State{world,Product.Owner{Product.Owner{request,Product.Owner{marker,exit}},peer},_,handler,_},_,_,_,Schedule.Deferred{systems,_,unapplied}},(report,buffered)):Report.report(report) ++ "|buffered=" ++ Observe.bool(buffered) ++ "|command-systems=" ++ List.show(&2,U32,U32.show,systems) ++ "|unapplied=" ++ List.show(&2,U32,U32.show,unapplied) ++ "|world{" ++ Observe.world(~Schema,world) ++ "}|request{" ++ Owners.enter(~Schema,request) ++ "}|marker{" ++ Owners.apply(~Schema,marker) ++ "}|exit{" ++ Owners.exit(~Schema,exit) ++ "}|peer{" ++ Owners.peer(~Schema,peer) ++ "}|handler=" ++ handler_text(handler)
def retained(report:App.Report<String,String>,result:Application() & Bool) -> Application() & (App.Report<String,String> & Bool):
  match result:
    case (app,buffered):(app,(report,buffered))
def returned(result:Application() & App.Report<String,String>) -> Application() & (App.Report<String,String> & Bool):
  match result:
    case (app,report):retained(report,pending(app))
def run_retained(app:Application()) -> IO(Application() & (App.Report<String,String> & Bool)):
  IO.bind(Application() & App.Report<String,String>,Application() & (App.Report<String,String> & Bool),Schedule.run_native(~Schema,~D.LeftStore(~Schema),~D.RightStore(~Schema),~D.Resources(~Schema),~Unit,~Unit,~D.root_layout(~Schema),~{==},~String,~String,~Left(),~Right(),~left,~right,~Unit,~Handler,~Conditions.empty_dispatch(~World(),~String),~Conditions.empty(~World(),~String),~handle,app),result => IO.pure(Application() & (App.Report<String,String> & Bool),returned(completed(result))))
def run_once(app:Application()) -> IO(String):IO.bind(Application() & (App.Report<String,String> & Bool),String,run_retained(app),result => IO.pure(String,final(result)))
def built(stop:Bool,finalApply:Bool,world:World(),request:Registry.RequestOwner(~Schema),marker:Registry.ApplyOwner(~Schema),exit:Exit.Owner(~Schema),peer:Right()) -> IO(String):
  run_once(Schedule.configure(~Inner(),Settings.Settings{False{},finalApply,[],[]},Schedule.build(~Schema,~D.LeftStore(~Schema),~D.RightStore(~Schema),~D.Resources(~Schema),~Unit,~Unit,~D.root_layout(~Schema),~{==},~String,~String,~Left(),~Right(),~left,~right,~Unit,~Handler,~Conditions.empty_dispatch(~World(),~String),~Conditions.empty(~World(),~String),~handle,~Report.available,world,Product.Owner{Product.Owner{request,Product.Owner{marker,exit}},peer},Unit{},Handler{stop,ALeaf{801},0},[Plan.Edge{1,2},Plan.Edge{2,3},Plan.Edge{2,4}],[])))
def peer_defined(stop:Bool,finalApply:Bool,request:Registry.RequestOwner(~Schema),marker:Registry.ApplyOwner(~Schema),exit:Exit.Owner(~Schema),result:Sys.Defined<World(),Right(),Peer.Local<Schema>>) -> IO(String):
  match result:
    case Sys.Defined{world,peer}:built(stop,finalApply,world,request,marker,exit,peer)
    case Sys.DefinitionRefused{_,_}:IO.pure(String,"ERROR:peer")
def exit_defined(stop:Bool,finalApply:Bool,handle:W.Handle<Schema>,request:Registry.RequestOwner(~Schema),marker:Registry.ApplyOwner(~Schema),result:Sys.Defined<World(),Exit.Owner(~Schema),Exit.Captures(~Schema)>) -> IO(String):
  match result:
    case Sys.Defined{world,exit}:peer_defined(stop,finalApply,request,marker,exit,Task.define(~Schema,~D.Store(~Schema),~D.RightStore(~Schema),~Unit,~Unit,~Peer.Ops(~Schema),~Peer.Local<Schema>,~String,~String,~Peer.declaration(~Schema),~Peer.body(~Schema),~Main.Resources(~Schema),world,"independent-peer",Peer.Local{handle,Body.local(201,202)}))
    case Sys.DefinitionRefused{_,_}:IO.pure(String,"ERROR:exit")
def marker_defined(stop:Bool,finalApply:Bool,+handle:W.Handle<Schema>,request:Registry.RequestOwner(~Schema),result:Sys.Defined<World(),Registry.ApplyOwner(~Schema),Body.Local()>) -> IO(String):
  match result:
    case Sys.Defined{world,marker}:exit_defined(stop,finalApply,handle,request,marker,Cmd.define(~Schema,~D.LeftStore(~Schema),~D.Resources(~Schema),~Unit,~D.component_layout(~Schema),~D.root_layout(~Schema),~Exit.route(),~{==},~Exit.Ops(~Schema),~Exit.User<Schema>,~String,~String,~Exit.declaration(~Schema),~Exit.body(~Schema),~Main.Resources(~Schema),world,"exit",Exit.User{handle,Body.local(301,302)}))
    case Sys.DefinitionRefused{_,_}:IO.pure(String,"ERROR:marker")
def request_defined(stop:Bool,finalApply:Bool,handle:W.Handle<Schema>,result:Sys.Defined<World(),Registry.RequestOwner(~Schema),Body.Local()>) -> IO(String):
  match result:
    case Sys.Defined{world,request}:marker_defined(stop,finalApply,handle,request,Task.define(~Schema,~D.Store(~Schema),~D.LeftStore(~Schema),~D.Resources(~Schema),~Unit,~D.apply_ops(~Schema),~Body.Local(),~String,~String,~D.apply(~Schema),~Body.apply(~Schema),~Main.Resources(~Schema),world,"transition-marker",Body.local(101,102)))
    case Sys.DefinitionRefused{_,_}:IO.pure(String,"ERROR:request")
def allocated(stop:Bool,finalApply:Bool,result:Allocation.Allocation<Schema>) -> IO(String):
  match result:
    case Allocation.Ready{world,handle}:request_defined(stop,finalApply,handle,Task.define(~Schema,~D.Store(~Schema),~D.LeftStore(~Schema),~D.Resources(~Schema),~Unit,~D.request_ops(~Schema),~Body.Local(),~String,~String,~D.request(~Schema),~Body.request(~Schema),~Main.Resources(~Schema),world,"request",Body.local(401,402)))
    case Allocation.Refused{_,_}:IO.pure(String,"ERROR:allocation")
def created(stop:Bool,finalApply:Bool,result:W.Creation<Schema,D.Store(~Schema),Main.Resources(~Schema),Unit>) -> IO(String):
  match result:
    case W.Created{_,world}:allocated(stop,finalApply,Allocation.allocate(~Schema,Init.setup(~Schema,world)))
    case W.CreateRejected{_,_}:IO.pure(String,"ERROR:create")
def run(stop:Bool,finalApply:Bool) -> IO(String):
  created(stop,finalApply,W.create(~Schema,~D.Store(~Schema),~Main.Resources(~Schema),~Unit,~Main.empty(~Schema),W.factory(),Main.resources(~Schema)))
def main() -> IO(Unit):IO.bind(String,Unit,run(False{},False{}),first => IO.bind(String,Unit,run(True{},True{}),second => IO.print("final-off{" ++ first ++ "}\nstop{" ++ second ++ "}")))
