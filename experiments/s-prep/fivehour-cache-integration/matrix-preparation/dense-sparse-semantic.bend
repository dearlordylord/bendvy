import Base
import ./measurement-bend.bend as M
import ./raw-boundaries.bend as B
import ./raw-reject-controls.bend as Audit
import ./types.bend as T
import ./storage.bend as S
import ./cache.bend as C
import ./cached-payload.bend as P
import ./payload.bend as Raw
import ./identity.bend as I
import ./dispatcher.bend as D
import ./schedule.bend as K
import ./host.bend as H
import ./observations.bend as O
import ./host-render.bend as J

def motion_snapshot(kind:String,pair:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> IO(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>):
  match pair:
    case (world,view):
      do IO<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>:
        IO.print("SEMANTIC-ONLY:motion:" ++ kind ++ ":" ++ J.render_world(T.PositionView,T.VelocityView,T.Selected,J.render_position,J.render_velocity,J.render_selected,T.LedgerView,T.MotionMode,J.render_ledger,J.render_motion_mode,view))
        return world
def motion_dump(state:D.Runtime<M.MotionBench,S.Handle<T.MotionSchema>>) -> IO(Unit):
  match state:
    case D.Runtime{M.MotionBench{H.Host{world,_,_,_,_,_,_},_,total,calls},_,_,+clock,_,_,_,_,_}:
      do IO<Unit>:
        IO.print("SEMANTIC-ONLY:motion:counts:" ++ U32.show(total) ++ ":" ++ U32.show(calls) ++ ":" ++ U32.show(D.clock_tick(clock)) ++ ":" ++ U32.show(M.clock_frame(clock)))
        cached : S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_snapshot("cached",O.world(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,P.position_get,Raw.velocity_get,P.motion_ledger_get,world))
        observed : S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_snapshot("raw",O.world(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,Audit.motion_main_audit,Raw.velocity_get,Audit.motion_ledger_audit,cached))
        return Unit{}
def motion_run(pair:D.Runtime<M.MotionBench,S.Handle<T.MotionSchema>> & K.System) -> IO(Unit):
  match pair:
    case (state,system): IO.bind(D.Runtime<M.MotionBench,S.Handle<T.MotionSchema>>,Unit,M.motion_loops(64n,system,state),motion_dump)
def motion_start(count:U32,sparse:Bool) -> IO(Unit):
  IO.bind(D.Runtime<M.MotionBench,S.Handle<T.MotionSchema>> & K.System,Unit,M.motion_created(count,sparse,B.motion_create(M.motion_ledger,I.factory(),T.MotionOn{})),motion_run)

def health_snapshot(kind:String,pair:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> IO(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>):
  match pair:
    case (world,view):
      do IO<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>:
        IO.print("SEMANTIC-ONLY:health:" ++ kind ++ ":" ++ J.render_world(T.VitalsView,T.ArmorView,T.Tracked,J.render_vitals,J.render_armor,J.render_tracked,T.LedgerView,T.HealthMode,J.render_ledger,J.render_health_mode,view))
        return world
def health_dump(state:D.Runtime<M.HealthBench,S.Handle<T.HealthSchema>>) -> IO(Unit):
  match state:
    case D.Runtime{M.HealthBench{H.Host{world,_,_,_,_,_,_},_,total,calls},_,_,+clock,_,_,_,_,_}:
      do IO<Unit>:
        IO.print("SEMANTIC-ONLY:health:counts:" ++ U32.show(total) ++ ":" ++ U32.show(calls) ++ ":" ++ U32.show(D.clock_tick(clock)) ++ ":" ++ U32.show(M.clock_frame(clock)))
        cached : S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_snapshot("cached",O.world(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,P.vitals_get,Raw.armor_get,P.health_ledger_get,world))
        observed : S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_snapshot("raw",O.world(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,Audit.health_main_audit,Raw.armor_get,Audit.health_ledger_audit,cached))
        return Unit{}
def health_run(pair:D.Runtime<M.HealthBench,S.Handle<T.HealthSchema>> & K.System) -> IO(Unit):
  match pair:
    case (state,system): IO.bind(D.Runtime<M.HealthBench,S.Handle<T.HealthSchema>>,Unit,M.health_loops(64n,system,state),health_dump)
def health_start(count:U32,sparse:Bool) -> IO(Unit):
  IO.bind(D.Runtime<M.HealthBench,S.Handle<T.HealthSchema>> & K.System,Unit,M.health_created(count,sparse,B.health_create(M.health_ledger,I.factory(),T.HealthOn{})),health_run)

def choose(schema:U32,sparse:U32,count:U32) -> IO(Unit):
  match schema:
    case 0: motion_start(count,U32.is_eq(sparse,1))
    case 1: health_start(count,U32.is_eq(sparse,1))
    case _: IO.die(Unit,2,"schema")
def parsed(schema:Maybe<&2,U32>,sparse:Maybe<&2,U32>,count:Maybe<&2,U32>) -> IO(Unit):
  match schema sparse count:
    case Some{schema} Some{sparse} Some{count}: choose(schema,sparse,count)
    case _ _ _: IO.die(Unit,2,"args")
def args(values:List<String>) -> IO(Unit):
  match values:
    case Con{_,Con{schema,Con{sparse,Con{count,_}}}}: parsed(U32.read(schema),U32.read(sparse),U32.read(count))
    case _: IO.die(Unit,2,"schema sparse count required")
def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    args(values)
