import Base
import ./types.bend as T
import ./payload.bend as P

def quad(a: U32,b: U32,c: U32,d: U32) -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,[a : U32^2n],1,b),2,c),3,d)
def four_text(v: T.Four) -> String:
  match v:
    case T.Four{a,b,c,d}: U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d)
def position_text(v: T.PositionView) -> String:
  match v:
    case T.PositionView{four,frame}: four_text(four) ++ ":" ++ U32.show(frame)
def vitals_text(v: T.VitalsView) -> String:
  match v:
    case T.VitalsView{four,reserve,class}: four_text(four) ++ ":" ++ U32.show(reserve) ++ ":" ++ U32.show(class)
def velocity_text(v: T.VelocityView) -> String:
  match v:
    case T.VelocityView{four,moving}: four_text(four) ++ ":" ++ Bool.show(moving)
def armor_text(v: T.ArmorView) -> String:
  match v:
    case T.ArmorView{four,grade}: four_text(four) ++ ":" ++ U32.show(grade)
def ledger_text(v: T.LedgerView) -> String:
  match v:
    case T.LedgerView{four,epoch}: four_text(four) ++ ":" ++ U32.show(epoch)

def final(~Owner: Type,~View: Data,~show: View -> String,trace: String,result: Owner & View) -> String:
  match result:
    case (owner,view): trace ++ "restore=" ++ show(view) ++ ";"
def undone_first(~Owner: Type,~View: Data,~get: Owner -> Owner & View,~show: View -> String,trace: String,result: Owner & U32) -> String:
  match result:
    case (owner,old): final(~Owner,~View,~show,trace ++ "undo1=" ++ U32.show(old) ++ ";",get(owner))
def undone_second(~Owner: Type,~View: Data,~get: Owner -> Owner & View,~swap: Owner -> U32 -> Owner & U32,~show: View -> String,first: U32,trace: String,result: Owner & U32) -> String:
  match result:
    case (owner,old): undone_first(~Owner,~View,~get,~show,trace ++ "undo2=" ++ U32.show(old) ++ ";",swap(owner,first))
def viewed_second(~Owner: Type,~View: Data,~get: Owner -> Owner & View,~swap: Owner -> U32 -> Owner & U32,~show: View -> String,first: U32,second: U32,trace: String,result: Owner & View) -> String:
  match result:
    case (owner,view): undone_second(~Owner,~View,~get,~swap,~show,first,trace ++ "after=" ++ show(view) ++ ";",swap(owner,second))
def wrote_second(~Owner: Type,~View: Data,~get: Owner -> Owner & View,~swap: Owner -> U32 -> Owner & U32,~show: View -> String,first: U32,trace: String,result: Owner & U32) -> String:
  match result:
    case (owner,+second): viewed_second(~Owner,~View,~get,~swap,~show,first,second,trace ++ "old2=" ++ U32.show(second) ++ ";",get(owner))
def viewed_first(~Owner: Type,~View: Data,~get: Owner -> Owner & View,~swap: Owner -> U32 -> Owner & U32,~show: View -> String,first: U32,secondValue: U32,trace: String,result: Owner & View) -> String:
  match result:
    case (owner,view): wrote_second(~Owner,~View,~get,~swap,~show,first,trace ++ "between=" ++ show(view) ++ ";",swap(owner,secondValue))
def wrote_first(~Owner: Type,~View: Data,~get: Owner -> Owner & View,~swap: Owner -> U32 -> Owner & U32,~show: View -> String,secondValue: U32,result: Owner & U32) -> String:
  match result:
    case (owner,+first): viewed_first(~Owner,~View,~get,~swap,~show,first,secondValue,"old1=" ++ U32.show(first) ++ ";",get(owner))
def exercise(~Owner: Type,~View: Data,~get: Owner -> Owner & View,~swap: Owner -> U32 -> Owner & U32,~show: View -> String,firstValue: U32,secondValue: U32,owner: Owner) -> String:
  wrote_first(~Owner,~View,~get,~swap,~show,secondValue,swap(owner,firstValue))
def read_again(~Owner: Type,~View: Data,~get: Owner -> Owner & View,~show: View -> String,first: String,result: Owner & View) -> String:
  match result:
    case (owner,view): first ++ "again=" ++ show(view) ++ ";"
def read_twice(~Owner: Type,~View: Data,~get: Owner -> Owner & View,~show: View -> String,result: Owner & View) -> String:
  match result:
    case (owner,view): read_again(~Owner,~View,~get,~show,"first=" ++ show(view) ++ ";",get(owner))
def main() -> String:
  "position:" ++ exercise(~T.Position,~T.PositionView,~P.position_get,~P.position_swap,~position_text,30,50,T.Position{quad(20,21,22,23),7}) ++ "\n" ++
  "vitals:" ++ exercise(~T.Vitals,~T.VitalsView,~P.vitals_get,~P.vitals_swap,~vitals_text,30,50,T.Vitals{quad(20,21,22,23),9,2}) ++ "\n" ++
  "motionLedger:" ++ exercise(~T.MotionLedger,~T.LedgerView,~P.motion_ledger_get,~P.motion_ledger_swap,~ledger_text,201,301,T.MotionLedger{quad(101,101,102,103),4}) ++ "\n" ++
  "healthLedger:" ++ exercise(~T.HealthLedger,~T.LedgerView,~P.health_ledger_get,~P.health_ledger_swap,~ledger_text,201,301,T.HealthLedger{quad(101,101,102,103),4}) ++ "\n" ++
  "velocity:" ++ read_twice(~T.Velocity,~T.VelocityView,~P.velocity_get,~velocity_text,P.velocity_get(T.Velocity{quad(1,2,3,4),True{}})) ++ "\n" ++
  "armor:" ++ read_twice(~T.Armor,~T.ArmorView,~P.armor_get,~armor_text,P.armor_get(T.Armor{quad(1,2,3,4),3}))
