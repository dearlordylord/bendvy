import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import ./state.bend as F
import ./bindings.bend as B
import ./base-application.bend as BaseApp
import ./event-setup.bend as Events
import ./dispatch.bend as Dispatch
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-condition-schedule.bend as Description
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-condition-declaration.bend as Condition
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-runtime.bend as Family
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Schedule
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-service-declaration.bend as Service
def always(world:F.World()) -> F.World() & Bool:(world,True{})
def never(world:F.World()) -> F.World() & Bool:(world,False{})
type Ids is Data:
  Ids{service:U32,component:U32,resource:U32}
def component_id(ids:Ids) -> U32:
  match ids:
    case Ids{_,component,_}:component
def resource_id(ids:Ids) -> U32:
  match ids:
    case Ids{_,_,resource}:resource
def service_id(ids:Ids) -> U32:
  match ids:
    case Ids{service,_,_}:service
# One ordinary composition supplies execution, placements and names. Actual
# returned Registry IDs are bound once through the same leaf selectors.
def program() -> Condition.Program<F.S,F.Store,F.Resources,F.Events(),Ids>:
  Condition.sequence(~F.S,~F.Store,~F.Resources,~F.Events(),~Ids,Condition.sequence(~F.S,~F.Store,~F.Resources,~F.Events(),~Ids,Condition.sequence(~F.S,~F.Store,~F.Resources,~F.Events(),~Ids,Condition.sequence(~F.S,~F.Store,~F.Resources,~F.Events(),~Ids,Condition.phase(~F.S,~F.Store,~F.Resources,~F.Events(),~Ids,"Queries",[]),Condition.system(~F.S,~F.Store,~F.Resources,~F.Events(),~Ids,~always,~component_id,[],Condition.named(~F.S,~F.Store,~F.Resources,~F.Events(),~always,"RunComponents"))),Condition.system(~F.S,~F.Store,~F.Resources,~F.Events(),~Ids,~never,~resource_id,[],Condition.named(~F.S,~F.Store,~F.Resources,~F.Events(),~never,"SkipResources"))),Condition.system(~F.S,~F.Store,~F.Resources,~F.Events(),~Ids,~always,~service_id,[Service.requirement(~F.S,~F.Resources,~Array<U32>,~F.ClockRest,~F.clock_take,~F.clock_put,~F.clock_call,F.clock_declaration())],Condition.named(~F.S,~F.Store,~F.Resources,~F.Events(),~always,"RunService"))),Condition.barrier(~F.S,~F.Store,~F.Resources,~F.Events(),~Ids,[]))
def Program() -> Data:Condition.Entries<F.S>
def Scheduled() -> Type:Description.Application<F.S,F.Store,F.Resources,F.Events(),B.Owners4(),B.Rows4(),B.observe4(),B.fold4(),Ids,program()>
type Application is Type:
  Application{scheduled:Scheduled(),family:Events.State(),tick:Nat}
type Attachment is Type:
  Attached{app:Application}
  Invalid{app:BaseApp.Application()}
def ids(sid:U32,cid:U32,rid:U32) -> Ids:Ids{sid,cid,rid}
def attached(family:Events.State(),tick:Nat,result:Schedule.Attachment<BaseApp.Previous(),Scheduled()>) -> Attachment:
  match result:
    case Schedule.Invalid{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}}}:Invalid{Family.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}}
    case Schedule.Attached{scheduled}:Attached{Application{scheduled,family,tick}}
def identified(schema:Schema.Schema<F.S,F.Store,F.Resources>,family:Events.State(),tick:Nat,recipe:Tree.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,world:F.World(),result:B.Owners4() & (U32 & (U32 & U32))) -> Attachment:
  match result:
    case (owners,(sid,(cid,rid))):attached(family,tick,Description.attach(~F.S,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),~Ids,~program(),SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},"Composed",ids(sid,cid,rid)))
def attach(value:BaseApp.Application()) -> Attachment:
  match value:
    case Family.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}:identified(schema,family,tick,recipe,debug,world,Dispatch.identified(owners))
def enabled(value:Application,flag:Bool) -> Application:
  match value:
    case Application{scheduled,family,tick}:Application{Description.enabled(~F.S,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),~Ids,~program(),scheduled,flag),family,tick}
def observed(family:Events.State(),tick:Nat,result:Scheduled() & Maybe<&2,Description.Description<F.S,B.Rows4()>>) -> Application & Maybe<&2,Description.Description<F.S,B.Rows4()>>:
  match result:
    case (scheduled,view):(Application{scheduled,family,tick},view)
def snapshot(value:Application) -> Application & Maybe<&2,Description.Description<F.S,B.Rows4()>>:
  match value:
    case Application{scheduled,family,tick}:observed(family,tick,Description.snapshot(~F.S,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),~Ids,~program(),scheduled))
type Completion is Data:
  Finished{observations:List<&2,Sch.Observation>}
  Failed{error:Dispatch.Error,observations:List<&2,Sch.Observation>}
  Missing{requirements:List<&2,SP.Requirement<F.S>>}
  Rejected{}
def completed(family:Events.State(),tick:Nat,result:Schedule.RunResult<Scheduled(),F.S,Dispatch.Error>) -> Application & Completion:
  match result:
    case Schedule.Finished{scheduled,observations}:(Application{scheduled,family,tick},Finished{observations})
    case Schedule.Failed{scheduled,error,observations}:(Application{scheduled,family,tick},Failed{error,observations})
    case Schedule.Missing{scheduled,requirements}:(Application{scheduled,family,tick},Missing{requirements})
    case Schedule.Rejected{scheduled}:(Application{scheduled,family,tick},Rejected{})
def run(value:Application) -> Application & Completion:
  match value:
    case Application{scheduled,family,tick}:completed(family,tick,Description.run(~F.S,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),~Ids,~program(),~Dispatch.Error,~Dispatch.dispatch,~Dispatch.provision,scheduled))
