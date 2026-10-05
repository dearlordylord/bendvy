import Base
import ./measurement-bend.bend as M
import ./raw-boundaries.bend as RB
import ./types.bend as T
import ./cache.bend as CC
import ./storage.bend as S
import ./identity.bend as I
import ./query.bend as Q
import ./observations.bend as O
import ./host.bend as H
import ./dispatcher.bend as D
import ./readers.bend as R
import ./schedule.bend as K
import ./host-render.bend as JSON
import ./original-raw-observer.bend as RP

def raw_done(-Raw:Type,-View:Data,cached:View,result:Raw & View) -> CC.Cache<Raw,View> & View:
  match result:
    case (raw,view): (CC.Cache{raw,cached},view)
def raw_get(~Raw:Type,~View:Data,~get:Raw -> Raw & View,owner:CC.Cache<Raw,View>) -> CC.Cache<Raw,View> & View:
  match owner:
    case CC.Cache{raw,cached}: raw_done(Raw,View,cached,get(raw))
def motion_raw(owner:CC.Cache<T.Position,T.PositionView>) -> CC.Cache<T.Position,T.PositionView> & T.PositionView:
  raw_get(~T.Position,~T.PositionView,~RP.position_get,owner)
def motion_ledger_raw(owner:CC.Cache<T.MotionLedger,T.LedgerView>) -> CC.Cache<T.MotionLedger,T.LedgerView> & T.LedgerView:
  raw_get(~T.MotionLedger,~T.LedgerView,~RP.motion_ledger_get,owner)
def motion_world(owner:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>) -> S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>:
  O.world(T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,motion_raw,RP.velocity_get,motion_ledger_raw,owner)
def motion_emit(total:U32,calls:U32,+clock:R.Clock,before:O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>,queries:List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>,result:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> IO(Unit):
  match result:
    case (_,after): IO.print("{\"readsum\":" ++ U32.show(total) ++ ",\"calls\":" ++ U32.show(calls) ++ ",\"tick\":" ++ U32.show(D.clock_tick(clock)) ++ ",\"frames\":" ++ U32.show(M.clock_frame(clock)) ++ ",\"world\":" ++ JSON.render_world(T.PositionView,T.VelocityView,T.Selected,JSON.render_position,JSON.render_velocity,JSON.render_selected,T.LedgerView,T.MotionMode,JSON.render_ledger,JSON.render_motion_mode,before) ++ ",\"query\":" ++ JSON.render_list(O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>,JSON.render_query(~T.MotionSchema,~T.PositionView,~T.VelocityView,~T.Selected,~JSON.render_position,~JSON.render_velocity,~JSON.render_selected),queries) ++ ",\"afterQuery\":" ++ JSON.render_world(T.PositionView,T.VelocityView,T.Selected,JSON.render_position,JSON.render_velocity,JSON.render_selected,T.LedgerView,T.MotionMode,JSON.render_ledger,JSON.render_motion_mode,after) ++ "}")
def motion_queried(total:U32,calls:U32,clock:R.Clock,before:O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>,result:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>) -> IO(Unit):
  match result:
    case (owner,queries): motion_emit(total,calls,clock,before,queries,motion_world(owner))
def motion_observed(total:U32,calls:U32,clock:R.Clock,result:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> IO(Unit):
  match result:
    case (owner,before): motion_queried(total,calls,clock,before,Q.each(T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,T.PositionToken,T.PositionView,T.VelocityView,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,motion_raw,RP.velocity_get,O.client(~T.MotionSchema,~T.PositionToken,~T.PositionView,~T.VelocityView,~T.Selected,~T.PositionToken{}),Q.Optional{},owner))
def motion_dump(state:D.Runtime<M.MotionBench,S.Handle<T.MotionSchema>>) -> IO(Unit):
  match state:
    case D.Runtime{M.MotionBench{H.Host{world,_,_,_,_,_,_},_,total,calls},_,_,clock,_,_,_,_,_}: motion_observed(total,calls,clock,motion_world(world))
def motion_run(result:D.Runtime<M.MotionBench,S.Handle<T.MotionSchema>> & K.System) -> IO(Unit):
  match result:
    case (state,system): IO.bind(D.Runtime<M.MotionBench,S.Handle<T.MotionSchema>>,Unit,M.motion_loops(64n,system,state),motion_dump)
def motion_start(count:U32,sparse:Bool) -> IO(Unit):
  IO.bind(D.Runtime<M.MotionBench,S.Handle<T.MotionSchema>> & K.System,Unit,M.motion_created(count,sparse,RB.motion_create(M.motion_ledger,I.factory(),T.MotionOn{})),motion_run)
def health_raw(owner:CC.Cache<T.Vitals,T.VitalsView>) -> CC.Cache<T.Vitals,T.VitalsView> & T.VitalsView:
  raw_get(~T.Vitals,~T.VitalsView,~RP.vitals_get,owner)
def health_ledger_raw(owner:CC.Cache<T.HealthLedger,T.LedgerView>) -> CC.Cache<T.HealthLedger,T.LedgerView> & T.LedgerView:
  raw_get(~T.HealthLedger,~T.LedgerView,~RP.health_ledger_get,owner)
def health_world(owner:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>) -> S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>:
  O.world(T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,health_raw,RP.armor_get,health_ledger_raw,owner)
def health_emit(total:U32,calls:U32,+clock:R.Clock,before:O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>,queries:List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>,result:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> IO(Unit):
  match result:
    case (_,after): IO.print("{\"readsum\":" ++ U32.show(total) ++ ",\"calls\":" ++ U32.show(calls) ++ ",\"tick\":" ++ U32.show(D.clock_tick(clock)) ++ ",\"frames\":" ++ U32.show(M.clock_frame(clock)) ++ ",\"world\":" ++ JSON.render_world(T.VitalsView,T.ArmorView,T.Tracked,JSON.render_vitals,JSON.render_armor,JSON.render_tracked,T.LedgerView,T.HealthMode,JSON.render_ledger,JSON.render_health_mode,before) ++ ",\"query\":" ++ JSON.render_list(O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>,JSON.render_query(~T.HealthSchema,~T.VitalsView,~T.ArmorView,~T.Tracked,~JSON.render_vitals,~JSON.render_armor,~JSON.render_tracked),queries) ++ ",\"afterQuery\":" ++ JSON.render_world(T.VitalsView,T.ArmorView,T.Tracked,JSON.render_vitals,JSON.render_armor,JSON.render_tracked,T.LedgerView,T.HealthMode,JSON.render_ledger,JSON.render_health_mode,after) ++ "}")
def health_queried(total:U32,calls:U32,clock:R.Clock,before:O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>,result:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>) -> IO(Unit):
  match result:
    case (owner,queries): health_emit(total,calls,clock,before,queries,health_world(owner))
def health_observed(total:U32,calls:U32,clock:R.Clock,result:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> IO(Unit):
  match result:
    case (owner,before): health_queried(total,calls,clock,before,Q.each(T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,T.VitalsToken,T.VitalsView,T.ArmorView,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,health_raw,RP.armor_get,O.client(~T.HealthSchema,~T.VitalsToken,~T.VitalsView,~T.ArmorView,~T.Tracked,~T.VitalsToken{}),Q.Optional{},owner))
def health_dump(state:D.Runtime<M.HealthBench,S.Handle<T.HealthSchema>>) -> IO(Unit):
  match state:
    case D.Runtime{M.HealthBench{H.Host{world,_,_,_,_,_,_},_,total,calls},_,_,clock,_,_,_,_,_}: health_observed(total,calls,clock,health_world(world))
def health_run(result:D.Runtime<M.HealthBench,S.Handle<T.HealthSchema>> & K.System) -> IO(Unit):
  match result:
    case (state,system): IO.bind(D.Runtime<M.HealthBench,S.Handle<T.HealthSchema>>,Unit,M.health_loops(64n,system,state),health_dump)
def health_start(count:U32,sparse:Bool) -> IO(Unit):
  IO.bind(D.Runtime<M.HealthBench,S.Handle<T.HealthSchema>> & K.System,Unit,M.health_created(count,sparse,RB.health_create(M.health_ledger,I.factory(),T.HealthOn{})),health_run)
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
    case _: IO.die(Unit,2,"args")
def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    args(values)
