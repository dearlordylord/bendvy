import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/scenario-schema.bend as S
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/scenario-driver.bend as Driver
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/scenario-execution.bend as Execution
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/scenario-systems.bend as Systems
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/scenario-queries.bend as Queries
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/scenario-body.bend as Body
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/scenario-dto.bend as DTO
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP

import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-run-v1/nominal-carrier-v1/accumulated-v1/dispatch.bend as Dispatch

import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-run-v1/nominal-carrier-v1/accumulated-v1/application.bend as Actual

type Phase is Data:
  Phase{+label:String,details:Actual.Details,snapshot:DTO.Snapshot}
type Observed<-C:Type,-H:Type> is Type:
  Observed{factory:W.Factory,delivery:Actual.Delivery<C,H>,phase:Phase}
  Failed{factory:W.Factory,delivery:Actual.Delivery<C,H>}

def plain_world_seen(+debug:Ordinary.Debug,+entries:List<&2,Ordinary.Entry<S.Schema>>,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,+requirements:List<&2,SP.Requirement<S.Schema>>,+trace:Dispatch.Trace,+details:Actual.Details,+label:String,factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:Driver.plain_owners(),snapshots:List<&2,DTO.Snapshot>) -> Observed<S.plain_store(),Dispatch.Plain>:
  match snapshots:
    case snapshot <> []:Observed{factory,Actual.Delivered{Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,Dispatch.plain_pack((owners,trace))},requirements}},world,details},Phase{label,details,snapshot}}
    case _:Failed{factory,Actual.Delivered{Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,Dispatch.plain_pack((owners,trace))},requirements}},world,details}}
def plain_owners_seen(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+details:Actual.Details,+label:String,+first:Maybe<&2,Ordinary.Description<S.Schema>>,+second:Maybe<&2,Ordinary.Description<S.Schema>>,+debug:Ordinary.Debug,+entries:List<&2,Ordinary.Entry<S.Schema>>,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,+requirements:List<&2,SP.Requirement<S.Schema>>,returned:Dispatch.plain_owners()) -> Observed<S.plain_store(),Dispatch.Plain>:
  Dispatch.Plain{main,added,changed,without,withHealth,+trace} = returned
  Driver.plain_observe(~Observed<S.plain_store(),Dispatch.Plain>,(factory => world => owners => snapshots => plain_world_seen(debug,entries,namespace,name,steps,requirements,trace,details,label,factory,world,owners,snapshots)),factory,world,(((((Unit{},main),added),changed),without),withHealth),[],label,DTO.Observed{},[first,second])
def plain_detached(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,details:Actual.Details,+label:String,first:Maybe<&2,Ordinary.Description<S.Schema>>,second:Maybe<&2,Ordinary.Description<S.Schema>>,app:Ordinary.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.plain_owners()>) -> Observed<S.plain_store(),Dispatch.Plain>:
  match app:
    case Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,returned},requirements}}:plain_owners_seen(factory,world,details,label,first,second,debug,entries,namespace,name,steps,requirements,returned)
def plain_described(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,details:Actual.Details,+label:String,first:Maybe<&2,Ordinary.Description<S.Schema>>,described:Ordinary.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.plain_owners()> & Maybe<&2,Ordinary.Description<S.Schema>>) -> Observed<S.plain_store(),Dispatch.Plain>:
  match described:
    case (app,second):plain_detached(factory,world,details,label,first,second,app)
def plain_first(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,details:Actual.Details,+label:String,described:Ordinary.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.plain_owners()> & Maybe<&2,Ordinary.Description<S.Schema>>) -> Observed<S.plain_store(),Dispatch.Plain>:
  match described:
    case (app,first):plain_described(factory,world,details,label,first,Ordinary.describe(~S.Schema,~S.plain_store(),~Unit,~Unit,~Dispatch.plain_owners(),app))
def plain_observe(factory:W.Factory,+label:String,delivery:Actual.Delivery<S.plain_store(),Dispatch.Plain>) -> Observed<S.plain_store(),Dispatch.Plain>:
  match delivery:
    case Actual.BuildRejected{world,owners}:Failed{factory,Actual.BuildRejected{world,owners}}
    case Actual.Delivered{app,world,details}:plain_first(factory,world,details,label,Ordinary.describe(~S.Schema,~S.plain_store(),~Unit,~Unit,~Dispatch.plain_owners(),app))

def transient_world_seen(+debug:Ordinary.Debug,+entries:List<&2,Ordinary.Entry<S.Schema>>,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,+requirements:List<&2,SP.Requirement<S.Schema>>,+trace:Dispatch.Trace,+details:Actual.Details,+label:String,factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:Driver.transient_owners(),snapshots:List<&2,DTO.Snapshot>) -> Observed<S.transient_store(),Dispatch.Transient>:
  match snapshots:
    case snapshot <> []:Observed{factory,Actual.Delivered{Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,Dispatch.transient_pack((owners,trace))},requirements}},world,details},Phase{label,details,snapshot}}
    case _:Failed{factory,Actual.Delivered{Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,Dispatch.transient_pack((owners,trace))},requirements}},world,details}}
def transient_owners_seen(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+details:Actual.Details,+label:String,+first:Maybe<&2,Ordinary.Description<S.Schema>>,+second:Maybe<&2,Ordinary.Description<S.Schema>>,+debug:Ordinary.Debug,+entries:List<&2,Ordinary.Entry<S.Schema>>,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,+requirements:List<&2,SP.Requirement<S.Schema>>,returned:Dispatch.transient_owners()) -> Observed<S.transient_store(),Dispatch.Transient>:
  Dispatch.Transient{main,added,changed,without,withHealth,+trace} = returned
  Driver.transient_observe(~Observed<S.transient_store(),Dispatch.Transient>,(factory => world => owners => snapshots => transient_world_seen(debug,entries,namespace,name,steps,requirements,trace,details,label,factory,world,owners,snapshots)),factory,world,(((((Unit{},main),added),changed),without),withHealth),[],label,DTO.Observed{},[first,second])
def transient_detached(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,details:Actual.Details,+label:String,first:Maybe<&2,Ordinary.Description<S.Schema>>,second:Maybe<&2,Ordinary.Description<S.Schema>>,app:Ordinary.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.transient_owners()>) -> Observed<S.transient_store(),Dispatch.Transient>:
  match app:
    case Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,returned},requirements}}:transient_owners_seen(factory,world,details,label,first,second,debug,entries,namespace,name,steps,requirements,returned)
def transient_described(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,details:Actual.Details,+label:String,first:Maybe<&2,Ordinary.Description<S.Schema>>,described:Ordinary.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.transient_owners()> & Maybe<&2,Ordinary.Description<S.Schema>>) -> Observed<S.transient_store(),Dispatch.Transient>:
  match described:
    case (app,second):transient_detached(factory,world,details,label,first,second,app)
def transient_first(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,details:Actual.Details,+label:String,described:Ordinary.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.transient_owners()> & Maybe<&2,Ordinary.Description<S.Schema>>) -> Observed<S.transient_store(),Dispatch.Transient>:
  match described:
    case (app,first):transient_described(factory,world,details,label,first,Ordinary.describe(~S.Schema,~S.transient_store(),~Unit,~Unit,~Dispatch.transient_owners(),app))
def transient_observe(factory:W.Factory,+label:String,delivery:Actual.Delivery<S.transient_store(),Dispatch.Transient>) -> Observed<S.transient_store(),Dispatch.Transient>:
  match delivery:
    case Actual.BuildRejected{world,owners}:Failed{factory,Actual.BuildRejected{world,owners}}
    case Actual.Delivered{app,world,details}:transient_first(factory,world,details,label,Ordinary.describe(~S.Schema,~S.transient_store(),~Unit,~Unit,~Dispatch.transient_owners(),app))

def constructed_world_seen(+debug:Ordinary.Debug,+entries:List<&2,Ordinary.Entry<S.Schema>>,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,+requirements:List<&2,SP.Requirement<S.Schema>>,+trace:Dispatch.Trace,+details:Actual.Details,+label:String,factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:Driver.constructed_owners(),snapshots:List<&2,DTO.Snapshot>) -> Observed<S.constructed_store(),Dispatch.Constructed>:
  match snapshots:
    case snapshot <> []:Observed{factory,Actual.Delivered{Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,Dispatch.constructed_pack((owners,trace))},requirements}},world,details},Phase{label,details,snapshot}}
    case _:Failed{factory,Actual.Delivered{Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,Dispatch.constructed_pack((owners,trace))},requirements}},world,details}}
def constructed_owners_seen(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+details:Actual.Details,+label:String,+first:Maybe<&2,Ordinary.Description<S.Schema>>,+second:Maybe<&2,Ordinary.Description<S.Schema>>,+debug:Ordinary.Debug,+entries:List<&2,Ordinary.Entry<S.Schema>>,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,+requirements:List<&2,SP.Requirement<S.Schema>>,returned:Dispatch.constructed_owners()) -> Observed<S.constructed_store(),Dispatch.Constructed>:
  Dispatch.Constructed{main,added,changed,without,withHealth,+trace} = returned
  Driver.constructed_observe(~Observed<S.constructed_store(),Dispatch.Constructed>,(factory => world => owners => snapshots => constructed_world_seen(debug,entries,namespace,name,steps,requirements,trace,details,label,factory,world,owners,snapshots)),factory,world,(((((Unit{},main),added),changed),without),withHealth),[],label,DTO.Observed{},[first,second])
def constructed_detached(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,details:Actual.Details,+label:String,first:Maybe<&2,Ordinary.Description<S.Schema>>,second:Maybe<&2,Ordinary.Description<S.Schema>>,app:Ordinary.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.constructed_owners()>) -> Observed<S.constructed_store(),Dispatch.Constructed>:
  match app:
    case Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,returned},requirements}}:constructed_owners_seen(factory,world,details,label,first,second,debug,entries,namespace,name,steps,requirements,returned)
def constructed_described(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,details:Actual.Details,+label:String,first:Maybe<&2,Ordinary.Description<S.Schema>>,described:Ordinary.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.constructed_owners()> & Maybe<&2,Ordinary.Description<S.Schema>>) -> Observed<S.constructed_store(),Dispatch.Constructed>:
  match described:
    case (app,second):constructed_detached(factory,world,details,label,first,second,app)
def constructed_first(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,details:Actual.Details,+label:String,described:Ordinary.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.constructed_owners()> & Maybe<&2,Ordinary.Description<S.Schema>>) -> Observed<S.constructed_store(),Dispatch.Constructed>:
  match described:
    case (app,first):constructed_described(factory,world,details,label,first,Ordinary.describe(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Dispatch.constructed_owners(),app))
def constructed_observe(factory:W.Factory,+label:String,delivery:Actual.Delivery<S.constructed_store(),Dispatch.Constructed>) -> Observed<S.constructed_store(),Dispatch.Constructed>:
  match delivery:
    case Actual.BuildRejected{world,owners}:Failed{factory,Actual.BuildRejected{world,owners}}
    case Actual.Delivered{app,world,details}:constructed_first(factory,world,details,label,Ordinary.describe(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Dispatch.constructed_owners(),app))
