import Base
import ../../src/ecs/dependency-plan.bend as Plan
import ./declarations.bend as D
import ./initialize.bend as Init
import ./observation.bend as Observe
import ./reports.bend as Report
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-parallel-registration.bend as Part
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/execution-machine-maintenance.bend as Maintenance
import ../../src/ecs/execution-composer-layout.bend as Layout
import ./conditions.bend as Cond
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-machine-state.bend as Machine
import ../../src/ecs/owner-product.bend as Product

# The actual builder rejects missing dependency endpoints. Its genuine Invalid
# result must preserve the initial queue without rotating a generation.
type Schema is Data:
  Schema{}
def Resources() -> Type:Product.Owner<D.Resources(~Schema),Unit>
def empty(_:Unit) -> D.Store(~Schema):Layout.empty_columns(~Schema,D.component_layout(~Schema))
def resources() -> Resources():Product.Owner{Layout.ResourceSlot{Layout.initialize(D.layout(~Schema),Layout.AtLeaf{},Machine.empty(~Schema,~D.Key,~D.Mode)),Layout.unknown_stamp()},Unit{}}
def machine_shape() -> {Layout.payload(Cond.layout(~Schema),Layout.InLeft{Layout.AtLeaf{}}) == Machine.Cell<Schema,D.Key,D.Mode> : Type}:{==}
def World() -> Type:W.World<Schema,D.Store(~Schema),Resources(),Unit>
def Application() -> Type:DepApp.Application<World(),Unit,Unit,Report.Handler,String,String,Reg.empty_dispatch(~World(),~String,~String),Reg.empty_dispatch(~World(),~String,~Bool),Report.handle>
def Scheduled() -> Type:Schedule.Scheduled<Application()>
def rotate(result:Application() & DepApp.Report<String,String>) -> Scheduled() & DepApp.Report<String,String>:
  match result:
    case (app,status):Maintenance.completed(~Schema,~D.Key,~D.Mode,~D.Store(~Schema),~Resources(),~Unit,~Cond.layout(~Schema),~Layout.InLeft{Layout.AtLeaf{}},~{==},~machine_shape(),~Unit,~Unit,~Report.Handler,~String,~String,~Reg.empty_dispatch(~World(),~String,~String),~Reg.empty_dispatch(~World(),~String,~Bool),~Report.handle,(Schedule.Scheduled{app,Part.Rules{[]},Schedule.Deferred{[],Settings.Settings{False{},False{},[],[]},[]}},status))
def run_once(app:Application()) -> Scheduled() & DepApp.Report<String,String>:
  rotate(DepApp.run(~World(),~Unit,~Unit,~Report.Handler,~String,~String,~Reg.empty_dispatch(~World(),~String,~String),~Reg.empty_dispatch(~World(),~String,~Bool),~Report.handle,app))
def final(trace:String,result:Scheduled() & DepApp.Report<String,String>) -> String:
  match result:
    case (Schedule.Scheduled{DepApp.Application{DepApp.State{world,_,_,handler,_},_,_},_,_},status):trace ++ "|" ++ Report.report(status) ++ "|" ++ Observe.world(~Schema,world) ++ "|handler=" ++ Report.handler(handler)
def prepared(world:World()) -> String:
  final("invalid",run_once(DepApp.trusted_build_checked(~World(),~Unit,~Unit,~Report.Handler,~String,~String,~Reg.empty_dispatch(~World(),~String,~String),~Reg.empty_dispatch(~World(),~String,~Bool),~Report.handle,~Report.available,world,Reg.empty(~World(),~String,~String),Reg.empty_conditions(~World(),~String),Report.Handler{ALeaf{801},0},[Plan.Edge{99,100}],[])))
def created(result:W.Creation<Schema,D.Store(~Schema),Resources(),Unit>) -> String:
  match result:
    case W.Created{_,world}:prepared(Init.setup(~Schema,world))
    case W.CreateRejected{_,_}:"ERROR:create"
def main() -> IO(Unit):IO.print(created(W.create(~Schema,~D.Store(~Schema),~Resources(),~Unit,~empty,W.factory(),resources())))
