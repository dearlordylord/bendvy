import Base
import failure-core.bend as Core
import driver.bend as Observe
import schema.bend as S
import ../../../../../../../../examples/scheduled-health/components.bend as D
import ../../../../../../../../examples/scheduled-health/system.bend as Decay
import ../../../../../../../../src/ecs/ordinary-app-run.bend as Entry
import ../../../../../../../../src/ecs/ordinary-app-execution.bend as Execution
import ../../../../../../../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../../../../../../../src/ecs/ordinary-app-schema.bend as App
import ../../../../../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../../../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../../../../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../../../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../../../../../../src/ecs/ordinary-app-component.bend as Component
import ../../../../../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../../../../../src/ecs/captured-schedule-composition.bend as Choice
import ../../../../../../../../src/ecs/compose.bend as Q
import ../../../../../../../../src/ecs/component.bend as C
import ../../../../../../../../src/ecs/column.bend as Col
import ../../../../../../../../src/ecs/world.bend as W

def cursor(value:Fields.Fields<S.Schema>) -> U32:
  match value:
    case Fields.Fields{_,_,_,_,position,_,_,_}:position
def printed(handle:W.Handle<S.Schema>,health:String,value:Core.Scheduled() & String) -> String:
  match value:
    case (Entry.Application{Schedule.Application{App.Application{_,Build.Registered{world,((_,Exec.Invocation{Leaf.Record{_,fields},_,_}),_),_,_}},_,_,_,_,_},_},counter):"failed health=" ++ health ++ " query-cursor=" ++ U32.show(cursor(fields)) ++ " " ++ counter ++ " " ++ Observe.sentinel(C.get(~S.Schema,~S.Store,~S.Resources,~Unit,~Col.Column<S.Schema,D.HealthDecay>,~D.Health,~D.Health,~S.HealthToken,~S.take_health,~S.put_health,~S.project_health,S.health_family(),world,handle))
def observed(handle:W.Handle<S.Schema>,value:Core.Scheduled() & Maybe<&2,Schedule.Description<S.Schema,Core.Rows()>>) -> String:
  match value:
    case (app,view):printed(handle,Observe.snapshot_text(view),Core.counter(app))
def returned(handle:W.Handle<S.Schema>,value:Execution.Run<Core.Scheduled(),S.Schema,Core.Error()>) -> String:
  match value:
    case Execution.Run{Schedule.Failed{app,Choice.LeftError{Choice.RightError{Component.CallbackFailure{Q.UserError{Decay.MissingComponent{}}}}},_},_}:observed(handle,Core.snapshot(app))
    case _:"ERROR: expected callback failure"
def attached(handle:W.Handle<S.Schema>,value:Schedule.Attachment<Core.Registered(),Core.Scheduled()>) -> String:
  match value:
    case Schedule.Attached{app}:returned(handle,Core.run(Core.enabled(app)))
    case _:"ERROR: attach"
def installed(handle:W.Handle<S.Schema>,app:Core.Registered()) -> String:
  attached(handle,Core.attach(app,True{}))
def service_failed(app:Core.First()) -> String:"ERROR: service registration"
def component_done(handle:W.Handle<S.Schema>,app:Core.First()) -> String:
  Core.service_added(~String,a => installed(handle,a),service_failed,app)
def component_failed(app:Exec.Registered<S.Schema,S.World(),Unit,Unit,Build.empty_observe(~S.World()),Leaf.empty(~S.Schema),Unit,Exec.empty_plan(~S.Schema),Exec.empty_dispatch(~S.World()),Exec.empty_provide(~S.Schema,~S.World())>) -> String:"ERROR: component registration"
def start(world:S.World(),handle:W.Handle<S.Schema>) -> String:
  Core.component_added(~String,a => component_done(handle,a),component_failed,world)
