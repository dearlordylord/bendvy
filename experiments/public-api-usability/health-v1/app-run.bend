import Base
import ../../../examples/scheduled-health/application.bend as Original
import ../../../src/ecs/schema-fragments.bend as Fragment
import ../../../examples/scheduled-health/schema.bend as S
import ../../../examples/scheduled-health/components.bend as D
import ../../../examples/scheduled-health/system.bend as Decay
import ../../../src/ecs/ordinary-query-observable.bend as Obs
import ../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../src/ecs/ordinary-app-component.bend as Component
import ../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../src/ecs/ordinary-app-recipe.bend as Tree
import ../../../src/ecs/ordinary-app-observation.bend as Leaves
import ../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../src/ecs/ordinary-app-schema.bend as App
import ../../../src/ecs/ordinary-schema.bend as Schema
import ../../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../src/ecs/ordinary-app-registration-run.bend as Run
import ../../../src/ecs/ordinary-system.bend as Ordinary
import ../../../src/ecs/inspector-query-projection.bend as P
import ../../../src/ecs/inspector-query.bend as IQ
import ../../../src/ecs/inspector.bend as I
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/schedule-provision.bend as SP
import ../../../src/ecs/schedule.bend as Sch
import app-core.bend as Core
def health(value:Core.Value()) -> String:
  match value:
    case P.Product{C.Found{D.Health{h}},_}:F32.show(h)
    case _:"ERROR"
def rows(values:List<&2,IQ.ProjectedRow<S.Schema,Core.Value()>>) -> String:
  match values:
    case []:""
    case IQ.ProjectedRow{_,value} <> []:health(value)
    case IQ.ProjectedRow{_,value} <> rest:health(value) ++ "," ++ rows(rest)
def snapshot(app:Core.Scheduled()) -> Core.Scheduled() & Maybe<&2,Schedule.Description<S.Schema,Core.Rows()>>:Schedule.snapshot(~S.Schema,~S.Store,~Unit,~Unit,~Core.Owners(),~Core.Rows(),~Core.observer(),~Core.folder(),app)
def snapshot_text(value:Maybe<&2,Schedule.Description<S.Schema,Core.Rows()>>) -> String:
  match value:
    case Some{Schedule.Description{App.Description{_,DTO.Product{_,DTO.Observation{DTO.Product{_,DTO.Product{_,values}},_}}},_,_,_}}:rows(values)
    case None{}:"ERROR: disabled"
def final_world(world:S.World(),handle:W.Handle<S.Schema>) -> String:
  Original.finished(world,handle)
def finish(app:Core.Scheduled(),handle:W.Handle<S.Schema>) -> String:
  match app:
    case Schedule.Application{App.Application{_,Build.Registered{world,_,_,_}},_,_,_,_,_}:final_world(world,handle)
def observed(next:Core.Scheduled() -> String,tick:U32,value:Core.Scheduled() & Maybe<&2,Schedule.Description<S.Schema,Core.Rows()>>) -> String:
  match value:
    case (app,view):"tick=" ++ U32.show(tick) ++ " health=" ++ snapshot_text(view) ++ "\n" ++ next(app)
def ran(next:Core.Scheduled() -> String,tick:U32,value:Schedule.RunResult<Core.Scheduled(),S.Schema,Core.Error>) -> String:
  match value:
    case Schedule.Finished{app,_}:observed(next,tick,snapshot(app))
    case _:"ERROR: App Core.run"
def ticks(left:Nat,+tick:U32,handle:W.Handle<S.Schema>,app:Core.Scheduled()) -> String:
  match left:
    case 0n:finish(app,handle)
    case 1n++rest:ran(a => ticks(rest,(tick + 1:U32),handle,a),tick,Core.run(app))
def attached(handle:W.Handle<S.Schema>,value:Schedule.Attachment<Core.Application(),Core.Scheduled()>) -> String:
  match value:
    case Schedule.Attached{app}:ticks(6n,1,handle,app)
    case _:"ERROR: Core.attach"
def after_pending(handle:W.Handle<S.Schema>,value:Core.Scheduled() & Maybe<&2,Schedule.Description<S.Schema,Core.Rows()>>) -> String:
  match value:
    case (Schedule.Application{app,_,_,_,_,_},view):"before-barrier=" ++ snapshot_text(view) ++ "\n" ++ attached(handle,Core.attach(True{},app))
def pending(handle:W.Handle<S.Schema>,value:Schedule.RunResult<Core.Scheduled(),S.Schema,Core.Error>) -> String:
  match value:
    case Schedule.Finished{app,_}:after_pending(handle,snapshot(app))
    case _:"ERROR: pending"
def pending_attached(handle:W.Handle<S.Schema>,value:Schedule.Attachment<Core.Application(),Core.Scheduled()>) -> String:
  match value:
    case Schedule.Attached{app}:pending(handle,Core.run(app))
    case _:"ERROR: initial Core.attach"
def start_created(handle:W.Handle<S.Schema>,value:Core.Creation) -> String:
  match value:
    case Core.Created{app}:pending_attached(handle,Core.attach(False{},App.enabled(~S.Schema,~S.Store,~Unit,~Unit,~Core.Owners(),~Core.Rows(),~Core.observer(),~Core.folder(),app,True{})))
    case _:"ERROR: App Core.create"
def start(world:S.World(),handle:W.Handle<S.Schema>) -> String:start_created(handle,Core.create(world))
