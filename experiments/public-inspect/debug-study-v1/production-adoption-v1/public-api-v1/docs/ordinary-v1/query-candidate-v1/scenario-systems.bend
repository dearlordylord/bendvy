import Base
import ./scenario-schema.bend as S
import ./scenario-queries.bend as Queries
import ./scenario-body.bend as Body
import ./scenario-dto.bend as DTO
import ./declaration.bend as Query
import ./system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T

def registry(~C:Type,~Ops:Type -> Type,~slot:Query.Declaration<S.Schema,Q.Frame<S.Schema,C,Unit,Unit>,Ops(Q.Frame<S.Schema,C,Unit,Unit>)>,~body:@-H:Type -> @-caps:Ops(H) -> Bool -> H -> H & (T.Outcome<Unit> & DTO.RowValues)) -> Type:
  Sys.Registry<S.Schema,C,Unit,Unit,Bool & U32,Q.Error<Unit>,List<&2,DTO.RowValues>,System.runner(~S.Schema,~C,~Unit,~Unit,~Ops,~Bool,~Unit,~DTO.RowValues,~slot,~body)>
def observe(~C:Type,~Ops:Type -> Type,~slot:Query.Declaration<S.Schema,Q.Frame<S.Schema,C,Unit,Unit>,Ops(Q.Frame<S.Schema,C,Unit,Unit>)>,~body:@-H:Type -> @-caps:Ops(H) -> Bool -> H -> H & (T.Outcome<Unit> & DTO.RowValues),owner:System.Owner<S.Schema,registry(~C,~Ops,~slot,~body)>) -> System.Owner<S.Schema,registry(~C,~Ops,~slot,~body)> & DTO.RegistrySnapshot:
  match owner:
    case System.Owner{Sys.Registry{+namespace,+id,+name,+access,+cursor},+nameSlot,+clauses}:
      (System.Owner{Sys.Registry{namespace,id,name,access,cursor},nameSlot,clauses},DTO.RegistrySnapshot{namespace,id,name,access,cursor,nameSlot,clauses})
def define(~C:Type,~Ops:Type -> Type,~slot:Query.Declaration<S.Schema,Q.Frame<S.Schema,C,Unit,Unit>,Ops(Q.Frame<S.Schema,C,Unit,Unit>)>,~body:@-H:Type -> @-caps:Ops(H) -> Bool -> H -> H & (T.Outcome<Unit> & DTO.RowValues),world:W.World<S.Schema,C,Unit,Unit>,name:String) -> System.Defined<S.Schema,W.World<S.Schema,C,Unit,Unit>,registry(~C,~Ops,~slot,~body)>:
  System.define(~S.Schema,~C,~Unit,~Unit,~Ops,~Bool,~Unit,~DTO.RowValues,~slot,~body,world,name,"entities")
def run(~C:Type,~Ops:Type -> Type,~slot:Query.Declaration<S.Schema,Q.Frame<S.Schema,C,Unit,Unit>,Ops(Q.Frame<S.Schema,C,Unit,Unit>)>,~body:@-H:Type -> @-caps:Ops(H) -> Bool -> H -> H & (T.Outcome<Unit> & DTO.RowValues),owner:System.Owner<S.Schema,registry(~C,~Ops,~slot,~body)>,world:W.World<S.Schema,C,Unit,Unit>,fail:Bool) -> Sys.RunResult<S.Schema,C,Unit,Unit,Bool & U32,Q.Error<Unit>,List<&2,DTO.RowValues>,System.runner(~S.Schema,~C,~Unit,~Unit,~Ops,~Bool,~Unit,~DTO.RowValues,~slot,~body)> & (String & List<&2,Query.Clause<S.Schema>>):
  System.run(~S.Schema,~C,~Unit,~Unit,~Ops,~Bool,~Unit,~DTO.RowValues,~slot,~body,owner,world,fail)

def plain_main_registry() -> Type:
  registry(~S.plain_store(),~Body.Ops,~Queries.plain_base(),~(H => caps => fail => owner => Body.body(~H,~caps,fail,owner)))
def plain_main_owner() -> Type:
  System.Owner<S.Schema,plain_main_registry()>
def plain_main_define(world:W.World<S.Schema,S.plain_store(),Unit,Unit>) -> System.Defined<S.Schema,W.World<S.Schema,S.plain_store(),Unit,Unit>,plain_main_registry()>:
  define(~S.plain_store(),~Body.Ops,~Queries.plain_base(),~(H => caps => fail => owner => Body.body(~H,~caps,fail,owner)),world,"main")
def plain_main_observe(owner:plain_main_owner()) -> plain_main_owner() & DTO.RegistrySnapshot:
  observe(~S.plain_store(),~Body.Ops,~Queries.plain_base(),~(H => caps => fail => owner => Body.body(~H,~caps,fail,owner)),owner)

def plain_added_registry() -> Type:
  registry(~S.plain_store(),~Body.FilterOps,~Queries.plain_base_added(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)))
def plain_added_owner() -> Type:
  System.Owner<S.Schema,plain_added_registry()>
def plain_added_define(world:W.World<S.Schema,S.plain_store(),Unit,Unit>) -> System.Defined<S.Schema,W.World<S.Schema,S.plain_store(),Unit,Unit>,plain_added_registry()>:
  define(~S.plain_store(),~Body.FilterOps,~Queries.plain_base_added(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),world,"added")
def plain_added_observe(owner:plain_added_owner()) -> plain_added_owner() & DTO.RegistrySnapshot:
  observe(~S.plain_store(),~Body.FilterOps,~Queries.plain_base_added(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),owner)

def plain_changed_registry() -> Type:
  registry(~S.plain_store(),~Body.FilterOps,~Queries.plain_base_changed(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)))
def plain_changed_owner() -> Type:
  System.Owner<S.Schema,plain_changed_registry()>
def plain_changed_define(world:W.World<S.Schema,S.plain_store(),Unit,Unit>) -> System.Defined<S.Schema,W.World<S.Schema,S.plain_store(),Unit,Unit>,plain_changed_registry()>:
  define(~S.plain_store(),~Body.FilterOps,~Queries.plain_base_changed(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),world,"changed")
def plain_changed_observe(owner:plain_changed_owner()) -> plain_changed_owner() & DTO.RegistrySnapshot:
  observe(~S.plain_store(),~Body.FilterOps,~Queries.plain_base_changed(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),owner)

def plain_without_registry() -> Type:
  registry(~S.plain_store(),~Body.FilterOps,~Queries.plain_base_without_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)))
def plain_without_owner() -> Type:
  System.Owner<S.Schema,plain_without_registry()>
def plain_without_define(world:W.World<S.Schema,S.plain_store(),Unit,Unit>) -> System.Defined<S.Schema,W.World<S.Schema,S.plain_store(),Unit,Unit>,plain_without_registry()>:
  define(~S.plain_store(),~Body.FilterOps,~Queries.plain_base_without_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),world,"withoutHealth")
def plain_without_observe(owner:plain_without_owner()) -> plain_without_owner() & DTO.RegistrySnapshot:
  observe(~S.plain_store(),~Body.FilterOps,~Queries.plain_base_without_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),owner)

def plain_with_registry() -> Type:
  registry(~S.plain_store(),~Body.FilterOps,~Queries.plain_base_with_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)))
def plain_with_owner() -> Type:
  System.Owner<S.Schema,plain_with_registry()>
def plain_with_define(world:W.World<S.Schema,S.plain_store(),Unit,Unit>) -> System.Defined<S.Schema,W.World<S.Schema,S.plain_store(),Unit,Unit>,plain_with_registry()>:
  define(~S.plain_store(),~Body.FilterOps,~Queries.plain_base_with_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),world,"withHealth")
def plain_with_observe(owner:plain_with_owner()) -> plain_with_owner() & DTO.RegistrySnapshot:
  observe(~S.plain_store(),~Body.FilterOps,~Queries.plain_base_with_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),owner)

def transient_main_registry() -> Type:
  registry(~S.transient_store(),~Body.Ops,~Queries.transient_base(),~(H => caps => fail => owner => Body.body(~H,~caps,fail,owner)))
def transient_main_owner() -> Type:
  System.Owner<S.Schema,transient_main_registry()>
def transient_main_define(world:W.World<S.Schema,S.transient_store(),Unit,Unit>) -> System.Defined<S.Schema,W.World<S.Schema,S.transient_store(),Unit,Unit>,transient_main_registry()>:
  define(~S.transient_store(),~Body.Ops,~Queries.transient_base(),~(H => caps => fail => owner => Body.body(~H,~caps,fail,owner)),world,"main")
def transient_main_observe(owner:transient_main_owner()) -> transient_main_owner() & DTO.RegistrySnapshot:
  observe(~S.transient_store(),~Body.Ops,~Queries.transient_base(),~(H => caps => fail => owner => Body.body(~H,~caps,fail,owner)),owner)

def transient_added_registry() -> Type:
  registry(~S.transient_store(),~Body.FilterOps,~Queries.transient_base_added(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)))
def transient_added_owner() -> Type:
  System.Owner<S.Schema,transient_added_registry()>
def transient_added_define(world:W.World<S.Schema,S.transient_store(),Unit,Unit>) -> System.Defined<S.Schema,W.World<S.Schema,S.transient_store(),Unit,Unit>,transient_added_registry()>:
  define(~S.transient_store(),~Body.FilterOps,~Queries.transient_base_added(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),world,"added")
def transient_added_observe(owner:transient_added_owner()) -> transient_added_owner() & DTO.RegistrySnapshot:
  observe(~S.transient_store(),~Body.FilterOps,~Queries.transient_base_added(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),owner)

def transient_changed_registry() -> Type:
  registry(~S.transient_store(),~Body.FilterOps,~Queries.transient_base_changed(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)))
def transient_changed_owner() -> Type:
  System.Owner<S.Schema,transient_changed_registry()>
def transient_changed_define(world:W.World<S.Schema,S.transient_store(),Unit,Unit>) -> System.Defined<S.Schema,W.World<S.Schema,S.transient_store(),Unit,Unit>,transient_changed_registry()>:
  define(~S.transient_store(),~Body.FilterOps,~Queries.transient_base_changed(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),world,"changed")
def transient_changed_observe(owner:transient_changed_owner()) -> transient_changed_owner() & DTO.RegistrySnapshot:
  observe(~S.transient_store(),~Body.FilterOps,~Queries.transient_base_changed(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),owner)

def transient_without_registry() -> Type:
  registry(~S.transient_store(),~Body.FilterOps,~Queries.transient_base_without_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)))
def transient_without_owner() -> Type:
  System.Owner<S.Schema,transient_without_registry()>
def transient_without_define(world:W.World<S.Schema,S.transient_store(),Unit,Unit>) -> System.Defined<S.Schema,W.World<S.Schema,S.transient_store(),Unit,Unit>,transient_without_registry()>:
  define(~S.transient_store(),~Body.FilterOps,~Queries.transient_base_without_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),world,"withoutHealth")
def transient_without_observe(owner:transient_without_owner()) -> transient_without_owner() & DTO.RegistrySnapshot:
  observe(~S.transient_store(),~Body.FilterOps,~Queries.transient_base_without_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),owner)

def transient_with_registry() -> Type:
  registry(~S.transient_store(),~Body.FilterOps,~Queries.transient_base_with_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)))
def transient_with_owner() -> Type:
  System.Owner<S.Schema,transient_with_registry()>
def transient_with_define(world:W.World<S.Schema,S.transient_store(),Unit,Unit>) -> System.Defined<S.Schema,W.World<S.Schema,S.transient_store(),Unit,Unit>,transient_with_registry()>:
  define(~S.transient_store(),~Body.FilterOps,~Queries.transient_base_with_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),world,"withHealth")
def transient_with_observe(owner:transient_with_owner()) -> transient_with_owner() & DTO.RegistrySnapshot:
  observe(~S.transient_store(),~Body.FilterOps,~Queries.transient_base_with_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),owner)

def constructed_main_registry() -> Type:
  registry(~S.constructed_store(),~Body.Ops,~Queries.constructed_base(),~(H => caps => fail => owner => Body.body(~H,~caps,fail,owner)))
def constructed_main_owner() -> Type:
  System.Owner<S.Schema,constructed_main_registry()>
def constructed_main_define(world:W.World<S.Schema,S.constructed_store(),Unit,Unit>) -> System.Defined<S.Schema,W.World<S.Schema,S.constructed_store(),Unit,Unit>,constructed_main_registry()>:
  define(~S.constructed_store(),~Body.Ops,~Queries.constructed_base(),~(H => caps => fail => owner => Body.body(~H,~caps,fail,owner)),world,"main")
def constructed_main_observe(owner:constructed_main_owner()) -> constructed_main_owner() & DTO.RegistrySnapshot:
  observe(~S.constructed_store(),~Body.Ops,~Queries.constructed_base(),~(H => caps => fail => owner => Body.body(~H,~caps,fail,owner)),owner)

def constructed_added_registry() -> Type:
  registry(~S.constructed_store(),~Body.FilterOps,~Queries.constructed_base_added(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)))
def constructed_added_owner() -> Type:
  System.Owner<S.Schema,constructed_added_registry()>
def constructed_added_define(world:W.World<S.Schema,S.constructed_store(),Unit,Unit>) -> System.Defined<S.Schema,W.World<S.Schema,S.constructed_store(),Unit,Unit>,constructed_added_registry()>:
  define(~S.constructed_store(),~Body.FilterOps,~Queries.constructed_base_added(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),world,"added")
def constructed_added_observe(owner:constructed_added_owner()) -> constructed_added_owner() & DTO.RegistrySnapshot:
  observe(~S.constructed_store(),~Body.FilterOps,~Queries.constructed_base_added(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),owner)

def constructed_changed_registry() -> Type:
  registry(~S.constructed_store(),~Body.FilterOps,~Queries.constructed_base_changed(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)))
def constructed_changed_owner() -> Type:
  System.Owner<S.Schema,constructed_changed_registry()>
def constructed_changed_define(world:W.World<S.Schema,S.constructed_store(),Unit,Unit>) -> System.Defined<S.Schema,W.World<S.Schema,S.constructed_store(),Unit,Unit>,constructed_changed_registry()>:
  define(~S.constructed_store(),~Body.FilterOps,~Queries.constructed_base_changed(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),world,"changed")
def constructed_changed_observe(owner:constructed_changed_owner()) -> constructed_changed_owner() & DTO.RegistrySnapshot:
  observe(~S.constructed_store(),~Body.FilterOps,~Queries.constructed_base_changed(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),owner)

def constructed_without_registry() -> Type:
  registry(~S.constructed_store(),~Body.FilterOps,~Queries.constructed_base_without_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)))
def constructed_without_owner() -> Type:
  System.Owner<S.Schema,constructed_without_registry()>
def constructed_without_define(world:W.World<S.Schema,S.constructed_store(),Unit,Unit>) -> System.Defined<S.Schema,W.World<S.Schema,S.constructed_store(),Unit,Unit>,constructed_without_registry()>:
  define(~S.constructed_store(),~Body.FilterOps,~Queries.constructed_base_without_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),world,"withoutHealth")
def constructed_without_observe(owner:constructed_without_owner()) -> constructed_without_owner() & DTO.RegistrySnapshot:
  observe(~S.constructed_store(),~Body.FilterOps,~Queries.constructed_base_without_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),owner)

def constructed_with_registry() -> Type:
  registry(~S.constructed_store(),~Body.FilterOps,~Queries.constructed_base_with_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)))
def constructed_with_owner() -> Type:
  System.Owner<S.Schema,constructed_with_registry()>
def constructed_with_define(world:W.World<S.Schema,S.constructed_store(),Unit,Unit>) -> System.Defined<S.Schema,W.World<S.Schema,S.constructed_store(),Unit,Unit>,constructed_with_registry()>:
  define(~S.constructed_store(),~Body.FilterOps,~Queries.constructed_base_with_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),world,"withHealth")
def constructed_with_observe(owner:constructed_with_owner()) -> constructed_with_owner() & DTO.RegistrySnapshot:
  observe(~S.constructed_store(),~Body.FilterOps,~Queries.constructed_base_with_component(),~(H => caps => fail => owner => Body.filter_body(~H,~caps,fail,owner)),owner)
