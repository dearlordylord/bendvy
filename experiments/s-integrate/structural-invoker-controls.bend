import Base
import ./types.bend as T
import ./storage.bend as S
import ./identity.bend as I
import ./commands.bend as C
import ./payload.bend as P
import ./storage-stage-fixture.bend as F
import ./structural-invoker.bend as V
import ./transaction-dispatch-adapters.bend as A
import ./observations.bend as O
import ./observation-render.bend as Z

def change(-Schema:Data,value:S.Change<Schema>) -> String:
  match value:
    case S.MainAdded{S.Handle{ns,id}}: "added:" ++ U32.show(ns) ++ ":" ++ U32.show(id)
    case S.MainChanged{S.Handle{ns,id}}: "changed:" ++ U32.show(ns) ++ ":" ++ U32.show(id)
    case S.MainRemoved{S.Handle{ns,id}}: "removed:" ++ U32.show(ns) ++ ":" ++ U32.show(id)
    case S.Despawned{S.Handle{ns,id}}: "despawned:" ++ U32.show(ns) ++ ":" ++ U32.show(id)
def motion_main(value:U32) -> T.Position:
  T.Position{F.vector(value),7}
def motion_ledger(u:Unit) -> T.MotionLedger:
  T.MotionLedger{Array.set(U32,F.vector(100),0,201),4}
def motion_snapshot_done(pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String:
  match pair:
    case (world,view): (world,Z.motion(view))
def motion_snapshot(world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String:
  motion_snapshot_done(O.world(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,P.position_get,P.velocity_get,P.motion_ledger_get,world))
def motion_dispose_final(pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String) -> IO(Unit):
  match pair:
    case (world,text): IO.print("motion:DISPOSE-after=" ++ text)
def motion_dispose_applied(pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,S.Change<T.MotionSchema>>) -> IO(Unit):
  match pair:
    case (world,changes): IO.bind(Unit,Unit,IO.print("motion:DISPOSE-changes=" ++ List.show(&2,S.Change<T.MotionSchema>,change(T.MotionSchema),changes)), _ => motion_dispose_final(motion_snapshot(world)))
def motion_dispose_pending(pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String) -> IO(Unit):
  match pair:
    case (world,text): IO.bind(Unit,Unit,IO.print("motion:DISPOSE-before=" ++ text), _ => motion_dispose_applied(C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,5)))
def motion_disposed(result:V.Batch<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit>) -> IO(Unit):
  match result:
    case V.Batch{world,rejected}: IO.bind(Unit,Unit,IO.print("motion:DISPOSE-rejected=" ++ Nat.show(List.length(&1,Unit,rejected))), _ => motion_dispose_pending(motion_snapshot(world)))
def motion_insert_final(a:S.Handle<T.MotionSchema>,c:S.Handle<T.MotionSchema>,p:S.Handle<T.MotionSchema>,r:S.Handle<T.MotionSchema>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String) -> IO(Unit):
  match pair:
    case (world,text): IO.bind(Unit,Unit,IO.print("motion:INSERTS-after=" ++ text), _ => motion_disposed(V.motion_dispose(world,c,a,p,r)))
def motion_insert_applied(a:S.Handle<T.MotionSchema>,c:S.Handle<T.MotionSchema>,p:S.Handle<T.MotionSchema>,r:S.Handle<T.MotionSchema>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,S.Change<T.MotionSchema>>) -> IO(Unit):
  match pair:
    case (world,changes): IO.bind(Unit,Unit,IO.print("motion:INSERTS-changes=" ++ List.show(&2,S.Change<T.MotionSchema>,change(T.MotionSchema),changes)), _ => motion_insert_final(a,c,p,r,motion_snapshot(world)))
def motion_insert_pending(a:S.Handle<T.MotionSchema>,c:S.Handle<T.MotionSchema>,p:S.Handle<T.MotionSchema>,r:S.Handle<T.MotionSchema>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String) -> IO(Unit):
  match pair:
    case (world,text): IO.bind(Unit,Unit,IO.print("motion:INSERTS-before=" ++ text), _ => motion_insert_applied(a,c,p,r,C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,4)))
def motion_inserted(a:S.Handle<T.MotionSchema>,c:S.Handle<T.MotionSchema>,p:S.Handle<T.MotionSchema>,r:S.Handle<T.MotionSchema>,result:V.Batch<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position>) -> IO(Unit):
  match result:
    case V.Batch{world,rejected}: IO.bind(Unit,Unit,IO.print("motion:INSERTS-rejected=" ++ Nat.show(List.length(&1,T.Position,rejected))), _ => motion_insert_pending(a,c,p,r,motion_snapshot(world)))
def motion_cleanup_final(+a:S.Handle<T.MotionSchema>,b:S.Handle<T.MotionSchema>,+c:S.Handle<T.MotionSchema>,+p:S.Handle<T.MotionSchema>,r:S.Handle<T.MotionSchema>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String) -> IO(Unit):
  match pair:
    case (world,text): IO.bind(Unit,Unit,IO.print("motion:CLEANUP-after=" ++ text), _ => motion_inserted(a,c,p,r,V.motion_inserts(world,p,a,c,b,motion_main(71),motion_main(80),motion_main(30),motion_main(81),motion_main(90))))
def motion_cleanup_applied(a:S.Handle<T.MotionSchema>,b:S.Handle<T.MotionSchema>,c:S.Handle<T.MotionSchema>,p:S.Handle<T.MotionSchema>,r:S.Handle<T.MotionSchema>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,S.Change<T.MotionSchema>>) -> IO(Unit):
  match pair:
    case (world,changes): IO.bind(Unit,Unit,IO.print("motion:CLEANUP-changes=" ++ List.show(&2,S.Change<T.MotionSchema>,change(T.MotionSchema),changes)), _ => motion_cleanup_final(a,b,c,p,r,motion_snapshot(world)))
def motion_cleanup_pending(a:S.Handle<T.MotionSchema>,b:S.Handle<T.MotionSchema>,c:S.Handle<T.MotionSchema>,p:S.Handle<T.MotionSchema>,r:S.Handle<T.MotionSchema>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String) -> IO(Unit):
  match pair:
    case (world,text): IO.bind(Unit,Unit,IO.print("motion:CLEANUP-before=" ++ text), _ => motion_cleanup_applied(a,b,c,p,r,C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,3)))
def motion_cleaned(a:S.Handle<T.MotionSchema>,b:S.Handle<T.MotionSchema>,c:S.Handle<T.MotionSchema>,p:S.Handle<T.MotionSchema>,r:S.Handle<T.MotionSchema>,result:A.RunResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>>) -> IO(Unit):
  match result:
    case A.RunResult{world,status,escaped,observations,pings}: IO.bind(Unit,Unit,IO.print("motion:CLEANUP-pings=" ++ List.show(&2,U32,U32.show,pings)), _ => motion_cleanup_pending(a,b,c,p,r,motion_snapshot(world)))
def motion_seed_applied(+a:S.Handle<T.MotionSchema>,+b:S.Handle<T.MotionSchema>,c:S.Handle<T.MotionSchema>,+p:S.Handle<T.MotionSchema>,r:S.Handle<T.MotionSchema>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,S.Change<T.MotionSchema>>) -> IO(Unit):
  match pair:
    case (world,changes): motion_cleaned(a,b,c,p,r,V.motion_cleanup(world,p,a,b,2))
def motion_r(a:S.Handle<T.MotionSchema>,b:S.Handle<T.MotionSchema>,c:S.Handle<T.MotionSchema>,p:S.Handle<T.MotionSchema>,result:T.Reservation<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>) -> IO(Unit):
  match result:
    case T.Reserved{world,r}: motion_seed_applied(a,b,c,p,r,C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,1))
    case T.ReserveRejected{_,_}: IO.print("reserve-r-failed")
def motion_q(a:S.Handle<T.MotionSchema>,b:S.Handle<T.MotionSchema>,c:S.Handle<T.MotionSchema>,p:S.Handle<T.MotionSchema>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & Maybe<&2,S.Handle<T.MotionSchema>>) -> IO(Unit):
  match pair:
    case (world,Some{q}): motion_r(a,b,c,p,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,S.Bundle{Some{motion_main(60)},None{},None{}}))
    case (_,None{}): IO.print("reserve-q-failed")
def motion_p(a:S.Handle<T.MotionSchema>,b:S.Handle<T.MotionSchema>,c:S.Handle<T.MotionSchema>,result:T.Reservation<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>) -> IO(Unit):
  match result:
    case T.Reserved{world,p}: motion_q(a,b,c,p,I.reserve_id(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world))
    case T.ReserveRejected{_,_}: IO.print("reserve-p-failed")
def motion_c(a:S.Handle<T.MotionSchema>,b:S.Handle<T.MotionSchema>,result:T.Reservation<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>) -> IO(Unit):
  match result:
    case T.Reserved{world,c}: motion_p(a,b,c,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,S.Bundle{Some{motion_main(50)},None{},Some{T.Selected{8}}}))
    case T.ReserveRejected{_,_}: IO.print("reserve-c-failed")
def motion_b(a:S.Handle<T.MotionSchema>,result:T.Reservation<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>) -> IO(Unit):
  match result:
    case T.Reserved{world,b}: motion_c(a,b,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,S.Bundle{None{},Some{T.Velocity{F.vector(1),True{}}},Some{T.Selected{8}}}))
    case T.ReserveRejected{_,_}: IO.print("reserve-b-failed")
def motion_a(result:T.Reservation<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>) -> IO(Unit):
  match result:
    case T.Reserved{world,a}: motion_b(a,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,S.Bundle{Some{T.Position{Array.set(U32,F.vector(20),0,50),7}},None{},Some{T.Selected{8}}}))
    case T.ReserveRejected{_,_}: IO.print("reserve-a-failed")
def motion_created(result:T.Creation<S.Factory,S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>>) -> IO(Unit):
  match result:
    case T.Created{factory,world}: motion_a(C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,S.Bundle{Some{T.Position{Array.set(U32,F.vector(10),0,11),7}},Some{T.Velocity{F.vector(1),True{}}},None{}}))
    case T.CreateRejected{_}: IO.print("create-failed")
def motion() -> IO(Unit):
  motion_created(I.create(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,motion_ledger,I.factory(),T.MotionOn{}))
def health_main(value:U32) -> T.Vitals:
  T.Vitals{F.vector(value),9,2}
def health_ledger(u:Unit) -> T.HealthLedger:
  T.HealthLedger{Array.set(U32,F.vector(100),0,201),4}
def health_snapshot_done(pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String:
  match pair:
    case (world,view): (world,Z.health(view))
def health_snapshot(world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String:
  health_snapshot_done(O.world(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,P.vitals_get,P.armor_get,P.health_ledger_get,world))
def health_dispose_final(pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String) -> IO(Unit):
  match pair:
    case (world,text): IO.print("health:DISPOSE-after=" ++ text)
def health_dispose_applied(pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,S.Change<T.HealthSchema>>) -> IO(Unit):
  match pair:
    case (world,changes): IO.bind(Unit,Unit,IO.print("health:DISPOSE-changes=" ++ List.show(&2,S.Change<T.HealthSchema>,change(T.HealthSchema),changes)), _ => health_dispose_final(health_snapshot(world)))
def health_dispose_pending(pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String) -> IO(Unit):
  match pair:
    case (world,text): IO.bind(Unit,Unit,IO.print("health:DISPOSE-before=" ++ text), _ => health_dispose_applied(C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,5)))
def health_disposed(result:V.Batch<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit>) -> IO(Unit):
  match result:
    case V.Batch{world,rejected}: IO.bind(Unit,Unit,IO.print("health:DISPOSE-rejected=" ++ Nat.show(List.length(&1,Unit,rejected))), _ => health_dispose_pending(health_snapshot(world)))
def health_insert_final(a:S.Handle<T.HealthSchema>,c:S.Handle<T.HealthSchema>,p:S.Handle<T.HealthSchema>,r:S.Handle<T.HealthSchema>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String) -> IO(Unit):
  match pair:
    case (world,text): IO.bind(Unit,Unit,IO.print("health:INSERTS-after=" ++ text), _ => health_disposed(V.health_dispose(world,c,a,p,r)))
def health_insert_applied(a:S.Handle<T.HealthSchema>,c:S.Handle<T.HealthSchema>,p:S.Handle<T.HealthSchema>,r:S.Handle<T.HealthSchema>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,S.Change<T.HealthSchema>>) -> IO(Unit):
  match pair:
    case (world,changes): IO.bind(Unit,Unit,IO.print("health:INSERTS-changes=" ++ List.show(&2,S.Change<T.HealthSchema>,change(T.HealthSchema),changes)), _ => health_insert_final(a,c,p,r,health_snapshot(world)))
def health_insert_pending(a:S.Handle<T.HealthSchema>,c:S.Handle<T.HealthSchema>,p:S.Handle<T.HealthSchema>,r:S.Handle<T.HealthSchema>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String) -> IO(Unit):
  match pair:
    case (world,text): IO.bind(Unit,Unit,IO.print("health:INSERTS-before=" ++ text), _ => health_insert_applied(a,c,p,r,C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,4)))
def health_inserted(a:S.Handle<T.HealthSchema>,c:S.Handle<T.HealthSchema>,p:S.Handle<T.HealthSchema>,r:S.Handle<T.HealthSchema>,result:V.Batch<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals>) -> IO(Unit):
  match result:
    case V.Batch{world,rejected}: IO.bind(Unit,Unit,IO.print("health:INSERTS-rejected=" ++ Nat.show(List.length(&1,T.Vitals,rejected))), _ => health_insert_pending(a,c,p,r,health_snapshot(world)))
def health_cleanup_final(+a:S.Handle<T.HealthSchema>,b:S.Handle<T.HealthSchema>,+c:S.Handle<T.HealthSchema>,+p:S.Handle<T.HealthSchema>,r:S.Handle<T.HealthSchema>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String) -> IO(Unit):
  match pair:
    case (world,text): IO.bind(Unit,Unit,IO.print("health:CLEANUP-after=" ++ text), _ => health_inserted(a,c,p,r,V.health_inserts(world,p,a,c,b,health_main(71),health_main(80),health_main(30),health_main(81),health_main(90))))
def health_cleanup_applied(a:S.Handle<T.HealthSchema>,b:S.Handle<T.HealthSchema>,c:S.Handle<T.HealthSchema>,p:S.Handle<T.HealthSchema>,r:S.Handle<T.HealthSchema>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,S.Change<T.HealthSchema>>) -> IO(Unit):
  match pair:
    case (world,changes): IO.bind(Unit,Unit,IO.print("health:CLEANUP-changes=" ++ List.show(&2,S.Change<T.HealthSchema>,change(T.HealthSchema),changes)), _ => health_cleanup_final(a,b,c,p,r,health_snapshot(world)))
def health_cleanup_pending(a:S.Handle<T.HealthSchema>,b:S.Handle<T.HealthSchema>,c:S.Handle<T.HealthSchema>,p:S.Handle<T.HealthSchema>,r:S.Handle<T.HealthSchema>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String) -> IO(Unit):
  match pair:
    case (world,text): IO.bind(Unit,Unit,IO.print("health:CLEANUP-before=" ++ text), _ => health_cleanup_applied(a,b,c,p,r,C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,3)))
def health_cleaned(a:S.Handle<T.HealthSchema>,b:S.Handle<T.HealthSchema>,c:S.Handle<T.HealthSchema>,p:S.Handle<T.HealthSchema>,r:S.Handle<T.HealthSchema>,result:A.RunResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>>) -> IO(Unit):
  match result:
    case A.RunResult{world,status,escaped,observations,pings}: IO.bind(Unit,Unit,IO.print("health:CLEANUP-pings=" ++ List.show(&2,U32,U32.show,pings)), _ => health_cleanup_pending(a,b,c,p,r,health_snapshot(world)))
def health_seed_applied(+a:S.Handle<T.HealthSchema>,+b:S.Handle<T.HealthSchema>,c:S.Handle<T.HealthSchema>,+p:S.Handle<T.HealthSchema>,r:S.Handle<T.HealthSchema>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,S.Change<T.HealthSchema>>) -> IO(Unit):
  match pair:
    case (world,changes): health_cleaned(a,b,c,p,r,V.health_cleanup(world,p,a,b,2))
def health_r(a:S.Handle<T.HealthSchema>,b:S.Handle<T.HealthSchema>,c:S.Handle<T.HealthSchema>,p:S.Handle<T.HealthSchema>,result:T.Reservation<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> IO(Unit):
  match result:
    case T.Reserved{world,r}: health_seed_applied(a,b,c,p,r,C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,1))
    case T.ReserveRejected{_,_}: IO.print("reserve-r-failed")
def health_q(a:S.Handle<T.HealthSchema>,b:S.Handle<T.HealthSchema>,c:S.Handle<T.HealthSchema>,p:S.Handle<T.HealthSchema>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & Maybe<&2,S.Handle<T.HealthSchema>>) -> IO(Unit):
  match pair:
    case (world,Some{q}): health_r(a,b,c,p,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,S.Bundle{Some{health_main(60)},None{},None{}}))
    case (_,None{}): IO.print("reserve-q-failed")
def health_p(a:S.Handle<T.HealthSchema>,b:S.Handle<T.HealthSchema>,c:S.Handle<T.HealthSchema>,result:T.Reservation<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> IO(Unit):
  match result:
    case T.Reserved{world,p}: health_q(a,b,c,p,I.reserve_id(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world))
    case T.ReserveRejected{_,_}: IO.print("reserve-p-failed")
def health_c(a:S.Handle<T.HealthSchema>,b:S.Handle<T.HealthSchema>,result:T.Reservation<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> IO(Unit):
  match result:
    case T.Reserved{world,c}: health_p(a,b,c,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,S.Bundle{Some{health_main(50)},None{},Some{T.Tracked{8}}}))
    case T.ReserveRejected{_,_}: IO.print("reserve-c-failed")
def health_b(a:S.Handle<T.HealthSchema>,result:T.Reservation<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> IO(Unit):
  match result:
    case T.Reserved{world,b}: health_c(a,b,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,S.Bundle{None{},Some{T.Armor{F.vector(1),3}},Some{T.Tracked{8}}}))
    case T.ReserveRejected{_,_}: IO.print("reserve-b-failed")
def health_a(result:T.Reservation<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> IO(Unit):
  match result:
    case T.Reserved{world,a}: health_b(a,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,S.Bundle{Some{T.Vitals{Array.set(U32,F.vector(20),0,50),9,2}},None{},Some{T.Tracked{8}}}))
    case T.ReserveRejected{_,_}: IO.print("reserve-a-failed")
def health_created(result:T.Creation<S.Factory,S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>>) -> IO(Unit):
  match result:
    case T.Created{factory,world}: health_a(C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,S.Bundle{Some{T.Vitals{Array.set(U32,F.vector(10),0,11),9,2}},Some{T.Armor{F.vector(1),3}},None{}}))
    case T.CreateRejected{_}: IO.print("create-failed")
def health() -> IO(Unit):
  health_created(I.create(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,health_ledger,I.factory(),T.HealthOn{}))

def main() -> IO(Unit):
  IO.bind(Unit,Unit,motion(), _ => health())
