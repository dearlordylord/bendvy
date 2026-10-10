import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v1/bridge.bend as Resource
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as DTO
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/compact-observation-app-v1/recipes.bend as Compact
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/schedule-observation-v1/schedule.bend as Projection
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
# Private additive DTO; existing App rows and actual bindings remain intact.
type ScheduleDescription<S:Data> is Data:
  ScheduleDescription{namespace:U32,name:String,steps:List<&2,Projection.PlannedStep<S>>,systems:List<&2,DTO.Binding<S>>}
type ApplicationType<-S:Data,-C:Type,-R:Type,-E:Data,-H:Type,-Rows:Data,-Recipe:Type> is Type:
  Application{world:W.World<S,C,R,E>,operational:SP.Plan<S>,schedule:SP.Provisioned<S,C,R,E,H>,recipe:Recipe,debug:Bool}
# Build-only catalog traversal serves the existing operational validation.
# It neither constructs descriptions nor calls any owner/fold callback.
def catalog_ids(registrations:List<&2,W.RegistrationMeta>) -> List<&2,U32>:
  match registrations:
    case []:[]
    case W.RegistrationMeta{id,_,_} <> rest:id <> catalog_ids(rest)
def catalog(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & (U32 & List<&2,U32>):
  match world:
    case W.World{+namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,+registrations,nextSystemId,clock}:
      (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},(namespace,catalog_ids(registrations)))
def attached(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~Recipe:Type,world:W.World<S,C,R,E>,plan:SP.Plan<S>,recipe:Recipe,debug:Bool,result:SP.Build<S,C,R,E,H>) -> DTO.Registration<Compact.Application<S,W.World<S,C,R,E>,H,Rows,Recipe>,ApplicationType<S,C,R,E,H,Rows,Recipe>>:
  match result:
    case SP.Invalid{owners}:DTO.Failed{Compact.Application{world,owners,recipe,debug}}
    case SP.Built{schedule}:DTO.Registered{Application{world,plan,schedule,recipe,debug}}
def cataloged(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~Recipe:Type,owners:H,recipe:Recipe,debug:Bool,name:String,+plan:SP.Plan<S>,observed:W.World<S,C,R,E> & (U32 & List<&2,U32>)) -> DTO.Registration<Compact.Application<S,W.World<S,C,R,E>,H,Rows,Recipe>,ApplicationType<S,C,R,E,H,Rows,Recipe>>:
  match observed:
    case (world,(namespace,ids)):attached(~S,~C,~R,~E,~H,~Rows,~Recipe,world,plan,recipe,debug,SP.build(~S,~C,~R,~E,~H,namespace,name,plan,ids,owners))
def attach(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~Recipe:Type,app:Compact.Application<S,W.World<S,C,R,E>,H,Rows,Recipe>,name:String,plan:SP.Plan<S>) -> DTO.Registration<Compact.Application<S,W.World<S,C,R,E>,H,Rows,Recipe>,ApplicationType<S,C,R,E,H,Rows,Recipe>>:
  match app:
    case Compact.Application{world,owners,recipe,debug}:cataloged(~S,~C,~R,~E,~H,~Rows,~Recipe,owners,recipe,debug,name,plan,catalog(~S,~C,~R,~E,world))
def enable_debug(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~Recipe:Type,app:ApplicationType<S,C,R,E,H,Rows,Recipe>,enabled:Bool) -> ApplicationType<S,C,R,E,H,Rows,Recipe>:
  match app:
    case Application{world,plan,schedule,recipe,_}:Application{world,plan,schedule,recipe,enabled}
def snapshot_returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~Recipe:Type,+plan:SP.Plan<S>,+namespace:U32,+name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,result:Compact.Application<S,W.World<S,C,R,E>,H,Rows,Recipe> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>) -> ApplicationType<S,C,R,E,H,Rows,Recipe> & Maybe<&2,DTO.Product<DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>,ScheduleDescription<S>>>:
  match result:
    case (Compact.Application{world,owners,recipe,debug},None{}):(Application{world,plan,SP.Provisioned{Sch.Schedule{namespace,name,steps,owners},needs},recipe,debug},None{})
    case (Compact.Application{world,owners,recipe,debug},Some{DTO.Product{+bindings,rows}}):(Application{world,plan,SP.Provisioned{Sch.Schedule{namespace,name,steps,owners},needs},recipe,debug},Some{DTO.Product{DTO.Product{bindings,rows},ScheduleDescription{namespace,name,Projection.planned(~S,plan),bindings}}})
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~Recipe:Type,snapshotApp:Compact.Application<S,W.World<S,C,R,E>,H,Rows,Recipe> -> Compact.Application<S,W.World<S,C,R,E>,H,Rows,Recipe> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>,app:ApplicationType<S,C,R,E,H,Rows,Recipe>) -> ApplicationType<S,C,R,E,H,Rows,Recipe> & Maybe<&2,DTO.Product<DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>,ScheduleDescription<S>>>:
  match app:
    case Application{world,plan,schedule,recipe,False{}}:(Application{world,plan,schedule,recipe,False{}},None{})
    case Application{world,plan,SP.Provisioned{Sch.Schedule{namespace,name,steps,owners},needs},recipe,True{}}:snapshot_returned(~S,~C,~R,~E,~H,~Rows,~Recipe,plan,namespace,name,steps,needs,snapshotApp(Compact.Application{world,owners,recipe,True{}}))
# Exact transport of every existing provision/schedule result; no refusal
# branch is converted to a success or a fixture-defined execution failure.
type RunResult<-Application:Type,-S:Data,-Error:Data> is Type:
  Finished{app:Application,observations:List<&2,Sch.Observation>}
  Failed{app:Application,error:Error,observations:List<&2,Sch.Observation>}
  Rejected{app:Application}
  Missing{app:Application,missing:List<&2,SP.Requirement<S>>}
def executed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~Recipe:Type,~Error:Data,plan:SP.Plan<S>,recipe:Recipe,debug:Bool,needs:List<&2,SP.Requirement<S>>,result:Sch.RunResult<S,C,R,E,H,Error>) -> RunResult<ApplicationType<S,C,R,E,H,Rows,Recipe>,S,Error>:
  match result:
    case Sch.Finished{schedule,world,observations}:Finished{Application{world,plan,SP.Provisioned{schedule,needs},recipe,debug},observations}
    case Sch.Failed{schedule,world,error,observations}:Failed{Application{world,plan,SP.Provisioned{schedule,needs},recipe,debug},error,observations}
    case Sch.Rejected{schedule,world}:Rejected{Application{world,plan,SP.Provisioned{schedule,needs},recipe,debug}}
def provisioned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~Recipe:Type,~Error:Data,plan:SP.Plan<S>,recipe:Recipe,debug:Bool,result:SP.ProvisionResult<S,C,R,E,H,Error>) -> RunResult<ApplicationType<S,C,R,E,H,Rows,Recipe>,S,Error>:
  match result:
    case SP.Missing{schedule,world,missing}:Missing{Application{world,plan,schedule,recipe,debug},missing}
    case SP.Executed{result,requirements}:executed(~S,~C,~R,~E,~H,~Rows,~Recipe,~Error,plan,recipe,debug,requirements,result)
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~Recipe:Type,~Error:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,app:ApplicationType<S,C,R,E,H,Rows,Recipe>) -> RunResult<ApplicationType<S,C,R,E,H,Rows,Recipe>,S,Error>:
  match app:
    case Application{world,plan,schedule,recipe,debug}:provisioned(~S,~C,~R,~E,~H,~Rows,~Recipe,~Error,plan,recipe,debug,SP.run(~S,~C,~R,~E,~H,~Error,~dispatch,~condition,~provision,schedule,world))
# Registration-generated invocation transports the same owner pack.
def invoked(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~Recipe:Type,~Args:Type,~Error:Data,~Out:Type,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,result:Resource.RunResult<Compact.Application<S,W.World<S,C,R,E>,H,Rows,Recipe>,Args,Error,Out>) -> Resource.RunResult<ApplicationType<S,C,R,E,H,Rows,Recipe>,Args,Error,Out>:
  match result:
    case Resource.Completed{Compact.Application{world,owners,recipe,debug},outcome}:Resource.Completed{Application{world,plan,SP.Provisioned{Sch.Schedule{namespace,name,steps,owners},needs},recipe,debug},outcome}
    case Resource.RegistrationRejected{Compact.Application{world,owners,recipe,debug},args}:Resource.RegistrationRejected{Application{world,plan,SP.Provisioned{Sch.Schedule{namespace,name,steps,owners},needs},recipe,debug},args}
def invoke(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~Recipe:Type,~Args:Type,~Error:Data,~Out:Type,invokeApp:Compact.Application<S,W.World<S,C,R,E>,H,Rows,Recipe> -> Args -> Resource.RunResult<Compact.Application<S,W.World<S,C,R,E>,H,Rows,Recipe>,Args,Error,Out>,app:ApplicationType<S,C,R,E,H,Rows,Recipe>,args:Args) -> Resource.RunResult<ApplicationType<S,C,R,E,H,Rows,Recipe>,Args,Error,Out>:
  match app:
    case Application{world,plan,SP.Provisioned{Sch.Schedule{namespace,name,steps,owners},needs},recipe,debug}:invoked(~S,~C,~R,~E,~H,~Rows,~Recipe,~Args,~Error,~Out,plan,namespace,name,steps,needs,invokeApp(Compact.Application{world,owners,recipe,debug},args))
