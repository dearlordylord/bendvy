import Base
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/ordinary-app-local-fields.bend as LocalApp
import ../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../src/ecs/ordinary-app-records.bend as Records
import ../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../src/ecs/ordinary-app-run.bend as Entry
import ../../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../../src/ecs/ordinary-app-execution.bend as Execution
import ../../../src/ecs/ordinary-app-schema.bend as App
import ../../../src/ecs/ordinary-app-recipe.bend as Tree
import ../../../src/ecs/ordinary-resource-system.bend as P
import ../../../src/ecs/ordinary-schema.bend as Schema
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/captured-schedule-composition.bend as Choice
import ../../../src/ecs/execution-context.bend as Ctx
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/local.bend as Local
import ../../../src/ecs/schedule-provision.bend as SP
import ../../../src/ecs/schedule.bend as Sch

type S is Data:S{}
type Error is Data:ExpectedFailure{}
def World() -> Type:W.World<S,Unit,U32,Unit>
def project(value:U32) -> U32 & U32:
  +actual=value
  (actual,actual)
def Ops(H:Type) -> Type:Cap.ValueWrite<H,U32,U32>
def declaration() -> P.Declaration<S,U32,T.Tx<World(),Unit>,Ops(T.Tx<World(),Unit>)>:
  P.write(~S,~Unit,~U32,~Unit,~U32,~project,Schema.resource(~S,~U32,"Count"))
def outcome(fail:Bool) -> T.Outcome<Error>:
  match fail:
    case True{}:T.Failure{ExpectedFailure{}}
    case False{}:T.Success{}
def body_resource(~H:Type,~caps:Ops(H),local:Array<U32>,fail:Bool,result:H & U32) -> H & (Array<U32> & (T.Outcome<Error> & Array<U32>)):
  match result:
    case (owner,value):(Cap.value_set(~H,~U32,~U32,~caps,owner,(value + 10:U32)),(local,(outcome(fail),Array.new(U32,0n,99))))
def body_flag(~H:Type,~caps:Ops(H),owner:H,result:Array<U32> & U32) -> H & (Array<U32> & (T.Outcome<Error> & Array<U32>)):
  match result:
    case (local,flag):body_resource(~H,~caps,Array.set(U32,local,1,0),Bool.not(U32.is_eq(flag,0)),Cap.value_get(~H,~U32,~U32,~caps,owner))
def body_count(~H:Type,~caps:Ops(H),owner:H,result:Array<U32> & U32) -> H & (Array<U32> & (T.Outcome<Error> & Array<U32>)):
  match result:
    case (local,value):body_flag(~H,~caps,owner,Array.get(U32,Array.set(U32,local,0,(value + 1:U32)),1))
def body(~H:Type,~caps:Ops(H),local:Array<U32>,args:Unit,owner:H) -> H & (Array<U32> & (T.Outcome<Error> & Array<U32>)):
  body_count(~H,~caps,owner,Array.get(U32,local,0))
def Registered() -> Type:LocalApp.Executable(~S,~Unit,~U32,~Unit,~Array<U32>,~Unit,~Error,~Array<U32>,~Ops,~declaration(),~body,~Unit,~Unit,~Build.empty_observe(~World()),~Records.empty(~S),~Unit,~Exec.empty_plan(~S),~Exec.empty_dispatch(~World()),~Exec.empty_provide(~S,~World()))
def Owners() -> Type:LocalApp.execution_owners(~S,~Unit,~U32,~Unit,~Array<U32>,~Unit,~Error,~Array<U32>,~Ops,~declaration(),~body,~Unit,~Unit,~Build.empty_observe(~World()),~Records.empty(~S),~Unit,~Exec.empty_plan(~S),~Exec.empty_dispatch(~World()),~Exec.empty_provide(~S,~World()))
def Rows() -> Data:LocalApp.execution_rows(~S,~Unit,~U32,~Unit,~Array<U32>,~Unit,~Error,~Array<U32>,~Ops,~declaration(),~body,~Unit,~Unit,~Build.empty_observe(~World()),~Records.empty(~S),~Unit,~Exec.empty_plan(~S),~Exec.empty_dispatch(~World()),~Exec.empty_provide(~S,~World()))
def observer() -> World() -> World() & DTO.Observation<Rows()>:LocalApp.execution_observe(~S,~Unit,~U32,~Unit,~Array<U32>,~Unit,~Error,~Array<U32>,~Ops,~declaration(),~body,~Unit,~Unit,~Build.empty_observe(~World()),~Records.empty(~S),~Unit,~Exec.empty_plan(~S),~Exec.empty_dispatch(~World()),~Exec.empty_provide(~S,~World()))
def folder() -> Owners() -> Owners() & List<&2,Fields.Fields<S>>:LocalApp.execution_fold(~S,~Unit,~U32,~Unit,~Array<U32>,~Unit,~Error,~Array<U32>,~Ops,~declaration(),~body,~Unit,~Unit,~Build.empty_observe(~World()),~Records.empty(~S),~Unit,~Exec.empty_plan(~S),~Exec.empty_dispatch(~World()),~Exec.empty_provide(~S,~World()))
def planner() -> Owners() -> Owners() & SP.Plan<S>:LocalApp.composed_plan(~S,~Unit,~U32,~Unit,~Array<U32>,~Unit,~Error,~Array<U32>,~Ops,~declaration(),~body,~Unit,~Unit,~Build.empty_observe(~World()),~Records.empty(~S),~Unit,~Exec.empty_plan(~S),~Exec.empty_dispatch(~World()),~Exec.empty_provide(~S,~World()))
def dispatcher() -> Owners() -> Ctx.Context<World()> -> U32 -> Owners() & Sys.Outcome<Ctx.Context<World()>,Choice.Choice<Unit,LocalApp.ExecutionError<Error>>,Unit>:LocalApp.execution_dispatch(~S,~Unit,~U32,~Unit,~Array<U32>,~Unit,~Error,~Array<U32>,~Ops,~declaration(),~body,~Unit,~Unit,~Build.empty_observe(~World()),~Records.empty(~S),~Unit,~Exec.empty_plan(~S),~Exec.empty_dispatch(~World()),~Exec.empty_provide(~S,~World()))
def provisioner() -> World() -> World() & List<&2,SP.Requirement<S>>:LocalApp.execution_provide(~S,~Unit,~U32,~Unit,~Array<U32>,~Unit,~Error,~Array<U32>,~Ops,~declaration(),~body,~Unit,~Unit,~Build.empty_observe(~World()),~Records.empty(~S),~Unit,~Exec.empty_plan(~S),~Exec.empty_dispatch(~World()),~Exec.empty_provide(~S,~World()))
def Application() -> Type:Entry.Application<S,Unit,U32,Unit,Owners(),Rows(),observer(),folder(),Choice.Choice<Unit,LocalApp.ExecutionError<Error>>,planner(),dispatcher(),provisioner()>
def run(app:Application()) -> Execution.Run<Application(),S,Choice.Choice<Unit,LocalApp.ExecutionError<Error>>>:Entry.run(~S,~Unit,~U32,~Unit,~Owners(),~Rows(),~observer(),~folder(),~Choice.Choice<Unit,LocalApp.ExecutionError<Error>>,~planner(),~dispatcher(),~provisioner(),app)
def attach(value:Registered()) -> Schedule.Attachment<Registered(),Application()>:Entry.attach(~S,~Unit,~U32,~Unit,~Owners(),~Rows(),~observer(),~folder(),~Choice.Choice<Unit,LocalApp.ExecutionError<Error>>,~planner(),~dispatcher(),~provisioner(),Schema.resource_schema(~S,~U32,Schema.resource(~S,~U32,"Count")),value,"Local retry",False{})
def register(world:World()) -> LocalApp.Appended<Exec.Registered<S,World(),Unit,Unit,Build.empty_observe(~World()),Records.empty(~S),Unit,Exec.empty_plan(~S),Exec.empty_dispatch(~World()),Exec.empty_provide(~S,~World())>,Registered(),Array<U32>>:LocalApp.add(~S,~Unit,~U32,~Unit,~Array<U32>,~Unit,~Error,~Array<U32>,~Ops,~declaration(),~body,~Unit,~Unit,~Build.empty_observe(~World()),~Records.empty(~S),~Unit,~Exec.empty_plan(~S),~Exec.empty_dispatch(~World()),~Exec.empty_provide(~S,~World()),Exec.empty(~S,~World(),world),"Local count",ANode{ALeaf{0},ALeaf{1}},Unit{})
def flag_observed(first:U32,result:Array<U32> & U32) -> Array<U32> & String:
  match result:
    case (owner,flag):(owner,U32.show(first) ++ "," ++ U32.show(flag))
def count_observed(result:Array<U32> & U32) -> Array<U32> & String:
  match result:
    case (owner,count):flag_observed(count,Array.get(U32,owner,1))
def local_observed(owner:Array<U32>) -> Array<U32> & String:
  count_observed(Array.get(U32,owner,0))
def restored(schema:Schema.Schema<S,Unit,U32>,world:World(),prior:Unit,namespace:U32,id:U32,name:String,access:List<&2,String>,args:Unit,recipe:Tree.Recipe<World(),Rows(),observer()>,debug:Bool,plan:SP.Plan<S>,scheduleNamespace:U32,scheduleName:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,result:Array<U32> & String) -> Application() & String:
  match result:
    case (local,text):(Entry.Application{Schedule.Application{App.Application{schema,Build.Registered{world,(prior,LocalApp.Invocation{LocalApp.Owner{Local.Instance{namespace,id,name,access,local}},args}),recipe,debug}},plan,scheduleNamespace,scheduleName,steps,needs},Exec.Recipe{}},text)
def observed(app:Application()) -> Application() & String:
  match app:
    case Entry.Application{Schedule.Application{App.Application{schema,Build.Registered{world,(prior,LocalApp.Invocation{LocalApp.Owner{Local.Instance{namespace,id,name,access,local}},args}),recipe,debug}},plan,scheduleNamespace,scheduleName,steps,needs},_}:restored(schema,world,prior,namespace,id,name,access,args,recipe,debug,plan,scheduleNamespace,scheduleName,steps,needs,local_observed(local))
def resource_world(world:World()) -> World() & U32:
  match world:
    case W.World{namespace,allocator,store,+value,events,pending,registrations,nextSystemId,clock}:(W.World{namespace,allocator,store,value,events,pending,registrations,nextSystemId,clock},value)
def resource(app:Application()) -> Application() & U32:
  Entry.inspect(~S,~Unit,~U32,~Unit,~Owners(),~Rows(),~observer(),~folder(),~Choice.Choice<Unit,LocalApp.ExecutionError<Error>>,~planner(),~dispatcher(),~provisioner(),~U32,~resource_world,app)
