import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import ./state.bend as F
import ./bindings.bend as B
import ./base-application.bend as BaseApp
import ./event-setup.bend as Events
import ./dispatch.bend as Dispatch
import ./description.bend as Description
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-runtime.bend as Family
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Schedule
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-service-declaration.bend as Service
def Scheduled() -> Type:Schedule.Application<F.Other,F.Store,F.Resources,F.Events(),B.Owners4(),B.Rows4(),B.observe4(),B.fold4()>
type Application is Type:
  Application{scheduled:Scheduled(),family:Events.State(),tick:Nat}
type Attachment is Type:
  Attached{app:Application}
  Invalid{app:BaseApp.Application()}
def plan(sid:U32,cid:U32,rid:U32) -> SP.Plan<F.Other>:
  SP.Sequence{SP.Entry{Sch.Phase{"Prepare"},[]},SP.Sequence{SP.Entry{Sch.Barrier{},[]},SP.Sequence{SP.Entry{Sch.Phase{"Queries"},[]},SP.Sequence{SP.Entry{Sch.System{cid,0},[]},SP.Sequence{SP.Entry{Sch.System{rid,0},[]},SP.Sequence{SP.Entry{Sch.Phase{"Service"},[]},SP.Entry{Sch.System{sid,0},[Service.requirement(~F.Other,~F.Resources,~Array<U32>,~F.ClockRest,~F.clock_take,~F.clock_put,~F.clock_call,F.clock_declaration())]}}}}}}}
def attached(family:Events.State(),tick:Nat,result:Schedule.Attachment<BaseApp.Previous(),Scheduled()>) -> Attachment:
  match result:
    case Schedule.Invalid{SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}}}:Invalid{Family.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}}
    case Schedule.Attached{scheduled}:Attached{Application{scheduled,family,tick}}
def identified(schema:Schema.Schema<F.Other,F.Store,F.Resources>,family:Events.State(),tick:Nat,recipe:Tree.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,world:F.World(),result:B.Owners4() & (U32 & (U32 & U32))) -> Attachment:
  match result:
    case (owners,(sid,(cid,rid))):attached(family,tick,Schedule.attach(~F.Other,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},"Composed",plan(sid,cid,rid)))
def attach(value:BaseApp.Application()) -> Attachment:
  match value:
    case Family.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}:identified(schema,family,tick,recipe,debug,world,Dispatch.identified(owners))
def enabled(value:Application,flag:Bool) -> Application:
  match value:
    case Application{scheduled,family,tick}:Application{Schedule.enabled(~F.Other,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),scheduled,flag),family,tick}
def observed(family:Events.State(),tick:Nat,result:Scheduled() & Maybe<&2,Description.Description<F.Other,B.Rows4()>>) -> Application & Maybe<&2,Description.Description<F.Other,B.Rows4()>>:
  match result:
    case (scheduled,view):(Application{scheduled,family,tick},view)
def snapshot(value:Application) -> Application & Maybe<&2,Description.Description<F.Other,B.Rows4()>>:
  match value:
    case Application{scheduled,family,tick}:observed(family,tick,Description.snapshot(~F.Other,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),scheduled))
type Completion is Data:
  Finished{observations:List<&2,Sch.Observation>}
  Failed{error:Dispatch.Error,observations:List<&2,Sch.Observation>}
  Missing{requirements:List<&2,SP.Requirement<F.Other>>}
  Rejected{}
def completed(family:Events.State(),tick:Nat,result:Schedule.RunResult<Scheduled(),F.Other,Dispatch.Error>) -> Application & Completion:
  match result:
    case Schedule.Finished{scheduled,observations}:(Application{scheduled,family,tick},Finished{observations})
    case Schedule.Failed{scheduled,error,observations}:(Application{scheduled,family,tick},Failed{error,observations})
    case Schedule.Missing{scheduled,requirements}:(Application{scheduled,family,tick},Missing{requirements})
    case Schedule.Rejected{scheduled}:(Application{scheduled,family,tick},Rejected{})
def run(value:Application) -> Application & Completion:
  match value:
    case Application{scheduled,family,tick}:completed(family,tick,Schedule.run(~F.Other,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),~Dispatch.Error,~Dispatch.dispatch,~Dispatch.condition,~Dispatch.provision,scheduled))
