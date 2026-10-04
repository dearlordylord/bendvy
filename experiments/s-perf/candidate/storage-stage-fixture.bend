import Base
import ./types.bend as T

# Used seed/formatting helpers only; old list-world fixtures remain in the baseline.
def vector(+x: U32) -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,[x : U32^2n],1,(x + 1 : U32)),2,(x + 2 : U32)),3,(x + 3 : U32))
def four(values: T.Four) -> String:
  match values:
    case T.Four{a,b,c,d}: U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d)
def bool(value: Bool) -> String:
  match value:
    case True{}: "true"
    case False{}: "false"
def position(value: T.PositionView) -> String:
  match value:
    case T.PositionView{values,frame}: "position[" ++ four(values) ++ "];frame=" ++ U32.show(frame)
def vitals(value: T.VitalsView) -> String:
  match value:
    case T.VitalsView{values,reserve,class}: "vitals[" ++ four(values) ++ "];reserve=" ++ U32.show(reserve) ++ ";class=" ++ U32.show(class)
def velocity(value: T.VelocityView) -> String:
  match value:
    case T.VelocityView{values,moving}: "velocity[" ++ four(values) ++ "];moving=" ++ bool(moving)
def armor(value: T.ArmorView) -> String:
  match value:
    case T.ArmorView{values,grade}: "armor[" ++ four(values) ++ "];grade=" ++ U32.show(grade)
def ledger_show(value: T.LedgerView) -> String:
  match value:
    case T.LedgerView{values,epoch}: "ledger[" ++ four(values) ++ "];epoch=" ++ U32.show(epoch)
def selected(value: T.Selected) -> String:
  match value:
    case T.Selected{group}: "selected=" ++ U32.show(group)
def tracked(value: T.Tracked) -> String:
  match value:
    case T.Tracked{group}: "tracked=" ++ U32.show(group)
def motion_mode(value: T.MotionMode) -> String:
  match value:
    case T.MotionOn{}: "On"
    case T.MotionOff{}: "Off"
def health_mode(value: T.HealthMode) -> String:
  match value:
    case T.HealthOn{}: "On"
    case T.HealthOff{}: "Off"
def maybe(~V: Data,~show: V -> String,value: Maybe<&2,V>) -> String:
  match value:
    case None{}: "none"
    case Some{v}: show(v)
def motion_ledger(unit: Unit) -> T.MotionLedger: T.MotionLedger{vector(100),4}
def health_ledger(unit: Unit) -> T.HealthLedger: T.HealthLedger{vector(100),4}
