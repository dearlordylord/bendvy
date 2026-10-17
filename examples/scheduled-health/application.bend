import Base
import registration.bend as Registration
import components.bend as D
import schema.bend as S
import ../../src/ecs/ordinary-app-run.bend as Entry
import ../../src/ecs/ordinary-app-execution.bend as Execution
import ../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../src/ecs/ordinary-app-schema.bend as App
import ../../src/ecs/ordinary-app-composer.bend as Build
import ../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../src/ecs/ordinary-app-records.bend as Leaf
import ../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../src/ecs/inspector-query-projection.bend as P
import ../../src/ecs/inspector-query.bend as IQ
import ../../src/ecs/component.bend as C
import ../../src/ecs/column.bend as Col
import ../../src/ecs/world.bend as W
def values(rows:List<&2,D.Health>) -> String:
  match rows:
    case []:""
    case D.Health{value} <> []:F32.show(value)
    case D.Health{value} <> rest:F32.show(value) ++ "," ++ values(rest)
def sentinel(value:S.World() & C.Access<D.Health>) -> String:
  match value:
    case (_,C.Found{D.Health{value}}):"untouched=" ++ F32.show(value)
    case _:"ERROR: sentinel missing"
def finished(world:S.World(),handle:W.Handle<S.Schema>) -> String:
  sentinel(C.get(~S.Schema,~S.Store,~Unit,~Unit,~Col.Column<S.Schema,D.HealthDecay>,~D.Health,~D.Health,~S.HealthToken,~S.take_health,~S.put_health,~S.project_health,S.health_family(),world,handle))
def health(value:Registration.Value()) -> String:
  match value:
    case P.Product{C.Found{D.Health{h}},_}:F32.show(h)
    case _:"ERROR"
def rows(values:List<&2,IQ.ProjectedRow<S.Schema,Registration.Value()>>) -> String:
  match values:
    case []:""
    case IQ.ProjectedRow{_,value} <> []:health(value)
    case IQ.ProjectedRow{_,value} <> rest:health(value) ++ "," ++ rows(rest)
def snapshot_text(value:Maybe<&2,Schedule.Description<S.Schema,Registration.Rows()>>) -> String:
  match value:
    case Some{Schedule.Description{App.Description{_,DTO.Product{_,DTO.Observation{DTO.Product{_,DTO.Product{_,values}},_}}},_,_,_}}:rows(values)
    case None{}:"ERROR: disabled"
def finish(app:Registration.Application(),handle:W.Handle<S.Schema>) -> String:
  match app:
    case Entry.Application{Schedule.Application{App.Application{_,Build.Registered{world,_,_,_}},_,_,_,_,_},_}:finished(world,handle)
def observed(next:Registration.Application() -> String,heading:String,value:Registration.Application() & Maybe<&2,Schedule.Description<S.Schema,Registration.Rows()>>) -> String:
  match value:
    case (app,view):heading ++ snapshot_text(view) ++ "\n" ++ next(app)
def ran(next:Registration.Application() -> String,heading:String,value:Execution.Run<Registration.Application(),S.Schema,Registration.Error()>) -> String:
  match value:
    case Execution.Run{Schedule.Finished{app,_},_}:observed(next,heading,Registration.snapshot(app))
    case _:"ERROR: App run"
def ticks(left:Nat,+tick:U32,handle:W.Handle<S.Schema>,app:Registration.Application()) -> String:
  match left:
    case 0n:finish(app,handle)
    case 1n++rest:ran(a => ticks(rest,(tick + 1:U32),handle,a),"tick=" ++ U32.show(tick) ++ " health=",Registration.run(app))
def replanned(handle:W.Handle<S.Schema>,value:Schedule.Attachment<Registration.Registered(),Registration.Application()>) -> String:
  match value:
    case Schedule.Attached{app}:ticks(6n,1,handle,app)
    case _:"ERROR: replan"
def replan(handle:W.Handle<S.Schema>,app:Registration.Application()) -> String:
  replanned(handle,Registration.replan(app))
def attached(handle:W.Handle<S.Schema>,value:Schedule.Attachment<Registration.Registered(),Registration.Application()>) -> String:
  match value:
    case Schedule.Attached{app}:ran(a => replan(handle,a),"before-barrier=",Registration.run(Registration.enabled(app)))
    case _:"ERROR: attach"
def registered(handle:W.Handle<S.Schema>,app:Registration.Registered()) -> String:
  attached(handle,Registration.attach(app))
def rejected(app:Exec.Registered<S.Schema,S.World(),Unit,Unit,Build.empty_observe(~S.World()),Leaf.empty(~S.Schema),Unit,Exec.empty_plan(~S.Schema),Exec.empty_dispatch(~S.World()),Exec.empty_provide(~S.Schema,~S.World())>) -> String:"ERROR: registration"
def start(world:S.World(),handle:W.Handle<S.Schema>) -> String:
  Registration.create(~String,a => registered(handle,a),rejected,world)
