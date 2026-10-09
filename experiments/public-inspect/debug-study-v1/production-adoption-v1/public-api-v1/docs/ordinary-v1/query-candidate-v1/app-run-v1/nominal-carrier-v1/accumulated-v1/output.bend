import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/scenario-schema.bend as S
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/scenario-driver.bend as Driver
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/scenario-execution.bend as Execution
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/scenario-systems.bend as Systems
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/scenario-queries.bend as Queries
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/scenario-body.bend as Body
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/scenario-dto.bend as DTO
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP

import ./dispatch.bend as Dispatch

import ./application.bend as Actual

import ./observation.bend as Observe
import ./scenario.bend as Scenario

type Outcome is Data:
  Report{report:Scenario.Report}
  SeedFailure{failure:Driver.Failure}
  Failure{category:String,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,details:Maybe<&2,Actual.Details>,trace:Dispatch.Trace,snapshots:List<&2,DTO.Snapshot>}

def plain_failure_owners(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,details:Maybe<&2,Actual.Details>,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,returned:Dispatch.plain_owners()) -> Outcome:
  Dispatch.Plain{main,added,changed,without,withHealth,+trace} = returned
  Driver.plain_observe(~Outcome,(factory => world => owners => snapshots => Failure{"plain",baseline,phases,details,trace,snapshots}),factory,world,(((((Unit{},main),added),changed),without),withHealth),[],"unexpected-fixture-refusal",DTO.Observed{},[])
def plain_failure_app(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,details:Actual.Details,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,app:Ordinary.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.plain_owners()>) -> Outcome:
  match app:
    case Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,returned},requirements}}:plain_failure_owners(factory,baseline,phases,Some{details},world,returned)
def plain_failure(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,actual:Actual.Delivery<S.plain_store(),Dispatch.Plain>) -> Outcome:
  match actual:
    case Actual.BuildRejected{world,owners}:plain_failure_owners(factory,baseline,phases,None{},world,owners)
    case Actual.Delivered{app,world,details}:plain_failure_app(factory,baseline,phases,details,world,app)
def plain(result:Scenario.ExecutionResult<S.plain_store(),Dispatch.Plain>) -> Outcome:
  match result:
    case Scenario.Completed{factory,app,world,detached,otherWorlds,report}:Report{report}
    case Scenario.Unexpected{factory,baseline,phases,detached,otherWorlds,actual}:plain_failure(factory,baseline,phases,actual)
    case Scenario.SeedRejected{failure}:SeedFailure{failure}

def transient_failure_owners(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,details:Maybe<&2,Actual.Details>,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,returned:Dispatch.transient_owners()) -> Outcome:
  Dispatch.Transient{main,added,changed,without,withHealth,+trace} = returned
  Driver.transient_observe(~Outcome,(factory => world => owners => snapshots => Failure{"transient",baseline,phases,details,trace,snapshots}),factory,world,(((((Unit{},main),added),changed),without),withHealth),[],"unexpected-fixture-refusal",DTO.Observed{},[])
def transient_failure_app(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,details:Actual.Details,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,app:Ordinary.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.transient_owners()>) -> Outcome:
  match app:
    case Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,returned},requirements}}:transient_failure_owners(factory,baseline,phases,Some{details},world,returned)
def transient_failure(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,actual:Actual.Delivery<S.transient_store(),Dispatch.Transient>) -> Outcome:
  match actual:
    case Actual.BuildRejected{world,owners}:transient_failure_owners(factory,baseline,phases,None{},world,owners)
    case Actual.Delivered{app,world,details}:transient_failure_app(factory,baseline,phases,details,world,app)
def transient(result:Scenario.ExecutionResult<S.transient_store(),Dispatch.Transient>) -> Outcome:
  match result:
    case Scenario.Completed{factory,app,world,detached,otherWorlds,report}:Report{report}
    case Scenario.Unexpected{factory,baseline,phases,detached,otherWorlds,actual}:transient_failure(factory,baseline,phases,actual)
    case Scenario.SeedRejected{failure}:SeedFailure{failure}

def constructed_failure_owners(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,details:Maybe<&2,Actual.Details>,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,returned:Dispatch.constructed_owners()) -> Outcome:
  Dispatch.Constructed{main,added,changed,without,withHealth,+trace} = returned
  Driver.constructed_observe(~Outcome,(factory => world => owners => snapshots => Failure{"constructed",baseline,phases,details,trace,snapshots}),factory,world,(((((Unit{},main),added),changed),without),withHealth),[],"unexpected-fixture-refusal",DTO.Observed{},[])
def constructed_failure_app(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,details:Actual.Details,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,app:Ordinary.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.constructed_owners()>) -> Outcome:
  match app:
    case Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,returned},requirements}}:constructed_failure_owners(factory,baseline,phases,Some{details},world,returned)
def constructed_failure(factory:W.Factory,baseline:DTO.ScenarioReport,phases:List<&2,Observe.Phase>,actual:Actual.Delivery<S.constructed_store(),Dispatch.Constructed>) -> Outcome:
  match actual:
    case Actual.BuildRejected{world,owners}:constructed_failure_owners(factory,baseline,phases,None{},world,owners)
    case Actual.Delivered{app,world,details}:constructed_failure_app(factory,baseline,phases,details,world,app)
def constructed(result:Scenario.ExecutionResult<S.constructed_store(),Dispatch.Constructed>) -> Outcome:
  match result:
    case Scenario.Completed{factory,app,world,detached,otherWorlds,report}:Report{report}
    case Scenario.Unexpected{factory,baseline,phases,detached,otherWorlds,actual}:constructed_failure(factory,baseline,phases,actual)
    case Scenario.SeedRejected{failure}:SeedFailure{failure}
