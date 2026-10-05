import Base
import ./types.bend as T
import ./cache.bend as CC
import ./cached-payload.bend as CP
import ./storage.bend as S
import ./query.bend as Q
import ./observations.bend as O
import ./host-render.bend as JSON
import ./original-raw-observer.bend as RP
def raw_done(-Raw:Type,-View:Data,cached:View,result:Raw & View) -> CC.Cache<Raw,View> & View:
  match result:
    case (raw,view): (CC.Cache{raw,cached},view)
def raw_get(~Raw:Type,~View:Data,~get:Raw -> Raw & View,owner:CC.Cache<Raw,View>) -> CC.Cache<Raw,View> & View:
  match owner:
    case CC.Cache{raw,cached}: raw_done(Raw,View,cached,get(raw))
def quad(+n:U32) -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,[n:U32^2n],1,U32.add(n,1)),2,U32.add(n,2)),3,U32.add(n,3))
def motion_raw(owner:CC.Cache<T.Position,T.PositionView>) -> CC.Cache<T.Position,T.PositionView> & T.PositionView:
  raw_get(~T.Position,~T.PositionView,~RP.position_get,owner)
def motion_ledger_raw(owner:CC.Cache<T.MotionLedger,T.LedgerView>) -> CC.Cache<T.MotionLedger,T.LedgerView> & T.LedgerView:
  raw_get(~T.MotionLedger,~T.LedgerView,~RP.motion_ledger_get,owner)
def motion_world(owner:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>) -> S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>:
  O.world(T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,motion_raw,RP.velocity_get,motion_ledger_raw,owner)
def motion_emit(old1:U32,old2:U32,before:O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>,queries:List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>,result:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> IO(Unit):
  match result:
    case (_,after): IO.print("{\"schema\":\"Motion\",\"old0\":[" ++ U32.show(old1) ++ "," ++ U32.show(old2) ++ "],\"world\":" ++ JSON.render_world(T.PositionView,T.VelocityView,T.Selected,JSON.render_position,JSON.render_velocity,JSON.render_selected,T.LedgerView,T.MotionMode,JSON.render_ledger,JSON.render_motion_mode,before) ++ ",\"query\":" ++ JSON.render_list(O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>,JSON.render_query(~T.MotionSchema,~T.PositionView,~T.VelocityView,~T.Selected,~JSON.render_position,~JSON.render_velocity,~JSON.render_selected),queries) ++ ",\"afterQuery\":" ++ JSON.render_world(T.PositionView,T.VelocityView,T.Selected,JSON.render_position,JSON.render_velocity,JSON.render_selected,T.LedgerView,T.MotionMode,JSON.render_ledger,JSON.render_motion_mode,after) ++ "}")
def motion_queried(old1:U32,old2:U32,before:O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>,result:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>) -> IO(Unit):
  match result:
    case (world,values): motion_emit(old1,old2,before,values,motion_world(world))
def motion_observed(old1:U32,old2:U32,result:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> IO(Unit):
  match result:
    case (world,before): motion_queried(old1,old2,before,Q.each(T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,T.PositionToken,T.PositionView,T.VelocityView,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,motion_raw,RP.velocity_get,O.client(~T.MotionSchema,~T.PositionToken,~T.PositionView,~T.VelocityView,~T.Selected,~T.PositionToken{}),Q.Optional{},world))
def motion_written(result:(CC.Cache<T.Position,T.PositionView> & U32) & (CC.Cache<T.Position,T.PositionView> & U32)) -> IO(Unit):
  match result:
    case ((one,old1),(two,old2)): motion_observed(old1,old2,motion_world(S.World{7,3,S.Rows{ANode{ALeaf{Some{one}},ALeaf{Some{two}}},ANode{ALeaf{Some{T.Velocity{quad(110),True{}}}},ALeaf{Some{T.Velocity{quad(190),True{}}}}},ANode{ALeaf{S.Metadata{True{},Some{T.Selected{8}},3,4}},ALeaf{S.Metadata{True{},None{},5,6}}},2,1n,2},[],Some{CP.motion_ledger_new(T.MotionLedger{quad(100),4})},T.MotionOn{}}))
def motion_one() -> IO(Unit):
  motion_written((CP.position_swap(CP.position_new(T.Position{quad(10),7}),17),CP.position_swap(CP.position_new(T.Position{quad(900),7}),901)))
def health_raw(owner:CC.Cache<T.Vitals,T.VitalsView>) -> CC.Cache<T.Vitals,T.VitalsView> & T.VitalsView:
  raw_get(~T.Vitals,~T.VitalsView,~RP.vitals_get,owner)
def health_ledger_raw(owner:CC.Cache<T.HealthLedger,T.LedgerView>) -> CC.Cache<T.HealthLedger,T.LedgerView> & T.LedgerView:
  raw_get(~T.HealthLedger,~T.LedgerView,~RP.health_ledger_get,owner)
def health_world(owner:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>) -> S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>:
  O.world(T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,health_raw,RP.armor_get,health_ledger_raw,owner)
def health_emit(old1:U32,old2:U32,before:O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>,queries:List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>,result:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> IO(Unit):
  match result:
    case (_,after): IO.print("{\"schema\":\"Health\",\"old0\":[" ++ U32.show(old1) ++ "," ++ U32.show(old2) ++ "],\"world\":" ++ JSON.render_world(T.VitalsView,T.ArmorView,T.Tracked,JSON.render_vitals,JSON.render_armor,JSON.render_tracked,T.LedgerView,T.HealthMode,JSON.render_ledger,JSON.render_health_mode,before) ++ ",\"query\":" ++ JSON.render_list(O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>,JSON.render_query(~T.HealthSchema,~T.VitalsView,~T.ArmorView,~T.Tracked,~JSON.render_vitals,~JSON.render_armor,~JSON.render_tracked),queries) ++ ",\"afterQuery\":" ++ JSON.render_world(T.VitalsView,T.ArmorView,T.Tracked,JSON.render_vitals,JSON.render_armor,JSON.render_tracked,T.LedgerView,T.HealthMode,JSON.render_ledger,JSON.render_health_mode,after) ++ "}")
def health_queried(old1:U32,old2:U32,before:O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>,result:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>) -> IO(Unit):
  match result:
    case (world,values): health_emit(old1,old2,before,values,health_world(world))
def health_observed(old1:U32,old2:U32,result:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> IO(Unit):
  match result:
    case (world,before): health_queried(old1,old2,before,Q.each(T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,T.VitalsToken,T.VitalsView,T.ArmorView,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,health_raw,RP.armor_get,O.client(~T.HealthSchema,~T.VitalsToken,~T.VitalsView,~T.ArmorView,~T.Tracked,~T.VitalsToken{}),Q.Optional{},world))
def health_written(result:(CC.Cache<T.Vitals,T.VitalsView> & U32) & (CC.Cache<T.Vitals,T.VitalsView> & U32)) -> IO(Unit):
  match result:
    case ((one,old1),(two,old2)): health_observed(old1,old2,health_world(S.World{7,3,S.Rows{ANode{ALeaf{Some{one}},ALeaf{Some{two}}},ANode{ALeaf{Some{T.Armor{quad(110),3}}},ALeaf{Some{T.Armor{quad(190),3}}}},ANode{ALeaf{S.Metadata{True{},Some{T.Tracked{8}},3,4}},ALeaf{S.Metadata{True{},None{},5,6}}},2,1n,2},[],Some{CP.health_ledger_new(T.HealthLedger{quad(100),4})},T.HealthOn{}}))
def health_one() -> IO(Unit):
  health_written((CP.vitals_swap(CP.vitals_new(T.Vitals{quad(10),9,2}),17),CP.vitals_swap(CP.vitals_new(T.Vitals{quad(900),9,2}),901)))
def main() -> IO(Unit):
  do IO<Unit>:
    motion_one()
    health_one()
