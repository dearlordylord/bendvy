import Base
import ./host-render.bend as R
import ./host-observations.bend as H
import ./types.bend as T
import ./storage.bend as S
import ./observations.bend as O
import ./dispatcher.bend as D

def controls(n: Nat,+code: U32) -> String:
  match n:
    case 0n: ""
    case 1n+n: SCon{Char.from_u32(code),controls(n,(code + 1 : U32))}
def position() -> T.PositionView:
  T.PositionView{T.Four{1,2,3,4},5}
def aux() -> T.VelocityView:
  T.VelocityView{T.Four{6,7,8,9},True{}}
def row() -> O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>:
  O.QueryRow{S.Handle{41,17},position(),Some{aux()},Some{T.Selected{10}}}
def snapshot() -> H.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>:
  H.Snapshot{"snapshot","world",D.Complete{},O.WorldView{41,18,
    [O.RowView{17,Some{position()},Some{aux()},None{},11,12},O.RowView{18,None{},None{},Some{T.Selected{13}},14,15}],
    [O.SpawnView{19,O.BundleView{Some{position()},Some{aux()},Some{T.Selected{16}}}},O.MainView{17,position()},O.FlagView{17,T.Selected{20}},O.RemoveMainView{18},O.RemoveFlagView{17},O.DespawnView{18}],
    Some{T.LedgerView{T.Four{21,22,23,24},25}},T.MotionOn{}},
    [row()],[row()],[],[row()],
    [H.Lookup{"found",S.Handle{41,17},T.Found{row()}},H.Lookup{"foreign",S.Handle{42,17},T.Mismatch{}},H.Lookup{"stale",S.Handle{41,99},T.Missing{}}]}
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(R.render_string(controls(32n,0) ++ "\"\\λ😀"))
    IO.print(R.render_motion(H.Reserved{"reserve","motion","raw",S.Handle{41,17},O.BundleView{Some{position()},Some{aux()},Some{T.Selected{10}}}}))
    IO.print(R.render_motion(snapshot()))
    IO.print(R.render_motion(H.Read{"read","Fast",26,T.ReadBoundary{27,28,29},[row()],[row()],[row()],[S.Handle{41,17}],[S.Handle{41,18}],[T.MotionPing{30},T.MotionPing{31}],True{},False{},True{}}))
    IO.print(R.render_motion(H.ReadDone{"readDone","Fast",32,33,T.Failure{34},False{},True{},False{}}))
    IO.print(R.render_motion(H.Dispatch{"dispatch",D.SystemFailure{"B",35},36,37,[H.Count{"A",T.Four{38,39,40,41}}]}))
    IO.print(R.render_motion(H.OwnWrites{"writes","B",[H.Main{T.Found{T.MotionMain{position()}}},H.Main{T.Missing{}},H.Main{T.Mismatch{}},H.ReservedLookup{T.Missing{}},H.Ledger{Some{T.LedgerView{T.Four{42,43,44,45},46}}},H.Ledger{None{}}]}))
    IO.print(R.render_health(H.Snapshot{"health","health-world",D.SetupRejected{"reason"},O.WorldView{47,48,[O.RowView{49,Some{T.VitalsView{T.Four{50,51,52,53},54,55}},Some{T.ArmorView{T.Four{56,57,58,59},60}},Some{T.Tracked{61}},62,63}],[],None{},T.HealthOff{}},[],[],[],[],[]}))
    IO.print(R.render_health(H.Read{"health-read","Slow",64,T.ReadBoundary{65,66,67},[],[],[],[],[],[T.HealthPing{68}],False{},False{},False{}}))
    IO.print(R.render_dispatch_outcome(D.MissingRuntimeRequirements{[D.ResourceRequired{"resource"},D.ServiceRequired{"service"},D.StateRequired{"state"}]}))
    IO.print(R.render_outcome(T.Success{}))
    IO.print(R.render_motion_mode(T.MotionOff{}))
    IO.print(R.render_health_mode(T.HealthOn{}))
    IO.print(R.render_main_view(T.HealthMain{T.VitalsView{T.Four{69,70,71,72},73,74}}))
