import Base
import ./types.bend as T
import ./active-payload.bend as P

def cells(+a: U32,+b: U32,+c: U32,+d: U32) -> Array<U32>:
  ANode{ANode{ALeaf{a},ALeaf{b}},ANode{ALeaf{c},ALeaf{d}}}
def show_owned(xs: List<U32>) -> String:
  match xs:
    case Nil{}: ""
    case head <> tail: U32.show(head) ++ "," ++ show_owned(tail)
def position_print_owner(text: String,owner: T.Position) -> IO(Unit):
  match owner:
    case T.Position{array,frame}: IO.print(text ++ ":owner:" ++ show_owned(Array.to_list(U32,array)) ++ ":frame:" ++ U32.show(frame))
def show_four(v: T.Four) -> String:
  match v:
    case T.Four{a,b,c,d}: U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d)
def show_position(v: T.PositionView) -> String:
  match v:
    case T.PositionView{v,frame}: show_four(v) ++ ":" ++ U32.show(frame)
def position_done(prefix: String,result: T.Position & T.PositionView) -> T.Position & String:
  match result:
    case (owner,view): (owner,prefix ++ ":repeat:" ++ show_position(view))
def position_restored(prefix: String,result: T.Position & T.PositionView) -> T.Position & String:
  match result:
    case (owner,view): position_done(prefix ++ ":restored:" ++ show_position(view),P.position_get(owner))
def position_restore(prefix: String,result: T.Position & U32) -> T.Position & String:
  match result:
    case (owner,replaced): position_restored(prefix ++ ":replaced:" ++ U32.show(replaced),P.position_get(owner))
def position_written(+old: U32,prefix: String,result: T.Position & T.PositionView) -> T.Position & String:
  match result:
    case (owner,view): position_restore(prefix ++ ":written:" ++ show_position(view),P.position_swap(owner,old))
def position_swapped(prefix: String,result: T.Position & U32) -> T.Position & String:
  match result:
    case (owner,+old): position_written(old,prefix ++ ":old:" ++ U32.show(old),P.position_get(owner))
def position_initial(result: T.Position & T.PositionView) -> T.Position & String:
  match result:
    case (owner,view): position_swapped("position:initial:" ++ show_position(view),P.position_swap(owner,211))
def position_print(result: T.Position & String) -> IO(Unit):
  match result:
    case (owner,text): position_print_owner(text,owner)
def show_velocity(v: T.VelocityView) -> String:
  match v:
    case T.VelocityView{v,moving}: show_four(v) ++ ":" ++ Bool.show(moving)
def velocity_done(prefix: String,result: T.Velocity & T.VelocityView) -> T.Velocity & String:
  match result:
    case (owner,view): (owner,prefix ++ ":repeat:" ++ show_velocity(view))
def velocity_restored(prefix: String,result: T.Velocity & T.VelocityView) -> T.Velocity & String:
  match result:
    case (owner,view): velocity_done(prefix ++ ":restored:" ++ show_velocity(view),P.velocity_get(owner))
def velocity_initial(result: T.Velocity & T.VelocityView) -> T.Velocity & String:
  match result:
    case (owner,view): velocity_restored("velocity:initial:" ++ show_velocity(view),P.velocity_get(owner))
def velocity_print(result: T.Velocity & String) -> IO(Unit):
  match result:
    case (owner,text): IO.print(text)
def show_vitals(v: T.VitalsView) -> String:
  match v:
    case T.VitalsView{v,reserve,class}: show_four(v) ++ ":" ++ U32.show(reserve) ++ ":" ++ U32.show(class)
def vitals_done(prefix: String,result: T.Vitals & T.VitalsView) -> T.Vitals & String:
  match result:
    case (owner,view): (owner,prefix ++ ":repeat:" ++ show_vitals(view))
def vitals_restored(prefix: String,result: T.Vitals & T.VitalsView) -> T.Vitals & String:
  match result:
    case (owner,view): vitals_done(prefix ++ ":restored:" ++ show_vitals(view),P.vitals_get(owner))
def vitals_restore(prefix: String,result: T.Vitals & U32) -> T.Vitals & String:
  match result:
    case (owner,replaced): vitals_restored(prefix ++ ":replaced:" ++ U32.show(replaced),P.vitals_get(owner))
def vitals_written(+old: U32,prefix: String,result: T.Vitals & T.VitalsView) -> T.Vitals & String:
  match result:
    case (owner,view): vitals_restore(prefix ++ ":written:" ++ show_vitals(view),P.vitals_swap(owner,old))
def vitals_swapped(prefix: String,result: T.Vitals & U32) -> T.Vitals & String:
  match result:
    case (owner,+old): vitals_written(old,prefix ++ ":old:" ++ U32.show(old),P.vitals_get(owner))
def vitals_initial(result: T.Vitals & T.VitalsView) -> T.Vitals & String:
  match result:
    case (owner,view): vitals_swapped("vitals:initial:" ++ show_vitals(view),P.vitals_swap(owner,211))
def vitals_print(result: T.Vitals & String) -> IO(Unit):
  match result:
    case (owner,text): IO.print(text)
def show_armor(v: T.ArmorView) -> String:
  match v:
    case T.ArmorView{v,grade}: show_four(v) ++ ":" ++ U32.show(grade)
def armor_done(prefix: String,result: T.Armor & T.ArmorView) -> T.Armor & String:
  match result:
    case (owner,view): (owner,prefix ++ ":repeat:" ++ show_armor(view))
def armor_restored(prefix: String,result: T.Armor & T.ArmorView) -> T.Armor & String:
  match result:
    case (owner,view): armor_done(prefix ++ ":restored:" ++ show_armor(view),P.armor_get(owner))
def armor_initial(result: T.Armor & T.ArmorView) -> T.Armor & String:
  match result:
    case (owner,view): armor_restored("armor:initial:" ++ show_armor(view),P.armor_get(owner))
def armor_print(result: T.Armor & String) -> IO(Unit):
  match result:
    case (owner,text): IO.print(text)
def show_motion_ledger(v: T.LedgerView) -> String:
  match v:
    case T.LedgerView{v,epoch}: show_four(v) ++ ":" ++ U32.show(epoch)
def motion_ledger_done(prefix: String,result: T.MotionLedger & T.LedgerView) -> T.MotionLedger & String:
  match result:
    case (owner,view): (owner,prefix ++ ":repeat:" ++ show_motion_ledger(view))
def motion_ledger_restored(prefix: String,result: T.MotionLedger & T.LedgerView) -> T.MotionLedger & String:
  match result:
    case (owner,view): motion_ledger_done(prefix ++ ":restored:" ++ show_motion_ledger(view),P.motion_ledger_get(owner))
def motion_ledger_restore(prefix: String,result: T.MotionLedger & U32) -> T.MotionLedger & String:
  match result:
    case (owner,replaced): motion_ledger_restored(prefix ++ ":replaced:" ++ U32.show(replaced),P.motion_ledger_get(owner))
def motion_ledger_written(+old: U32,prefix: String,result: T.MotionLedger & T.LedgerView) -> T.MotionLedger & String:
  match result:
    case (owner,view): motion_ledger_restore(prefix ++ ":written:" ++ show_motion_ledger(view),P.motion_ledger_swap(owner,old))
def motion_ledger_swapped(prefix: String,result: T.MotionLedger & U32) -> T.MotionLedger & String:
  match result:
    case (owner,+old): motion_ledger_written(old,prefix ++ ":old:" ++ U32.show(old),P.motion_ledger_get(owner))
def motion_ledger_initial(result: T.MotionLedger & T.LedgerView) -> T.MotionLedger & String:
  match result:
    case (owner,view): motion_ledger_swapped("motion_ledger:initial:" ++ show_motion_ledger(view),P.motion_ledger_swap(owner,211))
def motion_ledger_print(result: T.MotionLedger & String) -> IO(Unit):
  match result:
    case (owner,text): IO.print(text)
def show_health_ledger(v: T.LedgerView) -> String:
  match v:
    case T.LedgerView{v,epoch}: show_four(v) ++ ":" ++ U32.show(epoch)
def health_ledger_done(prefix: String,result: T.HealthLedger & T.LedgerView) -> T.HealthLedger & String:
  match result:
    case (owner,view): (owner,prefix ++ ":repeat:" ++ show_health_ledger(view))
def health_ledger_restored(prefix: String,result: T.HealthLedger & T.LedgerView) -> T.HealthLedger & String:
  match result:
    case (owner,view): health_ledger_done(prefix ++ ":restored:" ++ show_health_ledger(view),P.health_ledger_get(owner))
def health_ledger_restore(prefix: String,result: T.HealthLedger & U32) -> T.HealthLedger & String:
  match result:
    case (owner,replaced): health_ledger_restored(prefix ++ ":replaced:" ++ U32.show(replaced),P.health_ledger_get(owner))
def health_ledger_written(+old: U32,prefix: String,result: T.HealthLedger & T.LedgerView) -> T.HealthLedger & String:
  match result:
    case (owner,view): health_ledger_restore(prefix ++ ":written:" ++ show_health_ledger(view),P.health_ledger_swap(owner,old))
def health_ledger_swapped(prefix: String,result: T.HealthLedger & U32) -> T.HealthLedger & String:
  match result:
    case (owner,+old): health_ledger_written(old,prefix ++ ":old:" ++ U32.show(old),P.health_ledger_get(owner))
def health_ledger_initial(result: T.HealthLedger & T.LedgerView) -> T.HealthLedger & String:
  match result:
    case (owner,view): health_ledger_swapped("health_ledger:initial:" ++ show_health_ledger(view),P.health_ledger_swap(owner,211))
def health_ledger_print(result: T.HealthLedger & String) -> IO(Unit):
  match result:
    case (owner,text): IO.print(text)
def array_show(result: Array<U32> & T.Four) -> IO(Unit):
  match result:
    case (owner,view): IO.print("fallback:" ++ show_four(view) ++ ":owner:" ++ show_owned(Array.to_list(U32,owner)))
def main() -> IO(Unit):
  do IO<Unit>:
    position_print(position_initial(P.position_get(T.Position{cells(5,17,29,43),71})))
    velocity_print(velocity_initial(P.velocity_get(T.Velocity{cells(7,19,31,47),True{}})))
    vitals_print(vitals_initial(P.vitals_get(T.Vitals{cells(11,23,37,53),73,79})))
    armor_print(armor_initial(P.armor_get(T.Armor{cells(13,27,41,59),83})))
    motion_ledger_print(motion_ledger_initial(P.motion_ledger_get(T.MotionLedger{cells(61,67,89,97),101})))
    health_ledger_print(health_ledger_initial(P.health_ledger_get(T.HealthLedger{cells(103,107,109,113),127})))
    array_show(P.four(ALeaf{137}))
    array_show(P.four(ANode{ALeaf{139},ALeaf{149}}))
    array_show(P.four(ANode{cells(151,157,163,167),cells(173,179,181,191)}))
    position_print(position_initial(P.position_get(T.Position{ALeaf{137},131})))
    position_print(position_initial(P.position_get(T.Position{ANode{ALeaf{139},ALeaf{149}},133})))
    position_print(position_initial(P.position_get(T.Position{ANode{cells(151,157,163,167),cells(173,179,181,191)},135})))
