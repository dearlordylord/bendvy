import Base
import ./types.bend as T
import ./storage.bend as S
import ./identity.bend as I
import ./commands.bend as C
import ./storage-stage-fixture.bend as F
import ./transaction-dispatch-adapters.bend as A
import ./audited-invoker.bend as V
import ./observations.bend as O
import ./payload.bend as P
import ./observation-render.bend as Z
import ./schedule.bend as Q
import ./dispatcher.bend as D

def handle_id(-Schema:Data,value:Maybe<&2,S.Handle<Schema>>) -> String:
  match value:
    case Some{S.Handle{namespace,id}}: U32.show(namespace) ++ ":" ++ U32.show(id)
    case None{}: "none"
def outcome(value:T.Outcome) -> String:
  match value:
    case T.Success{}: "success"
    case T.Failure{code}: "failure" ++ U32.show(code)
def motion_main(value:U32) -> T.Position:
  T.Position{F.vector(value),7}
def motion_ledger(u:Unit) -> T.MotionLedger:
  T.MotionLedger{F.vector(100),4}
def motion_end(audit:D.Audit) -> IO(Unit):
  IO.bind(D.Audit,Unit,D.audit_log(audit,"after-retry-B"), _ => IO.pure(Unit,Unit{}))
def motion_retry_world(audit:D.Audit,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> IO(Unit):
  match pair:
    case (world,view): IO.bind(Unit,Unit,IO.print("motion:RETRY=" ++ Z.motion(view)), _ => motion_end(audit))
def motion_retry(result:V.ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>>) -> IO(Unit):
  match result:
    case V.ServiceResult{A.RunResult{world,status,escaped,observations,pings},audit}: IO.bind(Unit,Unit,IO.print("motion:retry:" ++ outcome(status) ++ ":escaped=" ++ handle_id(T.MotionSchema,escaped) ++ ":pings=" ++ List.show(&2,U32,U32.show,pings)), _ => motion_retry_world(audit,O.world(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,P.position_get,P.velocity_get,P.motion_ledger_get,world)))
def motion_after_fail(selected:S.Handle<T.MotionSchema>,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,audit:D.Audit) -> IO(Unit):
  IO.bind(D.Audit,Unit,D.audit_log(audit,"after-failed-B"), a => IO.bind(V.ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>>,Unit,V.motion_b(Q.Retry{},3,4,world,selected,a),motion_retry))
def motion_fail_world(selected:S.Handle<T.MotionSchema>,audit:D.Audit,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> IO(Unit):
  match pair:
    case (world,view): IO.bind(Unit,Unit,IO.print("motion:FAIL=" ++ Z.motion(view)), _ => motion_after_fail(selected,world,audit))
def motion_failed(selected:S.Handle<T.MotionSchema>,result:V.ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>>) -> IO(Unit):
  match result:
    case V.ServiceResult{A.RunResult{world,status,escaped,observations,pings},audit}: IO.bind(Unit,Unit,IO.print("motion:failed:" ++ outcome(status) ++ ":escaped=" ++ handle_id(T.MotionSchema,escaped) ++ ":pings=" ++ List.show(&2,U32,U32.show,pings)), _ => motion_fail_world(selected,audit,O.world(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,P.position_get,P.velocity_get,P.motion_ledger_get,world)))
def motion_after_a(+selected:S.Handle<T.MotionSchema>,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,audit:D.Audit) -> IO(Unit):
  IO.bind(D.Audit,Unit,D.audit_log(audit,"after-A"), a => IO.bind(V.ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>>,Unit,V.motion_b(Q.BFail{},2,3,world,selected,a), r => motion_failed(selected,r)))
def motion_a_world(selected:S.Handle<T.MotionSchema>,audit:D.Audit,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> IO(Unit):
  match pair:
    case (world,view): IO.bind(Unit,Unit,IO.print("motion:A=" ++ Z.motion(view)), _ => motion_after_a(selected,world,audit))
def motion_a_done(selected:S.Handle<T.MotionSchema>,result:V.ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>>) -> IO(Unit):
  match result:
    case V.ServiceResult{A.RunResult{world,status,escaped,observations,pings},audit}: IO.bind(Unit,Unit,IO.print("motion:A-result:" ++ outcome(status) ++ ":escaped=" ++ handle_id(T.MotionSchema,escaped) ++ ":pings=" ++ List.show(&2,U32,U32.show,pings)), _ => motion_a_world(selected,audit,O.world(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,P.position_get,P.velocity_get,P.motion_ledger_get,world)))
def motion_a_started(+selected:S.Handle<T.MotionSchema>,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,a:S.Handle<T.MotionSchema>) -> IO(Unit):
  IO.bind(V.ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>>,Unit,V.motion_a(1,T.Failure{99},2,world,a,D.Console{}), r => motion_a_done(selected,r))
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
def health_end(audit:D.Audit) -> IO(Unit):
  IO.bind(D.Audit,Unit,D.audit_log(audit,"after-retry-B"), _ => IO.pure(Unit,Unit{}))
def health_retry_world(audit:D.Audit,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> IO(Unit):
  match pair:
    case (world,view): IO.bind(Unit,Unit,IO.print("health:RETRY=" ++ Z.health(view)), _ => health_end(audit))
def health_retry(result:V.ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>>) -> IO(Unit):
  match result:
    case V.ServiceResult{A.RunResult{world,status,escaped,observations,pings},audit}: IO.bind(Unit,Unit,IO.print("health:retry:" ++ outcome(status) ++ ":escaped=" ++ handle_id(T.HealthSchema,escaped) ++ ":pings=" ++ List.show(&2,U32,U32.show,pings)), _ => health_retry_world(audit,O.world(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,P.vitals_get,P.armor_get,P.health_ledger_get,world)))
def health_after_fail(selected:S.Handle<T.HealthSchema>,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,audit:D.Audit) -> IO(Unit):
  IO.bind(D.Audit,Unit,D.audit_log(audit,"after-failed-B"), a => IO.bind(V.ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>>,Unit,V.health_b(Q.Retry{},3,4,world,selected,a),health_retry))
def health_fail_world(selected:S.Handle<T.HealthSchema>,audit:D.Audit,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> IO(Unit):
  match pair:
    case (world,view): IO.bind(Unit,Unit,IO.print("health:FAIL=" ++ Z.health(view)), _ => health_after_fail(selected,world,audit))
def health_failed(selected:S.Handle<T.HealthSchema>,result:V.ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>>) -> IO(Unit):
  match result:
    case V.ServiceResult{A.RunResult{world,status,escaped,observations,pings},audit}: IO.bind(Unit,Unit,IO.print("health:failed:" ++ outcome(status) ++ ":escaped=" ++ handle_id(T.HealthSchema,escaped) ++ ":pings=" ++ List.show(&2,U32,U32.show,pings)), _ => health_fail_world(selected,audit,O.world(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,P.vitals_get,P.armor_get,P.health_ledger_get,world)))
def health_after_a(+selected:S.Handle<T.HealthSchema>,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,audit:D.Audit) -> IO(Unit):
  IO.bind(D.Audit,Unit,D.audit_log(audit,"after-A"), a => IO.bind(V.ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>>,Unit,V.health_b(Q.BFail{},2,3,world,selected,a), r => health_failed(selected,r)))
def health_a_world(selected:S.Handle<T.HealthSchema>,audit:D.Audit,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> IO(Unit):
  match pair:
    case (world,view): IO.bind(Unit,Unit,IO.print("health:A=" ++ Z.health(view)), _ => health_after_a(selected,world,audit))
def health_a_done(selected:S.Handle<T.HealthSchema>,result:V.ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>>) -> IO(Unit):
  match result:
    case V.ServiceResult{A.RunResult{world,status,escaped,observations,pings},audit}: IO.bind(Unit,Unit,IO.print("health:A-result:" ++ outcome(status) ++ ":escaped=" ++ handle_id(T.HealthSchema,escaped) ++ ":pings=" ++ List.show(&2,U32,U32.show,pings)), _ => health_a_world(selected,audit,O.world(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,P.vitals_get,P.armor_get,P.health_ledger_get,world)))
def health_a_started(+selected:S.Handle<T.HealthSchema>,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,a:S.Handle<T.HealthSchema>) -> IO(Unit):
  IO.bind(V.ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>>,Unit,V.health_a(1,T.Failure{99},2,world,a,D.Console{}), r => health_a_done(selected,r))
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
