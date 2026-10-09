import Base
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/ordinary-schema.bend as Normal
import ../scenario-schema.bend as S
import ../scenario-driver.bend as Driver
import ../scenario-systems.bend as Systems
import ../scenario-queries.bend as Queries
import ../scenario-body.bend as Body
import ../scenario-dto.bend as DTO
import ./app.bend as Ordinary
import ./retained-schema.bend as Schema
import ../app-run-v1/nominal-carrier-v1/accumulated-v1/dispatch.bend as Dispatch
import ../app-run-v1/nominal-carrier-v1/accumulated-v1/application.bend as Plan
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def plain_augment(collected:Ordinary.Owners<S.Schema,S.plain_store(),Unit,Driver.plain_owners()>,trace:Dispatch.Trace) -> Ordinary.Owners<S.Schema,S.plain_store(),Unit,Dispatch.Plain>:
  match collected:
    case Ordinary.Owners{schema,debug,namespace,bindings,owners,valid}:Ordinary.Owners{schema,debug,namespace,bindings,Dispatch.plain_pack((owners,trace)),valid}
def plain_main_seen(schema:Normal.Schema<S.Schema,S.plain_store(),Unit>,others:((((Unit & Systems.plain_added_owner()) & Systems.plain_changed_owner()) & Systems.plain_without_owner()) & Systems.plain_with_owner()),debug:Ordinary.Debug,trace:Dispatch.Trace,observed:Systems.plain_main_owner() & DTO.RegistrySnapshot) -> Ordinary.Built<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>:
  ((((Unit{},added),changed),without),withHealth) = others
  (main,mainSnapshot) = observed
  collected = Ordinary.empty(~S.Schema,~S.plain_store(),~Unit,Driver.registry_namespace(mainSnapshot),debug,schema)
  collected = Ordinary.add(~S.Schema,~S.plain_store(),~Unit,~Unit,~Body.Ops,~Bool,~Unit,~DTO.RowValues,~Queries.plain_base(),~(H => caps => fail => owner => Body.body(~H,~caps,fail,owner)),~Unit,collected,main)
  collected = Ordinary.add(~S.Schema,~S.plain_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.plain_base_added(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~(Unit & Systems.plain_main_owner()),collected,added)
  collected = Ordinary.add(~S.Schema,~S.plain_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.plain_base_changed(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner()),collected,changed)
  collected = Ordinary.add(~S.Schema,~S.plain_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.plain_base_without_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~(((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner()) & Systems.plain_changed_owner()),collected,without)
  collected = Ordinary.add(~S.Schema,~S.plain_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.plain_base_with_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~((((Unit & Systems.plain_main_owner()) & Systems.plain_added_owner()) & Systems.plain_changed_owner()) & Systems.plain_without_owner()),collected,withHealth)
  Ordinary.build(~S.Schema,~S.plain_store(),~Unit,~Unit,~Dispatch.plain_owners(),"Update",Plan.plan(),plain_augment(collected,trace))
def plain(schema:Normal.Schema<S.Schema,S.plain_store(),Unit>,owners:Dispatch.Plain,debug:Ordinary.Debug) -> Ordinary.Built<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>:
  match owners:
    case Dispatch.Plain{main,added,changed,without,withHealth,trace}:plain_main_seen(schema,((((Unit{},added),changed),without),withHealth),debug,trace,Systems.plain_main_observe(main))
def transient_augment(collected:Ordinary.Owners<S.Schema,S.transient_store(),Unit,Driver.transient_owners()>,trace:Dispatch.Trace) -> Ordinary.Owners<S.Schema,S.transient_store(),Unit,Dispatch.Transient>:
  match collected:
    case Ordinary.Owners{schema,debug,namespace,bindings,owners,valid}:Ordinary.Owners{schema,debug,namespace,bindings,Dispatch.transient_pack((owners,trace)),valid}
def transient_main_seen(schema:Normal.Schema<S.Schema,S.transient_store(),Unit>,others:((((Unit & Systems.transient_added_owner()) & Systems.transient_changed_owner()) & Systems.transient_without_owner()) & Systems.transient_with_owner()),debug:Ordinary.Debug,trace:Dispatch.Trace,observed:Systems.transient_main_owner() & DTO.RegistrySnapshot) -> Ordinary.Built<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>:
  ((((Unit{},added),changed),without),withHealth) = others
  (main,mainSnapshot) = observed
  collected = Ordinary.empty(~S.Schema,~S.transient_store(),~Unit,Driver.registry_namespace(mainSnapshot),debug,schema)
  collected = Ordinary.add(~S.Schema,~S.transient_store(),~Unit,~Unit,~Body.Ops,~Bool,~Unit,~DTO.RowValues,~Queries.transient_base(),~(H => caps => fail => owner => Body.body(~H,~caps,fail,owner)),~Unit,collected,main)
  collected = Ordinary.add(~S.Schema,~S.transient_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.transient_base_added(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~(Unit & Systems.transient_main_owner()),collected,added)
  collected = Ordinary.add(~S.Schema,~S.transient_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.transient_base_changed(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner()),collected,changed)
  collected = Ordinary.add(~S.Schema,~S.transient_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.transient_base_without_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~(((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner()) & Systems.transient_changed_owner()),collected,without)
  collected = Ordinary.add(~S.Schema,~S.transient_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.transient_base_with_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~((((Unit & Systems.transient_main_owner()) & Systems.transient_added_owner()) & Systems.transient_changed_owner()) & Systems.transient_without_owner()),collected,withHealth)
  Ordinary.build(~S.Schema,~S.transient_store(),~Unit,~Unit,~Dispatch.transient_owners(),"Update",Plan.plan(),transient_augment(collected,trace))
def transient(schema:Normal.Schema<S.Schema,S.transient_store(),Unit>,owners:Dispatch.Transient,debug:Ordinary.Debug) -> Ordinary.Built<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>:
  match owners:
    case Dispatch.Transient{main,added,changed,without,withHealth,trace}:transient_main_seen(schema,((((Unit{},added),changed),without),withHealth),debug,trace,Systems.transient_main_observe(main))
def constructed_augment(collected:Ordinary.Owners<S.Schema,S.constructed_store(),Unit,Driver.constructed_owners()>,trace:Dispatch.Trace) -> Ordinary.Owners<S.Schema,S.constructed_store(),Unit,Dispatch.Constructed>:
  match collected:
    case Ordinary.Owners{schema,debug,namespace,bindings,owners,valid}:Ordinary.Owners{schema,debug,namespace,bindings,Dispatch.constructed_pack((owners,trace)),valid}
def constructed_main_seen(schema:Normal.Schema<S.Schema,S.constructed_store(),Unit>,others:((((Unit & Systems.constructed_added_owner()) & Systems.constructed_changed_owner()) & Systems.constructed_without_owner()) & Systems.constructed_with_owner()),debug:Ordinary.Debug,trace:Dispatch.Trace,observed:Systems.constructed_main_owner() & DTO.RegistrySnapshot) -> Ordinary.Built<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>:
  ((((Unit{},added),changed),without),withHealth) = others
  (main,mainSnapshot) = observed
  collected = Ordinary.empty(~S.Schema,~S.constructed_store(),~Unit,Driver.registry_namespace(mainSnapshot),debug,schema)
  collected = Ordinary.add(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Body.Ops,~Bool,~Unit,~DTO.RowValues,~Queries.constructed_base(),~(H => caps => fail => owner => Body.body(~H,~caps,fail,owner)),~Unit,collected,main)
  collected = Ordinary.add(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.constructed_base_added(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~(Unit & Systems.constructed_main_owner()),collected,added)
  collected = Ordinary.add(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.constructed_base_changed(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner()),collected,changed)
  collected = Ordinary.add(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.constructed_base_without_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~(((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner()) & Systems.constructed_changed_owner()),collected,without)
  collected = Ordinary.add(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Body.FilterOps,~Bool,~Unit,~DTO.RowValues,~Queries.constructed_base_with_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),~((((Unit & Systems.constructed_main_owner()) & Systems.constructed_added_owner()) & Systems.constructed_changed_owner()) & Systems.constructed_without_owner()),collected,withHealth)
  Ordinary.build(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Dispatch.constructed_owners(),"Update",Plan.plan(),constructed_augment(collected,trace))
def constructed(schema:Normal.Schema<S.Schema,S.constructed_store(),Unit>,owners:Dispatch.Constructed,debug:Ordinary.Debug) -> Ordinary.Built<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>:
  match owners:
    case Dispatch.Constructed{main,added,changed,without,withHealth,trace}:constructed_main_seen(schema,((((Unit{},added),changed),without),withHealth),debug,trace,Systems.constructed_main_observe(main))
