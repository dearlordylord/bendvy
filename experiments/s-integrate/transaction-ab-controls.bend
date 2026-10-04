import Base
import ./types.bend as T
import ./storage.bend as S
import ./identity.bend as I
import ./commands.bend as C
import ./payload.bend as P
import ./transaction.bend as X
import ./transaction-dispatch-adapters.bend as A
import ./observations.bend as O
import ./observation-render.bend as R
import ./storage-stage-fixture.bend as F
import ./systems.bend as U
import ./schedule.bend as Q

def handle_id(-Schema:Data,value:Maybe<&2,S.Handle<Schema>>) -> String:
  match value:
    case None{}: "none"
    case Some{S.Handle{ns,id}}: U32.show(ns) ++ ":" ++ U32.show(id)
def outcome(value:T.Outcome) -> String:
  match value:
    case T.Success{}: "success"
    case T.Failure{code}: "failure:" ++ U32.show(code)
def main_view(value:T.MainView) -> String:
  match value:
    case T.MotionMain{v}: F.position(v)
    case T.HealthMain{v}: F.vitals(v)
def access(value:T.Access<T.MainView>) -> String:
  match value:
    case T.Found{v}: main_view(v)
    case T.Mismatch{}: "mismatch"
    case T.Missing{}: "missing"
def body_observation(value:U.Observation) -> String:
  match value:
    case U.MainObserved{v}: access(v)
    case U.LedgerObserved{v}: Maybe.show(&2,T.LedgerView,F.ledger_show,v)

def motion_main(value:U32) -> T.Position:
  T.Position{F.vector(value),7}
def motion_ledger(u:Unit) -> T.MotionLedger:
  T.MotionLedger{F.vector(100),4}
def motion_audit(owner:X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,text:String) -> IO(X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>):
  IO.bind(Unit,X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,IO.print("audit:motion:" ++ text), _ => IO.pure(X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,owner))
def motion_snapshot_done(result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String:
  match result:
    case (world,v): (world,R.motion(v))
def motion_snapshot(world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String:
  motion_snapshot_done(O.world(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,P.position_get,P.velocity_get,P.motion_ledger_get,world))
def motion_final_second(first:String,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String) -> IO(Unit):
  match result:
    case (world,second): IO.print("motion:APPLY=" ++ first ++ "\nmotion:APPLY-again=" ++ second)
def motion_final_observed(result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String) -> IO(Unit):
  match result:
    case (world,text): motion_final_second(text,motion_snapshot(world))
def motion_applied(result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,S.Change<T.MotionSchema>>) -> IO(Unit):
  match result:
    case (world,changes): motion_final_observed(motion_snapshot(world))
def motion_retry_baseline(first:String,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String) -> IO(Unit):
  match result:
    case (world,baseline): IO.bind(Unit,Unit,IO.print("motion:RETRY=" ++ first ++ "\nmotion:RETRY-baseline=" ++ baseline), _ => motion_applied(C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,7)))
def motion_retry_observed(result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String) -> IO(Unit):
  match result:
    case (world,text): motion_retry_baseline(text,F.motion_observe(world))
def motion_retry_finished(result:A.RunResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>>) -> IO(Unit):
  match result:
    case A.RunResult{world,status,escaped,observations,pings}: IO.bind(Unit,Unit,IO.print("motion:B-retry:" ++ outcome(status) ++ ":escaped=" ++ handle_id(T.MotionSchema,escaped) ++ ":pings=" ++ List.show(&2,U32,U32.show,pings) ++ ":body=" ++ List.show(&2,U.Observation,body_observation,observations)), _ => motion_retry_observed(motion_snapshot(world)))
def motion_retry_body(result:U.BodyResult<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,S.Handle<T.MotionSchema>>) -> IO(Unit):
  motion_retry_finished(A.motion_finished(result,4))
def motion_failed_lookup(+selected:S.Handle<T.MotionSchema>,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & T.Access<T.PositionView>) -> IO(Unit):
  match result:
    case (world,T.Missing{}): IO.bind(U.BodyResult<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,S.Handle<T.MotionSchema>>,Unit,A.motion_invoke(U.motion_b,Q.Retry{},3,motion_audit,world,selected),motion_retry_body)
    case (_, _): IO.print("motion:FAILED-HANDLE-REVIVED")
def motion_failed_escaped(selected:S.Handle<T.MotionSchema>,escaped:Maybe<&2,S.Handle<T.MotionSchema>>,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> IO(Unit):
  match escaped:
    case Some{failed}: motion_failed_lookup(selected,S.with_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.PositionView,world,failed,P.position_get))
    case None{}: IO.print("motion:MISSING-ESCAPED")
def motion_failed_baseline(selected:S.Handle<T.MotionSchema>,escaped:Maybe<&2,S.Handle<T.MotionSchema>>,first:String,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String) -> IO(Unit):
  match result:
    case (world,baseline): IO.bind(Unit,Unit,IO.print("motion:FAIL=" ++ first ++ "\nmotion:FAIL-baseline=" ++ baseline), _ => motion_failed_escaped(selected,escaped,world))
def motion_failed_observed(selected:S.Handle<T.MotionSchema>,escaped:Maybe<&2,S.Handle<T.MotionSchema>>,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String) -> IO(Unit):
  match result:
    case (world,text): motion_failed_baseline(selected,escaped,text,F.motion_observe(world))
def motion_failed_finished(selected:S.Handle<T.MotionSchema>,result:A.RunResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>>) -> IO(Unit):
  match result:
    case A.RunResult{world,status,+escaped,observations,pings}: IO.bind(Unit,Unit,IO.print("motion:B-fail:" ++ outcome(status) ++ ":escaped=" ++ handle_id(T.MotionSchema,escaped) ++ ":pings=" ++ List.show(&2,U32,U32.show,pings) ++ ":body=" ++ List.show(&2,U.Observation,body_observation,observations)), _ => motion_failed_observed(selected,escaped,motion_snapshot(world)))
def motion_failed_body(selected:S.Handle<T.MotionSchema>,result:U.BodyResult<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,S.Handle<T.MotionSchema>>) -> IO(Unit):
  motion_failed_finished(selected,A.motion_finished(result,3))
def motion_a_baseline(+selected:S.Handle<T.MotionSchema>,first:String,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String) -> IO(Unit):
  match result:
    case (world,baseline): IO.bind(Unit,Unit,IO.print("motion:A=" ++ first ++ "\nmotion:A-baseline=" ++ baseline), _ => IO.bind(U.BodyResult<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,S.Handle<T.MotionSchema>>,Unit,A.motion_invoke(U.motion_b,Q.BFail{},2,motion_audit,world,selected), r => motion_failed_body(selected,r)))
def motion_a_observed(selected:S.Handle<T.MotionSchema>,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String) -> IO(Unit):
  match result:
    case (world,text): motion_a_baseline(selected,text,F.motion_observe(world))
def motion_a_committed(selected:S.Handle<T.MotionSchema>,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,U32>) -> IO(Unit):
  match result:
    case (world,pings): IO.bind(Unit,Unit,IO.print("motion:A-pings=" ++ List.show(&2,U32,U32.show,pings)), _ => motion_a_observed(selected,motion_snapshot(world)))
def motion_a_spawned(selected:S.Handle<T.MotionSchema>,result:T.Reservation<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,S.Handle<T.MotionSchema>,T.Position>) -> IO(Unit):
  match result:
    case T.Reserved{owner,escaped}: IO.bind(Unit,Unit,IO.print("audit:motion:A:attempt:1"), _ => motion_a_committed(selected,X.storage_commit(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,X.tx_finish_success(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,A.motion_emit(A.motion_remove_flag(owner),T.MotionPing{1})),2)))
    case T.ReserveRejected{_,_}: IO.print("motion:A-SPAWN-FAILED")
def motion_a_started(+selected:S.Handle<T.MotionSchema>,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,a:S.Handle<T.MotionSchema>) -> IO(Unit):
  motion_a_spawned(selected,A.motion_spawn_flagged(A.motion_set_ledger0(A.motion_set_main0(X.tx_begin(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,world,a),T.PositionToken{},11),T.MotionLedgerToken{},101),motion_main(50)))
def motion_seed_applied(selected:S.Handle<T.MotionSchema>,a:S.Handle<T.MotionSchema>,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,S.Change<T.MotionSchema>>) -> IO(Unit):
  match result:
    case (world,_): motion_a_started(selected,world,a)
def motion_seed_c(selected:S.Handle<T.MotionSchema>,a:S.Handle<T.MotionSchema>,result:T.Reservation<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>) -> IO(Unit):
  match result:
    case T.Reserved{world,c}: motion_seed_applied(selected,a,C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,1))
    case T.ReserveRejected{_,_}: IO.print("seed-c-failed")
def motion_seed_b(a:S.Handle<T.MotionSchema>,result:T.Reservation<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>) -> IO(Unit):
  match result:
    case T.Reserved{world,b}: motion_seed_c(b,a,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,S.Bundle{None{},Some{T.Velocity{F.vector(1),True{}}},Some{T.Selected{8}}}))
    case T.ReserveRejected{_,_}: IO.print("seed-b-failed")
def motion_seed_a(result:T.Reservation<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>) -> IO(Unit):
  match result:
    case T.Reserved{world,a}: motion_seed_b(a,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,S.Bundle{Some{motion_main(20)},None{},None{}}))
    case T.ReserveRejected{_,_}: IO.print("seed-a-failed")
def motion_created(result:T.Creation<S.Factory,S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>>) -> IO(Unit):
  match result:
    case T.Created{factory,world}: motion_seed_a(C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,S.Bundle{Some{motion_main(10)},Some{T.Velocity{F.vector(1),True{}}},Some{T.Selected{8}}}))
    case T.CreateRejected{_}: IO.print("create-failed")
def motion() -> IO(Unit):
  motion_created(I.create(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,motion_ledger,I.factory(),T.MotionOn{}))

def health_main(value:U32) -> T.Vitals:
  T.Vitals{F.vector(value),9,2}
def health_ledger(u:Unit) -> T.HealthLedger:
  T.HealthLedger{F.vector(100),4}
def health_audit(owner:X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,text:String) -> IO(X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>):
  IO.bind(Unit,X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,IO.print("audit:health:" ++ text), _ => IO.pure(X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,owner))
def health_snapshot_done(result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String:
  match result:
    case (world,v): (world,R.health(v))
def health_snapshot(world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String:
  health_snapshot_done(O.world(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,P.vitals_get,P.armor_get,P.health_ledger_get,world))
def health_final_second(first:String,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String) -> IO(Unit):
  match result:
    case (world,second): IO.print("health:APPLY=" ++ first ++ "\nhealth:APPLY-again=" ++ second)
def health_final_observed(result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String) -> IO(Unit):
  match result:
    case (world,text): health_final_second(text,health_snapshot(world))
def health_applied(result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,S.Change<T.HealthSchema>>) -> IO(Unit):
  match result:
    case (world,changes): health_final_observed(health_snapshot(world))
def health_retry_baseline(first:String,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String) -> IO(Unit):
  match result:
    case (world,baseline): IO.bind(Unit,Unit,IO.print("health:RETRY=" ++ first ++ "\nhealth:RETRY-baseline=" ++ baseline), _ => health_applied(C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,7)))
def health_retry_observed(result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String) -> IO(Unit):
  match result:
    case (world,text): health_retry_baseline(text,F.health_observe(world))
def health_retry_finished(result:A.RunResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>>) -> IO(Unit):
  match result:
    case A.RunResult{world,status,escaped,observations,pings}: IO.bind(Unit,Unit,IO.print("health:B-retry:" ++ outcome(status) ++ ":escaped=" ++ handle_id(T.HealthSchema,escaped) ++ ":pings=" ++ List.show(&2,U32,U32.show,pings) ++ ":body=" ++ List.show(&2,U.Observation,body_observation,observations)), _ => health_retry_observed(health_snapshot(world)))
def health_retry_body(result:U.BodyResult<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,S.Handle<T.HealthSchema>>) -> IO(Unit):
  health_retry_finished(A.health_finished(result,4))
def health_failed_lookup(+selected:S.Handle<T.HealthSchema>,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & T.Access<T.VitalsView>) -> IO(Unit):
  match result:
    case (world,T.Missing{}): IO.bind(U.BodyResult<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,S.Handle<T.HealthSchema>>,Unit,A.health_invoke(U.health_b,Q.Retry{},3,health_audit,world,selected),health_retry_body)
    case (_, _): IO.print("health:FAILED-HANDLE-REVIVED")
def health_failed_escaped(selected:S.Handle<T.HealthSchema>,escaped:Maybe<&2,S.Handle<T.HealthSchema>>,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> IO(Unit):
  match escaped:
    case Some{failed}: health_failed_lookup(selected,S.with_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.VitalsView,world,failed,P.vitals_get))
    case None{}: IO.print("health:MISSING-ESCAPED")
def health_failed_baseline(selected:S.Handle<T.HealthSchema>,escaped:Maybe<&2,S.Handle<T.HealthSchema>>,first:String,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String) -> IO(Unit):
  match result:
    case (world,baseline): IO.bind(Unit,Unit,IO.print("health:FAIL=" ++ first ++ "\nhealth:FAIL-baseline=" ++ baseline), _ => health_failed_escaped(selected,escaped,world))
def health_failed_observed(selected:S.Handle<T.HealthSchema>,escaped:Maybe<&2,S.Handle<T.HealthSchema>>,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String) -> IO(Unit):
  match result:
    case (world,text): health_failed_baseline(selected,escaped,text,F.health_observe(world))
def health_failed_finished(selected:S.Handle<T.HealthSchema>,result:A.RunResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>>) -> IO(Unit):
  match result:
    case A.RunResult{world,status,+escaped,observations,pings}: IO.bind(Unit,Unit,IO.print("health:B-fail:" ++ outcome(status) ++ ":escaped=" ++ handle_id(T.HealthSchema,escaped) ++ ":pings=" ++ List.show(&2,U32,U32.show,pings) ++ ":body=" ++ List.show(&2,U.Observation,body_observation,observations)), _ => health_failed_observed(selected,escaped,health_snapshot(world)))
def health_failed_body(selected:S.Handle<T.HealthSchema>,result:U.BodyResult<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,S.Handle<T.HealthSchema>>) -> IO(Unit):
  health_failed_finished(selected,A.health_finished(result,3))
def health_a_baseline(+selected:S.Handle<T.HealthSchema>,first:String,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String) -> IO(Unit):
  match result:
    case (world,baseline): IO.bind(Unit,Unit,IO.print("health:A=" ++ first ++ "\nhealth:A-baseline=" ++ baseline), _ => IO.bind(U.BodyResult<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,S.Handle<T.HealthSchema>>,Unit,A.health_invoke(U.health_b,Q.BFail{},2,health_audit,world,selected), r => health_failed_body(selected,r)))
def health_a_observed(selected:S.Handle<T.HealthSchema>,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String) -> IO(Unit):
  match result:
    case (world,text): health_a_baseline(selected,text,F.health_observe(world))
def health_a_committed(selected:S.Handle<T.HealthSchema>,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,U32>) -> IO(Unit):
  match result:
    case (world,pings): IO.bind(Unit,Unit,IO.print("health:A-pings=" ++ List.show(&2,U32,U32.show,pings)), _ => health_a_observed(selected,health_snapshot(world)))
def health_a_spawned(selected:S.Handle<T.HealthSchema>,result:T.Reservation<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,S.Handle<T.HealthSchema>,T.Vitals>) -> IO(Unit):
  match result:
    case T.Reserved{owner,escaped}: IO.bind(Unit,Unit,IO.print("audit:health:A:attempt:1"), _ => health_a_committed(selected,X.storage_commit(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,X.tx_finish_success(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,A.health_emit(A.health_remove_flag(owner),T.HealthPing{1})),2)))
    case T.ReserveRejected{_,_}: IO.print("health:A-SPAWN-FAILED")
def health_a_started(+selected:S.Handle<T.HealthSchema>,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,a:S.Handle<T.HealthSchema>) -> IO(Unit):
  health_a_spawned(selected,A.health_spawn_flagged(A.health_set_ledger0(A.health_set_main0(X.tx_begin(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,world,a),T.VitalsToken{},11),T.HealthLedgerToken{},101),health_main(50)))
def health_seed_applied(selected:S.Handle<T.HealthSchema>,a:S.Handle<T.HealthSchema>,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,S.Change<T.HealthSchema>>) -> IO(Unit):
  match result:
    case (world,_): health_a_started(selected,world,a)
def health_seed_c(selected:S.Handle<T.HealthSchema>,a:S.Handle<T.HealthSchema>,result:T.Reservation<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> IO(Unit):
  match result:
    case T.Reserved{world,c}: health_seed_applied(selected,a,C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,1))
    case T.ReserveRejected{_,_}: IO.print("seed-c-failed")
def health_seed_b(a:S.Handle<T.HealthSchema>,result:T.Reservation<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> IO(Unit):
  match result:
    case T.Reserved{world,b}: health_seed_c(b,a,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,S.Bundle{None{},Some{T.Armor{F.vector(1),3}},Some{T.Tracked{8}}}))
    case T.ReserveRejected{_,_}: IO.print("seed-b-failed")
def health_seed_a(result:T.Reservation<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> IO(Unit):
  match result:
    case T.Reserved{world,a}: health_seed_b(a,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,S.Bundle{Some{health_main(20)},None{},None{}}))
    case T.ReserveRejected{_,_}: IO.print("seed-a-failed")
def health_created(result:T.Creation<S.Factory,S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>>) -> IO(Unit):
  match result:
    case T.Created{factory,world}: health_seed_a(C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,S.Bundle{Some{health_main(10)},Some{T.Armor{F.vector(1),3}},Some{T.Tracked{8}}}))
    case T.CreateRejected{_}: IO.print("create-failed")
def health() -> IO(Unit):
  health_created(I.create(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,health_ledger,I.factory(),T.HealthOn{}))

def main() -> IO(Unit):
  IO.bind(Unit,Unit,motion(), _ => health())
