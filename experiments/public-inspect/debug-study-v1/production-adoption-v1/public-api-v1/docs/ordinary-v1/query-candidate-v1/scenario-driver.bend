import Base
import ./scenario-schema.bend as S
import ./scenario-systems.bend as Systems
import ./scenario-queries.bend as Queries
import ./scenario-body.bend as Body
import ./scenario-dto.bend as DTO
import ./scenario-execution.bend as Execution
import ./scenario-setup.bend as Setup
import ./scenario-returned.bend as Returned
import ./system.bend as System
import ./app.bend as App
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/experiments/public-simulation/bend-v1/owner-view.bend as View


type Failure is Data:
  Failure{stage:String,factoryNextNamespace:U32,world:Maybe<&2,DTO.WorldSnapshot>,registries:List<&2,DTO.RegistrySnapshot>,handles:List<&2,W.Handle<S.Schema>>,error:Maybe<&2,W.WorldError>,previous:List<&2,Maybe<&2,View.FullCell>>,incoming:Maybe<&2,View.FullCell>,otherWorlds:List<&2,DTO.WorldSnapshot>,operation:Maybe<&2,DTO.Operation>}
type Delivery<-C:Type,-H:Type> is Type:
  Delivered{factory:W.Factory,world:W.World<S.Schema,C,Unit,Unit>,owners:H,report:DTO.ScenarioReport}
  Rejected{failure:Failure}
def registry_namespace(snapshot:DTO.RegistrySnapshot) -> U32:
  match snapshot:
    case DTO.RegistrySnapshot{namespace,_,_,_,_,_,_}:namespace

def registry_seen(~H:Type,~Out:Type,next:H -> DTO.RegistrySnapshot -> Out,got:H & DTO.RegistrySnapshot) -> Out:
  match got:
    case (owner,snapshot):next(owner,snapshot)
def world_seen(~C:Type,~Out:Type,next:W.World<S.Schema,C,Unit,Unit> -> DTO.WorldSnapshot -> Out,got:W.World<S.Schema,C,Unit,Unit> & DTO.WorldSnapshot) -> Out:
  match got:
    case (world,snapshot):next(world,snapshot)

def failed_parts(~C:Type,~H:Type,stage:String,factory:W.Factory,registries:List<&2,DTO.RegistrySnapshot>,handles:List<&2,W.Handle<S.Schema>>,error:Maybe<&2,W.WorldError>,previous:List<&2,Maybe<&2,View.FullCell>>,incoming:Maybe<&2,View.FullCell>,otherWorlds:List<&2,DTO.WorldSnapshot>,operation:Maybe<&2,DTO.Operation>,got:W.World<S.Schema,C,Unit,Unit> & DTO.WorldSnapshot) -> Delivery<C,H>:
  match factory:
    case W.Factory{nextNamespace}:
      (world,snapshot) = got
      Rejected{Failure{stage,nextNamespace,Some{snapshot},registries,handles,error,previous,incoming,otherWorlds,operation}}
def failed(~C:Type,~H:Type,stage:String,factory:W.Factory,registries:List<&2,DTO.RegistrySnapshot>,got:W.World<S.Schema,C,Unit,Unit> & DTO.WorldSnapshot) -> Delivery<C,H>:
  failed_parts(~C,~H,stage,factory,registries,[],None{},[],None{},[],None{},got)
def previous_seen(~Out:Type,next:List<Maybe<&1,Array<U32>>> -> List<&2,Maybe<&2,View.FullCell>> -> Out,got:List<Maybe<&1,Array<U32>>> & List<&2,Maybe<&2,View.FullCell>>) -> Out:
  match got:
    case (owners,values):next(owners,values)
def incoming_seen(~Out:Type,next:Maybe<&1,Array<U32>> -> Maybe<&2,View.FullCell> -> Out,got:Maybe<&1,Array<U32>> & Maybe<&2,View.FullCell>) -> Out:
  match got:
    case (owner,value):next(owner,value)

def plain_owners() -> Type:
  (((((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner()) & Systems.plain_changed_owner()) & Systems.plain_without_owner()) & Systems.plain_with_owner())
def plain_observe(~Out:Type,next:W.Factory -> W.World<S.Schema,S.plain_store(),Unit,Unit> -> plain_owners() -> List<&2,DTO.Snapshot> -> Out,factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>,label:String,operation:DTO.Operation,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>) -> Out:
  match factory:
    case W.Factory{+nextNamespace}:
      (((((Unit{},main),added),changed),without),withHealth) = owners
      registry_seen(~Systems.plain_main_owner(),~Out,(main => snapshot_main => registry_seen(~Systems.plain_added_owner(),~Out,(added => snapshot_added => registry_seen(~Systems.plain_changed_owner(),~Out,(changed => snapshot_changed => registry_seen(~Systems.plain_without_owner(),~Out,(without => snapshot_without => registry_seen(~Systems.plain_with_owner(),~Out,(withHealth => snapshot_withHealth => world_seen(~S.plain_store(),~Out,(world => snapshotWorld => next(W.Factory{nextNamespace},world,(((((Unit{},main),added),changed),without),withHealth),List.append(&2,DTO.Snapshot,phases,[DTO.Snapshot{label,nextNamespace,snapshotWorld,[snapshot_main,snapshot_added,snapshot_changed,snapshot_without,snapshot_withHealth],operation,descriptions}]))),Execution.plain_world(world))),Systems.plain_with_observe(withHealth))),Systems.plain_without_observe(without))),Systems.plain_changed_observe(changed))),Systems.plain_added_observe(added))),Systems.plain_main_observe(main))
def plain_reject(stage:String,factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners()) -> Delivery<S.plain_store(),plain_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  registry_seen(~Systems.plain_main_owner(),~Delivery<S.plain_store(),plain_owners()>,(main => snapshot_main => registry_seen(~Systems.plain_added_owner(),~Delivery<S.plain_store(),plain_owners()>,(added => snapshot_added => registry_seen(~Systems.plain_changed_owner(),~Delivery<S.plain_store(),plain_owners()>,(changed => snapshot_changed => registry_seen(~Systems.plain_without_owner(),~Delivery<S.plain_store(),plain_owners()>,(without => snapshot_without => registry_seen(~Systems.plain_with_owner(),~Delivery<S.plain_store(),plain_owners()>,(withHealth => snapshot_withHealth => failed(~S.plain_store(),~plain_owners(),stage,factory,[snapshot_main,snapshot_added,snapshot_changed,snapshot_without,snapshot_withHealth],Execution.plain_world(world))),Systems.plain_with_observe(withHealth))),Systems.plain_without_observe(without))),Systems.plain_changed_observe(changed))),Systems.plain_added_observe(added))),Systems.plain_main_observe(main))
def plain_done(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  Delivered{factory,world,owners,DTO.ScenarioReport{"plain",phases}}
def plain_foreign_unexpected(factory:W.Factory,original:W.World<S.Schema,S.plain_store(),Unit,Unit>,foreign:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),operation:DTO.Operation) -> Delivery<S.plain_store(),plain_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  registry_seen(~Systems.plain_main_owner(),~Delivery<S.plain_store(),plain_owners()>,(main => snapshot_main => registry_seen(~Systems.plain_added_owner(),~Delivery<S.plain_store(),plain_owners()>,(added => snapshot_added => registry_seen(~Systems.plain_changed_owner(),~Delivery<S.plain_store(),plain_owners()>,(changed => snapshot_changed => registry_seen(~Systems.plain_without_owner(),~Delivery<S.plain_store(),plain_owners()>,(without => snapshot_without => registry_seen(~Systems.plain_with_owner(),~Delivery<S.plain_store(),plain_owners()>,(withHealth => snapshot_withHealth => world_seen(~S.plain_store(),~Delivery<S.plain_store(),plain_owners()>,(original => originalSnapshot => failed_parts(~S.plain_store(),~plain_owners(),"foreign-registration-unexpected-completion",factory,[snapshot_main,snapshot_added,snapshot_changed,snapshot_without,snapshot_withHealth],[],None{},[],None{},[originalSnapshot],Some{operation},Execution.plain_world(foreign))),Execution.plain_world(original))),Systems.plain_with_observe(withHealth))),Systems.plain_without_observe(without))),Systems.plain_changed_observe(changed))),Systems.plain_added_observe(added))),Systems.plain_main_observe(main))
def plain_foreign_ran(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,otherOwners:plain_owners(),phases:List<&2,DTO.Snapshot>,foreign:W.World<S.Schema,S.plain_store(),Unit,Unit>,operation:DTO.Operation) -> Delivery<S.plain_store(),plain_owners()>:
  match operation:
    case DTO.RefusedRegistration{args,foreignWorld,registry}:plain_observe(~Delivery<S.plain_store(),plain_owners()>,plain_done,factory,world,otherOwners,phases,"foreign-registration-refusal",DTO.RefusedRegistration{args,foreignWorld,registry},[])
    case operation:plain_foreign_unexpected(factory,world,foreign,otherOwners,operation)
def plain_foreign_ready(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>,foreign:W.World<S.Schema,S.plain_store(),Unit,Unit>) -> Delivery<S.plain_store(),plain_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.plain_main_run_then(~Delivery<S.plain_store(),plain_owners()>,(foreign => main => operation => plain_foreign_ran(factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,foreign,operation)),main,foreign,False{})
def plain_foreign_created(world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>,created:W.Creation<S.Schema,S.plain_store(),Unit,Unit>) -> Delivery<S.plain_store(),plain_owners()>:
  match created:
    case W.CreateRejected{factory,resource}:plain_reject("foreign-world-creation-refused",factory,world,owners)
    case W.Created{factory,foreign}:
      plain_foreign_ready(factory,world,owners,phases,foreign)
def plain_foreign(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  plain_foreign_created(world,owners,phases,W.create(~S.Schema,~S.plain_store(),~Unit,~Unit,~Setup.plain_empty,factory,Unit{}))
def plain_app_detached(next:W.Factory -> W.World<S.Schema,S.plain_store(),Unit,Unit> -> plain_owners() -> List<&2,DTO.Snapshot> -> Delivery<S.plain_store(),plain_owners()>,factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,phases:List<&2,DTO.Snapshot>, +debug:App.Debug,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>,app:App.Application<S.Schema,S.plain_store(),Unit,Unit,plain_owners()>) -> Delivery<S.plain_store(),plain_owners()>:
  match debug:
    case App.Enabled{}:
      match app:
        case App.Application{_,_,SP.Provisioned{Sch.Schedule{_,_,_,owners},_}}:plain_observe(~Delivery<S.plain_store(),plain_owners()>,next,factory,world,owners,phases,"app-enabled-descriptions",DTO.Observed{},descriptions)
    case App.Disabled{}:
      match app:
        case App.Application{_,_,SP.Provisioned{Sch.Schedule{_,_,_,owners},_}}:plain_observe(~Delivery<S.plain_store(),plain_owners()>,next,factory,world,owners,phases,"app-disabled-description",DTO.Observed{},descriptions)

def plain_app_described_twice(next:W.Factory -> W.World<S.Schema,S.plain_store(),Unit,Unit> -> plain_owners() -> List<&2,DTO.Snapshot> -> Delivery<S.plain_store(),plain_owners()>,factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,phases:List<&2,DTO.Snapshot>,first:Maybe<&2,App.Description<S.Schema>>,observed:App.Application<S.Schema,S.plain_store(),Unit,Unit,plain_owners()> & Maybe<&2,App.Description<S.Schema>>) -> Delivery<S.plain_store(),plain_owners()>:
  match observed:
    case (app,second):plain_app_detached(next,factory,world,phases,App.Enabled{},[first,second],app)
def plain_app_described(next:W.Factory -> W.World<S.Schema,S.plain_store(),Unit,Unit> -> plain_owners() -> List<&2,DTO.Snapshot> -> Delivery<S.plain_store(),plain_owners()>,factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,phases:List<&2,DTO.Snapshot>, +debug:App.Debug,observed:App.Application<S.Schema,S.plain_store(),Unit,Unit,plain_owners()> & Maybe<&2,App.Description<S.Schema>>) -> Delivery<S.plain_store(),plain_owners()>:
  match debug:
    case App.Disabled{}:
      match observed:
        case (app,first):plain_app_detached(next,factory,world,phases,App.Disabled{},[first],app)
    case App.Enabled{}:
      match observed:
        case (app,first):plain_app_described_twice(next,factory,world,phases,first,App.describe(~S.Schema,~S.plain_store(),~Unit,~Unit,~plain_owners(),app))

def plain_app_built(next:W.Factory -> W.World<S.Schema,S.plain_store(),Unit,Unit> -> plain_owners() -> List<&2,DTO.Snapshot> -> Delivery<S.plain_store(),plain_owners()>,factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,phases:List<&2,DTO.Snapshot>, +debug:App.Debug,result:App.Built<S.Schema,S.plain_store(),Unit,Unit,plain_owners()>) -> Delivery<S.plain_store(),plain_owners()>:
  match result:
    case App.Invalid{owners}:plain_reject("app-build-refused",factory,world,owners)
    case App.Built{app}:plain_app_described(next,factory,world,phases,debug,App.describe(~S.Schema,~S.plain_store(),~Unit,~Unit,~plain_owners(),app))
def plain_app_main_seen(next:W.Factory -> W.World<S.Schema,S.plain_store(),Unit,Unit> -> plain_owners() -> List<&2,DTO.Snapshot> -> Delivery<S.plain_store(),plain_owners()>,factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,others:((((Unit & Systems.plain_added_owner()) & Systems.plain_changed_owner()) & Systems.plain_without_owner()) & Systems.plain_with_owner()),phases:List<&2,DTO.Snapshot>, +debug:App.Debug,observed:Systems.plain_main_owner() & DTO.RegistrySnapshot) -> Delivery<S.plain_store(),plain_owners()>:
  ((((Unit{},added),changed),without),withHealth) = others
  (main,mainSnapshot) = observed
  collected = App.empty(~S.Schema,registry_namespace(mainSnapshot),debug)
  collected = App.add(~S.Schema,~S.plain_store(),~Unit,~Unit,~Body.Ops,~Bool,~Unit,~DTO.RowValues,~Queries.plain_base(),~(H => caps => fail => owner => Body.body(~H,~caps,fail,owner)),~Unit,collected,main)
  collected = App.add(~S.Schema,~S.plain_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.plain_base_added(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~(Unit & Systems.plain_main_owner()),collected,added)
  collected = App.add(~S.Schema,~S.plain_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.plain_base_changed(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner()),collected,changed)
  collected = App.add(~S.Schema,~S.plain_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.plain_base_without_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~(((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner()) & Systems.plain_changed_owner()),collected,without)
  collected = App.add(~S.Schema,~S.plain_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.plain_base_with_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~((((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner()) & Systems.plain_changed_owner()) & Systems.plain_without_owner()),collected,withHealth)
  plain_app_built(next,factory,world,phases,debug,App.build(~S.Schema,~S.plain_store(),~Unit,~Unit,~plain_owners(),"Update",SP.Sequence{SP.Entry{Sch.Phase{"Update"},[]},SP.Sequence{SP.Entry{Sch.System{1,0},[]},SP.Sequence{SP.Entry{Sch.System{2,0},[]},SP.Sequence{SP.Entry{Sch.System{3,0},[]},SP.Sequence{SP.Entry{Sch.System{4,0},[]},SP.Sequence{SP.Entry{Sch.System{5,0},[]},SP.Entry{Sch.Barrier{},[]}}}}}}},collected))
def plain_app_collect(next:W.Factory -> W.World<S.Schema,S.plain_store(),Unit,Unit> -> plain_owners() -> List<&2,DTO.Snapshot> -> Delivery<S.plain_store(),plain_owners()>,factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>, +debug:App.Debug) -> Delivery<S.plain_store(),plain_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  plain_app_main_seen(next,factory,world,((((Unit{},added),changed),without),withHealth),phases,debug,Systems.plain_main_observe(main))
def plain_app_disabled(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  plain_app_collect(plain_foreign,factory,world,owners,phases,App.Disabled{})
def plain_app_enabled(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  plain_app_collect(plain_app_disabled,factory,world,owners,phases,App.Enabled{})
def plain_with_health(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.plain_with_run_then(~Delivery<S.plain_store(),plain_owners()>,(world => withHealth => operation => plain_observe(~Delivery<S.plain_store(),plain_owners()>,plain_app_enabled,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"with-health",operation,[])),withHealth,world,False{})
def plain_without_health(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.plain_without_run_then(~Delivery<S.plain_store(),plain_owners()>,(world => without => operation => plain_observe(~Delivery<S.plain_store(),plain_owners()>,plain_with_health,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"without-health",operation,[])),without,world,False{})
def plain_changed_empty(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.plain_changed_run_then(~Delivery<S.plain_store(),plain_owners()>,(world => changed => operation => plain_observe(~Delivery<S.plain_store(),plain_owners()>,plain_without_health,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"changed-empty",operation,[])),changed,world,False{})
def plain_changed_first(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.plain_changed_run_then(~Delivery<S.plain_store(),plain_owners()>,(world => changed => operation => plain_observe(~Delivery<S.plain_store(),plain_owners()>,plain_changed_empty,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"changed-first",operation,[])),changed,world,False{})
def plain_position_replaced(factory:W.Factory,owners:plain_owners(),phases:List<&2,DTO.Snapshot>,result:Cmp.Replacement<W.World<S.Schema,S.plain_store(),Unit,Unit>,Array<U32>>) -> Delivery<S.plain_store(),plain_owners()>:
  match result:
    case Cmp.Replaced{world,previous}:plain_observe(~Delivery<S.plain_store(),plain_owners()>,plain_changed_first,factory,world,owners,phases,"position-e2-replace",DTO.PositionReplaced{W.Accepted{}},[])
    case Cmp.ReplaceRejected{world,incoming,error}:plain_observe(~Delivery<S.plain_store(),plain_owners()>,plain_changed_first,factory,world,owners,phases,"position-e2-replace",DTO.PositionReplaced{W.Rejected{error}},[])
def plain_position_named(factory:W.Factory,owners:plain_owners(),phases:List<&2,DTO.Snapshot>,observed:W.World<S.Schema,S.plain_store(),Unit,Unit> & List<&2,W.Handle<S.Schema>>) -> Delivery<S.plain_store(),plain_owners()>:
  match observed:
    case (world,_ <> (handle <> (_ <> []))):plain_position_replaced(factory,owners,phases,Cmp.replace(~S.Schema,~S.plain_store(),~Unit,~Unit,~Queries.plain_position_rest(),~Array<U32>,~View.FullCell,~Unit,~Queries.plain_position_take,~Queries.plain_position_put,~View.view,Cmp.Family{Identity.key(~S.Schema,~Array<U32>,S.identity("Position"))},world,handle,Some{Setup.payload(5,102)}))
    case (world,_):plain_reject("position-handle-shape",factory,world,owners)

def plain_position_replace(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  plain_position_named(factory,owners,phases,W.handles(~S.Schema,~S.plain_store(),~Unit,~Unit,world))
def plain_added_empty(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.plain_added_run_then(~Delivery<S.plain_store(),plain_owners()>,(world => added => operation => plain_observe(~Delivery<S.plain_store(),plain_owners()>,plain_position_replace,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"added-empty",operation,[])),added,world,False{})
def plain_added_first(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.plain_added_run_then(~Delivery<S.plain_store(),plain_owners()>,(world => added => operation => plain_observe(~Delivery<S.plain_store(),plain_owners()>,plain_added_empty,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"added-first",operation,[])),added,world,False{})
def plain_main_second(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.plain_main_run_then(~Delivery<S.plain_store(),plain_owners()>,(world => main => operation => plain_observe(~Delivery<S.plain_store(),plain_owners()>,plain_added_first,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"main-second",operation,[])),main,world,False{})
def plain_main_retry(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.plain_main_run_then(~Delivery<S.plain_store(),plain_owners()>,(world => main => operation => plain_observe(~Delivery<S.plain_store(),plain_owners()>,plain_main_second,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"main-retry",operation,[])),main,world,False{})
def plain_main_fail(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.plain_main_run_then(~Delivery<S.plain_store(),plain_owners()>,(world => main => operation => plain_observe(~Delivery<S.plain_store(),plain_owners()>,plain_main_retry,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"main-fail",operation,[])),main,world,True{})
def plain_registered(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:plain_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  plain_observe(~Delivery<S.plain_store(),plain_owners()>,plain_main_fail,factory,world,owners,phases,"register",DTO.Observed{},[])
def plain_register_failed_4(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,previous:((((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner()) & Systems.plain_changed_owner()) & Systems.plain_without_owner())) -> Delivery<S.plain_store(),plain_owners()>:
  ((((Unit{},main),added),changed),without) = previous
  registry_seen(~Systems.plain_main_owner(),~Delivery<S.plain_store(),plain_owners()>,(main => snapshot_main => registry_seen(~Systems.plain_added_owner(),~Delivery<S.plain_store(),plain_owners()>,(added => snapshot_added => registry_seen(~Systems.plain_changed_owner(),~Delivery<S.plain_store(),plain_owners()>,(changed => snapshot_changed => registry_seen(~Systems.plain_without_owner(),~Delivery<S.plain_store(),plain_owners()>,(without => snapshot_without => failed(~S.plain_store(),~plain_owners(),"register-with-refused",factory,[snapshot_main,snapshot_added,snapshot_changed,snapshot_without],Execution.plain_world(world))),Systems.plain_without_observe(without))),Systems.plain_changed_observe(changed))),Systems.plain_added_observe(added))),Systems.plain_main_observe(main))
def plain_defined_4(factory:W.Factory,previous:((((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner()) & Systems.plain_changed_owner()) & Systems.plain_without_owner()),phases:List<&2,DTO.Snapshot>,result:System.Defined<S.Schema,W.World<S.Schema,S.plain_store(),Unit,Unit>,Systems.plain_with_registry()>) -> Delivery<S.plain_store(),plain_owners()>:
  match result:
    case System.Defined{world,owner}:plain_registered(factory,world,(previous,owner),phases)
    case System.Rejected{world}:plain_register_failed_4(factory,world,previous)
def plain_register_4(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,previous:((((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner()) & Systems.plain_changed_owner()) & Systems.plain_without_owner()),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  plain_defined_4(factory,previous,phases,Systems.plain_with_define(world))
def plain_register_failed_3(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,previous:(((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner()) & Systems.plain_changed_owner())) -> Delivery<S.plain_store(),plain_owners()>:
  (((Unit{},main),added),changed) = previous
  registry_seen(~Systems.plain_main_owner(),~Delivery<S.plain_store(),plain_owners()>,(main => snapshot_main => registry_seen(~Systems.plain_added_owner(),~Delivery<S.plain_store(),plain_owners()>,(added => snapshot_added => registry_seen(~Systems.plain_changed_owner(),~Delivery<S.plain_store(),plain_owners()>,(changed => snapshot_changed => failed(~S.plain_store(),~plain_owners(),"register-without-refused",factory,[snapshot_main,snapshot_added,snapshot_changed],Execution.plain_world(world))),Systems.plain_changed_observe(changed))),Systems.plain_added_observe(added))),Systems.plain_main_observe(main))
def plain_defined_3(factory:W.Factory,previous:(((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner()) & Systems.plain_changed_owner()),phases:List<&2,DTO.Snapshot>,result:System.Defined<S.Schema,W.World<S.Schema,S.plain_store(),Unit,Unit>,Systems.plain_without_registry()>) -> Delivery<S.plain_store(),plain_owners()>:
  match result:
    case System.Defined{world,owner}:plain_register_4(factory,world,(previous,owner),phases)
    case System.Rejected{world}:plain_register_failed_3(factory,world,previous)
def plain_register_3(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,previous:(((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner()) & Systems.plain_changed_owner()),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  plain_defined_3(factory,previous,phases,Systems.plain_without_define(world))
def plain_register_failed_2(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,previous:((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner())) -> Delivery<S.plain_store(),plain_owners()>:
  ((Unit{},main),added) = previous
  registry_seen(~Systems.plain_main_owner(),~Delivery<S.plain_store(),plain_owners()>,(main => snapshot_main => registry_seen(~Systems.plain_added_owner(),~Delivery<S.plain_store(),plain_owners()>,(added => snapshot_added => failed(~S.plain_store(),~plain_owners(),"register-changed-refused",factory,[snapshot_main,snapshot_added],Execution.plain_world(world))),Systems.plain_added_observe(added))),Systems.plain_main_observe(main))
def plain_defined_2(factory:W.Factory,previous:((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner()),phases:List<&2,DTO.Snapshot>,result:System.Defined<S.Schema,W.World<S.Schema,S.plain_store(),Unit,Unit>,Systems.plain_changed_registry()>) -> Delivery<S.plain_store(),plain_owners()>:
  match result:
    case System.Defined{world,owner}:plain_register_3(factory,world,(previous,owner),phases)
    case System.Rejected{world}:plain_register_failed_2(factory,world,previous)
def plain_register_2(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,previous:((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner()),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  plain_defined_2(factory,previous,phases,Systems.plain_changed_define(world))
def plain_register_failed_1(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,previous:(Unit & Systems.plain_main_owner())) -> Delivery<S.plain_store(),plain_owners()>:
  (Unit{},main) = previous
  registry_seen(~Systems.plain_main_owner(),~Delivery<S.plain_store(),plain_owners()>,(main => snapshot_main => failed(~S.plain_store(),~plain_owners(),"register-added-refused",factory,[snapshot_main],Execution.plain_world(world))),Systems.plain_main_observe(main))
def plain_defined_1(factory:W.Factory,previous:(Unit & Systems.plain_main_owner()),phases:List<&2,DTO.Snapshot>,result:System.Defined<S.Schema,W.World<S.Schema,S.plain_store(),Unit,Unit>,Systems.plain_added_registry()>) -> Delivery<S.plain_store(),plain_owners()>:
  match result:
    case System.Defined{world,owner}:plain_register_2(factory,world,(previous,owner),phases)
    case System.Rejected{world}:plain_register_failed_1(factory,world,previous)
def plain_register_1(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,previous:(Unit & Systems.plain_main_owner()),phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  plain_defined_1(factory,previous,phases,Systems.plain_added_define(world))
def plain_register_failed_0(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,previous:Unit) -> Delivery<S.plain_store(),plain_owners()>:
  Unit{} = previous
  failed(~S.plain_store(),~plain_owners(),"register-main-refused",factory,[],Execution.plain_world(world))
def plain_defined_0(factory:W.Factory,previous:Unit,phases:List<&2,DTO.Snapshot>,result:System.Defined<S.Schema,W.World<S.Schema,S.plain_store(),Unit,Unit>,Systems.plain_main_registry()>) -> Delivery<S.plain_store(),plain_owners()>:
  match result:
    case System.Defined{world,owner}:plain_register_1(factory,world,(previous,owner),phases)
    case System.Rejected{world}:plain_register_failed_0(factory,world,previous)
def plain_register_0(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,previous:Unit,phases:List<&2,DTO.Snapshot>) -> Delivery<S.plain_store(),plain_owners()>:
  plain_defined_0(factory,previous,phases,Systems.plain_main_define(world))
def plain_seed_seen(factory:W.Factory,observed:W.World<S.Schema,S.plain_store(),Unit,Unit> & DTO.WorldSnapshot) -> Delivery<S.plain_store(),plain_owners()>:
  match factory:
    case W.Factory{+nextNamespace}:
      match observed:
        case (world,snapshot):plain_register_0(W.Factory{nextNamespace},world,Unit{},[DTO.Snapshot{"seed",nextNamespace,snapshot,[],DTO.Observed{},[]}])
def plain_seed_previous_checked(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>,values:List<&2,Maybe<&2,View.FullCell>>,accepted:Bool) -> Delivery<S.plain_store(),plain_owners()>:
  match accepted:
    case True{}:plain_seed_seen(factory,Execution.plain_world(world))
    case False{}:failed_parts(~S.plain_store(),~plain_owners(),"seed-previous-unexpected",factory,[],handles,None{},values,None{},[],None{},Execution.plain_world(world))
def plain_seed_previous_decide(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>,+values:List<&2,Maybe<&2,View.FullCell>>) -> Delivery<S.plain_store(),plain_owners()>:
  plain_seed_previous_checked(factory,world,handles,previous,values,Returned.all_none(7n,values))
def plain_seed_previous(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Delivery<S.plain_store(),plain_owners()>:
  previous_seen(~Delivery<S.plain_store(),plain_owners()>,(previous => values => plain_seed_previous_decide(factory,world,handles,previous,values)),Returned.owners(previous))
def plain_seed_replace_failed(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>,incoming:Maybe<&1,Array<U32>>,error:W.WorldError) -> Delivery<S.plain_store(),plain_owners()>:
  previous_seen(~Delivery<S.plain_store(),plain_owners()>,(previous => values => incoming_seen(~Delivery<S.plain_store(),plain_owners()>,(incoming => incomingValue => failed_parts(~S.plain_store(),~plain_owners(),"seed-replace-refused",factory,[],handles,Some{error},values,incomingValue,[],None{},Execution.plain_world(world))),Returned.owner(incoming))),Returned.owners(previous))
def plain_seeded(result:Setup.Seed<S.plain_store()>) -> Delivery<S.plain_store(),plain_owners()>:
  match result:
    case Setup.Seeded{factory,world,handles,previous}:plain_seed_previous(factory,world,handles,previous)
    case Setup.CreateRefused{W.Factory{nextNamespace},resource}:Rejected{Failure{"seed-create-refused",nextNamespace,None{},[],[],None{},[],None{},[],None{}}}
    case Setup.AllocationShapeRefused{factory,world,handles}:failed_parts(~S.plain_store(),~plain_owners(),"seed-allocation-shape",factory,[],handles,None{},[],None{},[],None{},Execution.plain_world(world))
    case Setup.ReserveRefused{factory,world,handles,error}:failed_parts(~S.plain_store(),~plain_owners(),"seed-reserve-refused",factory,[],handles,Some{error},[],None{},[],None{},Execution.plain_world(world))
    case Setup.ActivateRefused{factory,world,handles,error}:failed_parts(~S.plain_store(),~plain_owners(),"seed-activate-refused",factory,[],handles,Some{error},[],None{},[],None{},Execution.plain_world(world))
    case Setup.ReplaceRefused{factory,world,handles,previous,incoming,error}:plain_seed_replace_failed(factory,world,handles,previous,incoming,error)
def plain() -> Delivery<S.plain_store(),plain_owners()>:
  plain_seeded(Setup.plain(W.factory()))

def transient_owners() -> Type:
  (((((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner()) & Systems.transient_changed_owner()) & Systems.transient_without_owner()) & Systems.transient_with_owner())
def transient_observe(~Out:Type,next:W.Factory -> W.World<S.Schema,S.transient_store(),Unit,Unit> -> transient_owners() -> List<&2,DTO.Snapshot> -> Out,factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>,label:String,operation:DTO.Operation,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>) -> Out:
  match factory:
    case W.Factory{+nextNamespace}:
      (((((Unit{},main),added),changed),without),withHealth) = owners
      registry_seen(~Systems.transient_main_owner(),~Out,(main => snapshot_main => registry_seen(~Systems.transient_added_owner(),~Out,(added => snapshot_added => registry_seen(~Systems.transient_changed_owner(),~Out,(changed => snapshot_changed => registry_seen(~Systems.transient_without_owner(),~Out,(without => snapshot_without => registry_seen(~Systems.transient_with_owner(),~Out,(withHealth => snapshot_withHealth => world_seen(~S.transient_store(),~Out,(world => snapshotWorld => next(W.Factory{nextNamespace},world,(((((Unit{},main),added),changed),without),withHealth),List.append(&2,DTO.Snapshot,phases,[DTO.Snapshot{label,nextNamespace,snapshotWorld,[snapshot_main,snapshot_added,snapshot_changed,snapshot_without,snapshot_withHealth],operation,descriptions}]))),Execution.transient_world(world))),Systems.transient_with_observe(withHealth))),Systems.transient_without_observe(without))),Systems.transient_changed_observe(changed))),Systems.transient_added_observe(added))),Systems.transient_main_observe(main))
def transient_reject(stage:String,factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners()) -> Delivery<S.transient_store(),transient_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  registry_seen(~Systems.transient_main_owner(),~Delivery<S.transient_store(),transient_owners()>,(main => snapshot_main => registry_seen(~Systems.transient_added_owner(),~Delivery<S.transient_store(),transient_owners()>,(added => snapshot_added => registry_seen(~Systems.transient_changed_owner(),~Delivery<S.transient_store(),transient_owners()>,(changed => snapshot_changed => registry_seen(~Systems.transient_without_owner(),~Delivery<S.transient_store(),transient_owners()>,(without => snapshot_without => registry_seen(~Systems.transient_with_owner(),~Delivery<S.transient_store(),transient_owners()>,(withHealth => snapshot_withHealth => failed(~S.transient_store(),~transient_owners(),stage,factory,[snapshot_main,snapshot_added,snapshot_changed,snapshot_without,snapshot_withHealth],Execution.transient_world(world))),Systems.transient_with_observe(withHealth))),Systems.transient_without_observe(without))),Systems.transient_changed_observe(changed))),Systems.transient_added_observe(added))),Systems.transient_main_observe(main))
def transient_done(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  Delivered{factory,world,owners,DTO.ScenarioReport{"transient",phases}}
def transient_foreign_unexpected(factory:W.Factory,original:W.World<S.Schema,S.transient_store(),Unit,Unit>,foreign:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),operation:DTO.Operation) -> Delivery<S.transient_store(),transient_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  registry_seen(~Systems.transient_main_owner(),~Delivery<S.transient_store(),transient_owners()>,(main => snapshot_main => registry_seen(~Systems.transient_added_owner(),~Delivery<S.transient_store(),transient_owners()>,(added => snapshot_added => registry_seen(~Systems.transient_changed_owner(),~Delivery<S.transient_store(),transient_owners()>,(changed => snapshot_changed => registry_seen(~Systems.transient_without_owner(),~Delivery<S.transient_store(),transient_owners()>,(without => snapshot_without => registry_seen(~Systems.transient_with_owner(),~Delivery<S.transient_store(),transient_owners()>,(withHealth => snapshot_withHealth => world_seen(~S.transient_store(),~Delivery<S.transient_store(),transient_owners()>,(original => originalSnapshot => failed_parts(~S.transient_store(),~transient_owners(),"foreign-registration-unexpected-completion",factory,[snapshot_main,snapshot_added,snapshot_changed,snapshot_without,snapshot_withHealth],[],None{},[],None{},[originalSnapshot],Some{operation},Execution.transient_world(foreign))),Execution.transient_world(original))),Systems.transient_with_observe(withHealth))),Systems.transient_without_observe(without))),Systems.transient_changed_observe(changed))),Systems.transient_added_observe(added))),Systems.transient_main_observe(main))
def transient_foreign_ran(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,otherOwners:transient_owners(),phases:List<&2,DTO.Snapshot>,foreign:W.World<S.Schema,S.transient_store(),Unit,Unit>,operation:DTO.Operation) -> Delivery<S.transient_store(),transient_owners()>:
  match operation:
    case DTO.RefusedRegistration{args,foreignWorld,registry}:transient_observe(~Delivery<S.transient_store(),transient_owners()>,transient_done,factory,world,otherOwners,phases,"foreign-registration-refusal",DTO.RefusedRegistration{args,foreignWorld,registry},[])
    case operation:transient_foreign_unexpected(factory,world,foreign,otherOwners,operation)
def transient_foreign_ready(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>,foreign:W.World<S.Schema,S.transient_store(),Unit,Unit>) -> Delivery<S.transient_store(),transient_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.transient_main_run_then(~Delivery<S.transient_store(),transient_owners()>,(foreign => main => operation => transient_foreign_ran(factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,foreign,operation)),main,foreign,False{})
def transient_foreign_created(world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>,created:W.Creation<S.Schema,S.transient_store(),Unit,Unit>) -> Delivery<S.transient_store(),transient_owners()>:
  match created:
    case W.CreateRejected{factory,resource}:transient_reject("foreign-world-creation-refused",factory,world,owners)
    case W.Created{factory,foreign}:
      transient_foreign_ready(factory,world,owners,phases,foreign)
def transient_foreign(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  transient_foreign_created(world,owners,phases,W.create(~S.Schema,~S.transient_store(),~Unit,~Unit,~Setup.transient_empty,factory,Unit{}))
def transient_app_detached(next:W.Factory -> W.World<S.Schema,S.transient_store(),Unit,Unit> -> transient_owners() -> List<&2,DTO.Snapshot> -> Delivery<S.transient_store(),transient_owners()>,factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,phases:List<&2,DTO.Snapshot>, +debug:App.Debug,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>,app:App.Application<S.Schema,S.transient_store(),Unit,Unit,transient_owners()>) -> Delivery<S.transient_store(),transient_owners()>:
  match debug:
    case App.Enabled{}:
      match app:
        case App.Application{_,_,SP.Provisioned{Sch.Schedule{_,_,_,owners},_}}:transient_observe(~Delivery<S.transient_store(),transient_owners()>,next,factory,world,owners,phases,"app-enabled-descriptions",DTO.Observed{},descriptions)
    case App.Disabled{}:
      match app:
        case App.Application{_,_,SP.Provisioned{Sch.Schedule{_,_,_,owners},_}}:transient_observe(~Delivery<S.transient_store(),transient_owners()>,next,factory,world,owners,phases,"app-disabled-description",DTO.Observed{},descriptions)

def transient_app_described_twice(next:W.Factory -> W.World<S.Schema,S.transient_store(),Unit,Unit> -> transient_owners() -> List<&2,DTO.Snapshot> -> Delivery<S.transient_store(),transient_owners()>,factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,phases:List<&2,DTO.Snapshot>,first:Maybe<&2,App.Description<S.Schema>>,observed:App.Application<S.Schema,S.transient_store(),Unit,Unit,transient_owners()> & Maybe<&2,App.Description<S.Schema>>) -> Delivery<S.transient_store(),transient_owners()>:
  match observed:
    case (app,second):transient_app_detached(next,factory,world,phases,App.Enabled{},[first,second],app)
def transient_app_described(next:W.Factory -> W.World<S.Schema,S.transient_store(),Unit,Unit> -> transient_owners() -> List<&2,DTO.Snapshot> -> Delivery<S.transient_store(),transient_owners()>,factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,phases:List<&2,DTO.Snapshot>, +debug:App.Debug,observed:App.Application<S.Schema,S.transient_store(),Unit,Unit,transient_owners()> & Maybe<&2,App.Description<S.Schema>>) -> Delivery<S.transient_store(),transient_owners()>:
  match debug:
    case App.Disabled{}:
      match observed:
        case (app,first):transient_app_detached(next,factory,world,phases,App.Disabled{},[first],app)
    case App.Enabled{}:
      match observed:
        case (app,first):transient_app_described_twice(next,factory,world,phases,first,App.describe(~S.Schema,~S.transient_store(),~Unit,~Unit,~transient_owners(),app))

def transient_app_built(next:W.Factory -> W.World<S.Schema,S.transient_store(),Unit,Unit> -> transient_owners() -> List<&2,DTO.Snapshot> -> Delivery<S.transient_store(),transient_owners()>,factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,phases:List<&2,DTO.Snapshot>, +debug:App.Debug,result:App.Built<S.Schema,S.transient_store(),Unit,Unit,transient_owners()>) -> Delivery<S.transient_store(),transient_owners()>:
  match result:
    case App.Invalid{owners}:transient_reject("app-build-refused",factory,world,owners)
    case App.Built{app}:transient_app_described(next,factory,world,phases,debug,App.describe(~S.Schema,~S.transient_store(),~Unit,~Unit,~transient_owners(),app))
def transient_app_main_seen(next:W.Factory -> W.World<S.Schema,S.transient_store(),Unit,Unit> -> transient_owners() -> List<&2,DTO.Snapshot> -> Delivery<S.transient_store(),transient_owners()>,factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,others:((((Unit & Systems.transient_added_owner()) & Systems.transient_changed_owner()) & Systems.transient_without_owner()) & Systems.transient_with_owner()),phases:List<&2,DTO.Snapshot>, +debug:App.Debug,observed:Systems.transient_main_owner() & DTO.RegistrySnapshot) -> Delivery<S.transient_store(),transient_owners()>:
  ((((Unit{},added),changed),without),withHealth) = others
  (main,mainSnapshot) = observed
  collected = App.empty(~S.Schema,registry_namespace(mainSnapshot),debug)
  collected = App.add(~S.Schema,~S.transient_store(),~Unit,~Unit,~Body.Ops,~Bool,~Unit,~DTO.RowValues,~Queries.transient_base(),~(H => caps => fail => owner => Body.body(~H,~caps,fail,owner)),~Unit,collected,main)
  collected = App.add(~S.Schema,~S.transient_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.transient_base_added(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~(Unit & Systems.transient_main_owner()),collected,added)
  collected = App.add(~S.Schema,~S.transient_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.transient_base_changed(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner()),collected,changed)
  collected = App.add(~S.Schema,~S.transient_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.transient_base_without_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~(((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner()) & Systems.transient_changed_owner()),collected,without)
  collected = App.add(~S.Schema,~S.transient_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.transient_base_with_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~((((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner()) & Systems.transient_changed_owner()) & Systems.transient_without_owner()),collected,withHealth)
  transient_app_built(next,factory,world,phases,debug,App.build(~S.Schema,~S.transient_store(),~Unit,~Unit,~transient_owners(),"Update",SP.Sequence{SP.Entry{Sch.Phase{"Update"},[]},SP.Sequence{SP.Entry{Sch.System{1,0},[]},SP.Sequence{SP.Entry{Sch.System{2,0},[]},SP.Sequence{SP.Entry{Sch.System{3,0},[]},SP.Sequence{SP.Entry{Sch.System{4,0},[]},SP.Sequence{SP.Entry{Sch.System{5,0},[]},SP.Entry{Sch.Barrier{},[]}}}}}}},collected))
def transient_app_collect(next:W.Factory -> W.World<S.Schema,S.transient_store(),Unit,Unit> -> transient_owners() -> List<&2,DTO.Snapshot> -> Delivery<S.transient_store(),transient_owners()>,factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>, +debug:App.Debug) -> Delivery<S.transient_store(),transient_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  transient_app_main_seen(next,factory,world,((((Unit{},added),changed),without),withHealth),phases,debug,Systems.transient_main_observe(main))
def transient_app_disabled(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  transient_app_collect(transient_foreign,factory,world,owners,phases,App.Disabled{})
def transient_app_enabled(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  transient_app_collect(transient_app_disabled,factory,world,owners,phases,App.Enabled{})
def transient_with_health(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.transient_with_run_then(~Delivery<S.transient_store(),transient_owners()>,(world => withHealth => operation => transient_observe(~Delivery<S.transient_store(),transient_owners()>,transient_app_enabled,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"with-health",operation,[])),withHealth,world,False{})
def transient_without_health(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.transient_without_run_then(~Delivery<S.transient_store(),transient_owners()>,(world => without => operation => transient_observe(~Delivery<S.transient_store(),transient_owners()>,transient_with_health,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"without-health",operation,[])),without,world,False{})
def transient_changed_empty(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.transient_changed_run_then(~Delivery<S.transient_store(),transient_owners()>,(world => changed => operation => transient_observe(~Delivery<S.transient_store(),transient_owners()>,transient_without_health,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"changed-empty",operation,[])),changed,world,False{})
def transient_changed_first(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.transient_changed_run_then(~Delivery<S.transient_store(),transient_owners()>,(world => changed => operation => transient_observe(~Delivery<S.transient_store(),transient_owners()>,transient_changed_empty,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"changed-first",operation,[])),changed,world,False{})
def transient_position_replaced(factory:W.Factory,owners:transient_owners(),phases:List<&2,DTO.Snapshot>,result:Cmp.Replacement<W.World<S.Schema,S.transient_store(),Unit,Unit>,Array<U32>>) -> Delivery<S.transient_store(),transient_owners()>:
  match result:
    case Cmp.Replaced{world,previous}:transient_observe(~Delivery<S.transient_store(),transient_owners()>,transient_changed_first,factory,world,owners,phases,"position-e2-replace",DTO.PositionReplaced{W.Accepted{}},[])
    case Cmp.ReplaceRejected{world,incoming,error}:transient_observe(~Delivery<S.transient_store(),transient_owners()>,transient_changed_first,factory,world,owners,phases,"position-e2-replace",DTO.PositionReplaced{W.Rejected{error}},[])
def transient_position_named(factory:W.Factory,owners:transient_owners(),phases:List<&2,DTO.Snapshot>,observed:W.World<S.Schema,S.transient_store(),Unit,Unit> & List<&2,W.Handle<S.Schema>>) -> Delivery<S.transient_store(),transient_owners()>:
  match observed:
    case (world,_ <> (handle <> (_ <> []))):transient_position_replaced(factory,owners,phases,Cmp.replace(~S.Schema,~S.transient_store(),~Unit,~Unit,~Queries.transient_position_rest(),~Array<U32>,~View.FullCell,~Unit,~Queries.transient_position_take,~Queries.transient_position_put,~View.view,Cmp.Family{Identity.key(~S.Schema,~Array<U32>,S.identity("Position"))},world,handle,Some{Setup.payload(5,102)}))
    case (world,_):transient_reject("position-handle-shape",factory,world,owners)

def transient_position_replace(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  transient_position_named(factory,owners,phases,W.handles(~S.Schema,~S.transient_store(),~Unit,~Unit,world))
def transient_added_empty(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.transient_added_run_then(~Delivery<S.transient_store(),transient_owners()>,(world => added => operation => transient_observe(~Delivery<S.transient_store(),transient_owners()>,transient_position_replace,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"added-empty",operation,[])),added,world,False{})
def transient_added_first(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.transient_added_run_then(~Delivery<S.transient_store(),transient_owners()>,(world => added => operation => transient_observe(~Delivery<S.transient_store(),transient_owners()>,transient_added_empty,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"added-first",operation,[])),added,world,False{})
def transient_main_second(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.transient_main_run_then(~Delivery<S.transient_store(),transient_owners()>,(world => main => operation => transient_observe(~Delivery<S.transient_store(),transient_owners()>,transient_added_first,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"main-second",operation,[])),main,world,False{})
def transient_main_retry(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.transient_main_run_then(~Delivery<S.transient_store(),transient_owners()>,(world => main => operation => transient_observe(~Delivery<S.transient_store(),transient_owners()>,transient_main_second,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"main-retry",operation,[])),main,world,False{})
def transient_main_fail(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.transient_main_run_then(~Delivery<S.transient_store(),transient_owners()>,(world => main => operation => transient_observe(~Delivery<S.transient_store(),transient_owners()>,transient_main_retry,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"main-fail",operation,[])),main,world,True{})
def transient_registered(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:transient_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  transient_observe(~Delivery<S.transient_store(),transient_owners()>,transient_main_fail,factory,world,owners,phases,"register",DTO.Observed{},[])
def transient_register_failed_4(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,previous:((((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner()) & Systems.transient_changed_owner()) & Systems.transient_without_owner())) -> Delivery<S.transient_store(),transient_owners()>:
  ((((Unit{},main),added),changed),without) = previous
  registry_seen(~Systems.transient_main_owner(),~Delivery<S.transient_store(),transient_owners()>,(main => snapshot_main => registry_seen(~Systems.transient_added_owner(),~Delivery<S.transient_store(),transient_owners()>,(added => snapshot_added => registry_seen(~Systems.transient_changed_owner(),~Delivery<S.transient_store(),transient_owners()>,(changed => snapshot_changed => registry_seen(~Systems.transient_without_owner(),~Delivery<S.transient_store(),transient_owners()>,(without => snapshot_without => failed(~S.transient_store(),~transient_owners(),"register-with-refused",factory,[snapshot_main,snapshot_added,snapshot_changed,snapshot_without],Execution.transient_world(world))),Systems.transient_without_observe(without))),Systems.transient_changed_observe(changed))),Systems.transient_added_observe(added))),Systems.transient_main_observe(main))
def transient_defined_4(factory:W.Factory,previous:((((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner()) & Systems.transient_changed_owner()) & Systems.transient_without_owner()),phases:List<&2,DTO.Snapshot>,result:System.Defined<S.Schema,W.World<S.Schema,S.transient_store(),Unit,Unit>,Systems.transient_with_registry()>) -> Delivery<S.transient_store(),transient_owners()>:
  match result:
    case System.Defined{world,owner}:transient_registered(factory,world,(previous,owner),phases)
    case System.Rejected{world}:transient_register_failed_4(factory,world,previous)
def transient_register_4(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,previous:((((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner()) & Systems.transient_changed_owner()) & Systems.transient_without_owner()),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  transient_defined_4(factory,previous,phases,Systems.transient_with_define(world))
def transient_register_failed_3(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,previous:(((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner()) & Systems.transient_changed_owner())) -> Delivery<S.transient_store(),transient_owners()>:
  (((Unit{},main),added),changed) = previous
  registry_seen(~Systems.transient_main_owner(),~Delivery<S.transient_store(),transient_owners()>,(main => snapshot_main => registry_seen(~Systems.transient_added_owner(),~Delivery<S.transient_store(),transient_owners()>,(added => snapshot_added => registry_seen(~Systems.transient_changed_owner(),~Delivery<S.transient_store(),transient_owners()>,(changed => snapshot_changed => failed(~S.transient_store(),~transient_owners(),"register-without-refused",factory,[snapshot_main,snapshot_added,snapshot_changed],Execution.transient_world(world))),Systems.transient_changed_observe(changed))),Systems.transient_added_observe(added))),Systems.transient_main_observe(main))
def transient_defined_3(factory:W.Factory,previous:(((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner()) & Systems.transient_changed_owner()),phases:List<&2,DTO.Snapshot>,result:System.Defined<S.Schema,W.World<S.Schema,S.transient_store(),Unit,Unit>,Systems.transient_without_registry()>) -> Delivery<S.transient_store(),transient_owners()>:
  match result:
    case System.Defined{world,owner}:transient_register_4(factory,world,(previous,owner),phases)
    case System.Rejected{world}:transient_register_failed_3(factory,world,previous)
def transient_register_3(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,previous:(((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner()) & Systems.transient_changed_owner()),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  transient_defined_3(factory,previous,phases,Systems.transient_without_define(world))
def transient_register_failed_2(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,previous:((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner())) -> Delivery<S.transient_store(),transient_owners()>:
  ((Unit{},main),added) = previous
  registry_seen(~Systems.transient_main_owner(),~Delivery<S.transient_store(),transient_owners()>,(main => snapshot_main => registry_seen(~Systems.transient_added_owner(),~Delivery<S.transient_store(),transient_owners()>,(added => snapshot_added => failed(~S.transient_store(),~transient_owners(),"register-changed-refused",factory,[snapshot_main,snapshot_added],Execution.transient_world(world))),Systems.transient_added_observe(added))),Systems.transient_main_observe(main))
def transient_defined_2(factory:W.Factory,previous:((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner()),phases:List<&2,DTO.Snapshot>,result:System.Defined<S.Schema,W.World<S.Schema,S.transient_store(),Unit,Unit>,Systems.transient_changed_registry()>) -> Delivery<S.transient_store(),transient_owners()>:
  match result:
    case System.Defined{world,owner}:transient_register_3(factory,world,(previous,owner),phases)
    case System.Rejected{world}:transient_register_failed_2(factory,world,previous)
def transient_register_2(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,previous:((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner()),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  transient_defined_2(factory,previous,phases,Systems.transient_changed_define(world))
def transient_register_failed_1(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,previous:(Unit & Systems.transient_main_owner())) -> Delivery<S.transient_store(),transient_owners()>:
  (Unit{},main) = previous
  registry_seen(~Systems.transient_main_owner(),~Delivery<S.transient_store(),transient_owners()>,(main => snapshot_main => failed(~S.transient_store(),~transient_owners(),"register-added-refused",factory,[snapshot_main],Execution.transient_world(world))),Systems.transient_main_observe(main))
def transient_defined_1(factory:W.Factory,previous:(Unit & Systems.transient_main_owner()),phases:List<&2,DTO.Snapshot>,result:System.Defined<S.Schema,W.World<S.Schema,S.transient_store(),Unit,Unit>,Systems.transient_added_registry()>) -> Delivery<S.transient_store(),transient_owners()>:
  match result:
    case System.Defined{world,owner}:transient_register_2(factory,world,(previous,owner),phases)
    case System.Rejected{world}:transient_register_failed_1(factory,world,previous)
def transient_register_1(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,previous:(Unit & Systems.transient_main_owner()),phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  transient_defined_1(factory,previous,phases,Systems.transient_added_define(world))
def transient_register_failed_0(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,previous:Unit) -> Delivery<S.transient_store(),transient_owners()>:
  Unit{} = previous
  failed(~S.transient_store(),~transient_owners(),"register-main-refused",factory,[],Execution.transient_world(world))
def transient_defined_0(factory:W.Factory,previous:Unit,phases:List<&2,DTO.Snapshot>,result:System.Defined<S.Schema,W.World<S.Schema,S.transient_store(),Unit,Unit>,Systems.transient_main_registry()>) -> Delivery<S.transient_store(),transient_owners()>:
  match result:
    case System.Defined{world,owner}:transient_register_1(factory,world,(previous,owner),phases)
    case System.Rejected{world}:transient_register_failed_0(factory,world,previous)
def transient_register_0(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,previous:Unit,phases:List<&2,DTO.Snapshot>) -> Delivery<S.transient_store(),transient_owners()>:
  transient_defined_0(factory,previous,phases,Systems.transient_main_define(world))
def transient_seed_seen(factory:W.Factory,observed:W.World<S.Schema,S.transient_store(),Unit,Unit> & DTO.WorldSnapshot) -> Delivery<S.transient_store(),transient_owners()>:
  match factory:
    case W.Factory{+nextNamespace}:
      match observed:
        case (world,snapshot):transient_register_0(W.Factory{nextNamespace},world,Unit{},[DTO.Snapshot{"seed",nextNamespace,snapshot,[],DTO.Observed{},[]}])
def transient_seed_previous_checked(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>,values:List<&2,Maybe<&2,View.FullCell>>,accepted:Bool) -> Delivery<S.transient_store(),transient_owners()>:
  match accepted:
    case True{}:transient_seed_seen(factory,Execution.transient_world(world))
    case False{}:failed_parts(~S.transient_store(),~transient_owners(),"seed-previous-unexpected",factory,[],handles,None{},values,None{},[],None{},Execution.transient_world(world))
def transient_seed_previous_decide(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>,+values:List<&2,Maybe<&2,View.FullCell>>) -> Delivery<S.transient_store(),transient_owners()>:
  transient_seed_previous_checked(factory,world,handles,previous,values,Returned.all_none(7n,values))
def transient_seed_previous(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Delivery<S.transient_store(),transient_owners()>:
  previous_seen(~Delivery<S.transient_store(),transient_owners()>,(previous => values => transient_seed_previous_decide(factory,world,handles,previous,values)),Returned.owners(previous))
def transient_seed_replace_failed(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>,incoming:Maybe<&1,Array<U32>>,error:W.WorldError) -> Delivery<S.transient_store(),transient_owners()>:
  previous_seen(~Delivery<S.transient_store(),transient_owners()>,(previous => values => incoming_seen(~Delivery<S.transient_store(),transient_owners()>,(incoming => incomingValue => failed_parts(~S.transient_store(),~transient_owners(),"seed-replace-refused",factory,[],handles,Some{error},values,incomingValue,[],None{},Execution.transient_world(world))),Returned.owner(incoming))),Returned.owners(previous))
def transient_seeded(result:Setup.Seed<S.transient_store()>) -> Delivery<S.transient_store(),transient_owners()>:
  match result:
    case Setup.Seeded{factory,world,handles,previous}:transient_seed_previous(factory,world,handles,previous)
    case Setup.CreateRefused{W.Factory{nextNamespace},resource}:Rejected{Failure{"seed-create-refused",nextNamespace,None{},[],[],None{},[],None{},[],None{}}}
    case Setup.AllocationShapeRefused{factory,world,handles}:failed_parts(~S.transient_store(),~transient_owners(),"seed-allocation-shape",factory,[],handles,None{},[],None{},[],None{},Execution.transient_world(world))
    case Setup.ReserveRefused{factory,world,handles,error}:failed_parts(~S.transient_store(),~transient_owners(),"seed-reserve-refused",factory,[],handles,Some{error},[],None{},[],None{},Execution.transient_world(world))
    case Setup.ActivateRefused{factory,world,handles,error}:failed_parts(~S.transient_store(),~transient_owners(),"seed-activate-refused",factory,[],handles,Some{error},[],None{},[],None{},Execution.transient_world(world))
    case Setup.ReplaceRefused{factory,world,handles,previous,incoming,error}:transient_seed_replace_failed(factory,world,handles,previous,incoming,error)
def transient() -> Delivery<S.transient_store(),transient_owners()>:
  transient_seeded(Setup.transient(W.factory()))

def constructed_owners() -> Type:
  (((((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner()) & Systems.constructed_changed_owner()) & Systems.constructed_without_owner()) & Systems.constructed_with_owner())
def constructed_observe(~Out:Type,next:W.Factory -> W.World<S.Schema,S.constructed_store(),Unit,Unit> -> constructed_owners() -> List<&2,DTO.Snapshot> -> Out,factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>,label:String,operation:DTO.Operation,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>) -> Out:
  match factory:
    case W.Factory{+nextNamespace}:
      (((((Unit{},main),added),changed),without),withHealth) = owners
      registry_seen(~Systems.constructed_main_owner(),~Out,(main => snapshot_main => registry_seen(~Systems.constructed_added_owner(),~Out,(added => snapshot_added => registry_seen(~Systems.constructed_changed_owner(),~Out,(changed => snapshot_changed => registry_seen(~Systems.constructed_without_owner(),~Out,(without => snapshot_without => registry_seen(~Systems.constructed_with_owner(),~Out,(withHealth => snapshot_withHealth => world_seen(~S.constructed_store(),~Out,(world => snapshotWorld => next(W.Factory{nextNamespace},world,(((((Unit{},main),added),changed),without),withHealth),List.append(&2,DTO.Snapshot,phases,[DTO.Snapshot{label,nextNamespace,snapshotWorld,[snapshot_main,snapshot_added,snapshot_changed,snapshot_without,snapshot_withHealth],operation,descriptions}]))),Execution.constructed_world(world))),Systems.constructed_with_observe(withHealth))),Systems.constructed_without_observe(without))),Systems.constructed_changed_observe(changed))),Systems.constructed_added_observe(added))),Systems.constructed_main_observe(main))
def constructed_reject(stage:String,factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners()) -> Delivery<S.constructed_store(),constructed_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  registry_seen(~Systems.constructed_main_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(main => snapshot_main => registry_seen(~Systems.constructed_added_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(added => snapshot_added => registry_seen(~Systems.constructed_changed_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(changed => snapshot_changed => registry_seen(~Systems.constructed_without_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(without => snapshot_without => registry_seen(~Systems.constructed_with_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(withHealth => snapshot_withHealth => failed(~S.constructed_store(),~constructed_owners(),stage,factory,[snapshot_main,snapshot_added,snapshot_changed,snapshot_without,snapshot_withHealth],Execution.constructed_world(world))),Systems.constructed_with_observe(withHealth))),Systems.constructed_without_observe(without))),Systems.constructed_changed_observe(changed))),Systems.constructed_added_observe(added))),Systems.constructed_main_observe(main))
def constructed_done(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  Delivered{factory,world,owners,DTO.ScenarioReport{"constructed",phases}}
def constructed_foreign_unexpected(factory:W.Factory,original:W.World<S.Schema,S.constructed_store(),Unit,Unit>,foreign:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),operation:DTO.Operation) -> Delivery<S.constructed_store(),constructed_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  registry_seen(~Systems.constructed_main_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(main => snapshot_main => registry_seen(~Systems.constructed_added_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(added => snapshot_added => registry_seen(~Systems.constructed_changed_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(changed => snapshot_changed => registry_seen(~Systems.constructed_without_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(without => snapshot_without => registry_seen(~Systems.constructed_with_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(withHealth => snapshot_withHealth => world_seen(~S.constructed_store(),~Delivery<S.constructed_store(),constructed_owners()>,(original => originalSnapshot => failed_parts(~S.constructed_store(),~constructed_owners(),"foreign-registration-unexpected-completion",factory,[snapshot_main,snapshot_added,snapshot_changed,snapshot_without,snapshot_withHealth],[],None{},[],None{},[originalSnapshot],Some{operation},Execution.constructed_world(foreign))),Execution.constructed_world(original))),Systems.constructed_with_observe(withHealth))),Systems.constructed_without_observe(without))),Systems.constructed_changed_observe(changed))),Systems.constructed_added_observe(added))),Systems.constructed_main_observe(main))
def constructed_foreign_ran(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,otherOwners:constructed_owners(),phases:List<&2,DTO.Snapshot>,foreign:W.World<S.Schema,S.constructed_store(),Unit,Unit>,operation:DTO.Operation) -> Delivery<S.constructed_store(),constructed_owners()>:
  match operation:
    case DTO.RefusedRegistration{args,foreignWorld,registry}:constructed_observe(~Delivery<S.constructed_store(),constructed_owners()>,constructed_done,factory,world,otherOwners,phases,"foreign-registration-refusal",DTO.RefusedRegistration{args,foreignWorld,registry},[])
    case operation:constructed_foreign_unexpected(factory,world,foreign,otherOwners,operation)
def constructed_foreign_ready(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>,foreign:W.World<S.Schema,S.constructed_store(),Unit,Unit>) -> Delivery<S.constructed_store(),constructed_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.constructed_main_run_then(~Delivery<S.constructed_store(),constructed_owners()>,(foreign => main => operation => constructed_foreign_ran(factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,foreign,operation)),main,foreign,False{})
def constructed_foreign_created(world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>,created:W.Creation<S.Schema,S.constructed_store(),Unit,Unit>) -> Delivery<S.constructed_store(),constructed_owners()>:
  match created:
    case W.CreateRejected{factory,resource}:constructed_reject("foreign-world-creation-refused",factory,world,owners)
    case W.Created{factory,foreign}:
      constructed_foreign_ready(factory,world,owners,phases,foreign)
def constructed_foreign(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  constructed_foreign_created(world,owners,phases,W.create(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Setup.constructed_empty,factory,Unit{}))
def constructed_app_detached(next:W.Factory -> W.World<S.Schema,S.constructed_store(),Unit,Unit> -> constructed_owners() -> List<&2,DTO.Snapshot> -> Delivery<S.constructed_store(),constructed_owners()>,factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,phases:List<&2,DTO.Snapshot>, +debug:App.Debug,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>,app:App.Application<S.Schema,S.constructed_store(),Unit,Unit,constructed_owners()>) -> Delivery<S.constructed_store(),constructed_owners()>:
  match debug:
    case App.Enabled{}:
      match app:
        case App.Application{_,_,SP.Provisioned{Sch.Schedule{_,_,_,owners},_}}:constructed_observe(~Delivery<S.constructed_store(),constructed_owners()>,next,factory,world,owners,phases,"app-enabled-descriptions",DTO.Observed{},descriptions)
    case App.Disabled{}:
      match app:
        case App.Application{_,_,SP.Provisioned{Sch.Schedule{_,_,_,owners},_}}:constructed_observe(~Delivery<S.constructed_store(),constructed_owners()>,next,factory,world,owners,phases,"app-disabled-description",DTO.Observed{},descriptions)

def constructed_app_described_twice(next:W.Factory -> W.World<S.Schema,S.constructed_store(),Unit,Unit> -> constructed_owners() -> List<&2,DTO.Snapshot> -> Delivery<S.constructed_store(),constructed_owners()>,factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,phases:List<&2,DTO.Snapshot>,first:Maybe<&2,App.Description<S.Schema>>,observed:App.Application<S.Schema,S.constructed_store(),Unit,Unit,constructed_owners()> & Maybe<&2,App.Description<S.Schema>>) -> Delivery<S.constructed_store(),constructed_owners()>:
  match observed:
    case (app,second):constructed_app_detached(next,factory,world,phases,App.Enabled{},[first,second],app)
def constructed_app_described(next:W.Factory -> W.World<S.Schema,S.constructed_store(),Unit,Unit> -> constructed_owners() -> List<&2,DTO.Snapshot> -> Delivery<S.constructed_store(),constructed_owners()>,factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,phases:List<&2,DTO.Snapshot>, +debug:App.Debug,observed:App.Application<S.Schema,S.constructed_store(),Unit,Unit,constructed_owners()> & Maybe<&2,App.Description<S.Schema>>) -> Delivery<S.constructed_store(),constructed_owners()>:
  match debug:
    case App.Disabled{}:
      match observed:
        case (app,first):constructed_app_detached(next,factory,world,phases,App.Disabled{},[first],app)
    case App.Enabled{}:
      match observed:
        case (app,first):constructed_app_described_twice(next,factory,world,phases,first,App.describe(~S.Schema,~S.constructed_store(),~Unit,~Unit,~constructed_owners(),app))

def constructed_app_built(next:W.Factory -> W.World<S.Schema,S.constructed_store(),Unit,Unit> -> constructed_owners() -> List<&2,DTO.Snapshot> -> Delivery<S.constructed_store(),constructed_owners()>,factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,phases:List<&2,DTO.Snapshot>, +debug:App.Debug,result:App.Built<S.Schema,S.constructed_store(),Unit,Unit,constructed_owners()>) -> Delivery<S.constructed_store(),constructed_owners()>:
  match result:
    case App.Invalid{owners}:constructed_reject("app-build-refused",factory,world,owners)
    case App.Built{app}:constructed_app_described(next,factory,world,phases,debug,App.describe(~S.Schema,~S.constructed_store(),~Unit,~Unit,~constructed_owners(),app))
def constructed_app_main_seen(next:W.Factory -> W.World<S.Schema,S.constructed_store(),Unit,Unit> -> constructed_owners() -> List<&2,DTO.Snapshot> -> Delivery<S.constructed_store(),constructed_owners()>,factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,others:((((Unit & Systems.constructed_added_owner()) & Systems.constructed_changed_owner()) & Systems.constructed_without_owner()) & Systems.constructed_with_owner()),phases:List<&2,DTO.Snapshot>, +debug:App.Debug,observed:Systems.constructed_main_owner() & DTO.RegistrySnapshot) -> Delivery<S.constructed_store(),constructed_owners()>:
  ((((Unit{},added),changed),without),withHealth) = others
  (main,mainSnapshot) = observed
  collected = App.empty(~S.Schema,registry_namespace(mainSnapshot),debug)
  collected = App.add(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Body.Ops,~Bool,~Unit,~DTO.RowValues,~Queries.constructed_base(),~(H => caps => fail => owner => Body.body(~H,~caps,fail,owner)),~Unit,collected,main)
  collected = App.add(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.constructed_base_added(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~(Unit & Systems.constructed_main_owner()),collected,added)
  collected = App.add(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.constructed_base_changed(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner()),collected,changed)
  collected = App.add(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.constructed_base_without_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~(((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner()) & Systems.constructed_changed_owner()),collected,without)
  collected = App.add(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.constructed_base_with_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~((((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner()) & Systems.constructed_changed_owner()) & Systems.constructed_without_owner()),collected,withHealth)
  constructed_app_built(next,factory,world,phases,debug,App.build(~S.Schema,~S.constructed_store(),~Unit,~Unit,~constructed_owners(),"Update",SP.Sequence{SP.Entry{Sch.Phase{"Update"},[]},SP.Sequence{SP.Entry{Sch.System{1,0},[]},SP.Sequence{SP.Entry{Sch.System{2,0},[]},SP.Sequence{SP.Entry{Sch.System{3,0},[]},SP.Sequence{SP.Entry{Sch.System{4,0},[]},SP.Sequence{SP.Entry{Sch.System{5,0},[]},SP.Entry{Sch.Barrier{},[]}}}}}}},collected))
def constructed_app_collect(next:W.Factory -> W.World<S.Schema,S.constructed_store(),Unit,Unit> -> constructed_owners() -> List<&2,DTO.Snapshot> -> Delivery<S.constructed_store(),constructed_owners()>,factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>, +debug:App.Debug) -> Delivery<S.constructed_store(),constructed_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  constructed_app_main_seen(next,factory,world,((((Unit{},added),changed),without),withHealth),phases,debug,Systems.constructed_main_observe(main))
def constructed_app_disabled(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  constructed_app_collect(constructed_foreign,factory,world,owners,phases,App.Disabled{})
def constructed_app_enabled(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  constructed_app_collect(constructed_app_disabled,factory,world,owners,phases,App.Enabled{})
def constructed_with_health(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.constructed_with_run_then(~Delivery<S.constructed_store(),constructed_owners()>,(world => withHealth => operation => constructed_observe(~Delivery<S.constructed_store(),constructed_owners()>,constructed_app_enabled,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"with-health",operation,[])),withHealth,world,False{})
def constructed_without_health(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.constructed_without_run_then(~Delivery<S.constructed_store(),constructed_owners()>,(world => without => operation => constructed_observe(~Delivery<S.constructed_store(),constructed_owners()>,constructed_with_health,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"without-health",operation,[])),without,world,False{})
def constructed_changed_empty(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.constructed_changed_run_then(~Delivery<S.constructed_store(),constructed_owners()>,(world => changed => operation => constructed_observe(~Delivery<S.constructed_store(),constructed_owners()>,constructed_without_health,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"changed-empty",operation,[])),changed,world,False{})
def constructed_changed_first(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.constructed_changed_run_then(~Delivery<S.constructed_store(),constructed_owners()>,(world => changed => operation => constructed_observe(~Delivery<S.constructed_store(),constructed_owners()>,constructed_changed_empty,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"changed-first",operation,[])),changed,world,False{})
def constructed_position_replaced(factory:W.Factory,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>,result:Cmp.Replacement<W.World<S.Schema,S.constructed_store(),Unit,Unit>,Array<U32>>) -> Delivery<S.constructed_store(),constructed_owners()>:
  match result:
    case Cmp.Replaced{world,previous}:constructed_observe(~Delivery<S.constructed_store(),constructed_owners()>,constructed_changed_first,factory,world,owners,phases,"position-e2-replace",DTO.PositionReplaced{W.Accepted{}},[])
    case Cmp.ReplaceRejected{world,incoming,error}:constructed_observe(~Delivery<S.constructed_store(),constructed_owners()>,constructed_changed_first,factory,world,owners,phases,"position-e2-replace",DTO.PositionReplaced{W.Rejected{error}},[])
def constructed_position_named(factory:W.Factory,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>,observed:W.World<S.Schema,S.constructed_store(),Unit,Unit> & List<&2,W.Handle<S.Schema>>) -> Delivery<S.constructed_store(),constructed_owners()>:
  match observed:
    case (world,_ <> (handle <> (_ <> []))):constructed_position_replaced(factory,owners,phases,Cmp.replace(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Queries.constructed_position_rest(),~Array<U32>,~View.FullCell,~Unit,~Queries.constructed_position_take,~Queries.constructed_position_put,~View.view,Cmp.Family{Identity.key(~S.Schema,~Array<U32>,S.identity("Position"))},world,handle,Some{Setup.payload(5,102)}))
    case (world,_):constructed_reject("position-handle-shape",factory,world,owners)

def constructed_position_replace(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  constructed_position_named(factory,owners,phases,W.handles(~S.Schema,~S.constructed_store(),~Unit,~Unit,world))
def constructed_added_empty(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.constructed_added_run_then(~Delivery<S.constructed_store(),constructed_owners()>,(world => added => operation => constructed_observe(~Delivery<S.constructed_store(),constructed_owners()>,constructed_position_replace,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"added-empty",operation,[])),added,world,False{})
def constructed_added_first(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.constructed_added_run_then(~Delivery<S.constructed_store(),constructed_owners()>,(world => added => operation => constructed_observe(~Delivery<S.constructed_store(),constructed_owners()>,constructed_added_empty,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"added-first",operation,[])),added,world,False{})
def constructed_main_second(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.constructed_main_run_then(~Delivery<S.constructed_store(),constructed_owners()>,(world => main => operation => constructed_observe(~Delivery<S.constructed_store(),constructed_owners()>,constructed_added_first,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"main-second",operation,[])),main,world,False{})
def constructed_main_retry(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.constructed_main_run_then(~Delivery<S.constructed_store(),constructed_owners()>,(world => main => operation => constructed_observe(~Delivery<S.constructed_store(),constructed_owners()>,constructed_main_second,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"main-retry",operation,[])),main,world,False{})
def constructed_main_fail(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  (((((Unit{},main),added),changed),without),withHealth) = owners
  Execution.constructed_main_run_then(~Delivery<S.constructed_store(),constructed_owners()>,(world => main => operation => constructed_observe(~Delivery<S.constructed_store(),constructed_owners()>,constructed_main_retry,factory,world,(((((Unit{},main),added),changed),without),withHealth),phases,"main-fail",operation,[])),main,world,True{})
def constructed_registered(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:constructed_owners(),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  constructed_observe(~Delivery<S.constructed_store(),constructed_owners()>,constructed_main_fail,factory,world,owners,phases,"register",DTO.Observed{},[])
def constructed_register_failed_4(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,previous:((((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner()) & Systems.constructed_changed_owner()) & Systems.constructed_without_owner())) -> Delivery<S.constructed_store(),constructed_owners()>:
  ((((Unit{},main),added),changed),without) = previous
  registry_seen(~Systems.constructed_main_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(main => snapshot_main => registry_seen(~Systems.constructed_added_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(added => snapshot_added => registry_seen(~Systems.constructed_changed_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(changed => snapshot_changed => registry_seen(~Systems.constructed_without_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(without => snapshot_without => failed(~S.constructed_store(),~constructed_owners(),"register-with-refused",factory,[snapshot_main,snapshot_added,snapshot_changed,snapshot_without],Execution.constructed_world(world))),Systems.constructed_without_observe(without))),Systems.constructed_changed_observe(changed))),Systems.constructed_added_observe(added))),Systems.constructed_main_observe(main))
def constructed_defined_4(factory:W.Factory,previous:((((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner()) & Systems.constructed_changed_owner()) & Systems.constructed_without_owner()),phases:List<&2,DTO.Snapshot>,result:System.Defined<S.Schema,W.World<S.Schema,S.constructed_store(),Unit,Unit>,Systems.constructed_with_registry()>) -> Delivery<S.constructed_store(),constructed_owners()>:
  match result:
    case System.Defined{world,owner}:constructed_registered(factory,world,(previous,owner),phases)
    case System.Rejected{world}:constructed_register_failed_4(factory,world,previous)
def constructed_register_4(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,previous:((((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner()) & Systems.constructed_changed_owner()) & Systems.constructed_without_owner()),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  constructed_defined_4(factory,previous,phases,Systems.constructed_with_define(world))
def constructed_register_failed_3(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,previous:(((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner()) & Systems.constructed_changed_owner())) -> Delivery<S.constructed_store(),constructed_owners()>:
  (((Unit{},main),added),changed) = previous
  registry_seen(~Systems.constructed_main_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(main => snapshot_main => registry_seen(~Systems.constructed_added_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(added => snapshot_added => registry_seen(~Systems.constructed_changed_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(changed => snapshot_changed => failed(~S.constructed_store(),~constructed_owners(),"register-without-refused",factory,[snapshot_main,snapshot_added,snapshot_changed],Execution.constructed_world(world))),Systems.constructed_changed_observe(changed))),Systems.constructed_added_observe(added))),Systems.constructed_main_observe(main))
def constructed_defined_3(factory:W.Factory,previous:(((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner()) & Systems.constructed_changed_owner()),phases:List<&2,DTO.Snapshot>,result:System.Defined<S.Schema,W.World<S.Schema,S.constructed_store(),Unit,Unit>,Systems.constructed_without_registry()>) -> Delivery<S.constructed_store(),constructed_owners()>:
  match result:
    case System.Defined{world,owner}:constructed_register_4(factory,world,(previous,owner),phases)
    case System.Rejected{world}:constructed_register_failed_3(factory,world,previous)
def constructed_register_3(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,previous:(((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner()) & Systems.constructed_changed_owner()),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  constructed_defined_3(factory,previous,phases,Systems.constructed_without_define(world))
def constructed_register_failed_2(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,previous:((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner())) -> Delivery<S.constructed_store(),constructed_owners()>:
  ((Unit{},main),added) = previous
  registry_seen(~Systems.constructed_main_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(main => snapshot_main => registry_seen(~Systems.constructed_added_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(added => snapshot_added => failed(~S.constructed_store(),~constructed_owners(),"register-changed-refused",factory,[snapshot_main,snapshot_added],Execution.constructed_world(world))),Systems.constructed_added_observe(added))),Systems.constructed_main_observe(main))
def constructed_defined_2(factory:W.Factory,previous:((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner()),phases:List<&2,DTO.Snapshot>,result:System.Defined<S.Schema,W.World<S.Schema,S.constructed_store(),Unit,Unit>,Systems.constructed_changed_registry()>) -> Delivery<S.constructed_store(),constructed_owners()>:
  match result:
    case System.Defined{world,owner}:constructed_register_3(factory,world,(previous,owner),phases)
    case System.Rejected{world}:constructed_register_failed_2(factory,world,previous)
def constructed_register_2(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,previous:((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner()),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  constructed_defined_2(factory,previous,phases,Systems.constructed_changed_define(world))
def constructed_register_failed_1(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,previous:(Unit & Systems.constructed_main_owner())) -> Delivery<S.constructed_store(),constructed_owners()>:
  (Unit{},main) = previous
  registry_seen(~Systems.constructed_main_owner(),~Delivery<S.constructed_store(),constructed_owners()>,(main => snapshot_main => failed(~S.constructed_store(),~constructed_owners(),"register-added-refused",factory,[snapshot_main],Execution.constructed_world(world))),Systems.constructed_main_observe(main))
def constructed_defined_1(factory:W.Factory,previous:(Unit & Systems.constructed_main_owner()),phases:List<&2,DTO.Snapshot>,result:System.Defined<S.Schema,W.World<S.Schema,S.constructed_store(),Unit,Unit>,Systems.constructed_added_registry()>) -> Delivery<S.constructed_store(),constructed_owners()>:
  match result:
    case System.Defined{world,owner}:constructed_register_2(factory,world,(previous,owner),phases)
    case System.Rejected{world}:constructed_register_failed_1(factory,world,previous)
def constructed_register_1(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,previous:(Unit & Systems.constructed_main_owner()),phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  constructed_defined_1(factory,previous,phases,Systems.constructed_added_define(world))
def constructed_register_failed_0(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,previous:Unit) -> Delivery<S.constructed_store(),constructed_owners()>:
  Unit{} = previous
  failed(~S.constructed_store(),~constructed_owners(),"register-main-refused",factory,[],Execution.constructed_world(world))
def constructed_defined_0(factory:W.Factory,previous:Unit,phases:List<&2,DTO.Snapshot>,result:System.Defined<S.Schema,W.World<S.Schema,S.constructed_store(),Unit,Unit>,Systems.constructed_main_registry()>) -> Delivery<S.constructed_store(),constructed_owners()>:
  match result:
    case System.Defined{world,owner}:constructed_register_1(factory,world,(previous,owner),phases)
    case System.Rejected{world}:constructed_register_failed_0(factory,world,previous)
def constructed_register_0(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,previous:Unit,phases:List<&2,DTO.Snapshot>) -> Delivery<S.constructed_store(),constructed_owners()>:
  constructed_defined_0(factory,previous,phases,Systems.constructed_main_define(world))
def constructed_seed_seen(factory:W.Factory,observed:W.World<S.Schema,S.constructed_store(),Unit,Unit> & DTO.WorldSnapshot) -> Delivery<S.constructed_store(),constructed_owners()>:
  match factory:
    case W.Factory{+nextNamespace}:
      match observed:
        case (world,snapshot):constructed_register_0(W.Factory{nextNamespace},world,Unit{},[DTO.Snapshot{"seed",nextNamespace,snapshot,[],DTO.Observed{},[]}])
def constructed_seed_previous_checked(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>,values:List<&2,Maybe<&2,View.FullCell>>,accepted:Bool) -> Delivery<S.constructed_store(),constructed_owners()>:
  match accepted:
    case True{}:constructed_seed_seen(factory,Execution.constructed_world(world))
    case False{}:failed_parts(~S.constructed_store(),~constructed_owners(),"seed-previous-unexpected",factory,[],handles,None{},values,None{},[],None{},Execution.constructed_world(world))
def constructed_seed_previous_decide(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>,+values:List<&2,Maybe<&2,View.FullCell>>) -> Delivery<S.constructed_store(),constructed_owners()>:
  constructed_seed_previous_checked(factory,world,handles,previous,values,Returned.all_none(7n,values))
def constructed_seed_previous(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Delivery<S.constructed_store(),constructed_owners()>:
  previous_seen(~Delivery<S.constructed_store(),constructed_owners()>,(previous => values => constructed_seed_previous_decide(factory,world,handles,previous,values)),Returned.owners(previous))
def constructed_seed_replace_failed(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>,incoming:Maybe<&1,Array<U32>>,error:W.WorldError) -> Delivery<S.constructed_store(),constructed_owners()>:
  previous_seen(~Delivery<S.constructed_store(),constructed_owners()>,(previous => values => incoming_seen(~Delivery<S.constructed_store(),constructed_owners()>,(incoming => incomingValue => failed_parts(~S.constructed_store(),~constructed_owners(),"seed-replace-refused",factory,[],handles,Some{error},values,incomingValue,[],None{},Execution.constructed_world(world))),Returned.owner(incoming))),Returned.owners(previous))
def constructed_seeded(result:Setup.Seed<S.constructed_store()>) -> Delivery<S.constructed_store(),constructed_owners()>:
  match result:
    case Setup.Seeded{factory,world,handles,previous}:constructed_seed_previous(factory,world,handles,previous)
    case Setup.CreateRefused{W.Factory{nextNamespace},resource}:Rejected{Failure{"seed-create-refused",nextNamespace,None{},[],[],None{},[],None{},[],None{}}}
    case Setup.AllocationShapeRefused{factory,world,handles}:failed_parts(~S.constructed_store(),~constructed_owners(),"seed-allocation-shape",factory,[],handles,None{},[],None{},[],None{},Execution.constructed_world(world))
    case Setup.ReserveRefused{factory,world,handles,error}:failed_parts(~S.constructed_store(),~constructed_owners(),"seed-reserve-refused",factory,[],handles,Some{error},[],None{},[],None{},Execution.constructed_world(world))
    case Setup.ActivateRefused{factory,world,handles,error}:failed_parts(~S.constructed_store(),~constructed_owners(),"seed-activate-refused",factory,[],handles,Some{error},[],None{},[],None{},Execution.constructed_world(world))
    case Setup.ReplaceRefused{factory,world,handles,previous,incoming,error}:constructed_seed_replace_failed(factory,world,handles,previous,incoming,error)
def constructed() -> Delivery<S.constructed_store(),constructed_owners()>:
  constructed_seeded(Setup.constructed(W.factory()))
