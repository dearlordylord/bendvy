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

import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-run-v1/nominal-carrier-v1/accumulated-v1/observation.bend as Observe
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/scenario-setup.bend as Setup
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/experiments/public-simulation/bend-v1/owner-view.bend as View

type Report is Data:
  Report{category:String,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,registrationBefore:List<&2,W.RegistrationMeta>,removedRegistrations:List<&2,W.RegistrationMeta>}
type ExecutionResult<-C:Type,-H:Type> is Type:
  Completed{factory:W.Factory,app:Ordinary.Application<S.Schema,C,Unit,Unit,H>,world:W.World<S.Schema,C,Unit,Unit>,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,C,Unit,Unit>>,report:Report}
  Unexpected{factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,C,Unit,Unit>>,actual:Actual.Delivery<C,H>}
  SeedRejected{failure:Driver.Failure}


# Trusted corruption/refusal control only, not a public disposal operation.
def remove_decide(allowed:Bool,+head:W.RegistrationMeta,tail:List<&2,W.RegistrationMeta> & List<&2,W.RegistrationMeta>) -> List<&2,W.RegistrationMeta> & List<&2,W.RegistrationMeta>:
  match allowed:
    case True{}:
      (kept,removed) = tail
      (kept,head <> removed)
    case False{}:
      (kept,removed) = tail
      (head <> kept,removed)
def remove_head(+head:W.RegistrationMeta,tail:List<&2,W.RegistrationMeta> & List<&2,W.RegistrationMeta>) -> List<&2,W.RegistrationMeta> & List<&2,W.RegistrationMeta>:
  match head:
    case W.RegistrationMeta{+id,+name,+access}:remove_decide(U32.is_eq(id,1),W.RegistrationMeta{id,name,access},tail)
def remove_id(items:List<&2,W.RegistrationMeta>) -> List<&2,W.RegistrationMeta> & List<&2,W.RegistrationMeta>:
  match items:
    case []:([],[])
    case +head <> rest:remove_head(head,remove_id(rest))
def removed_world(~C:Type,world:W.World<S.Schema,C,Unit,Unit>,+before:List<&2,W.RegistrationMeta>,filtered:List<&2,W.RegistrationMeta> & List<&2,W.RegistrationMeta>) -> W.World<S.Schema,C,Unit,Unit> & (List<&2,W.RegistrationMeta> & List<&2,W.RegistrationMeta>):
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,_,nextSystemId,clock}:
      (kept,removed) = filtered
      (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,kept,nextSystemId,clock},(before,removed))
def remove_registration(~C:Type,world:W.World<S.Schema,C,Unit,Unit>) -> W.World<S.Schema,C,Unit,Unit> & (List<&2,W.RegistrationMeta> & List<&2,W.RegistrationMeta>):
  match world:
    case W.World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}:
      removed_world(~C,W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},registrations,remove_id(registrations))

def plain_refusal_done(baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,foreign:W.World<S.Schema,S.plain_store(),Unit,Unit>,before:List<&2,W.RegistrationMeta>,removed:List<&2,W.RegistrationMeta>,observed:Observe.Observed<S.plain_store(),Dispatch.Plain>) -> ExecutionResult<S.plain_store(),Dispatch.Plain>:
  match observed:
    case Observe.Failed{factory,actual}:Unexpected{factory,baseline,phases,detached,[foreign],actual}
    case Observe.Observed{factory,Actual.Delivered{app,world,details},phase}:Completed{factory,app,world,detached,[foreign],Report{"plain",baseline,List.append(&2,Observe.Phase,phases,[phase]),before,removed}}
    case Observe.Observed{factory,actual,phase}:Unexpected{factory,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,[foreign],actual}
def plain_removed(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,foreign:W.World<S.Schema,S.plain_store(),Unit,Unit>,app:Ordinary.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.plain_owners()>,removedWorld:W.World<S.Schema,S.plain_store(),Unit,Unit> & (List<&2,W.RegistrationMeta> & List<&2,W.RegistrationMeta>)) -> ExecutionResult<S.plain_store(),Dispatch.Plain>:
  (world,(before,removed)) = removedWorld
  plain_refusal_done(baseline,phases,detached,foreign,before,removed,Observe.plain_observe(factory,"registration-refusal",Actual.plain_run(app,world)))
def plain_foreign_done(original:W.World<S.Schema,S.plain_store(),Unit,Unit>,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,observed:Observe.Observed<S.plain_store(),Dispatch.Plain>) -> ExecutionResult<S.plain_store(),Dispatch.Plain>:
  match observed:
    case Observe.Failed{factory,actual}:Unexpected{factory,baseline,phases,detached,[original],actual}
    case Observe.Observed{factory,Actual.Delivered{app,foreign,details},phase}:plain_removed(factory,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,foreign,app,remove_registration(~S.plain_store(),original))
    case Observe.Observed{factory,actual,phase}:Unexpected{factory,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,[original],actual}
def plain_foreign_created(original:W.World<S.Schema,S.plain_store(),Unit,Unit>,app:Ordinary.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.plain_owners()>,details:Actual.Details,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,created:W.Creation<S.Schema,S.plain_store(),Unit,Unit>) -> ExecutionResult<S.plain_store(),Dispatch.Plain>:
  match created:
    case W.CreateRejected{factory,resource}:Unexpected{factory,baseline,phases,detached,[],Actual.Delivered{app,original,details}}
    case W.Created{factory,foreign}:plain_foreign_done(original,baseline,phases,detached,Observe.plain_observe(factory,"namespace-rejected",Actual.plain_run(app,foreign)))

def transient_refusal_done(baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,foreign:W.World<S.Schema,S.transient_store(),Unit,Unit>,before:List<&2,W.RegistrationMeta>,removed:List<&2,W.RegistrationMeta>,observed:Observe.Observed<S.transient_store(),Dispatch.Transient>) -> ExecutionResult<S.transient_store(),Dispatch.Transient>:
  match observed:
    case Observe.Failed{factory,actual}:Unexpected{factory,baseline,phases,detached,[foreign],actual}
    case Observe.Observed{factory,Actual.Delivered{app,world,details},phase}:Completed{factory,app,world,detached,[foreign],Report{"transient",baseline,List.append(&2,Observe.Phase,phases,[phase]),before,removed}}
    case Observe.Observed{factory,actual,phase}:Unexpected{factory,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,[foreign],actual}
def transient_removed(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,foreign:W.World<S.Schema,S.transient_store(),Unit,Unit>,app:Ordinary.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.transient_owners()>,removedWorld:W.World<S.Schema,S.transient_store(),Unit,Unit> & (List<&2,W.RegistrationMeta> & List<&2,W.RegistrationMeta>)) -> ExecutionResult<S.transient_store(),Dispatch.Transient>:
  (world,(before,removed)) = removedWorld
  transient_refusal_done(baseline,phases,detached,foreign,before,removed,Observe.transient_observe(factory,"registration-refusal",Actual.transient_run(app,world)))
def transient_foreign_done(original:W.World<S.Schema,S.transient_store(),Unit,Unit>,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,observed:Observe.Observed<S.transient_store(),Dispatch.Transient>) -> ExecutionResult<S.transient_store(),Dispatch.Transient>:
  match observed:
    case Observe.Failed{factory,actual}:Unexpected{factory,baseline,phases,detached,[original],actual}
    case Observe.Observed{factory,Actual.Delivered{app,foreign,details},phase}:transient_removed(factory,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,foreign,app,remove_registration(~S.transient_store(),original))
    case Observe.Observed{factory,actual,phase}:Unexpected{factory,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,[original],actual}
def transient_foreign_created(original:W.World<S.Schema,S.transient_store(),Unit,Unit>,app:Ordinary.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.transient_owners()>,details:Actual.Details,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,created:W.Creation<S.Schema,S.transient_store(),Unit,Unit>) -> ExecutionResult<S.transient_store(),Dispatch.Transient>:
  match created:
    case W.CreateRejected{factory,resource}:Unexpected{factory,baseline,phases,detached,[],Actual.Delivered{app,original,details}}
    case W.Created{factory,foreign}:transient_foreign_done(original,baseline,phases,detached,Observe.transient_observe(factory,"namespace-rejected",Actual.transient_run(app,foreign)))

def constructed_refusal_done(baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,foreign:W.World<S.Schema,S.constructed_store(),Unit,Unit>,before:List<&2,W.RegistrationMeta>,removed:List<&2,W.RegistrationMeta>,observed:Observe.Observed<S.constructed_store(),Dispatch.Constructed>) -> ExecutionResult<S.constructed_store(),Dispatch.Constructed>:
  match observed:
    case Observe.Failed{factory,actual}:Unexpected{factory,baseline,phases,detached,[foreign],actual}
    case Observe.Observed{factory,Actual.Delivered{app,world,details},phase}:Completed{factory,app,world,detached,[foreign],Report{"constructed",baseline,List.append(&2,Observe.Phase,phases,[phase]),before,removed}}
    case Observe.Observed{factory,actual,phase}:Unexpected{factory,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,[foreign],actual}
def constructed_removed(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,foreign:W.World<S.Schema,S.constructed_store(),Unit,Unit>,app:Ordinary.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.constructed_owners()>,removedWorld:W.World<S.Schema,S.constructed_store(),Unit,Unit> & (List<&2,W.RegistrationMeta> & List<&2,W.RegistrationMeta>)) -> ExecutionResult<S.constructed_store(),Dispatch.Constructed>:
  (world,(before,removed)) = removedWorld
  constructed_refusal_done(baseline,phases,detached,foreign,before,removed,Observe.constructed_observe(factory,"registration-refusal",Actual.constructed_run(app,world)))
def constructed_foreign_done(original:W.World<S.Schema,S.constructed_store(),Unit,Unit>,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,observed:Observe.Observed<S.constructed_store(),Dispatch.Constructed>) -> ExecutionResult<S.constructed_store(),Dispatch.Constructed>:
  match observed:
    case Observe.Failed{factory,actual}:Unexpected{factory,baseline,phases,detached,[original],actual}
    case Observe.Observed{factory,Actual.Delivered{app,foreign,details},phase}:constructed_removed(factory,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,foreign,app,remove_registration(~S.constructed_store(),original))
    case Observe.Observed{factory,actual,phase}:Unexpected{factory,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,[original],actual}
def constructed_foreign_created(original:W.World<S.Schema,S.constructed_store(),Unit,Unit>,app:Ordinary.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.constructed_owners()>,details:Actual.Details,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,created:W.Creation<S.Schema,S.constructed_store(),Unit,Unit>) -> ExecutionResult<S.constructed_store(),Dispatch.Constructed>:
  match created:
    case W.CreateRejected{factory,resource}:Unexpected{factory,baseline,phases,detached,[],Actual.Delivered{app,original,details}}
    case W.Created{factory,foreign}:constructed_foreign_done(original,baseline,phases,detached,Observe.constructed_observe(factory,"namespace-rejected",Actual.constructed_run(app,foreign)))
def plain_disabled_done(baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,observed:Observe.Observed<S.plain_store(),Dispatch.Plain>) -> ExecutionResult<S.plain_store(),Dispatch.Plain>:
  match observed:
    case Observe.Failed{factory,actual}:Unexpected{factory,baseline,phases,detached,[],actual}
    case Observe.Observed{factory,Actual.Delivered{app,world,details},phase}:plain_foreign_created(world,app,details,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,W.create(~S.Schema,~S.plain_store(),~Unit,~Unit,~Setup.plain_empty,factory,Unit{}))
    case Observe.Observed{factory,actual,phase}:Unexpected{factory,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,[],actual}
def plain_disabled_unpacked(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,returned:Driver.plain_owners() & Dispatch.Trace) -> ExecutionResult<S.plain_store(),Dispatch.Plain>:
  (owners,trace) = returned
  plain_disabled_done(baseline,phases,detached,Observe.plain_observe(factory,"disabled-success",Actual.plain_start(world,owners,Ordinary.Disabled{},0)))
def plain_disabled_start(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,app:Ordinary.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.plain_owners()>) -> ExecutionResult<S.plain_store(),Dispatch.Plain>:
  match app:
    case Ordinary.Application{_,_,SP.Provisioned{Sch.Schedule{_,_,_,returned},_}}:
      plain_disabled_unpacked(factory,baseline,phases,detached,world,Dispatch.plain_unpack(returned))
def plain_retry_done(baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,observed:Observe.Observed<S.plain_store(),Dispatch.Plain>) -> ExecutionResult<S.plain_store(),Dispatch.Plain>:
  match observed:
    case Observe.Failed{factory,actual}:Unexpected{factory,baseline,phases,detached,[],actual}
    case Observe.Observed{factory,Actual.Delivered{app,world,details},phase}:plain_disabled_start(factory,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,world,app)
    case Observe.Observed{factory,actual,phase}:Unexpected{factory,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,[],actual}
def plain_retry_start(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,app:Ordinary.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>,world:W.World<S.Schema,S.plain_store(),Unit,Unit>) -> ExecutionResult<S.plain_store(),Dispatch.Plain>:
  plain_retry_done(baseline,phases,detached,Observe.plain_observe(factory,"enabled-retry",Actual.plain_run(Actual.plain_reset_fail(0,app),world)))
def plain_failed_done(baseline:DTO.ScenarioReport,detached:List<Maybe<&1,Array<U32>>>,observed:Observe.Observed<S.plain_store(),Dispatch.Plain>) -> ExecutionResult<S.plain_store(),Dispatch.Plain>:
  match observed:
    case Observe.Failed{factory,actual}:Unexpected{factory,baseline,[],detached,[],actual}
    case Observe.Observed{factory,Actual.Delivered{app,world,details},phase}:plain_retry_start(factory,baseline,[phase],detached,app,world)
    case Observe.Observed{factory,actual,phase}:Unexpected{factory,baseline,[phase],detached,[],actual}
def plain_seeded(delivery:Driver.Delivery<S.plain_store(),Driver.plain_owners()>) -> ExecutionResult<S.plain_store(),Dispatch.Plain>:
  match delivery:
    case Driver.Rejected{failure}:SeedRejected{failure}
    case Driver.Delivered{factory,world,owners,detached,baseline}:plain_failed_done(baseline,detached,Observe.plain_observe(factory,"enabled-failure",Actual.plain_start(world,owners,Ordinary.Enabled{},1)))
def plain() -> ExecutionResult<S.plain_store(),Dispatch.Plain>:
  plain_seeded(Driver.plain())

def transient_disabled_done(baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,observed:Observe.Observed<S.transient_store(),Dispatch.Transient>) -> ExecutionResult<S.transient_store(),Dispatch.Transient>:
  match observed:
    case Observe.Failed{factory,actual}:Unexpected{factory,baseline,phases,detached,[],actual}
    case Observe.Observed{factory,Actual.Delivered{app,world,details},phase}:transient_foreign_created(world,app,details,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,W.create(~S.Schema,~S.transient_store(),~Unit,~Unit,~Setup.transient_empty,factory,Unit{}))
    case Observe.Observed{factory,actual,phase}:Unexpected{factory,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,[],actual}
def transient_disabled_unpacked(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,returned:Driver.transient_owners() & Dispatch.Trace) -> ExecutionResult<S.transient_store(),Dispatch.Transient>:
  (owners,trace) = returned
  transient_disabled_done(baseline,phases,detached,Observe.transient_observe(factory,"disabled-success",Actual.transient_start(world,owners,Ordinary.Disabled{},0)))
def transient_disabled_start(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,app:Ordinary.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.transient_owners()>) -> ExecutionResult<S.transient_store(),Dispatch.Transient>:
  match app:
    case Ordinary.Application{_,_,SP.Provisioned{Sch.Schedule{_,_,_,returned},_}}:
      transient_disabled_unpacked(factory,baseline,phases,detached,world,Dispatch.transient_unpack(returned))
def transient_retry_done(baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,observed:Observe.Observed<S.transient_store(),Dispatch.Transient>) -> ExecutionResult<S.transient_store(),Dispatch.Transient>:
  match observed:
    case Observe.Failed{factory,actual}:Unexpected{factory,baseline,phases,detached,[],actual}
    case Observe.Observed{factory,Actual.Delivered{app,world,details},phase}:transient_disabled_start(factory,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,world,app)
    case Observe.Observed{factory,actual,phase}:Unexpected{factory,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,[],actual}
def transient_retry_start(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,app:Ordinary.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>,world:W.World<S.Schema,S.transient_store(),Unit,Unit>) -> ExecutionResult<S.transient_store(),Dispatch.Transient>:
  transient_retry_done(baseline,phases,detached,Observe.transient_observe(factory,"enabled-retry",Actual.transient_run(Actual.transient_reset_fail(0,app),world)))
def transient_failed_done(baseline:DTO.ScenarioReport,detached:List<Maybe<&1,Array<U32>>>,observed:Observe.Observed<S.transient_store(),Dispatch.Transient>) -> ExecutionResult<S.transient_store(),Dispatch.Transient>:
  match observed:
    case Observe.Failed{factory,actual}:Unexpected{factory,baseline,[],detached,[],actual}
    case Observe.Observed{factory,Actual.Delivered{app,world,details},phase}:transient_retry_start(factory,baseline,[phase],detached,app,world)
    case Observe.Observed{factory,actual,phase}:Unexpected{factory,baseline,[phase],detached,[],actual}
def transient_seeded(delivery:Driver.Delivery<S.transient_store(),Driver.transient_owners()>) -> ExecutionResult<S.transient_store(),Dispatch.Transient>:
  match delivery:
    case Driver.Rejected{failure}:SeedRejected{failure}
    case Driver.Delivered{factory,world,owners,detached,baseline}:transient_failed_done(baseline,detached,Observe.transient_observe(factory,"enabled-failure",Actual.transient_start(world,owners,Ordinary.Enabled{},1)))
def transient() -> ExecutionResult<S.transient_store(),Dispatch.Transient>:
  transient_seeded(Driver.transient())

def constructed_disabled_done(baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,observed:Observe.Observed<S.constructed_store(),Dispatch.Constructed>) -> ExecutionResult<S.constructed_store(),Dispatch.Constructed>:
  match observed:
    case Observe.Failed{factory,actual}:Unexpected{factory,baseline,phases,detached,[],actual}
    case Observe.Observed{factory,Actual.Delivered{app,world,details},phase}:constructed_foreign_created(world,app,details,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,W.create(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Setup.constructed_empty,factory,Unit{}))
    case Observe.Observed{factory,actual,phase}:Unexpected{factory,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,[],actual}
def constructed_disabled_unpacked(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,returned:Driver.constructed_owners() & Dispatch.Trace) -> ExecutionResult<S.constructed_store(),Dispatch.Constructed>:
  (owners,trace) = returned
  constructed_disabled_done(baseline,phases,detached,Observe.constructed_observe(factory,"disabled-success",Actual.constructed_start(world,owners,Ordinary.Disabled{},0)))
def constructed_disabled_start(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,app:Ordinary.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.constructed_owners()>) -> ExecutionResult<S.constructed_store(),Dispatch.Constructed>:
  match app:
    case Ordinary.Application{_,_,SP.Provisioned{Sch.Schedule{_,_,_,returned},_}}:
      constructed_disabled_unpacked(factory,baseline,phases,detached,world,Dispatch.constructed_unpack(returned))
def constructed_retry_done(baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,observed:Observe.Observed<S.constructed_store(),Dispatch.Constructed>) -> ExecutionResult<S.constructed_store(),Dispatch.Constructed>:
  match observed:
    case Observe.Failed{factory,actual}:Unexpected{factory,baseline,phases,detached,[],actual}
    case Observe.Observed{factory,Actual.Delivered{app,world,details},phase}:constructed_disabled_start(factory,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,world,app)
    case Observe.Observed{factory,actual,phase}:Unexpected{factory,baseline,List.append(&2,Observe.Phase,phases,[phase]),detached,[],actual}
def constructed_retry_start(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,detached:List<Maybe<&1,Array<U32>>>,app:Ordinary.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>) -> ExecutionResult<S.constructed_store(),Dispatch.Constructed>:
  constructed_retry_done(baseline,phases,detached,Observe.constructed_observe(factory,"enabled-retry",Actual.constructed_run(Actual.constructed_reset_fail(0,app),world)))
def constructed_failed_done(baseline:DTO.ScenarioReport,detached:List<Maybe<&1,Array<U32>>>,observed:Observe.Observed<S.constructed_store(),Dispatch.Constructed>) -> ExecutionResult<S.constructed_store(),Dispatch.Constructed>:
  match observed:
    case Observe.Failed{factory,actual}:Unexpected{factory,baseline,[],detached,[],actual}
    case Observe.Observed{factory,Actual.Delivered{app,world,details},phase}:constructed_retry_start(factory,baseline,[phase],detached,app,world)
    case Observe.Observed{factory,actual,phase}:Unexpected{factory,baseline,[phase],detached,[],actual}
def constructed_seeded(delivery:Driver.Delivery<S.constructed_store(),Driver.constructed_owners()>) -> ExecutionResult<S.constructed_store(),Dispatch.Constructed>:
  match delivery:
    case Driver.Rejected{failure}:SeedRejected{failure}
    case Driver.Delivered{factory,world,owners,detached,baseline}:constructed_failed_done(baseline,detached,Observe.constructed_observe(factory,"enabled-failure",Actual.constructed_start(world,owners,Ordinary.Enabled{},1)))
def constructed() -> ExecutionResult<S.constructed_store(),Dispatch.Constructed>:
  constructed_seeded(Driver.constructed())
