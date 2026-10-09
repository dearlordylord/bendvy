import Base
import ../scenario-schema.bend as S
import ../scenario-driver.bend as Driver
import ../scenario-execution.bend as Execution
import ../scenario-systems.bend as Systems
import ../scenario-queries.bend as Queries
import ../scenario-body.bend as Body
import ../scenario-dto.bend as DTO
import ../app.bend as App
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


def plain_owners() -> Type:
  Driver.plain_owners() & Trace

def plain_dispatch_5_decide(allowed:Bool,owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      ((((((Unit{},main),added),changed),without),withHealth),Trace{+failId,records}) = owners
      Execution.plain_with_run_then(~(plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => finish(~S.plain_store(),~Driver.plain_owners(),(((((Unit{},main),added),changed),without),selected),Trace{failId,records},world,id,operation)),withHealth,world,U32.is_eq(failId,id))
    case False{}:(owners,Sys.Failed{world,UnknownSystem{id}})

def plain_dispatch_5(owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  plain_dispatch_5_decide(U32.is_eq(id,5),owners,world,id)

def plain_dispatch_4_decide(allowed:Bool,owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      ((((((Unit{},main),added),changed),without),withHealth),Trace{+failId,records}) = owners
      Execution.plain_without_run_then(~(plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => finish(~S.plain_store(),~Driver.plain_owners(),(((((Unit{},main),added),changed),selected),withHealth),Trace{failId,records},world,id,operation)),without,world,U32.is_eq(failId,id))
    case False{}:plain_dispatch_5(owners,world,id)

def plain_dispatch_4(owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  plain_dispatch_4_decide(U32.is_eq(id,4),owners,world,id)

def plain_dispatch_3_decide(allowed:Bool,owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      ((((((Unit{},main),added),changed),without),withHealth),Trace{+failId,records}) = owners
      Execution.plain_changed_run_then(~(plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => finish(~S.plain_store(),~Driver.plain_owners(),(((((Unit{},main),added),selected),without),withHealth),Trace{failId,records},world,id,operation)),changed,world,U32.is_eq(failId,id))
    case False{}:plain_dispatch_4(owners,world,id)

def plain_dispatch_3(owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  plain_dispatch_3_decide(U32.is_eq(id,3),owners,world,id)

def plain_dispatch_2_decide(allowed:Bool,owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      ((((((Unit{},main),added),changed),without),withHealth),Trace{+failId,records}) = owners
      Execution.plain_added_run_then(~(plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => finish(~S.plain_store(),~Driver.plain_owners(),(((((Unit{},main),selected),changed),without),withHealth),Trace{failId,records},world,id,operation)),added,world,U32.is_eq(failId,id))
    case False{}:plain_dispatch_3(owners,world,id)

def plain_dispatch_2(owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  plain_dispatch_2_decide(U32.is_eq(id,2),owners,world,id)

def plain_dispatch_1_decide(allowed:Bool,owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      ((((((Unit{},main),added),changed),without),withHealth),Trace{+failId,records}) = owners
      Execution.plain_main_run_then(~(plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => finish(~S.plain_store(),~Driver.plain_owners(),(((((Unit{},selected),added),changed),without),withHealth),Trace{failId,records},world,id,operation)),main,world,U32.is_eq(failId,id))
    case False{}:plain_dispatch_2(owners,world,id)

def plain_dispatch_1(owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,+id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  plain_dispatch_1_decide(U32.is_eq(id,1),owners,world,id)

def plain_dispatch(owners:plain_owners(),world:W.World<S.Schema,S.plain_store(),Unit,Unit>,id:U32) -> plain_owners() & Sys.Outcome<W.World<S.Schema,S.plain_store(),Unit,Unit>,ApplicationError,Unit>:
  plain_dispatch_1(owners,world,id)

def transient_owners() -> Type:
  Driver.transient_owners() & Trace

def transient_dispatch_5_decide(allowed:Bool,owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      ((((((Unit{},main),added),changed),without),withHealth),Trace{+failId,records}) = owners
      Execution.transient_with_run_then(~(transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => finish(~S.transient_store(),~Driver.transient_owners(),(((((Unit{},main),added),changed),without),selected),Trace{failId,records},world,id,operation)),withHealth,world,U32.is_eq(failId,id))
    case False{}:(owners,Sys.Failed{world,UnknownSystem{id}})

def transient_dispatch_5(owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  transient_dispatch_5_decide(U32.is_eq(id,5),owners,world,id)

def transient_dispatch_4_decide(allowed:Bool,owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      ((((((Unit{},main),added),changed),without),withHealth),Trace{+failId,records}) = owners
      Execution.transient_without_run_then(~(transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => finish(~S.transient_store(),~Driver.transient_owners(),(((((Unit{},main),added),changed),selected),withHealth),Trace{failId,records},world,id,operation)),without,world,U32.is_eq(failId,id))
    case False{}:transient_dispatch_5(owners,world,id)

def transient_dispatch_4(owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  transient_dispatch_4_decide(U32.is_eq(id,4),owners,world,id)

def transient_dispatch_3_decide(allowed:Bool,owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      ((((((Unit{},main),added),changed),without),withHealth),Trace{+failId,records}) = owners
      Execution.transient_changed_run_then(~(transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => finish(~S.transient_store(),~Driver.transient_owners(),(((((Unit{},main),added),selected),without),withHealth),Trace{failId,records},world,id,operation)),changed,world,U32.is_eq(failId,id))
    case False{}:transient_dispatch_4(owners,world,id)

def transient_dispatch_3(owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  transient_dispatch_3_decide(U32.is_eq(id,3),owners,world,id)

def transient_dispatch_2_decide(allowed:Bool,owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      ((((((Unit{},main),added),changed),without),withHealth),Trace{+failId,records}) = owners
      Execution.transient_added_run_then(~(transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => finish(~S.transient_store(),~Driver.transient_owners(),(((((Unit{},main),selected),changed),without),withHealth),Trace{failId,records},world,id,operation)),added,world,U32.is_eq(failId,id))
    case False{}:transient_dispatch_3(owners,world,id)

def transient_dispatch_2(owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  transient_dispatch_2_decide(U32.is_eq(id,2),owners,world,id)

def transient_dispatch_1_decide(allowed:Bool,owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      ((((((Unit{},main),added),changed),without),withHealth),Trace{+failId,records}) = owners
      Execution.transient_main_run_then(~(transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => finish(~S.transient_store(),~Driver.transient_owners(),(((((Unit{},selected),added),changed),without),withHealth),Trace{failId,records},world,id,operation)),main,world,U32.is_eq(failId,id))
    case False{}:transient_dispatch_2(owners,world,id)

def transient_dispatch_1(owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,+id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  transient_dispatch_1_decide(U32.is_eq(id,1),owners,world,id)

def transient_dispatch(owners:transient_owners(),world:W.World<S.Schema,S.transient_store(),Unit,Unit>,id:U32) -> transient_owners() & Sys.Outcome<W.World<S.Schema,S.transient_store(),Unit,Unit>,ApplicationError,Unit>:
  transient_dispatch_1(owners,world,id)

def constructed_owners() -> Type:
  Driver.constructed_owners() & Trace

def constructed_dispatch_5_decide(allowed:Bool,owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      ((((((Unit{},main),added),changed),without),withHealth),Trace{+failId,records}) = owners
      Execution.constructed_with_run_then(~(constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => finish(~S.constructed_store(),~Driver.constructed_owners(),(((((Unit{},main),added),changed),without),selected),Trace{failId,records},world,id,operation)),withHealth,world,U32.is_eq(failId,id))
    case False{}:(owners,Sys.Failed{world,UnknownSystem{id}})

def constructed_dispatch_5(owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  constructed_dispatch_5_decide(U32.is_eq(id,5),owners,world,id)

def constructed_dispatch_4_decide(allowed:Bool,owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      ((((((Unit{},main),added),changed),without),withHealth),Trace{+failId,records}) = owners
      Execution.constructed_without_run_then(~(constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => finish(~S.constructed_store(),~Driver.constructed_owners(),(((((Unit{},main),added),changed),selected),withHealth),Trace{failId,records},world,id,operation)),without,world,U32.is_eq(failId,id))
    case False{}:constructed_dispatch_5(owners,world,id)

def constructed_dispatch_4(owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  constructed_dispatch_4_decide(U32.is_eq(id,4),owners,world,id)

def constructed_dispatch_3_decide(allowed:Bool,owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      ((((((Unit{},main),added),changed),without),withHealth),Trace{+failId,records}) = owners
      Execution.constructed_changed_run_then(~(constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => finish(~S.constructed_store(),~Driver.constructed_owners(),(((((Unit{},main),added),selected),without),withHealth),Trace{failId,records},world,id,operation)),changed,world,U32.is_eq(failId,id))
    case False{}:constructed_dispatch_4(owners,world,id)

def constructed_dispatch_3(owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  constructed_dispatch_3_decide(U32.is_eq(id,3),owners,world,id)

def constructed_dispatch_2_decide(allowed:Bool,owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      ((((((Unit{},main),added),changed),without),withHealth),Trace{+failId,records}) = owners
      Execution.constructed_added_run_then(~(constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => finish(~S.constructed_store(),~Driver.constructed_owners(),(((((Unit{},main),selected),changed),without),withHealth),Trace{failId,records},world,id,operation)),added,world,U32.is_eq(failId,id))
    case False{}:constructed_dispatch_3(owners,world,id)

def constructed_dispatch_2(owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  constructed_dispatch_2_decide(U32.is_eq(id,2),owners,world,id)

def constructed_dispatch_1_decide(allowed:Bool,owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  match allowed:
    case True{}:
      ((((((Unit{},main),added),changed),without),withHealth),Trace{+failId,records}) = owners
      Execution.constructed_main_run_then(~(constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>),(world => selected => operation => finish(~S.constructed_store(),~Driver.constructed_owners(),(((((Unit{},selected),added),changed),without),withHealth),Trace{failId,records},world,id,operation)),main,world,U32.is_eq(failId,id))
    case False{}:constructed_dispatch_2(owners,world,id)

def constructed_dispatch_1(owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,+id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  constructed_dispatch_1_decide(U32.is_eq(id,1),owners,world,id)

def constructed_dispatch(owners:constructed_owners(),world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,id:U32) -> constructed_owners() & Sys.Outcome<W.World<S.Schema,S.constructed_store(),Unit,Unit>,ApplicationError,Unit>:
  constructed_dispatch_1(owners,world,id)
