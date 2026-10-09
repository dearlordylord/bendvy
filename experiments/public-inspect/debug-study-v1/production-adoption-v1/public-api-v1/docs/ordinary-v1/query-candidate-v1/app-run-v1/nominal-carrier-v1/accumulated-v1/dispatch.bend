import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/scenario-schema.bend as S
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/scenario-driver.bend as Driver
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/scenario-execution.bend as Execution
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/scenario-systems.bend as Systems
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/scenario-queries.bend as Queries
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/scenario-body.bend as Body
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/scenario-dto.bend as DTO
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP

# Fixture application policy only; no generic ECS refusal semantics are selected.
type ApplicationError is Data:
  BodyFailure{id:U32,error:Q.Error<Unit>}
  RegistrationRefused{id:U32,args:DTO.RejectedArgs,world:DTO.WorldSnapshot,registry:DTO.RegistrySnapshot}
  UnknownSystem{id:U32}
type DispatchRecord is Data:
  DispatchRecord{id:U32,operation:DTO.Operation}
type Trace is Data:
  Trace{failId:U32,records:List<&2,DispatchRecord>}
def outcome(~C:Type,~H:Type,owners:H,trace:Trace,world:W.World<S.Schema,C,Unit,Unit>,id:U32,operation:DTO.Operation) -> (H & Trace) & Sys.Outcome<W.World<S.Schema,C,Unit,Unit>,ApplicationError,Unit>:
  match operation:
    case DTO.Run{Done{_}}:((owners,trace),Sys.Succeeded{world,Unit{}})
    case DTO.Run{Fail{error}}:((owners,trace),Sys.Failed{world,BodyFailure{id,error}})
    case DTO.RefusedRegistration{args,snapshot,registry}:((owners,trace),Sys.Failed{world,RegistrationRefused{id,args,snapshot,registry}})
    case _:((owners,trace),Sys.Failed{world,UnknownSystem{id}})
def finish(~C:Type,~H:Type,owners:H,trace:Trace,world:W.World<S.Schema,C,Unit,Unit>,+id:U32,+operation:DTO.Operation) -> (H & Trace) & Sys.Outcome<W.World<S.Schema,C,Unit,Unit>,ApplicationError,Unit>:
  match trace:
    case Trace{failId,records}:outcome(~C,~H,owners,Trace{failId,List.append(&2,DispatchRecord,records,[DispatchRecord{id,operation}])},world,id,operation)
def condition(~C:Type,world:W.World<S.Schema,C,Unit,Unit>,slot:U32) -> W.World<S.Schema,C,Unit,Unit> & Bool:
  (world,Bool.not(U32.is_eq(slot,1)))
def provision(~C:Type,world:W.World<S.Schema,C,Unit,Unit>) -> W.World<S.Schema,C,Unit,Unit> & List<&2,SP.Requirement<S.Schema>>:
  (world,[])


type Plain is Type:
  Plain{main:Systems.plain_main_owner(),added:Systems.plain_added_owner(),changed:Systems.plain_changed_owner(),without:Systems.plain_without_owner(),withHealth:Systems.plain_with_owner(),trace:Trace}
def plain_owners() -> Type:
  Plain
def plain_pack(value:Driver.plain_owners() & Trace) -> Plain:
  match value:
    case ((((((Unit{},main),added),changed),without),withHealth),trace):Plain{main,added,changed,without,withHealth,trace}
def plain_unpack(value:Plain) -> Driver.plain_owners() & Trace:
  match value:
    case Plain{main,added,changed,without,withHealth,trace}:((((((Unit{},main),added),changed),without),withHealth),trace)
def plain_trace(value:Plain) -> Plain & Trace:
  match value:
    case Plain{main,added,changed,without,withHealth,+trace}:(Plain{main,added,changed,without,withHealth,trace},trace)
def plain_outcome(owners:Plain,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,id:U32,operation:DTO.Operation) -> Plain & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  match operation:
    case DTO.Run{Done{_}}:(owners,Sys.Succeeded{world,Unit{}})
    case DTO.Run{Fail{error}}:(owners,Sys.Failed{world,BodyFailure{id,error}})
    case DTO.RefusedRegistration{args,snapshot,registry}:(owners,Sys.Failed{world,RegistrationRefused{id,args,snapshot,registry}})
    case _:(owners,Sys.Failed{world,UnknownSystem{id}})
def plain_finish(owners:Plain,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32,+operation:DTO.Operation) -> Plain & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  match owners:
    case Plain{main,added,changed,without,withHealth,Trace{failId,records}}:
      plain_outcome(Plain{main,added,changed,without,withHealth,Trace{failId,List.append(&2,DispatchRecord,records,[DispatchRecord{id,operation}])}},world,id,operation)


def plain_dispatch_5_decide(allowed:Bool,owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      Plain{main,added,changed,without,withHealth,Trace{+failId,records}} = owners
      Execution.plain_with_run_then(~(plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => plain_finish(Plain{main,added,changed,without,selected,Trace{failId,records}},world,id,operation)),withHealth,world,U32.is_eq(failId,id))
    case False{}:(owners,Sys.Failed{world,UnknownSystem{id}})

def plain_dispatch_5(owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  plain_dispatch_5_decide(U32.is_eq(id,5),owners,world,id)

def plain_dispatch_4_decide(allowed:Bool,owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      Plain{main,added,changed,without,withHealth,Trace{+failId,records}} = owners
      Execution.plain_without_run_then(~(plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => plain_finish(Plain{main,added,changed,selected,withHealth,Trace{failId,records}},world,id,operation)),without,world,U32.is_eq(failId,id))
    case False{}:plain_dispatch_5(owners,world,id)

def plain_dispatch_4(owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  plain_dispatch_4_decide(U32.is_eq(id,4),owners,world,id)

def plain_dispatch_3_decide(allowed:Bool,owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      Plain{main,added,changed,without,withHealth,Trace{+failId,records}} = owners
      Execution.plain_changed_run_then(~(plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => plain_finish(Plain{main,added,selected,without,withHealth,Trace{failId,records}},world,id,operation)),changed,world,U32.is_eq(failId,id))
    case False{}:plain_dispatch_4(owners,world,id)

def plain_dispatch_3(owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  plain_dispatch_3_decide(U32.is_eq(id,3),owners,world,id)

def plain_dispatch_2_decide(allowed:Bool,owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      Plain{main,added,changed,without,withHealth,Trace{+failId,records}} = owners
      Execution.plain_added_run_then(~(plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => plain_finish(Plain{main,selected,changed,without,withHealth,Trace{failId,records}},world,id,operation)),added,world,U32.is_eq(failId,id))
    case False{}:plain_dispatch_3(owners,world,id)

def plain_dispatch_2(owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  plain_dispatch_2_decide(U32.is_eq(id,2),owners,world,id)

def plain_dispatch_1_decide(allowed:Bool,owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      Plain{main,added,changed,without,withHealth,Trace{+failId,records}} = owners
      Execution.plain_main_run_then(~(plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => plain_finish(Plain{selected,added,changed,without,withHealth,Trace{failId,records}},world,id,operation)),main,world,U32.is_eq(failId,id))
    case False{}:plain_dispatch_2(owners,world,id)

def plain_dispatch_1(owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  plain_dispatch_1_decide(U32.is_eq(id,1),owners,world,id)

def plain_dispatch(owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  plain_dispatch_1(owners,world,id)

type Transient is Type:
  Transient{main:Systems.transient_main_owner(),added:Systems.transient_added_owner(),changed:Systems.transient_changed_owner(),without:Systems.transient_without_owner(),withHealth:Systems.transient_with_owner(),trace:Trace}
def transient_owners() -> Type:
  Transient
def transient_pack(value:Driver.transient_owners() & Trace) -> Transient:
  match value:
    case ((((((Unit{},main),added),changed),without),withHealth),trace):Transient{main,added,changed,without,withHealth,trace}
def transient_unpack(value:Transient) -> Driver.transient_owners() & Trace:
  match value:
    case Transient{main,added,changed,without,withHealth,trace}:((((((Unit{},main),added),changed),without),withHealth),trace)
def transient_trace(value:Transient) -> Transient & Trace:
  match value:
    case Transient{main,added,changed,without,withHealth,+trace}:(Transient{main,added,changed,without,withHealth,trace},trace)
def transient_outcome(owners:Transient,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,id:U32,operation:DTO.Operation) -> Transient & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  match operation:
    case DTO.Run{Done{_}}:(owners,Sys.Succeeded{world,Unit{}})
    case DTO.Run{Fail{error}}:(owners,Sys.Failed{world,BodyFailure{id,error}})
    case DTO.RefusedRegistration{args,snapshot,registry}:(owners,Sys.Failed{world,RegistrationRefused{id,args,snapshot,registry}})
    case _:(owners,Sys.Failed{world,UnknownSystem{id}})
def transient_finish(owners:Transient,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32,+operation:DTO.Operation) -> Transient & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  match owners:
    case Transient{main,added,changed,without,withHealth,Trace{failId,records}}:
      transient_outcome(Transient{main,added,changed,without,withHealth,Trace{failId,List.append(&2,DispatchRecord,records,[DispatchRecord{id,operation}])}},world,id,operation)


def transient_dispatch_5_decide(allowed:Bool,owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      Transient{main,added,changed,without,withHealth,Trace{+failId,records}} = owners
      Execution.transient_with_run_then(~(transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => transient_finish(Transient{main,added,changed,without,selected,Trace{failId,records}},world,id,operation)),withHealth,world,U32.is_eq(failId,id))
    case False{}:(owners,Sys.Failed{world,UnknownSystem{id}})

def transient_dispatch_5(owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  transient_dispatch_5_decide(U32.is_eq(id,5),owners,world,id)

def transient_dispatch_4_decide(allowed:Bool,owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      Transient{main,added,changed,without,withHealth,Trace{+failId,records}} = owners
      Execution.transient_without_run_then(~(transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => transient_finish(Transient{main,added,changed,selected,withHealth,Trace{failId,records}},world,id,operation)),without,world,U32.is_eq(failId,id))
    case False{}:transient_dispatch_5(owners,world,id)

def transient_dispatch_4(owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  transient_dispatch_4_decide(U32.is_eq(id,4),owners,world,id)

def transient_dispatch_3_decide(allowed:Bool,owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      Transient{main,added,changed,without,withHealth,Trace{+failId,records}} = owners
      Execution.transient_changed_run_then(~(transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => transient_finish(Transient{main,added,selected,without,withHealth,Trace{failId,records}},world,id,operation)),changed,world,U32.is_eq(failId,id))
    case False{}:transient_dispatch_4(owners,world,id)

def transient_dispatch_3(owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  transient_dispatch_3_decide(U32.is_eq(id,3),owners,world,id)

def transient_dispatch_2_decide(allowed:Bool,owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      Transient{main,added,changed,without,withHealth,Trace{+failId,records}} = owners
      Execution.transient_added_run_then(~(transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => transient_finish(Transient{main,selected,changed,without,withHealth,Trace{failId,records}},world,id,operation)),added,world,U32.is_eq(failId,id))
    case False{}:transient_dispatch_3(owners,world,id)

def transient_dispatch_2(owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  transient_dispatch_2_decide(U32.is_eq(id,2),owners,world,id)

def transient_dispatch_1_decide(allowed:Bool,owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      Transient{main,added,changed,without,withHealth,Trace{+failId,records}} = owners
      Execution.transient_main_run_then(~(transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => transient_finish(Transient{selected,added,changed,without,withHealth,Trace{failId,records}},world,id,operation)),main,world,U32.is_eq(failId,id))
    case False{}:transient_dispatch_2(owners,world,id)

def transient_dispatch_1(owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  transient_dispatch_1_decide(U32.is_eq(id,1),owners,world,id)

def transient_dispatch(owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  transient_dispatch_1(owners,world,id)

type Constructed is Type:
  Constructed{main:Systems.constructed_main_owner(),added:Systems.constructed_added_owner(),changed:Systems.constructed_changed_owner(),without:Systems.constructed_without_owner(),withHealth:Systems.constructed_with_owner(),trace:Trace}
def constructed_owners() -> Type:
  Constructed
def constructed_pack(value:Driver.constructed_owners() & Trace) -> Constructed:
  match value:
    case ((((((Unit{},main),added),changed),without),withHealth),trace):Constructed{main,added,changed,without,withHealth,trace}
def constructed_unpack(value:Constructed) -> Driver.constructed_owners() & Trace:
  match value:
    case Constructed{main,added,changed,without,withHealth,trace}:((((((Unit{},main),added),changed),without),withHealth),trace)
def constructed_trace(value:Constructed) -> Constructed & Trace:
  match value:
    case Constructed{main,added,changed,without,withHealth,+trace}:(Constructed{main,added,changed,without,withHealth,trace},trace)
def constructed_outcome(owners:Constructed,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,id:U32,operation:DTO.Operation) -> Constructed & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  match operation:
    case DTO.Run{Done{_}}:(owners,Sys.Succeeded{world,Unit{}})
    case DTO.Run{Fail{error}}:(owners,Sys.Failed{world,BodyFailure{id,error}})
    case DTO.RefusedRegistration{args,snapshot,registry}:(owners,Sys.Failed{world,RegistrationRefused{id,args,snapshot,registry}})
    case _:(owners,Sys.Failed{world,UnknownSystem{id}})
def constructed_finish(owners:Constructed,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32,+operation:DTO.Operation) -> Constructed & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  match owners:
    case Constructed{main,added,changed,without,withHealth,Trace{failId,records}}:
      constructed_outcome(Constructed{main,added,changed,without,withHealth,Trace{failId,List.append(&2,DispatchRecord,records,[DispatchRecord{id,operation}])}},world,id,operation)


def constructed_dispatch_5_decide(allowed:Bool,owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      Constructed{main,added,changed,without,withHealth,Trace{+failId,records}} = owners
      Execution.constructed_with_run_then(~(constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => constructed_finish(Constructed{main,added,changed,without,selected,Trace{failId,records}},world,id,operation)),withHealth,world,U32.is_eq(failId,id))
    case False{}:(owners,Sys.Failed{world,UnknownSystem{id}})

def constructed_dispatch_5(owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  constructed_dispatch_5_decide(U32.is_eq(id,5),owners,world,id)

def constructed_dispatch_4_decide(allowed:Bool,owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      Constructed{main,added,changed,without,withHealth,Trace{+failId,records}} = owners
      Execution.constructed_without_run_then(~(constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => constructed_finish(Constructed{main,added,changed,selected,withHealth,Trace{failId,records}},world,id,operation)),without,world,U32.is_eq(failId,id))
    case False{}:constructed_dispatch_5(owners,world,id)

def constructed_dispatch_4(owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  constructed_dispatch_4_decide(U32.is_eq(id,4),owners,world,id)

def constructed_dispatch_3_decide(allowed:Bool,owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      Constructed{main,added,changed,without,withHealth,Trace{+failId,records}} = owners
      Execution.constructed_changed_run_then(~(constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => constructed_finish(Constructed{main,added,selected,without,withHealth,Trace{failId,records}},world,id,operation)),changed,world,U32.is_eq(failId,id))
    case False{}:constructed_dispatch_4(owners,world,id)

def constructed_dispatch_3(owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  constructed_dispatch_3_decide(U32.is_eq(id,3),owners,world,id)

def constructed_dispatch_2_decide(allowed:Bool,owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      Constructed{main,added,changed,without,withHealth,Trace{+failId,records}} = owners
      Execution.constructed_added_run_then(~(constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => constructed_finish(Constructed{main,selected,changed,without,withHealth,Trace{failId,records}},world,id,operation)),added,world,U32.is_eq(failId,id))
    case False{}:constructed_dispatch_3(owners,world,id)

def constructed_dispatch_2(owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  constructed_dispatch_2_decide(U32.is_eq(id,2),owners,world,id)

def constructed_dispatch_1_decide(allowed:Bool,owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      Constructed{main,added,changed,without,withHealth,Trace{+failId,records}} = owners
      Execution.constructed_main_run_then(~(constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => constructed_finish(Constructed{selected,added,changed,without,withHealth,Trace{failId,records}},world,id,operation)),main,world,U32.is_eq(failId,id))
    case False{}:constructed_dispatch_2(owners,world,id)

def constructed_dispatch_1(owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  constructed_dispatch_1_decide(U32.is_eq(id,1),owners,world,id)

def constructed_dispatch(owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  constructed_dispatch_1(owners,world,id)
