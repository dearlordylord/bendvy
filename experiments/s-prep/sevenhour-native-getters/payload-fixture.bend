import Base
import ./types.bend as T
import ./cached-payload.bend as P
import ./cache.bend as C

def cells(+a: U32,+b: U32,+c: U32,+d: U32) -> Array<U32>:
  ANode{ANode{ALeaf{a},ALeaf{b}},ANode{ALeaf{c},ALeaf{d}}}
def show_owned(xs: List<U32>) -> String:
  match xs:
    case Nil{}: ""
    case head <> tail: U32.show(head) ++ "," ++ show_owned(tail)
def show_four(v: T.Four) -> String:
  match v:
    case T.Four{a,b,c,d}: U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d)
def show_position(v: T.PositionView) -> String:
  match v:
    case T.PositionView{v,frame}: show_four(v) ++ ":" ++ U32.show(frame)
def position_print_owner(text: String,owner: C.Cache<T.Position,T.PositionView>) -> IO(Unit):
  match owner:
    case C.Cache{T.Position{array,frame},cached}: IO.print(text ++ ":cache:" ++ show_position(cached) ++ ":owner:" ++ show_owned(Array.to_list(U32,array)) ++ ":frame:" ++ U32.show(frame))
def position_done(prefix: String,result: C.Cache<T.Position,T.PositionView> & T.PositionView) -> C.Cache<T.Position,T.PositionView> & String:
  match result:
    case (owner,view): (owner,prefix ++ ":repeat:" ++ show_position(view))
def position_restored(prefix: String,result: C.Cache<T.Position,T.PositionView> & T.PositionView) -> C.Cache<T.Position,T.PositionView> & String:
  match result:
    case (owner,view): position_done(prefix ++ ":restored:" ++ show_position(view),P.position_get(owner))
def position_restore(prefix: String,result: C.Cache<T.Position,T.PositionView> & U32) -> C.Cache<T.Position,T.PositionView> & String:
  match result:
    case (owner,replaced): position_restored(prefix ++ ":replaced:" ++ U32.show(replaced),P.position_get(owner))
def position_written(+old: U32,prefix: String,result: C.Cache<T.Position,T.PositionView> & T.PositionView) -> C.Cache<T.Position,T.PositionView> & String:
  match result:
    case (owner,view): position_restore(prefix ++ ":written:" ++ show_position(view),P.position_swap(owner,old))
def position_swapped(prefix: String,result: C.Cache<T.Position,T.PositionView> & U32) -> C.Cache<T.Position,T.PositionView> & String:
  match result:
    case (owner,+old): position_written(old,prefix ++ ":old:" ++ U32.show(old),P.position_get(owner))
def position_initial(result: C.Cache<T.Position,T.PositionView> & T.PositionView) -> C.Cache<T.Position,T.PositionView> & String:
  match result:
    case (owner,view): position_swapped("position:initial:" ++ show_position(view),P.position_swap(owner,211))
def position_print(result: C.Cache<T.Position,T.PositionView> & String) -> IO(Unit):
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
def velocity_print_owner(text:String,owner:T.Velocity) -> IO(Unit):
  match owner:
    case T.Velocity{array,moving}: IO.print(text ++ ":owner:" ++ show_owned(Array.to_list(U32,array)) ++ ":meta:" ++ Bool.show(moving))
def velocity_print(result: T.Velocity & String) -> IO(Unit):
  match result:
    case (owner,text): velocity_print_owner(text,owner)
def show_vitals(v: T.VitalsView) -> String:
  match v:
    case T.VitalsView{v,reserve,class}: show_four(v) ++ ":" ++ U32.show(reserve) ++ ":" ++ U32.show(class)
def vitals_done(prefix: String,result: C.Cache<T.Vitals,T.VitalsView> & T.VitalsView) -> C.Cache<T.Vitals,T.VitalsView> & String:
  match result:
    case (owner,view): (owner,prefix ++ ":repeat:" ++ show_vitals(view))
def vitals_restored(prefix: String,result: C.Cache<T.Vitals,T.VitalsView> & T.VitalsView) -> C.Cache<T.Vitals,T.VitalsView> & String:
  match result:
    case (owner,view): vitals_done(prefix ++ ":restored:" ++ show_vitals(view),P.vitals_get(owner))
def vitals_restore(prefix: String,result: C.Cache<T.Vitals,T.VitalsView> & U32) -> C.Cache<T.Vitals,T.VitalsView> & String:
  match result:
    case (owner,replaced): vitals_restored(prefix ++ ":replaced:" ++ U32.show(replaced),P.vitals_get(owner))
def vitals_written(+old: U32,prefix: String,result: C.Cache<T.Vitals,T.VitalsView> & T.VitalsView) -> C.Cache<T.Vitals,T.VitalsView> & String:
  match result:
    case (owner,view): vitals_restore(prefix ++ ":written:" ++ show_vitals(view),P.vitals_swap(owner,old))
def vitals_swapped(prefix: String,result: C.Cache<T.Vitals,T.VitalsView> & U32) -> C.Cache<T.Vitals,T.VitalsView> & String:
  match result:
    case (owner,+old): vitals_written(old,prefix ++ ":old:" ++ U32.show(old),P.vitals_get(owner))
def vitals_initial(result: C.Cache<T.Vitals,T.VitalsView> & T.VitalsView) -> C.Cache<T.Vitals,T.VitalsView> & String:
  match result:
    case (owner,view): vitals_swapped("vitals:initial:" ++ show_vitals(view),P.vitals_swap(owner,211))
def vitals_print_owner(text:String,owner:C.Cache<T.Vitals,T.VitalsView>) -> IO(Unit):
  match owner:
    case C.Cache{T.Vitals{array,reserve,class},cached}: IO.print(text ++ ":cache:" ++ show_vitals(cached) ++ ":owner:" ++ show_owned(Array.to_list(U32,array)) ++ ":meta:" ++ U32.show(reserve) ++ "," ++ U32.show(class))
def vitals_print(result: C.Cache<T.Vitals,T.VitalsView> & String) -> IO(Unit):
  match result:
    case (owner,text): vitals_print_owner(text,owner)
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
def armor_print_owner(text:String,owner:T.Armor) -> IO(Unit):
  match owner:
    case T.Armor{array,grade}: IO.print(text ++ ":owner:" ++ show_owned(Array.to_list(U32,array)) ++ ":meta:" ++ U32.show(grade))
def armor_print(result: T.Armor & String) -> IO(Unit):
  match result:
    case (owner,text): armor_print_owner(text,owner)
def show_motion_ledger(v: T.LedgerView) -> String:
  match v:
    case T.LedgerView{v,epoch}: show_four(v) ++ ":" ++ U32.show(epoch)
def motion_ledger_done(prefix: String,result: C.Cache<T.MotionLedger,T.LedgerView> & T.LedgerView) -> C.Cache<T.MotionLedger,T.LedgerView> & String:
  match result:
    case (owner,view): (owner,prefix ++ ":repeat:" ++ show_motion_ledger(view))
def motion_ledger_restored(prefix: String,result: C.Cache<T.MotionLedger,T.LedgerView> & T.LedgerView) -> C.Cache<T.MotionLedger,T.LedgerView> & String:
  match result:
    case (owner,view): motion_ledger_done(prefix ++ ":restored:" ++ show_motion_ledger(view),P.motion_ledger_get(owner))
def motion_ledger_restore(prefix: String,result: C.Cache<T.MotionLedger,T.LedgerView> & U32) -> C.Cache<T.MotionLedger,T.LedgerView> & String:
  match result:
    case (owner,replaced): motion_ledger_restored(prefix ++ ":replaced:" ++ U32.show(replaced),P.motion_ledger_get(owner))
def motion_ledger_written(+old: U32,prefix: String,result: C.Cache<T.MotionLedger,T.LedgerView> & T.LedgerView) -> C.Cache<T.MotionLedger,T.LedgerView> & String:
  match result:
    case (owner,view): motion_ledger_restore(prefix ++ ":written:" ++ show_motion_ledger(view),P.motion_ledger_swap(owner,old))
def motion_ledger_swapped(prefix: String,result: C.Cache<T.MotionLedger,T.LedgerView> & U32) -> C.Cache<T.MotionLedger,T.LedgerView> & String:
  match result:
    case (owner,+old): motion_ledger_written(old,prefix ++ ":old:" ++ U32.show(old),P.motion_ledger_get(owner))
def motion_ledger_initial(result: C.Cache<T.MotionLedger,T.LedgerView> & T.LedgerView) -> C.Cache<T.MotionLedger,T.LedgerView> & String:
  match result:
    case (owner,view): motion_ledger_swapped("motion_ledger:initial:" ++ show_motion_ledger(view),P.motion_ledger_swap(owner,211))
def motion_ledger_print_owner(text:String,owner:C.Cache<T.MotionLedger,T.LedgerView>) -> IO(Unit):
  match owner:
    case C.Cache{T.MotionLedger{array,epoch},cached}: IO.print(text ++ ":cache:" ++ show_motion_ledger(cached) ++ ":owner:" ++ show_owned(Array.to_list(U32,array)) ++ ":meta:" ++ U32.show(epoch))
def motion_ledger_print(result: C.Cache<T.MotionLedger,T.LedgerView> & String) -> IO(Unit):
  match result:
    case (owner,text): motion_ledger_print_owner(text,owner)
def show_health_ledger(v: T.LedgerView) -> String:
  match v:
    case T.LedgerView{v,epoch}: show_four(v) ++ ":" ++ U32.show(epoch)
def health_ledger_done(prefix: String,result: C.Cache<T.HealthLedger,T.LedgerView> & T.LedgerView) -> C.Cache<T.HealthLedger,T.LedgerView> & String:
  match result:
    case (owner,view): (owner,prefix ++ ":repeat:" ++ show_health_ledger(view))
def health_ledger_restored(prefix: String,result: C.Cache<T.HealthLedger,T.LedgerView> & T.LedgerView) -> C.Cache<T.HealthLedger,T.LedgerView> & String:
  match result:
    case (owner,view): health_ledger_done(prefix ++ ":restored:" ++ show_health_ledger(view),P.health_ledger_get(owner))
def health_ledger_restore(prefix: String,result: C.Cache<T.HealthLedger,T.LedgerView> & U32) -> C.Cache<T.HealthLedger,T.LedgerView> & String:
  match result:
    case (owner,replaced): health_ledger_restored(prefix ++ ":replaced:" ++ U32.show(replaced),P.health_ledger_get(owner))
def health_ledger_written(+old: U32,prefix: String,result: C.Cache<T.HealthLedger,T.LedgerView> & T.LedgerView) -> C.Cache<T.HealthLedger,T.LedgerView> & String:
  match result:
    case (owner,view): health_ledger_restore(prefix ++ ":written:" ++ show_health_ledger(view),P.health_ledger_swap(owner,old))
def health_ledger_swapped(prefix: String,result: C.Cache<T.HealthLedger,T.LedgerView> & U32) -> C.Cache<T.HealthLedger,T.LedgerView> & String:
  match result:
    case (owner,+old): health_ledger_written(old,prefix ++ ":old:" ++ U32.show(old),P.health_ledger_get(owner))
def health_ledger_initial(result: C.Cache<T.HealthLedger,T.LedgerView> & T.LedgerView) -> C.Cache<T.HealthLedger,T.LedgerView> & String:
  match result:
    case (owner,view): health_ledger_swapped("health_ledger:initial:" ++ show_health_ledger(view),P.health_ledger_swap(owner,211))
def health_ledger_print_owner(text:String,owner:C.Cache<T.HealthLedger,T.LedgerView>) -> IO(Unit):
  match owner:
    case C.Cache{T.HealthLedger{array,epoch},cached}: IO.print(text ++ ":cache:" ++ show_health_ledger(cached) ++ ":owner:" ++ show_owned(Array.to_list(U32,array)) ++ ":meta:" ++ U32.show(epoch))
def health_ledger_print(result: C.Cache<T.HealthLedger,T.LedgerView> & String) -> IO(Unit):
  match result:
    case (owner,text): health_ledger_print_owner(text,owner)
def array_show(result: Array<U32> & T.Four) -> IO(Unit):
  match result:
    case (owner,view): IO.print("fallback:" ++ show_four(view) ++ ":owner:" ++ show_owned(Array.to_list(U32,owner)))
def main() -> IO(Unit):
  do IO<Unit>:
    position_print(position_initial(P.position_get(P.position_new(T.Position{cells(5,17,29,43),71}))))
    velocity_print(velocity_initial(P.velocity_get(T.Velocity{cells(7,19,31,47),True{}})))
    vitals_print(vitals_initial(P.vitals_get(P.vitals_new(T.Vitals{cells(11,23,37,53),73,79}))))
    armor_print(armor_initial(P.armor_get(T.Armor{cells(13,27,41,59),83})))
    motion_ledger_print(motion_ledger_initial(P.motion_ledger_get(P.motion_ledger_new(T.MotionLedger{cells(61,67,89,97),101}))))
    health_ledger_print(health_ledger_initial(P.health_ledger_get(P.health_ledger_new(T.HealthLedger{cells(103,107,109,113),127}))))
