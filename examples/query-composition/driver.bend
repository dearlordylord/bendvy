import Base
import schema.bend as S
import gameplay.bend as G
import declarations.bend as D
import observe.bend as O
import json.bend as J
import scenario-ops.bend as Ops
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/compose.bend as Q
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/commands.bend as Cmd
import ../../src/ecs/component.bend as C

def unit_outcome(result: Q.Executed<S.World(),Q.Error<G.Error>,Unit>) -> Sys.Outcome<S.World(),String,Unit>:
  match result:
    case Q.Executed{world,T.Success{},_}: Sys.Succeeded{world,Unit{}}
    case Q.Executed{world,T.Failure{Q.UserError{G.Rejected{}}},_}: Sys.Failed{world,"Rejected"}
    case Q.Executed{world,T.Failure{_},_}: Sys.Failed{world,"UnexpectedFailure"}
def run_work(world: S.World(),args: Unit) -> Sys.Outcome<S.World(),String,Unit>:
  unit_outcome(D.work(world))
def run_retry(world: S.World(),args: G.RetryArgs) -> Sys.Outcome<S.World(),String,Unit>:
  unit_outcome(D.retry(world,args))
def WorkRegistry() -> Type:
  Sys.Registry<S.Schema,S.Store,Unit,Unit,Unit,String,Unit,run_work>
def RetryRegistry() -> Type:
  Sys.Registry<S.Schema,S.Store,Unit,Unit,G.RetryArgs,String,Unit,run_retry>
def advanced_outcome(result: Q.Executed<S.World(),Q.Error<G.Error>,U32>) -> Sys.Outcome<S.World(),String,List<&2,U32>>:
  match result:
    case Q.Executed{world,T.Success{},+values}: Sys.Succeeded{world,values}
    case Q.Executed{world,T.Failure{_},_}: Sys.Failed{world,"UnexpectedLifecycleFailure"}
def run_advanced(world: S.World(),cursor: U32) -> Sys.Outcome<S.World(),String,List<&2,U32>>:
  advanced_outcome(D.advanced(world,cursor))
def AdvancedRegistry() -> Type:
  Sys.Registry<S.Schema,S.Store,Unit,Unit,U32,String,List<&2,U32>,run_advanced>
type State is Type:
  State{factory: W.Factory,world: S.World(),work: WorkRegistry(),retry: RetryRegistry(),advanced: AdvancedRegistry(),checkpoints: List<&2,String>}
type Owners is Type:
  Owners{factory: W.Factory,work: WorkRegistry(),retry: RetryRegistry(),advanced: AdvancedRegistry(),checkpoints: List<&2,String>}
def rejoin(owners: Owners,world: S.World()) -> State:
  match owners:
    case Owners{factory,work,retry,advanced,+checkpoints}: State{factory,world,work,retry,advanced,checkpoints}
def record_finish(owners: Owners,+label: String,+rows: List<&2,String>,+composed: List<&2,String>,+empty: List<&2,String>,result: Q.Executed<S.World(),Q.Error<G.Error>,String>) -> State:
  match owners result:
    case Owners{factory,work,retry,advanced,+checkpoints} Q.Executed{world,_,+contradict}: State{factory,world,work,retry,advanced,("{\"label\":" ++ J.quoted(label) ++ ",\"entities\":" ++ J.array(rows) ++ ",\"composed\":" ++ J.array(composed) ++ ",\"empty\":" ++ J.array(empty) ++ ",\"contradict\":" ++ J.array(contradict) ++ "}") <> checkpoints}
def record_empty(owners: Owners,+label: String,+rows: List<&2,String>,+composed: List<&2,String>,result: Q.Executed<S.World(),Q.Error<G.Error>,String>) -> State:
  match result:
    case Q.Executed{world,_,+empty}: record_finish(owners,label,rows,composed,empty,D.contradictory(world))
def record_composed(owners: Owners,+label: String,+rows: List<&2,String>,result: Q.Executed<S.World(),Q.Error<G.Error>,String>) -> State:
  match result:
    case Q.Executed{world,_,+composed}: record_empty(owners,label,rows,composed,D.empty(world))
def record_rows(owners: Owners,+label: String,observed: S.World() & List<&2,String>) -> State:
  (world,+rows) = observed
  record_composed(owners,label,rows,D.composed(world))
def record(state: State,+label: String) -> State:
  match state:
    case State{factory,world,work,retry,advanced,+checkpoints}: record_rows(Owners{factory,work,retry,advanced,checkpoints},label,O.all(world))
def change(~action: S.World() -> S.World(),state: State) -> State:
  match state:
    case State{factory,world,work,retry,advanced,+checkpoints}: State{factory,action(world),work,retry,advanced,checkpoints}
def step_work_result(factory: W.Factory,retry: RetryRegistry(),advanced: AdvancedRegistry(),+checkpoints: List<&2,String>,result: Sys.RunResult<S.Schema,S.Store,Unit,Unit,Unit,String,Unit,run_work>) -> State:
  match result:
    case Sys.Completed{work,Sys.Succeeded{world,_}}: State{factory,world,work,retry,advanced,checkpoints}
    case Sys.Completed{work,Sys.Failed{world,error}}: State{factory,world,work,retry,advanced,("{\"unexpectedWorkError\":" ++ J.quoted(error) ++ "}") <> checkpoints}
    case Sys.RegistrationRejected{work,world,_}: State{factory,world,work,retry,advanced,"{\"unexpectedRegistrationRefusal\":true}" <> checkpoints}
def step_work(state: State) -> State:
  match state:
    case State{factory,world,work,retry,advanced,+checkpoints}: step_work_result(factory,retry,advanced,checkpoints,Sys.run(~S.Schema,~S.Store,~Unit,~Unit,~Unit,~String,~Unit,~run_work,work,world,Unit{}))
def step_retry_result(factory: W.Factory,work: WorkRegistry(),advanced: AdvancedRegistry(),+checkpoints: List<&2,String>,result: Sys.RunResult<S.Schema,S.Store,Unit,Unit,G.RetryArgs,String,Unit,run_retry>) -> State:
  match result:
    case Sys.Completed{retry,Sys.Succeeded{world,_}}: State{factory,world,work,retry,advanced,checkpoints}
    case Sys.Completed{retry,Sys.Failed{world,error}}: State{factory,world,work,retry,advanced,("{\"label\":\"failed-result\",\"ok\":false,\"error\":{\"kind\":\"SystemFailure\",\"system\":\"retry\",\"error\":" ++ J.quoted(error) ++ "}}") <> checkpoints}
    case Sys.RegistrationRejected{retry,world,_}: State{factory,world,work,retry,advanced,"{\"unexpectedRegistrationRefusal\":true}" <> checkpoints}
def retry_named(factory: W.Factory,work: WorkRegistry(),retry: RetryRegistry(),advanced: AdvancedRegistry(),+checkpoints: List<&2,String>,+fail: Bool,named: S.World() & U32) -> State:
  (world,+namespace) = named
  step_retry_result(factory,work,advanced,checkpoints,Sys.run(~S.Schema,~S.Store,~Unit,~Unit,~G.RetryArgs,~String,~Unit,~run_retry,retry,world,G.RetryArgs{fail,W.Handle{namespace,2}}))
def step_retry(state: State,+fail: Bool) -> State:
  match state:
    case State{factory,world,work,retry,advanced,+checkpoints}: retry_named(factory,work,retry,advanced,checkpoints,fail,W.namespace(~S.Schema,~S.Store,~Unit,~Unit,world))
def first_nonempty(values: List<&2,String>) -> String:
  match values:
    case []: "{\"unexpectedDuplicateEmpty\":true}"
    case value <> _: value

def duplicate_result(owners: Owners,result: Q.Executed<S.World(),Q.Error<G.Error>,String>) -> State:
  match owners result:
    case Owners{factory,work,retry,advanced,+checkpoints} Q.Executed{world,_,+values}: State{factory,world,work,retry,advanced,first_nonempty(values) <> checkpoints}
def step_duplicate(state: State) -> State:
  match state:
    case State{factory,world,work,retry,advanced,+checkpoints}: duplicate_result(Owners{factory,work,retry,advanced,checkpoints},D.duplicate(world))
def advanced_result(factory: W.Factory,work: WorkRegistry(),retry: RetryRegistry(),+checkpoints: List<&2,String>,+label: String,result: Sys.RunResult<S.Schema,S.Store,Unit,Unit,U32,String,List<&2,U32>,run_advanced>) -> State:
  match result:
    case Sys.Completed{advanced,Sys.Succeeded{world,+ids}}: State{factory,world,work,retry,advanced,("{\"label\":" ++ J.quoted(label) ++ ",\"ids\":" ++ J.numbers(ids) ++ "}") <> checkpoints}
    case Sys.Completed{advanced,Sys.Failed{world,error}}: State{factory,world,work,retry,advanced,("{\"label\":" ++ J.quoted(label) ++ ",\"error\":" ++ J.quoted(error) ++ "}") <> checkpoints}
    case Sys.RegistrationRejected{advanced,world,_}: State{factory,world,work,retry,advanced,"{\"unexpectedAdvancedRefusal\":true}" <> checkpoints}
def advanced_cursor(factory: W.Factory,work: WorkRegistry(),retry: RetryRegistry(),advanced: AdvancedRegistry(),+checkpoints: List<&2,String>,+label: String,world: S.World()) -> State:
  match advanced:
    case Sys.Registry{+namespace,+id,+name,+access,+cursor}: advanced_result(factory,work,retry,checkpoints,label,Sys.run_tracked(~S.Schema,~S.Store,~Unit,~Unit,~U32,~String,~List<&2,U32>,~run_advanced,Sys.Registry{namespace,id,name,access,cursor},world,cursor))
def step_advanced(state: State,+label: String) -> State:
  match state:
    case State{factory,world,work,retry,advanced,+checkpoints}: advanced_cursor(factory,work,retry,advanced,checkpoints,label,world)
def init_advanced(factory: W.Factory,work: WorkRegistry(),retry: RetryRegistry(),result: Sys.RegistrationResult<S.Schema,S.Store,Unit,Unit,U32,String,List<&2,U32>,run_advanced>) -> Maybe<&1,State>:
  match result:
    case Sys.Registered{world,advanced}: Some{State{factory,world,work,retry,advanced,[]}}
    case _: None{}
def init_retry(factory: W.Factory,work: WorkRegistry(),result: Sys.RegistrationResult<S.Schema,S.Store,Unit,Unit,G.RetryArgs,String,Unit,run_retry>) -> Maybe<&1,State>:
  match result:
    case Sys.Registered{world,retry}: init_advanced(factory,work,retry,Sys.register(~S.Schema,~S.Store,~Unit,~Unit,~U32,~String,~List<&2,U32>,~run_advanced,world,"advanced-reader",["Stock.read","Queue.optional","Enabled.present","Locked.absent","Recipe.added","Stock.changed"]))
    case _: None{}
def init_work(factory: W.Factory,result: Sys.RegistrationResult<S.Schema,S.Store,Unit,Unit,Unit,String,Unit,run_work>) -> Maybe<&1,State>:
  match result:
    case Sys.Registered{world,work}: init_retry(factory,work,Sys.register(~S.Schema,~S.Store,~Unit,~Unit,~G.RetryArgs,~String,~Unit,~run_retry,world,"retry",["Stock.write","Recipe.write","Queue.write","Enabled.present","Locked.absent","Queue.insert"]))
    case _: None{}
def init_created(result: W.Creation<S.Schema,S.Store,Unit,Unit>) -> Maybe<&1,State>:
  match result:
    case W.Created{factory,world}: init_work(factory,Sys.register(~S.Schema,~S.Store,~Unit,~Unit,~Unit,~String,~Unit,~run_work,world,"produce",["Stock.write","Recipe.read","Queue.optional","Enabled.present","Locked.absent"]))
    case _: None{}
def phase_seed(state: State) -> State:
  record(change(~Ops.barrier,record(change(~Ops.seed,record(state,"empty")),"spawn-pending")),"seed-visible")
def phase_work(state: State) -> State:
  record(step_work(record(step_work(state),"work-first")),"work-repeat")
def phase_retry(state: State) -> State:
  record(change(~Ops.barrier,record(step_retry(record(change(~Ops.barrier,record(step_retry(state,True{}),"rollback-three-families")),"rollback-no-command"),False{}),"retry-committed-command-pending")),"retry-command-visible")
def phase_insert(state: State) -> State:
  record(change(~Ops.barrier,record(change(~Ops.insert,state),"insert-pending")),"insert-visible")
def phase_remove(state: State) -> State:
  record(change(~Ops.barrier,record(change(~Ops.remove,state),"remove-pending")),"remove-visible")
def phase_churn(state: State) -> State:
  record(step_work(record(change(~Ops.barrier,record(change(~Ops.churn,state),"churn-pending")),"churn-visible")),"work-after-churn")
def phase_duplicate(state: State) -> State:
  record(step_duplicate(state),"duplicate-final-world")
def phase_advanced(state: State) -> State:
  step_advanced(change(~(world => Ops.barrier(Ops.advanced_replace(world))),step_advanced(step_advanced(state,"advanced-first"),"advanced-repeat")),"advanced-replacement")
def foreign_finished(owners: Owners,+foreignId: U32,+missing: Bool,+queueUnchanged: Bool,+before: String,observed: S.World() & List<&2,String>) -> State:
  match owners observed:
    case Owners{factory,work,retry,advanced,+checkpoints}, (world,+rows): State{factory,world,work,retry,advanced,("{\"label\":\"foreign-collision-reference\",\"foreignId\":" ++ U32.show(foreignId) ++ ",\"localId\":1,\"ok\":" ++ J.boolean(Bool.not(missing)) ++ ",\"error\":\"MissingEntity\",\"queueUnchanged\":" ++ J.boolean(queueUnchanged) ++ ",\"postBarrierUnchanged\":" ++ J.boolean(String.eq(before,J.array(rows))) ++ "}") <> checkpoints}
def foreign_after(owners: Owners,+foreignId: U32,+missing: Bool,+count: U32,+before: String,counted: S.World() & U32) -> State:
  (world,+after) = counted
  foreign_finished(owners,foreignId,missing,U32.is_eq(count,after),before,O.all(Ops.barrier(world)))
def foreign_command(owners: Owners,+foreignId: U32,+lookupMissing: Bool,+count: U32,+before: String,result: S.Tx() & W.Status) -> State:
  match result:
    case (tx,W.Rejected{W.MissingEntity{}}): foreign_after(owners,foreignId,lookupMissing,count,before,W.pending_count(~S.Schema,~S.Store,~Unit,~Unit,Ops.commit(tx)))
    case (tx,_): foreign_after(owners,foreignId,False{},count,before,W.pending_count(~S.Schema,~S.Store,~Unit,~Unit,Ops.commit(tx)))
def foreign_lookup(owners: Owners,+handle: W.Handle<S.Schema>,+count: U32,+before: String,result: S.World() & C.Access<S.StockView>) -> State:
  match result:
    case (world,C.MissingEntity{}): foreign_command(owners,O.handle_id(handle),True{},count,before,Cmd.tx_despawn_with(~S.Schema,~S.Store,~Unit,~Unit,~S.clear,T.begin(~S.World(),~Unit,world),handle))
    case (world,_): foreign_command(owners,O.handle_id(handle),False{},count,before,Cmd.tx_despawn_with(~S.Schema,~S.Store,~Unit,~Unit,~S.clear,T.begin(~S.World(),~Unit,world),handle))
def foreign_counted(owners: Owners,+handle: W.Handle<S.Schema>,+before: String,result: S.World() & U32) -> State:
  (world,+count) = result
  foreign_lookup(owners,handle,count,before,S.get_stock(world,handle))
def foreign_rows(owners: Owners,+handle: W.Handle<S.Schema>,observed: S.World() & List<&2,String>) -> State:
  (world,+rows) = observed
  foreign_counted(owners,handle,J.array(rows),W.pending_count(~S.Schema,~S.Store,~Unit,~Unit,world))
def foreign_activated(owners: Owners,local: S.World(),+handle: W.Handle<S.Schema>,result: S.World() & W.Status) -> State:
  match result:
    case (_,W.Accepted{}): foreign_rows(owners,handle,O.all(local))
    case (_,_): rejoin(owners,local)
def foreign_reserved(owners: Owners,local: S.World(),result: S.World() & W.Reservation<S.Schema>) -> State:
  match result:
    case (foreign,W.Reserved{+handle}): foreign_activated(owners,local,handle,W.activate(~S.Schema,~S.Store,~Unit,~Unit,S.populate(foreign,handle,S.Bundle{Some{S.stock_payload(777)},None{},None{},None{},None{}}),handle))
    case (_,_): rejoin(owners,local)
def foreign_created(local: S.World(),work: WorkRegistry(),retry: RetryRegistry(),advanced: AdvancedRegistry(),+checkpoints: List<&2,String>,result: W.Creation<S.Schema,S.Store,Unit,Unit>) -> State:
  match result:
    case W.Created{factory,foreign}: foreign_reserved(Owners{factory,work,retry,advanced,checkpoints},local,W.reserve_id(~S.Schema,~S.Store,~Unit,~Unit,foreign))
    case W.CreateRejected{factory,_}: State{factory,local,work,retry,advanced,checkpoints}
def phase_foreign(state: State) -> State:
  match state:
    case State{factory,world,work,retry,advanced,+checkpoints}: foreign_created(world,work,retry,advanced,checkpoints,S.create(factory))
def finish(state: State) -> List<&2,String>:
  match state:
    case State{_,_,_,_,_,+checkpoints}: List.reverse(&2,String,checkpoints)
def run_ready(result: Maybe<&1,State>) -> List<&2,String>:
  match result:
    case None{}: ["{\"initFailure\":true}"]
    case Some{state}: finish(phase_advanced(phase_duplicate(phase_churn(phase_remove(phase_insert(phase_retry(phase_work(phase_seed(state)))))))))
def equivalent() -> List<&2,String>:
  run_ready(init_created(S.create(W.factory())))
def main_ready(result: Maybe<&1,State>) -> List<&2,String>:
  match result:
    case None{}: ["{\"initFailure\":true}"]
    case Some{state}: finish(phase_foreign(phase_advanced(phase_duplicate(phase_churn(phase_remove(phase_insert(phase_retry(phase_work(phase_seed(state))))))))))
def main() -> List<&2,String>:
  main_ready(init_created(S.create(W.factory())))
