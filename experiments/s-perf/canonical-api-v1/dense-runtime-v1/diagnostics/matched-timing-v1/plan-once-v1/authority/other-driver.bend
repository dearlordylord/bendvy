import Base
import other-core.bend as Core
import other-schema.bend as S
import ../../../../../../../../examples/scheduled-health/components.bend as D
import ../../../../../../../../src/ecs/ordinary-app-run.bend as Entry
import ../../../../../../../../src/ecs/ordinary-app-execution.bend as Execution
import ../../../../../../../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../../../../../../../src/ecs/ordinary-app-schema.bend as App
import ../../../../../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../../../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../../../../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../../../../../../src/ecs/inspector-query-projection.bend as P
import ../../../../../../../../src/ecs/inspector-query.bend as IQ
import ../../../../../../../../src/ecs/component.bend as C
import ../../../../../../../../src/ecs/column.bend as Col
import ../../../../../../../../src/ecs/world.bend as W

def health(value:Core.Value()) -> String:
  match value:
    case P.Product{C.Found{D.Health{h}},_}:F32.show(h)
    case _:"ERROR"
def rows(values:List<&2,IQ.ProjectedRow<S.Schema,Core.Value()>>) -> String:
  match values:
    case []:""
    case IQ.ProjectedRow{_,value} <> []:health(value)
    case IQ.ProjectedRow{_,value} <> rest:health(value) ++ "," ++ rows(rest)
def snapshot_text(value:Maybe<&2,Schedule.Description<S.Schema,Core.Rows()>>) -> String:
  match value:
    case Some{Schedule.Description{App.Description{_,DTO.Product{_,DTO.Observation{DTO.Product{DTO.Product{_,DTO.Product{_,values}},_},_}}},_,_,_}}:rows(values)
    case None{}:"ERROR: disabled"
def sentinel(value:S.World() & C.Access<D.Health>) -> String:
  match value:
    case (_,C.Found{D.Health{value}}):"untouched=" ++ F32.show(value)
    case _:"ERROR: sentinel"
def finish(app:Core.Scheduled(),handle:W.Handle<S.Schema>) -> String:
  match app:
    case Entry.Application{Schedule.Application{App.Application{_,Build.Registered{world,_,_,_}},_,_,_,_,_},_}:sentinel(C.get(~S.Schema,~S.Store,~S.Resources,~Unit,~Col.Column<S.Schema,D.HealthDecay>,~D.Health,~D.Health,~S.HealthToken,~S.take_health,~S.put_health,~S.project_health,S.health_family(),world,handle))
def counted(next:Core.Scheduled() -> String,heading:String,value:Core.Scheduled() & String) -> String:
  match value:
    case (app,counter):heading ++ "\n" ++ counter ++ "\n" ++ next(app)
def observed(next:Core.Scheduled() -> String,heading:String,value:Core.Scheduled() & Maybe<&2,Schedule.Description<S.Schema,Core.Rows()>>) -> String:
  match value:
    case (app,view):counted(next,heading ++ snapshot_text(view),Core.counter(app))
def ran(next:Core.Scheduled() -> String,heading:String,value:Execution.Run<Core.Scheduled(),S.Schema,Core.Error()>) -> String:
  match value:
    case Execution.Run{Schedule.Finished{app,_},_}:observed(next,heading,Core.snapshot(app))
    case _:"ERROR: ordinary run"
def ticks(left:Nat,+tick:U32,handle:W.Handle<S.Schema>,app:Core.Scheduled()) -> String:
  match left:
    case 0n:finish(app,handle)
    case 1n++rest:ran(a => ticks(rest,(tick + 1:U32),handle,a),"tick=" ++ U32.show(tick) ++ " health=",Core.run(app))
def replanned(handle:W.Handle<S.Schema>,value:Schedule.Attachment<Core.Registered(),Core.Scheduled()>) -> String:
  match value:
    case Schedule.Attached{app}:ticks(6n,1,handle,app)
    case _:"ERROR: replan"
def replan(handle:W.Handle<S.Schema>,app:Core.Scheduled()) -> String:
  replanned(handle,Core.replan(app))
def attached(handle:W.Handle<S.Schema>,value:Schedule.Attachment<Core.Registered(),Core.Scheduled()>) -> String:
  match value:
    case Schedule.Attached{app}:ran(a => replan(handle,a),"before-barrier=",Core.run(Core.enabled(app)))
    case _:"ERROR: attach"
def installed(handle:W.Handle<S.Schema>,app:Core.Registered()) -> String:
  attached(handle,Core.attach(app,False{}))
def service_failed(app:Core.First()) -> String:"ERROR: service registration"
def component_done(handle:W.Handle<S.Schema>,app:Core.First()) -> String:
  Core.service_added(~String,a => installed(handle,a),service_failed,app)
def component_failed(app:Exec.Registered<S.Schema,S.World(),Unit,Unit,Build.empty_observe(~S.World()),Leaf.empty(~S.Schema),Unit,Exec.empty_plan(~S.Schema),Exec.empty_dispatch(~S.World()),Exec.empty_provide(~S.Schema,~S.World())>) -> String:"ERROR: component registration"
def start(world:S.World(),handle:W.Handle<S.Schema>) -> String:
  Core.component_added(~String,a => component_done(handle,a),component_failed,world)
