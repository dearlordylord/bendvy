import Base
import ./declarations.bend as D
import ./scheduled.bend as Main
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

# Generic ordinary App edge control. DepApp.run supplies the real Finished result;
# no Root tree, synthetic callback, or supplied Tick is involved.
type Schema is Data:
  Schema{}
def World() -> Type:Main.World(~Schema)
def Application() -> Type:DepApp.Application<World(),Unit,Unit,Report.Handler,String,String,Reg.empty_dispatch(~World(),~String,~String),Reg.empty_dispatch(~World(),~String,~Bool),Report.handle>
def Scheduled() -> Type:Schedule.Scheduled<DepApp.State<World(),Unit,Unit,Report.Handler>>
def rotate(result:Application() & DepApp.Report<String,String>) -> Scheduled() & DepApp.Report<String,String>:
  match result:
    case (DepApp.Application{state,plan,bindings},status):Maintenance.completed(~Schema,~D.Key,~D.Mode,~D.Store(~Schema),~Main.Resources(~Schema),~Unit,~Cond.layout(Schema),~Layout.InLeft{Layout.AtLeaf{}},~{==},~Main.machine_shape(~Schema),~Unit,~Unit,~Report.Handler,~String,~String,(Schedule.Scheduled{state,plan,bindings,Part.Rules{[]},Schedule.Deferred{[],Settings.Settings{False{},False{},[],[]},[]}},status))
def run_once(app:Application()) -> Scheduled() & DepApp.Report<String,String>:
  rotate(DepApp.run(~World(),~Unit,~Unit,~Report.Handler,~String,~String,~Reg.empty_dispatch(~World(),~String,~String),~Reg.empty_dispatch(~World(),~String,~Bool),~Report.handle,app))
def progress_resource(owner:Main.Resources(~Schema)) -> Main.Resources(~Schema) & String:
  match owner:
    case Product.Owner{Layout.ResourceSlot{Layout.Viewed{Machine.Cell{slot,+stream,revision,stamp,nextStamp,sequence,initialPending,namespace,intent},cache},resourceStamp},peer}:(Product.Owner{Layout.ResourceSlot{Layout.Viewed{Machine.Cell{slot,stream,revision,stamp,nextStamp,sequence,initialPending,namespace,intent},cache},resourceStamp},peer},Observe.stream(stream))
def final(trace:String,result:Scheduled() & DepApp.Report<String,String>) -> String:
  match result:
    case (Schedule.Scheduled{DepApp.State{world,_,_,handler,_},_,_,_,_},status):trace ++ "|" ++ Report.report(status) ++ "|" ++ Observe.world(~Schema,world) ++ "|handler=" ++ Report.handler(handler)
def first_observed(status:DepApp.Report<String,String>,restore:World() -> Application(),result:World() & String) -> String:
  match result:
    case (world,stream):final(Report.report(status) ++ "/after-first{" ++ stream ++ "}",run_once(restore(world)))
def first(result:Scheduled() & DepApp.Report<String,String>) -> String:
  match result:
    case (Schedule.Scheduled{DepApp.State{world,owners,guards,handler,bindings},plan,appBindings,_,_},status):first_observed(status,world => DepApp.Application{DepApp.State{world,owners,guards,handler,bindings},plan,appBindings},W.observe_resource(~Schema,~D.Store(~Schema),~Main.Resources(~Schema),~Unit,~String,~progress_resource,world))
def prepared(world:World()) -> String:
  first(run_once(DepApp.trusted_build_checked(~World(),~Unit,~Unit,~Report.Handler,~String,~String,~Reg.empty_dispatch(~World(),~String,~String),~Reg.empty_dispatch(~World(),~String,~Bool),~Report.handle,~Report.available,world,Reg.empty(~World(),~String,~String),Reg.empty_conditions(~World(),~String),Report.Handler{ALeaf{801},0},[],[])))
def created(result:W.Creation<Schema,D.Store(~Schema),Main.Resources(~Schema),Unit>) -> String:
  match result:
    case W.Created{_,world}:prepared(Init.setup(~Schema,world))
    case W.CreateRejected{_,_}:"ERROR:create"
def main() -> IO(Unit):IO.print(created(W.create(~Schema,~D.Store(~Schema),~Main.Resources(~Schema),~Unit,~Main.empty(~Schema),W.factory(),Main.resources(~Schema))))
