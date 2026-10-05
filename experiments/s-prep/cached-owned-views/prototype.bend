import Base
import ./types.bend as T
import ./uncached-payload.bend as P
import ./cached-payload.bend as K
import ./cache.bend as C
import ./held.bend as H
import ./callbacks.bend as B
import ./host-render.bend as R
import ./transaction.bend as X

def quad(+n:U32) -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,[n:U32^2n],1,U32.add(n,1)),2,U32.add(n,2)),3,U32.add(n,3))
def render_check(~V:Data,~render:V -> String,values:List<&2,C.Check<V>>) -> String:
  match values:
    case Nil{}: ""
    case Con{C.Check{raw,cached},tail}: "[" ++ render(raw) ++ "," ++ render(cached) ++ "]\n" ++ render_check(V,render,tail)
def undo_text(values:List<&2,X.Inverse<U32>>) -> String:
  match values:
    case Nil{}: ""
    case Con{X.MainInverse{_,old},rest}: "M:" ++ U32.show(old) ++ ";" ++ undo_text(rest)
    case Con{X.LedgerInverse{old},rest}: "L:" ++ U32.show(old) ++ ";" ++ undo_text(rest)

type MotionContext is Type:
  MotionContext{aux:T.Velocity,flag:T.Selected,added:U32,changed:U32}
def motion_get(owner:H.Held<MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit>,token:T.PositionToken) -> H.Held<MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit> & T.Access<T.PositionView>:
  match token:
    case T.PositionToken{}: H.main_read(MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit,T.PositionView,K.position_get,owner)

def motion_ledger(owner:H.Held<MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit>,token:T.MotionLedgerToken) -> H.Held<MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit> & Maybe<&2,T.LedgerView>:
  match token:
    case T.MotionLedgerToken{}: H.ledger_read(MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit,T.LedgerView,K.motion_ledger_get,owner)

def motion_set(owner:H.Held<MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit>,token:T.PositionToken,value:U32) -> H.Held<MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit>:
  match token:
    case T.PositionToken{}: H.main_write(MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit,K.position_swap,owner,value)

def motion_setledger(owner:H.Held<MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit>,token:T.MotionLedgerToken,value:U32) -> H.Held<MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit>:
  match token:
    case T.MotionLedgerToken{}: H.ledger_write(MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit,K.motion_ledger_swap,owner,value)

def motion_invoke(~client:@-Owner:Type -> (Owner -> T.PositionToken -> Owner & T.Access<T.PositionView>) -> (Owner -> T.PositionToken -> U32 -> Owner) -> (Owner -> T.MotionLedgerToken -> Owner & Maybe<&2,T.LedgerView>) -> (Owner -> T.MotionLedgerToken -> U32 -> Owner) -> Owner -> Owner & U32,owner:H.Held<MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit>) -> H.Held<MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit> & U32:
  client(H.Held<MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit>,motion_get,motion_set,motion_ledger,motion_setledger,owner)
def motion_twice(result:H.Held<MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit> & U32) -> H.Held<MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit> & U32:
  match result:
    case (owner,_): motion_invoke(B.motion_body,owner)
def motion_raw_main(result:T.Position & T.PositionView) -> IO(Unit):
  match result:
    case (_,view): IO.print("motion:raw-main:" ++ R.render_position(view))
def motion_raw_ledger(result:T.MotionLedger & T.LedgerView) -> IO(Unit):
  match result:
    case (_,view): IO.print("motion:raw-ledger:" ++ R.render_ledger(view))
def motion_released(main:T.Position,ledger:T.MotionLedger,mchecks:List<&2,C.Check<T.PositionView>>,lchecks:List<&2,C.Check<T.LedgerView>>) -> IO(Unit):
  do IO<Unit>:
    IO.print("motion:main-checks")
    IO.print(render_check(T.PositionView,R.render_position,mchecks))
    IO.print("motion:ledger-checks")
    IO.print(render_check(T.LedgerView,R.render_ledger,lchecks))
    motion_raw_main(P.position_get(main))
    motion_raw_ledger(P.motion_ledger_get(ledger))
def motion_release_both(pair:(T.Position & List<&2,C.Check<T.PositionView>>) & (T.MotionLedger & List<&2,C.Check<T.LedgerView>>)) -> IO(Unit):
  match pair:
    case ((main,mchecks),(ledger,lchecks)): motion_released(main,ledger,mchecks,lchecks)
def motion_context(group:U32,added:U32,changed:U32,result:T.Velocity & T.VelocityView) -> IO(Unit):
  match result:
    case (_,view): IO.print("motion:context:" ++ "{\"aux\":" ++ R.render_velocity(view) ++ ",\"flag\":{\"group\":" ++ U32.show(group) ++ "},\"added\":" ++ U32.show(added) ++ ",\"changed\":" ++ U32.show(changed) ++ "}")
def motion_finish(result:H.Held<MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit> & U32) -> IO(Unit):
  match result:
    case (H.Held{MotionContext{aux,T.Selected{group},added,changed},main,ledger,_,undo,_,_,marks},sum):
      do IO<Unit>:
        IO.print("motion:sum:" ++ U32.show(sum))
        IO.print("motion:inverse:" ++ undo_text(undo))
        IO.print("motion:marks:" ++ Nat.show(List.length(&2,U32,marks)))
        motion_context(group,added,changed,P.velocity_get(aux))
        motion_release_both((C.release(T.Position,T.PositionView,main),C.release(T.MotionLedger,T.LedgerView,ledger)))
def motion_restore(result:H.Held<MotionContext,C.Checked<T.Position,T.PositionView>,C.Checked<T.MotionLedger,T.LedgerView>,U32,Unit> & U32) -> IO(Unit):
  match result:
    case (owner,sum): motion_finish((motion_setledger(motion_set(owner,T.PositionToken{},10),T.MotionLedgerToken{},100),sum))
def motion_case() -> IO(Unit):
  motion_restore(motion_twice(motion_invoke(B.motion_body,H.Held{MotionContext{T.Velocity{quad(110),True{}},T.Selected{8},3,4},K.position_new(T.Position{quad(10),7}),K.motion_ledger_new(T.MotionLedger{quad(100),4}),1,[],[],[],[]})))

type HealthContext is Type:
  HealthContext{aux:T.Armor,flag:T.Tracked,added:U32,changed:U32}
def health_get(owner:H.Held<HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit>,token:T.VitalsToken) -> H.Held<HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit> & T.Access<T.VitalsView>:
  match token:
    case T.VitalsToken{}: H.main_read(HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit,T.VitalsView,K.vitals_get,owner)

def health_ledger(owner:H.Held<HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit>,token:T.HealthLedgerToken) -> H.Held<HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit> & Maybe<&2,T.LedgerView>:
  match token:
    case T.HealthLedgerToken{}: H.ledger_read(HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit,T.LedgerView,K.health_ledger_get,owner)

def health_set(owner:H.Held<HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit>,token:T.VitalsToken,value:U32) -> H.Held<HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit>:
  match token:
    case T.VitalsToken{}: H.main_write(HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit,K.vitals_swap,owner,value)

def health_setledger(owner:H.Held<HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit>,token:T.HealthLedgerToken,value:U32) -> H.Held<HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit>:
  match token:
    case T.HealthLedgerToken{}: H.ledger_write(HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit,K.health_ledger_swap,owner,value)

def health_invoke(~client:@-Owner:Type -> (Owner -> T.VitalsToken -> Owner & T.Access<T.VitalsView>) -> (Owner -> T.VitalsToken -> U32 -> Owner) -> (Owner -> T.HealthLedgerToken -> Owner & Maybe<&2,T.LedgerView>) -> (Owner -> T.HealthLedgerToken -> U32 -> Owner) -> Owner -> Owner & U32,owner:H.Held<HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit>) -> H.Held<HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit> & U32:
  client(H.Held<HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit>,health_get,health_set,health_ledger,health_setledger,owner)
def health_twice(result:H.Held<HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit> & U32) -> H.Held<HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit> & U32:
  match result:
    case (owner,_): health_invoke(B.health_body,owner)
def health_raw_main(result:T.Vitals & T.VitalsView) -> IO(Unit):
  match result:
    case (_,view): IO.print("health:raw-main:" ++ R.render_vitals(view))
def health_raw_ledger(result:T.HealthLedger & T.LedgerView) -> IO(Unit):
  match result:
    case (_,view): IO.print("health:raw-ledger:" ++ R.render_ledger(view))
def health_released(main:T.Vitals,ledger:T.HealthLedger,mchecks:List<&2,C.Check<T.VitalsView>>,lchecks:List<&2,C.Check<T.LedgerView>>) -> IO(Unit):
  do IO<Unit>:
    IO.print("health:main-checks")
    IO.print(render_check(T.VitalsView,R.render_vitals,mchecks))
    IO.print("health:ledger-checks")
    IO.print(render_check(T.LedgerView,R.render_ledger,lchecks))
    health_raw_main(P.vitals_get(main))
    health_raw_ledger(P.health_ledger_get(ledger))
def health_release_both(pair:(T.Vitals & List<&2,C.Check<T.VitalsView>>) & (T.HealthLedger & List<&2,C.Check<T.LedgerView>>)) -> IO(Unit):
  match pair:
    case ((main,mchecks),(ledger,lchecks)): health_released(main,ledger,mchecks,lchecks)
def health_context(group:U32,added:U32,changed:U32,result:T.Armor & T.ArmorView) -> IO(Unit):
  match result:
    case (_,view): IO.print("health:context:" ++ "{\"aux\":" ++ R.render_armor(view) ++ ",\"flag\":{\"group\":" ++ U32.show(group) ++ "},\"added\":" ++ U32.show(added) ++ ",\"changed\":" ++ U32.show(changed) ++ "}")
def health_finish(result:H.Held<HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit> & U32) -> IO(Unit):
  match result:
    case (H.Held{HealthContext{aux,T.Tracked{group},added,changed},main,ledger,_,undo,_,_,marks},sum):
      do IO<Unit>:
        IO.print("health:sum:" ++ U32.show(sum))
        IO.print("health:inverse:" ++ undo_text(undo))
        IO.print("health:marks:" ++ Nat.show(List.length(&2,U32,marks)))
        health_context(group,added,changed,P.armor_get(aux))
        health_release_both((C.release(T.Vitals,T.VitalsView,main),C.release(T.HealthLedger,T.LedgerView,ledger)))
def health_restore(result:H.Held<HealthContext,C.Checked<T.Vitals,T.VitalsView>,C.Checked<T.HealthLedger,T.LedgerView>,U32,Unit> & U32) -> IO(Unit):
  match result:
    case (owner,sum): health_finish((health_setledger(health_set(owner,T.VitalsToken{},10),T.HealthLedgerToken{},100),sum))
def health_case() -> IO(Unit):
  health_restore(health_twice(health_invoke(B.health_body,H.Held{HealthContext{T.Armor{quad(110),3},T.Tracked{8},3,4},K.vitals_new(T.Vitals{quad(10),9,2}),K.health_ledger_new(T.HealthLedger{quad(100),4}),1,[],[],[],[]})))

def main() -> IO(Unit):
  do IO<Unit>:
    motion_case()
    health_case()
