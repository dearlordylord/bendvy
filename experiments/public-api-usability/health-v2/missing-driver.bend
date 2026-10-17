import Base
import core.bend as Core
import schema.bend as S
import ../../../src/ecs/ordinary-app-run.bend as Entry
import ../../../src/ecs/ordinary-app-execution.bend as Execution
import ../../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../../src/ecs/ordinary-app-schema.bend as App
import ../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../src/ecs/ordinary-service-declaration.bend as Service
import ../../../src/ecs/ordinary-app-service-registration.bend as ServiceApp
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/schedule-provision.bend as SP

def cursor(value:Fields.Fields<S.Schema>) -> U32:
  match value:
    case Fields.Fields{_,_,_,_,position,_,_,_}:position
def observed(position:U32,value:S.World() & U32) -> String:
  match value:
    case (W.World{_,_,_,S.Resources{Service.Missing{}},_,_,_,_,_},pending):"missing=Service:1 pending=" ++ U32.show(pending) ++ " query-cursor=" ++ U32.show(position) ++ " service-ready=false"
    case _:"ERROR: missing service changed"
def returned(value:Execution.Run<Core.Scheduled(),S.Schema,Core.Error()>) -> String:
  match value:
    case Execution.Run{Schedule.Missing{Entry.Application{Schedule.Application{App.Application{_,Build.Registered{world,((_,Exec.Invocation{Leaf.Record{_,fields},_,_}),_),_,_}},_,_,_,_,_},_},[SP.Service{1}]},_}:observed(cursor(fields),W.pending_count(~S.Schema,~S.Store,~S.Resources,~Unit,world))
    case _:"ERROR: missing preflight"
def attached(value:Schedule.Attachment<Core.Registered(),Core.Scheduled()>) -> String:
  match value:
    case Schedule.Attached{app}:returned(Core.run(Core.enabled(app)))
    case _:"ERROR: missing attach"
def installed(app:Core.Registered()) -> String:
  attached(Core.attach(app,True{}))
def service_failed(app:Core.First()) -> String:"ERROR: service registration"
def component_done(app:Core.First()) -> String:
  Core.service_added(~String,installed,service_failed,app)
def component_failed(app:Exec.Registered<S.Schema,S.World(),Unit,Unit,Build.empty_observe(~S.World()),Leaf.empty(~S.Schema),Unit,Exec.empty_plan(~S.Schema),Exec.empty_dispatch(~S.World()),Exec.empty_provide(~S.Schema,~S.World())>) -> String:"ERROR: component registration"
def start(world:S.World(),handle:W.Handle<S.Schema>) -> String:
  Core.component_added(~String,component_done,component_failed,world)
