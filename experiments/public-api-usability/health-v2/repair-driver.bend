import Base
import core.bend as Core
import driver.bend as Observe
import schema.bend as S
import ../../../src/ecs/ordinary-app-run.bend as Entry
import ../../../src/ecs/ordinary-app-execution.bend as Execution
import ../../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../../src/ecs/ordinary-app-schema.bend as App
import ../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../src/ecs/ordinary-service-declaration.bend as Service
import ../../../src/ecs/schedule-provision.bend as SP
import ../../../src/ecs/world.bend as W

type Stamp is Data:Stamp{namespace:U32,id:U32,cursor:U32}
def stamp(value:Maybe<&2,Schedule.Description<S.Schema,Core.Rows()>>) -> Maybe<&2,Stamp>:
  match value:
    case Some{Schedule.Description{App.Description{_,DTO.Product{DTO.Binding{ns,id,_,_,cursor,_,_} <> _,_}},_,_,_}}:Some{Stamp{ns,id,cursor}}
    case _:None{}
def repaired_world(world:S.World()) -> S.World() & Unit:
  match world:
    case W.World{ns,allocator,store,S.Resources{Service.Missing{}},events,pending,registrations,nextSystemId,clock}:(W.World{ns,allocator,store,S.Resources{Service.Ready{Array.new(U32,0n,0)}},events,pending,registrations,nextSystemId,clock},Unit{})
    case world:(world,Unit{})
def repair(app:Core.Scheduled()) -> Core.Scheduled() & Unit:Entry.inspect(~S.Schema,~S.Store,~S.Resources,~Unit,~Core.Owners(),~Core.Rows(),~Core.observer(),~Core.folder(),~Core.Error(),~Core.plan(),~Core.dispatch(),~Core.provide(),~Unit,~repaired_world,app)
def pending(app:Core.Scheduled()) -> Core.Scheduled() & U32:Entry.inspect(~S.Schema,~S.Store,~S.Resources,~Unit,~Core.Owners(),~Core.Rows(),~Core.observer(),~Core.folder(),~Core.Error(),~Core.plan(),~Core.dispatch(),~Core.provide(),~U32,~W.pending_count(~S.Schema,~S.Store,~S.Resources,~Unit),app)
def same(before:Stamp,after:Stamp) -> Bool:
  match before after:
    case Stamp{ns,id,_} Stamp{otherNs,otherId,_}:Bool.and(U32.is_eq(ns,otherNs),U32.is_eq(id,otherId))
def advanced(before:Stamp,after:Stamp) -> Bool:
  match before after:
    case Stamp{_,_,cursor} Stamp{_,_,next}:U32.is_gt(next,cursor)
def position(value:Stamp) -> U32:
  match value:
    case Stamp{_,_,cursor}:cursor
def boolean(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
def counted(+before:Stamp,+after:Stamp,health:String,value:Core.Scheduled() & String) -> String:
  match value:
    case (_,counter):"repaired health=" ++ health ++ " " ++ counter ++ " same-registration=" ++ boolean(same(before,after)) ++ " cursor-advanced=" ++ boolean(advanced(before,after))
def after_view(+before:Stamp,app:Core.Scheduled(),+view:Maybe<&2,Schedule.Description<S.Schema,Core.Rows()>>,found:Maybe<&2,Stamp>) -> String:
  match found:
    case Some{after}:counted(before,after,Observe.snapshot_text(view),Core.counter(app))
    case _:"ERROR: after snapshot"
def after_observed(before:Stamp,value:Core.Scheduled() & Maybe<&2,Schedule.Description<S.Schema,Core.Rows()>>) -> String:
  match value:
    case (app,+view):after_view(before,app,view,stamp(view))
def retried(before:Stamp,value:Execution.Run<Core.Scheduled(),S.Schema,Core.Error()>) -> String:
  match value:
    case Execution.Run{Schedule.Finished{app,_},_}:after_observed(before,Core.snapshot(app))
    case _:"ERROR: repair retry"
def repaired(before:Stamp,value:Core.Scheduled() & Unit) -> String:
  match value:
    case (app,_):retried(before,Core.run(app))
def pending_observed(+before:Stamp,value:Core.Scheduled() & U32) -> String:
  match value:
    case (app,count):"missing pending=" ++ U32.show(count) ++ " cursor=" ++ U32.show(position(before)) ++ "\n" ++ repaired(before,repair(app))
def before_view(app:Core.Scheduled(),value:Maybe<&2,Stamp>) -> String:
  match value:
    case Some{before}:pending_observed(before,pending(app))
    case _:"ERROR: before snapshot"
def before_observed(value:Core.Scheduled() & Maybe<&2,Schedule.Description<S.Schema,Core.Rows()>>) -> String:
  match value:
    case (app,view):before_view(app,stamp(view))
def missing(value:Execution.Run<Core.Scheduled(),S.Schema,Core.Error()>) -> String:
  match value:
    case Execution.Run{Schedule.Missing{app,[SP.Service{1}]},_}:before_observed(Core.snapshot(app))
    case _:"ERROR: expected missing"
def attached(value:Schedule.Attachment<Core.Registered(),Core.Scheduled()>) -> String:
  match value:
    case Schedule.Attached{app}:missing(Core.run(Core.enabled(app)))
    case _:"ERROR: attach"
def installed(app:Core.Registered()) -> String:
  attached(Core.attach(app,True{}))
def service_failed(app:Core.First()) -> String:"ERROR: service registration"
def component_done(app:Core.First()) -> String:
  Core.service_added(~String,installed,service_failed,app)
def component_failed(app:Exec.Registered<S.Schema,S.World(),Unit,Unit,Build.empty_observe(~S.World()),Leaf.empty(~S.Schema),Unit,Exec.empty_plan(~S.Schema),Exec.empty_dispatch(~S.World()),Exec.empty_provide(~S.Schema,~S.World())>) -> String:"ERROR: component registration"
def start(world:S.World(),handle:W.Handle<S.Schema>) -> String:
  Core.component_added(~String,component_done,component_failed,world)
