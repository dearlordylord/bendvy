import Base
import ../../src/ecs/execution-builder.bend as Build
import ./declarations.bend as D
import ./bodies.bend as Body
import ./observe.bend as Observe
import ./reports.bend as Common
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/execution-parallel-app.bend as Pair
import ../../src/ecs/execution-parallel-rootcut.bend as Root
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/change-tick.bend as Tick
def World(~S:Data) -> Type:W.World<S,D.Store(~S),D.Resources(~S),Unit>
def LeftOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.LeftStore(~S),D.LeftResource(~S),Unit,D.LeftOps(~S),Body.LeftLocal(),String,String,Build.framework_program(~S,~D.Store(~S),~D.LeftStore(~S),~D.LeftResource(~S),~D.LeftOps(~S),~D.left(~S)),Body.left(~S)>
def RightOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.RightStore(~S),D.RightResource(~S),Unit,D.RightOps(~S),Body.RightLocal(),String,String,Build.framework_program(~S,~D.Store(~S),~D.RightStore(~S),~D.RightResource(~S),~D.RightOps(~S),~D.right(~S)),Body.right(~S)>
def LeftTree(~S:Data) -> Type:Product.Owner<LeftOwner(~S),LeftOwner(~S)>
def left_tree(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~D.Store(~S),~D.LeftStore(~S),~D.LeftResource(~S),~Unit,~String,~String,~F),~command:Tree.CommandLeaf(~S,~D.Store(~S),~D.LeftStore(~S),~D.LeftResource(~S),~Unit,~String,~String,~F),~join:Tree.Join(~F),owners:LeftTree(~S)) -> F(LeftTree(~S)):
  match owners:
    case Product.Owner{left,other}:join(LeftOwner(~S),LeftOwner(~S),leaf(D.LeftOps(~S),Body.LeftLocal(),Build.framework_program(~S,~D.Store(~S),~D.LeftStore(~S),~D.LeftResource(~S),~D.LeftOps(~S),~D.left(~S)),Body.left(~S),left),leaf(D.LeftOps(~S),Body.LeftLocal(),Build.framework_program(~S,~D.Store(~S),~D.LeftStore(~S),~D.LeftResource(~S),~D.LeftOps(~S),~D.left(~S)),Body.left(~S),other))
def right_tree(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~D.Store(~S),~D.RightStore(~S),~D.RightResource(~S),~Unit,~String,~String,~F),~command:Tree.CommandLeaf(~S,~D.Store(~S),~D.RightStore(~S),~D.RightResource(~S),~Unit,~String,~String,~F),~join:Tree.Join(~F),owner:RightOwner(~S)) -> F(RightOwner(~S)):
  leaf(D.RightOps(~S),Body.RightLocal(),Build.framework_program(~S,~D.Store(~S),~D.RightStore(~S),~D.RightResource(~S),~D.RightOps(~S),~D.right(~S)),Body.right(~S),owner)
def Application(~S:Data) -> Type:Schedule.Scheduled<DepApp.State<World(~S),Product.Owner<LeftTree(~S),RightOwner(~S)>,Unit,Common.Handler>>
def report(value:DepApp.Report<String,String>) -> String:Common.report(value)
def observed(~S:Data,trace:String,app:Application(~S)) -> String:
  match app:
    case Schedule.Scheduled{DepApp.State{world,Product.Owner{Product.Owner{Sys.Owner{_,_,_,_,lc,ll},Sys.Owner{_,_,_,_,oc,ol}},Sys.Owner{_,_,_,_,rc,rl}},_,handler,_},_,_,_,_}:trace ++ "|world=" ++ Observe.world(~S,world) ++ "|locals=" ++ Body.observe_left(ll) ++ "," ++ Body.observe_right(rl) ++ "," ++ Body.observe_left(ol) ++ "|cursors=" ++ Tick.cursor_show(lc) ++ "," ++ Tick.cursor_show(rc) ++ "," ++ Tick.cursor_show(oc) ++ "|handler=" ++ Common.handler(handler)
def run_selected(~S:Data,native:Bool,app:Application(~S)) -> IO(Application(~S) & DepApp.Report<String,String>):
  match native:
    case False{}:Schedule.run_serial(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~String,~String,~LeftTree(~S),~RightOwner(~S),~left_tree(~S),~right_tree(~S),~Unit,~Common.Handler,~Conditions.empty_dispatch(~W.World<S,D.Store(~S),D.Resources(~S),Unit>,~String),~Conditions.empty(~W.World<S,D.Store(~S),D.Resources(~S),Unit>,~String),~Common.handle,app)
    case True{}:Schedule.run_native(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~String,~String,~LeftTree(~S),~RightOwner(~S),~left_tree(~S),~right_tree(~S),~Unit,~Common.Handler,~Conditions.empty_dispatch(~W.World<S,D.Store(~S),D.Resources(~S),Unit>,~String),~Conditions.empty(~W.World<S,D.Store(~S),D.Resources(~S),Unit>,~String),~Common.handle,app)
def third(~S:Data,trace:String,result:Application(~S) & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):observed(~S,trace ++ "|" ++ report(status),app)
def second(~S:Data,native:Bool,trace:String,result:Application(~S) & DepApp.Report<String,String>) -> IO(String):
  match result:
    case (app,status):IO.bind(Application(~S) & DepApp.Report<String,String>,String,run_selected(~S,native,app),next => IO.pure(String,third(~S,trace ++ "|" ++ report(status),next)))
def first(~S:Data,+native:Bool,result:Application(~S) & DepApp.Report<String,String>) -> IO(String):
  match result:
    case (app,status):IO.bind(Application(~S) & DepApp.Report<String,String>,String,run_selected(~S,native,app),next => second(~S,native,report(status),next))
def other_defined(~S:Data,+native:Bool,left:LeftOwner(~S),right:RightOwner(~S),result:Sys.Defined<World(~S),LeftOwner(~S),Body.LeftLocal()>) -> IO(String):
  match result:
    case Sys.Defined{world,other}:IO.bind(Application(~S) & DepApp.Report<String,String>,String,run_selected(~S,native,Schedule.build(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~String,~String,~LeftTree(~S),~RightOwner(~S),~left_tree(~S),~right_tree(~S),~Unit,~Common.Handler,~Conditions.empty_dispatch(~W.World<S,D.Store(~S),D.Resources(~S),Unit>,~String),~Conditions.empty(~W.World<S,D.Store(~S),D.Resources(~S),Unit>,~String),~Common.handle,~Common.available,world,Product.Owner{Product.Owner{left,other},right},Unit{},Common.Handler{ALeaf{701},0},[],[])),next => first(~S,native,next))
    case Sys.DefinitionRefused{_,_}:IO.pure(String,"ERROR:other")
def registered(~S:Data,native:Bool,result:Pair.Definition<World(~S),LeftOwner(~S),RightOwner(~S),Body.LeftLocal(),Body.RightLocal()>) -> IO(String):
  match result:
    case Pair.Defined{Pair.ParallelApp{world,left,right}}:other_defined(~S,native,left,right,Task.define(~S,~D.Store(~S),~D.LeftStore(~S),~D.LeftResource(~S),~Unit,~D.LeftOps(~S),~Body.LeftLocal(),~String,~String,~D.left(~S),~Body.left(~S),~D.Resources(~S),world,"other",Body.left_local(801,203)))
    case Pair.LeftRefused{_,_,_}:IO.pure(String,"ERROR:left")
    case Pair.RightRefused{_,_,_}:IO.pure(String,"ERROR:right")
def created(~S:Data,native:Bool,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> IO(String):
  match result:
    case W.Created{_,world}:registered(~S,native,Pair.define(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.LeftLocal(),~Body.RightLocal(),~String,~String,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S),world,"left","right",Body.left_local(501,201),Body.right_local()))
    case W.CreateRejected{_,_}:IO.pure(String,"ERROR:create")
def run(~S:Data,native:Bool) -> IO(String):
  created(~S,native,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),W.factory(),D.resources(~S)))
type SchemaA is Data:
  SchemaA{}
type SchemaB is Data:
  SchemaB{}
def main() -> IO(Unit):
  IO.bind(String,Unit,run(~SchemaA,False{}),aSerial => IO.bind(String,Unit,run(~SchemaA,True{}),aNative => IO.bind(String,Unit,run(~SchemaB,False{}),bSerial => IO.bind(String,Unit,run(~SchemaB,True{}),bNative => IO.print("A-serial=" ++ aSerial ++ "\nA-native=" ++ aNative ++ "\nB-serial=" ++ bSerial ++ "\nB-native=" ++ bNative)))))
