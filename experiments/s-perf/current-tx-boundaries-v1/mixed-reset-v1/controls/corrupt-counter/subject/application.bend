import Base
import schema.bend as S
import runtime.bend as R
import ../private/src/ecs/ordinary-app-existing-execution.bend as Existing
import ../private/src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../private/src/ecs/ordinary-app-run.bend as Entry
import ../private/src/ecs/ordinary-app-composer.bend as Build
import ../private/src/ecs/ordinary-app-schema.bend as App
import ../private/src/ecs/ordinary-app-schedule.bend as Schedule
import ../private/src/ecs/ordinary-app-execution.bend as Execution
import ../private/src/ecs/ordinary-app-registration-fields.bend as Fields
import ../private/src/ecs/ordinary-schema.bend as Schema
import ../private/src/ecs/schema-fragments.bend as Fragment
import ../private/src/ecs/ordinary-declaration.bend as Identity
import ../private/src/ecs/execution-context.bend as Ctx
import ../private/src/ecs/local.bend as Local
import ../private/src/ecs/system.bend as Sys
import ../private/src/ecs/schedule-provision.bend as SP
import ../private/src/ecs/trace-facts.bend as Facts
import ../private/src/ecs/world.bend as W

type Shared is Data:Shared{fail:Bool}
def Owners() -> Type:R.Instance() & Shared
def fields(owner:R.Instance()) -> R.Instance() & Fields.Fields<S.Schema>:Existing.local_fields(~S.Schema,~S.Store(),~Array<U32>,~U32,~R.State,~Bool,~Unit,~Unit,~R.runner,owner)
def completed(shared:Shared,trace:Facts.State,result:Local.Run<S.Schema,S.Store(),Array<U32>,U32,R.State,Bool,Unit,Unit,R.runner>) -> R.Instance() & (Shared & Sys.Outcome<Ctx.Context<S.World()>,Unit,Unit>):
  match result:
    case Local.Completed{world,instance,Done{Unit{}}}:(instance,(shared,Sys.Succeeded{Ctx.Context{world,trace},Unit{}}))
    case Local.Completed{world,instance,Fail{error}}:(instance,(shared,Sys.Failed{Ctx.Context{world,trace},error}))
    case Local.Refused{world,instance,_}:(instance,(shared,Sys.Failed{Ctx.Context{world,trace},Unit{}}))
def invoke(owner:R.Instance(),shared:Shared,context:Ctx.Context<S.World()>) -> R.Instance() & (Shared & Sys.Outcome<Ctx.Context<S.World()>,Unit,Unit>):
  match shared context:
    case Shared{+fail},Ctx.Context{world,trace}:completed(Shared{fail},trace,Local.run(~S.Schema,~S.Store(),~Array<U32>,~U32,~R.State,~Bool,~Unit,~Unit,~R.runner,owner,world,fail))
def enabled(shared:Shared) -> Shared & Bool:(shared,True{})
def fold(value:Owners()) -> Owners() & List<&2,Fields.Fields<S.Schema>>:Existing.fold(~S.Schema,~R.Instance(),~Shared,~fields,value)
def base_plan(value:Owners()) -> Owners() & SP.Plan<S.Schema>:Existing.plan(~S.Schema,~R.Instance(),~Shared,~fields,~enabled,~[],value)
def plan(value:Owners()) -> Owners() & SP.Plan<S.Schema>:Existing.after(~S.Schema,~R.Instance(),~Shared,~base_plan,~enabled,value)
def dispatch(value:Owners(),context:Ctx.Context<S.World()>,id:U32) -> Owners() & Sys.Outcome<Ctx.Context<S.World()>,Unit,Unit>:Existing.dispatch(~S.Schema,~S.World(),~R.Instance(),~Shared,~Unit,~fields,~invoke,~Unit{},value,context,id)
def provide(world:S.World()) -> S.World() & List<&2,SP.Requirement<S.Schema>>:(world,[])
def Registered() -> Type:Exec.Registered<S.Schema,S.World(),Owners(),Unit,Build.empty_observe(~S.World()),fold,Unit,plan,dispatch,provide>
def Application() -> Type:Entry.Application<S.Schema,S.Store(),Array<U32>,U32,Owners(),Unit,Build.empty_observe(~S.World()),fold,Unit,plan,dispatch,provide>
def resource() -> Schema.Resource<S.Schema,Array<U32>>:Schema.resource(~S.Schema,~Array<U32>,"Ledger")
def event() -> Fragment.Descriptor<S.Schema,Unit,U32>:Fragment.Descriptor{Fragment.Event{},"Ping","Ping"}
def schema() -> Schema.Schema<S.Schema,S.Store(),Array<U32>>:Schema.Schema{List.append(&2,Fragment.Entry<S.Schema>,Schema.entries(~S.Schema,~S.Store(),~Unit,Schema.component(~S.Schema,~Array<U32>,S.identity())),List.append(&2,Fragment.Entry<S.Schema>,Schema.entries(~S.Schema,~Unit,~Array<U32>,Schema.resource_schema(~S.Schema,~Array<U32>,resource())),[Fragment.entry(~S.Schema,~Unit,~U32,event())]))}
def keys(values:List<&2,Fragment.Entry<S.Schema>>) -> List<&2,String>:
  match values:
    case []:[]
    case Fragment.Entry{_,key,_} <> rest:key <> keys(rest)
    case Fragment.Classified{_,key,_,_} <> rest:key <> keys(rest)
def access() -> List<&2,String>:keys(Schema.entries(~S.Schema,~S.Store(),~Array<U32>,schema()))
def attach(world:S.World(),owners:Owners()) -> Schedule.Attachment<Registered(),Application()>:Entry.attach(~S.Schema,~S.Store(),~Array<U32>,~U32,~Owners(),~Unit,~Build.empty_observe(~S.World()),~fold,~Unit,~plan,~dispatch,~provide,schema(),Existing.registered(~S.Schema,~S.World(),~Owners(),~fold,~Unit,~plan,~dispatch,~provide,world,owners),"MixedBoundary",False{})
def run(app:Application()) -> Execution.Run<Application(),S.Schema,Unit>:Entry.run(~S.Schema,~S.Store(),~Array<U32>,~U32,~Owners(),~Unit,~Build.empty_observe(~S.World()),~fold,~Unit,~plan,~dispatch,~provide,app)
type Created is Type:
  Created{world:S.World(),owners:Owners()}
  Refused{}
def registered(fail:Bool,result:Local.Registered<S.Schema,S.Store(),Array<U32>,U32,R.State,Bool,Unit,Unit,R.runner>) -> Created:
  match result:
    case Local.Registered{world,instance}:Created{world,(instance,Shared{fail})}
    case _:Refused{}
def register(world:S.World(),fail:Bool) -> Created:registered(fail,Local.register(~S.Schema,~S.Store(),~Array<U32>,~U32,~R.State,~Bool,~Unit,~Unit,~R.runner,world,"MixedLocal",access(),R.initial(Unit{})))
