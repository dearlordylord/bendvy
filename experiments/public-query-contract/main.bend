import Base
import ../../src/ecs/query-contract.bend as QC
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/compose.bend as Q
import ../../src/ecs/capabilities.bend as Cap
import ../../examples/query-composition/schema.bend as S
import ../../examples/query-composition/declarations.bend as D
import ../../examples/query-composition/gameplay.bend as G
import ../../examples/query-composition/observe.bend as O
import ../../examples/query-composition/json.bend as J
import ../../examples/query-composition/scenario-ops.bend as Ops

type State is Type:
  State{factory: W.Factory,namespace: U32,world: S.World(),points: List<&2,String>}
def result(result: Result<&2,&2,QC.Error<G.Error>,String>) -> String:
  match result:
    case Done{value}: "{\"ok\":true,\"value\":" ++ value ++ "}"
    case Fail{QC.NoEntities{}}: "{\"ok\":false,\"error\":\"NoEntities\"}"
    case Fail{QC.MultipleEntities{count}}: "{\"ok\":false,\"error\":\"MultipleEntities\",\"count\":" ++ U32.show(count) ++ "}"
    case Fail{QC.MissingEntity{entityId}}: "{\"ok\":false,\"error\":\"MissingEntity\",\"entityId\":" ++ U32.show(entityId) ++ "}"
    case Fail{QC.QueryMismatch{entityId}}: "{\"ok\":false,\"error\":\"QueryMismatch\",\"entityId\":" ++ U32.show(entityId) ++ "}"
    case Fail{_}: "{\"ok\":false,\"error\":\"BodyError\"}"
def snapshot(factory: W.Factory,namespace: U32,label: String,value: String,+points: List<&2,String>,observed: S.World() & List<&2,String>) -> State:
  (world,+entities) = observed
  State{factory,namespace,world,("{\"label\":" ++ J.quoted(label) ++ ",\"result\":" ++ value ++ ",\"entities\":" ++ J.array(entities) ++ "}") <> points}
def observed(factory: W.Factory,namespace: U32,label: String,points: List<&2,String>,executed: QC.Executed<S.World(),G.Error,String>) -> State:
  match executed:
    case QC.Executed{world,value}: snapshot(factory,namespace,label,result(value),points,O.all(world))
def counted(factory: W.Factory,namespace: U32,label: String,points: List<&2,String>,observed: S.World() & U32) -> State:
  (world,n) = observed
  snapshot(factory,namespace,label,U32.show(n),points,O.all(world))
def write_abstract(~H: Type,observed: H & (T.Outcome<G.Error> & Unit)) -> H & (T.Outcome<G.Error> & String):
  (ctx,(outcome,_)) = observed
  (ctx,(outcome,"null"))
def write_body(~H: Type,~caps: G.WorkOps(H),args: Unit,ctx: H) -> H & (T.Outcome<G.Error> & String):
  write_abstract(~H,G.work_body(~H,~caps,args,ctx))
def unique_select(frame: D.Frame()) -> D.Frame() & Bool:
  Q.both(~S.Schema,~S.Store,~Unit,~Unit,~D.work_match,~D.match_queue(~Q.Required{}),frame)
def unique_plan() -> Q.Plan<S.Schema,S.Store,Unit,Unit,G.WorkOps>:
  Q.Plan{D.work_caps(),unique_select}
def step0(state: State) -> State:
  match state:
    case State{factory,+namespace,world,points}: counted(factory,namespace,"count-zero",points,QC.count(~S.Schema,~S.Store,~Unit,~Unit,~D.EmptyOps,~D.empty_plan(),world,0))
def step1(state: State) -> State:
  match state:
    case State{factory,+namespace,world,points}: observed(factory,namespace,"single-zero",points,QC.single(~S.Schema,~S.Store,~Unit,~Unit,~G.WorkOps,~D.work_plan(),~Unit,~G.Error,~String,~write_body,Unit{},world,0))
def step2(state: State) -> State:
  match state:
    case State{factory,+namespace,world,points}: observed(factory,namespace,"missing-zero",points,QC.get(~S.Schema,~S.Store,~Unit,~Unit,~G.WorkOps,~D.work_plan(),~Unit,~G.Error,~String,~write_body,Unit{},world,W.Handle{namespace,99},0))
def step3(state: State) -> State:
  match state:
    case State{factory,+namespace,world,points}: snapshot(factory,namespace,"seed","null",points,O.all(W.barrier(~S.Schema,~S.Store,~Unit,~Unit,Ops.seed(world))))
def step4(state: State) -> State:
  match state:
    case State{factory,+namespace,world,points}: counted(factory,namespace,"count-all",points,QC.count(~S.Schema,~S.Store,~Unit,~Unit,~D.EmptyOps,~D.empty_plan(),world,0))
def step5(state: State) -> State:
  match state:
    case State{factory,+namespace,world,points}: counted(factory,namespace,"count-work",points,QC.count(~S.Schema,~S.Store,~Unit,~Unit,~G.WorkOps,~D.work_plan(),world,0))
def step6(state: State) -> State:
  match state:
    case State{factory,+namespace,world,points}: observed(factory,namespace,"single-multiple",points,QC.single(~S.Schema,~S.Store,~Unit,~Unit,~G.WorkOps,~D.work_plan(),~Unit,~G.Error,~String,~write_body,Unit{},world,0))
def step7(state: State) -> State:
  match state:
    case State{factory,+namespace,world,points}: observed(factory,namespace,"get-mismatch",points,QC.get(~S.Schema,~S.Store,~Unit,~Unit,~G.WorkOps,~D.work_plan(),~Unit,~G.Error,~String,~write_body,Unit{},world,W.Handle{namespace,4},0))
def step8(state: State) -> State:
  match state:
    case State{factory,+namespace,world,points}: observed(factory,namespace,"get-missing",points,QC.get(~S.Schema,~S.Store,~Unit,~Unit,~G.WorkOps,~D.work_plan(),~Unit,~G.Error,~String,~write_body,Unit{},world,W.Handle{namespace,99},0))
def step9(state: State) -> State:
  match state:
    case State{factory,+namespace,world,points}: observed(factory,namespace,"get-write",points,QC.get(~S.Schema,~S.Store,~Unit,~Unit,~G.WorkOps,~D.work_plan(),~Unit,~G.Error,~String,~write_body,Unit{},world,W.Handle{namespace,1},0))
def step10(state: State) -> State:
  match state:
    case State{factory,+namespace,world,points}: observed(factory,namespace,"single-one-write",points,QC.single(~S.Schema,~S.Store,~Unit,~Unit,~G.WorkOps,~unique_plan(),~Unit,~G.Error,~String,~write_body,Unit{},world,0))
def step11(state: State) -> State:
  match state:
    case State{factory,+namespace,world,points}: observed(factory,namespace,"get-alias",points,QC.get(~S.Schema,~S.Store,~Unit,~Unit,~G.DuplicateOps,~D.duplicate_plan(),~Unit,~G.Error,~String,~G.duplicate_body,Unit{},world,W.Handle{namespace,1},0))
def step12(state: State) -> State:
  match state:
    case State{factory,+namespace,world,points}: snapshot(factory,namespace,"churn","null",points,O.all(W.barrier(~S.Schema,~S.Store,~Unit,~Unit,Ops.churn(world))))
def step13(state: State) -> State:
  match state:
    case State{factory,+namespace,world,points}: observed(factory,namespace,"get-stale",points,QC.get(~S.Schema,~S.Store,~Unit,~Unit,~G.WorkOps,~D.work_plan(),~Unit,~G.Error,~String,~write_body,Unit{},world,W.Handle{namespace,2},0))
def step14(state: State) -> State:
  match state:
    case State{factory,+namespace,world,points}: counted(factory,namespace,"count-after-churn",points,QC.count(~S.Schema,~S.Store,~Unit,~Unit,~G.WorkOps,~D.work_plan(),world,0))
def foreign_reserved(factory: W.Factory,namespace: U32,local: S.World(),points: List<&2,String>,reservation: S.World() & W.Reservation<S.Schema>) -> State:
  match reservation:
    case (_,W.Reserved{handle}): observed(factory,namespace,"get-foreign",points,QC.get(~S.Schema,~S.Store,~Unit,~Unit,~G.WorkOps,~D.work_plan(),~Unit,~G.Error,~String,~write_body,Unit{},local,handle,0))
    case (_,W.ReservationRejected{_}): State{factory,namespace,local,points}
def foreign_created(namespace: U32,local: S.World(),points: List<&2,String>,creation: W.Creation<S.Schema,S.Store,Unit,Unit>) -> State:
  match creation:
    case W.Created{factory,foreign}: foreign_reserved(factory,namespace,local,points,W.reserve_id(~S.Schema,~S.Store,~Unit,~Unit,foreign))
    case W.CreateRejected{factory,_}: State{factory,namespace,local,points}
def step15(state: State) -> State:
  match state:
    case State{factory,namespace,world,points}: foreign_created(namespace,world,points,S.create(factory))
def finish(state: State) -> String:
  match state:
    case State{_,_,_,points}: J.array(List.reverse(&2,String,points))
def initialized(factory: W.Factory,observed: S.World() & U32) -> String:
  (world,namespace) = observed
  finish(step15(step14(step13(step12(step11(step10(step9(step8(step7(step6(step5(step4(step3(step2(step1(step0(State{factory,namespace,world,[]})))))))))))))))))
def created(result: W.Creation<S.Schema,S.Store,Unit,Unit>) -> String:
  match result:
    case W.Created{factory,world}: initialized(factory,W.namespace(~S.Schema,~S.Store,~Unit,~Unit,world))
    case W.CreateRejected{_,_}: "[]"
def main() -> IO(Unit):
  IO.print(created(S.create(W.factory())))
