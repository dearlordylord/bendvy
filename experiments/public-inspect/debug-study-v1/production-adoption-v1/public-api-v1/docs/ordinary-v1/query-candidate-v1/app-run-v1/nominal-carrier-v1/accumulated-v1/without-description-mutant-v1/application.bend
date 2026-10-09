import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/scenario-schema.bend as S
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-run-v1/nominal-carrier-v1/accumulated-v1/without-description-mutant-v1/scenario-driver.bend as Driver
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-run-v1/nominal-carrier-v1/accumulated-v1/without-description-mutant-v1/scenario-execution.bend as Execution
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-run-v1/nominal-carrier-v1/accumulated-v1/without-description-mutant-v1/scenario-systems.bend as Systems
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-run-v1/nominal-carrier-v1/accumulated-v1/without-description-mutant-v1/scenario-queries.bend as Queries
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-run-v1/nominal-carrier-v1/accumulated-v1/without-description-mutant-v1/scenario-body.bend as Body
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-run-v1/nominal-carrier-v1/accumulated-v1/without-description-mutant-v1/scenario-dto.bend as DTO
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-run-v1/nominal-carrier-v1/accumulated-v1/without-description-mutant-v1/app.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP

import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-run-v1/nominal-carrier-v1/accumulated-v1/without-description-mutant-v1/dispatch.bend as Dispatch

type Status is Data:
  Finished{}
  Failed{error:Dispatch.ApplicationError}
  Rejected{}
  Missing{needs:List<&2,SP.Requirement<S.Schema>>}
type Details is Data:
  Details{status:Status,observations:List<&2,Sch.Observation>,trace:Dispatch.Trace,namespace:U32,name:String,steps:List<&2,Sch.Step>,requirements:List<&2,SP.Requirement<S.Schema>>}
type Delivery<-C:Type,-H:Type> is Type:
  Delivered{app:Ordinary.Application<S.Schema,C,Unit,Unit,H>,world:W.World<S.Schema,C,Unit,Unit>,details:Details}
  BuildRejected{world:W.World<S.Schema,C,Unit,Unit>,owners:H}
def plan() -> SP.Plan<S.Schema>:
  SP.Sequence{SP.Entry{Sch.Phase{"Update"},[]},SP.Sequence{SP.Entry{Sch.System{1,0},[]},SP.Sequence{SP.Entry{Sch.System{2,1},[]},SP.Sequence{SP.Entry{Sch.System{3,0},[]},SP.Sequence{SP.Entry{Sch.System{4,0},[]},SP.Sequence{SP.Entry{Sch.System{5,0},[]},SP.Entry{Sch.Barrier{},[]}}}}}}}

def plain_restored(debug:Ordinary.Debug,+entries:List<&2,Ordinary.Entry<S.Schema>>,+status:Status,+observations:List<&2,Sch.Observation>,+requirements:List<&2,SP.Requirement<S.Schema>>,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,schedule:Sch.Schedule<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>) -> Delivery<S.plain_store(),Dispatch.Plain>:
  match schedule:
    case Sch.Schedule{+namespace,+name,+steps,Dispatch.Plain{main,added,changed,without,withHealth,+trace}}:
      Delivered{Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,Dispatch.Plain{main,added,changed,without,withHealth,trace}},requirements}},world,Details{status,observations,trace,namespace,name,steps,requirements}}
def plain_scheduled(debug:Ordinary.Debug,entries:List<&2,Ordinary.Entry<S.Schema>>,requirements:List<&2,SP.Requirement<S.Schema>>,result:Sch.RunResult<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain,Dispatch.ApplicationError>) -> Delivery<S.plain_store(),Dispatch.Plain>:
  match result:
    case Sch.Finished{schedule,world,observations}:plain_restored(debug,entries,Finished{},observations,requirements,world,schedule)
    case Sch.Failed{schedule,world,error,observations}:plain_restored(debug,entries,Failed{error},observations,requirements,world,schedule)
    case Sch.Rejected{schedule,world}:plain_restored(debug,entries,Rejected{},[],requirements,world,schedule)
def plain_provisioned(debug:Ordinary.Debug,entries:List<&2,Ordinary.Entry<S.Schema>>,result:SP.ProvisionResult<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain,Dispatch.ApplicationError>) -> Delivery<S.plain_store(),Dispatch.Plain>:
  match result:
    case SP.Executed{result,requirements}:plain_scheduled(debug,entries,requirements,result)
    case SP.Missing{SP.Provisioned{schedule,requirements},world,missing}:plain_restored(debug,entries,Missing{missing},[],requirements,world,schedule)
def plain_ran(result:SP.ProvisionResult<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain,Dispatch.ApplicationError> & (Ordinary.Debug & List<&2,Ordinary.Entry<S.Schema>>)) -> Delivery<S.plain_store(),Dispatch.Plain>:
  match result:
    case (result,(debug,entries)):plain_provisioned(debug,entries,result)
def plain_augment(collected:Ordinary.Owners<S.Schema,Driver.plain_owners()>,failId:U32) -> Ordinary.Owners<S.Schema,Dispatch.Plain>:
  match collected:
    case Ordinary.Owners{debug,namespace,catalog,entries,owners,valid}:Ordinary.Owners{debug,namespace,catalog,entries,Dispatch.plain_pack((owners,Dispatch.Trace{failId,[]})),valid}

def transient_restored(debug:Ordinary.Debug,+entries:List<&2,Ordinary.Entry<S.Schema>>,+status:Status,+observations:List<&2,Sch.Observation>,+requirements:List<&2,SP.Requirement<S.Schema>>,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,schedule:Sch.Schedule<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>) -> Delivery<S.transient_store(),Dispatch.Transient>:
  match schedule:
    case Sch.Schedule{+namespace,+name,+steps,Dispatch.Transient{main,added,changed,without,withHealth,+trace}}:
      Delivered{Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,Dispatch.Transient{main,added,changed,without,withHealth,trace}},requirements}},world,Details{status,observations,trace,namespace,name,steps,requirements}}
def transient_scheduled(debug:Ordinary.Debug,entries:List<&2,Ordinary.Entry<S.Schema>>,requirements:List<&2,SP.Requirement<S.Schema>>,result:Sch.RunResult<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient,Dispatch.ApplicationError>) -> Delivery<S.transient_store(),Dispatch.Transient>:
  match result:
    case Sch.Finished{schedule,world,observations}:transient_restored(debug,entries,Finished{},observations,requirements,world,schedule)
    case Sch.Failed{schedule,world,error,observations}:transient_restored(debug,entries,Failed{error},observations,requirements,world,schedule)
    case Sch.Rejected{schedule,world}:transient_restored(debug,entries,Rejected{},[],requirements,world,schedule)
def transient_provisioned(debug:Ordinary.Debug,entries:List<&2,Ordinary.Entry<S.Schema>>,result:SP.ProvisionResult<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient,Dispatch.ApplicationError>) -> Delivery<S.transient_store(),Dispatch.Transient>:
  match result:
    case SP.Executed{result,requirements}:transient_scheduled(debug,entries,requirements,result)
    case SP.Missing{SP.Provisioned{schedule,requirements},world,missing}:transient_restored(debug,entries,Missing{missing},[],requirements,world,schedule)
def transient_ran(result:SP.ProvisionResult<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient,Dispatch.ApplicationError> & (Ordinary.Debug & List<&2,Ordinary.Entry<S.Schema>>)) -> Delivery<S.transient_store(),Dispatch.Transient>:
  match result:
    case (result,(debug,entries)):transient_provisioned(debug,entries,result)
def transient_augment(collected:Ordinary.Owners<S.Schema,Driver.transient_owners()>,failId:U32) -> Ordinary.Owners<S.Schema,Dispatch.Transient>:
  match collected:
    case Ordinary.Owners{debug,namespace,catalog,entries,owners,valid}:Ordinary.Owners{debug,namespace,catalog,entries,Dispatch.transient_pack((owners,Dispatch.Trace{failId,[]})),valid}

def constructed_restored(debug:Ordinary.Debug,+entries:List<&2,Ordinary.Entry<S.Schema>>,+status:Status,+observations:List<&2,Sch.Observation>,+requirements:List<&2,SP.Requirement<S.Schema>>,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,schedule:Sch.Schedule<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>) -> Delivery<S.constructed_store(),Dispatch.Constructed>:
  match schedule:
    case Sch.Schedule{+namespace,+name,+steps,Dispatch.Constructed{main,added,changed,without,withHealth,+trace}}:
      Delivered{Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,Dispatch.Constructed{main,added,changed,without,withHealth,trace}},requirements}},world,Details{status,observations,trace,namespace,name,steps,requirements}}
def constructed_scheduled(debug:Ordinary.Debug,entries:List<&2,Ordinary.Entry<S.Schema>>,requirements:List<&2,SP.Requirement<S.Schema>>,result:Sch.RunResult<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed,Dispatch.ApplicationError>) -> Delivery<S.constructed_store(),Dispatch.Constructed>:
  match result:
    case Sch.Finished{schedule,world,observations}:constructed_restored(debug,entries,Finished{},observations,requirements,world,schedule)
    case Sch.Failed{schedule,world,error,observations}:constructed_restored(debug,entries,Failed{error},observations,requirements,world,schedule)
    case Sch.Rejected{schedule,world}:constructed_restored(debug,entries,Rejected{},[],requirements,world,schedule)
def constructed_provisioned(debug:Ordinary.Debug,entries:List<&2,Ordinary.Entry<S.Schema>>,result:SP.ProvisionResult<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed,Dispatch.ApplicationError>) -> Delivery<S.constructed_store(),Dispatch.Constructed>:
  match result:
    case SP.Executed{result,requirements}:constructed_scheduled(debug,entries,requirements,result)
    case SP.Missing{SP.Provisioned{schedule,requirements},world,missing}:constructed_restored(debug,entries,Missing{missing},[],requirements,world,schedule)
def constructed_ran(result:SP.ProvisionResult<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed,Dispatch.ApplicationError> & (Ordinary.Debug & List<&2,Ordinary.Entry<S.Schema>>)) -> Delivery<S.constructed_store(),Dispatch.Constructed>:
  match result:
    case (result,(debug,entries)):constructed_provisioned(debug,entries,result)
def constructed_augment(collected:Ordinary.Owners<S.Schema,Driver.constructed_owners()>,failId:U32) -> Ordinary.Owners<S.Schema,Dispatch.Constructed>:
  match collected:
    case Ordinary.Owners{debug,namespace,catalog,entries,owners,valid}:Ordinary.Owners{debug,namespace,catalog,entries,Dispatch.constructed_pack((owners,Dispatch.Trace{failId,[]})),valid}

def plain_run(app:Ordinary.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.plain_owners()>,world:W.World<S.Schema,S.plain_store(),Unit,Unit>) -> Delivery<S.plain_store(),Dispatch.Plain>:
  plain_ran(Ordinary.run(~S.Schema,~S.plain_store(),~Unit,~Unit,~Dispatch.plain_owners(),~Dispatch.ApplicationError,~Dispatch.plain_dispatch,~(world => slot => Dispatch.condition(~S.plain_store(),world,slot)),~(world => Dispatch.provision(~S.plain_store(),world)),app,world))
def plain_built(world:W.World<S.Schema,S.plain_store(),Unit,Unit>,result:Ordinary.Built<S.Schema,S.plain_store(),Unit,Unit,Dispatch.plain_owners()>) -> Delivery<S.plain_store(),Dispatch.Plain>:
  match result:
    case Ordinary.Invalid{owners}:BuildRejected{world,owners}
    case Ordinary.Built{app}:plain_run(app,world)
def plain_main_seen(world:W.World<S.Schema,S.plain_store(),Unit,Unit>,others:((((Unit & Systems.plain_added_owner()) & Systems.plain_changed_owner()) & Systems.plain_without_owner()) & Systems.plain_with_owner()),debug:Ordinary.Debug,failId:U32,observed:Systems.plain_main_owner() & DTO.RegistrySnapshot) -> Delivery<S.plain_store(),Dispatch.Plain>:
  ((((Unit{},added),changed),without),withHealth) = others
  (main,mainSnapshot) = observed
  collected = Ordinary.empty(~S.Schema,Driver.registry_namespace(mainSnapshot),debug)
  collected = Ordinary.add(~S.Schema,~S.plain_store(),~Unit,~Unit,~Body.Ops,~Bool,~Unit,~DTO.RowValues,~Queries.plain_base(),~(H => caps => fail => owner => Body.body(~H,~caps,fail,owner)),~Unit,collected,main)
  collected = Ordinary.add(~S.Schema,~S.plain_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.plain_base_added(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~(Unit & Systems.plain_main_owner()),collected,added)
  collected = Ordinary.add(~S.Schema,~S.plain_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.plain_base_changed(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner()),collected,changed)
  collected = Ordinary.add(~S.Schema,~S.plain_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.plain_base_without_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~(((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner()) & Systems.plain_changed_owner()),collected,without)
  collected = Ordinary.add(~S.Schema,~S.plain_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.plain_base_with_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~((((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner()) & Systems.plain_changed_owner()) & Systems.plain_without_owner()),collected,withHealth)
  plain_built(world,Ordinary.build(~S.Schema,~S.plain_store(),~Unit,~Unit,~Dispatch.plain_owners(),"Update",plan(),plain_augment(collected,failId)))
def plain_start(world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:Driver.plain_owners(),debug:Ordinary.Debug,failId:U32) -> Delivery<S.plain_store(),Dispatch.Plain>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  plain_main_seen(world,((((Unit{},added),changed),without),withHealth),debug,failId,Systems.plain_main_observe(main))

def transient_run(app:Ordinary.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.transient_owners()>,world:W.World<S.Schema,S.transient_store(),Unit,Unit>) -> Delivery<S.transient_store(),Dispatch.Transient>:
  transient_ran(Ordinary.run(~S.Schema,~S.transient_store(),~Unit,~Unit,~Dispatch.transient_owners(),~Dispatch.ApplicationError,~Dispatch.transient_dispatch,~(world => slot => Dispatch.condition(~S.transient_store(),world,slot)),~(world => Dispatch.provision(~S.transient_store(),world)),app,world))
def transient_built(world:W.World<S.Schema,S.transient_store(),Unit,Unit>,result:Ordinary.Built<S.Schema,S.transient_store(),Unit,Unit,Dispatch.transient_owners()>) -> Delivery<S.transient_store(),Dispatch.Transient>:
  match result:
    case Ordinary.Invalid{owners}:BuildRejected{world,owners}
    case Ordinary.Built{app}:transient_run(app,world)
def transient_main_seen(world:W.World<S.Schema,S.transient_store(),Unit,Unit>,others:((((Unit & Systems.transient_added_owner()) & Systems.transient_changed_owner()) & Systems.transient_without_owner()) & Systems.transient_with_owner()),debug:Ordinary.Debug,failId:U32,observed:Systems.transient_main_owner() & DTO.RegistrySnapshot) -> Delivery<S.transient_store(),Dispatch.Transient>:
  ((((Unit{},added),changed),without),withHealth) = others
  (main,mainSnapshot) = observed
  collected = Ordinary.empty(~S.Schema,Driver.registry_namespace(mainSnapshot),debug)
  collected = Ordinary.add(~S.Schema,~S.transient_store(),~Unit,~Unit,~Body.Ops,~Bool,~Unit,~DTO.RowValues,~Queries.transient_base(),~(H => caps => fail => owner => Body.body(~H,~caps,fail,owner)),~Unit,collected,main)
  collected = Ordinary.add(~S.Schema,~S.transient_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.transient_base_added(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~(Unit & Systems.transient_main_owner()),collected,added)
  collected = Ordinary.add(~S.Schema,~S.transient_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.transient_base_changed(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner()),collected,changed)
  collected = Ordinary.add(~S.Schema,~S.transient_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.transient_base_without_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~(((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner()) & Systems.transient_changed_owner()),collected,without)
  collected = Ordinary.add(~S.Schema,~S.transient_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.transient_base_with_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~((((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner()) & Systems.transient_changed_owner()) & Systems.transient_without_owner()),collected,withHealth)
  transient_built(world,Ordinary.build(~S.Schema,~S.transient_store(),~Unit,~Unit,~Dispatch.transient_owners(),"Update",plan(),transient_augment(collected,failId)))
def transient_start(world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:Driver.transient_owners(),debug:Ordinary.Debug,failId:U32) -> Delivery<S.transient_store(),Dispatch.Transient>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  transient_main_seen(world,((((Unit{},added),changed),without),withHealth),debug,failId,Systems.transient_main_observe(main))

def constructed_run(app:Ordinary.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.constructed_owners()>,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>) -> Delivery<S.constructed_store(),Dispatch.Constructed>:
  constructed_ran(Ordinary.run(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Dispatch.constructed_owners(),~Dispatch.ApplicationError,~Dispatch.constructed_dispatch,~(world => slot => Dispatch.condition(~S.constructed_store(),world,slot)),~(world => Dispatch.provision(~S.constructed_store(),world)),app,world))
def constructed_built(world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,result:Ordinary.Built<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.constructed_owners()>) -> Delivery<S.constructed_store(),Dispatch.Constructed>:
  match result:
    case Ordinary.Invalid{owners}:BuildRejected{world,owners}
    case Ordinary.Built{app}:constructed_run(app,world)
def constructed_main_seen(world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,others:((((Unit & Systems.constructed_added_owner()) & Systems.constructed_changed_owner()) & Systems.constructed_without_owner()) & Systems.constructed_with_owner()),debug:Ordinary.Debug,failId:U32,observed:Systems.constructed_main_owner() & DTO.RegistrySnapshot) -> Delivery<S.constructed_store(),Dispatch.Constructed>:
  ((((Unit{},added),changed),without),withHealth) = others
  (main,mainSnapshot) = observed
  collected = Ordinary.empty(~S.Schema,Driver.registry_namespace(mainSnapshot),debug)
  collected = Ordinary.add(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Body.Ops,~Bool,~Unit,~DTO.RowValues,~Queries.constructed_base(),~(H => caps => fail => owner => Body.body(~H,~caps,fail,owner)),~Unit,collected,main)
  collected = Ordinary.add(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.constructed_base_added(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~(Unit & Systems.constructed_main_owner()),collected,added)
  collected = Ordinary.add(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.constructed_base_changed(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner()),collected,changed)
  collected = Ordinary.add(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.constructed_base_without_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~(((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner()) & Systems.constructed_changed_owner()),collected,without)
  collected = Ordinary.add(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.constructed_base_with_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~((((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner()) & Systems.constructed_changed_owner()) & Systems.constructed_without_owner()),collected,withHealth)
  constructed_built(world,Ordinary.build(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Dispatch.constructed_owners(),"Update",plan(),constructed_augment(collected,failId)))
def constructed_start(world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:Driver.constructed_owners(),debug:Ordinary.Debug,failId:U32) -> Delivery<S.constructed_store(),Dispatch.Constructed>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  constructed_main_seen(world,((((Unit{},added),changed),without),withHealth),debug,failId,Systems.constructed_main_observe(main))

def plain_reset_fail(failId:U32,app:Ordinary.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>) -> Ordinary.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>:
  match app:
    case Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,Dispatch.Plain{main,added,changed,without,withHealth,Dispatch.Trace{_,records}}},requirements}}:
      Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,Dispatch.Plain{main,added,changed,without,withHealth,Dispatch.Trace{failId,records}}},requirements}}
def transient_reset_fail(failId:U32,app:Ordinary.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>) -> Ordinary.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>:
  match app:
    case Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,Dispatch.Transient{main,added,changed,without,withHealth,Dispatch.Trace{_,records}}},requirements}}:
      Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,Dispatch.Transient{main,added,changed,without,withHealth,Dispatch.Trace{failId,records}}},requirements}}
def constructed_reset_fail(failId:U32,app:Ordinary.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>) -> Ordinary.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>:
  match app:
    case Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,Dispatch.Constructed{main,added,changed,without,withHealth,Dispatch.Trace{_,records}}},requirements}}:
      Ordinary.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,Dispatch.Constructed{main,added,changed,without,withHealth,Dispatch.Trace{failId,records}}},requirements}}
