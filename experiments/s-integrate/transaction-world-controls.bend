import Base
import ./types.bend as T
import ./storage.bend as S
import ./identity.bend as I
import ./payload.bend as P
import ./transaction.bend as X

def quad(a:U32,b:U32,c:U32,d:U32) -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,[a:U32^2n],1,b),2,c),3,d)
def motion_ledger(u:Unit) -> T.MotionLedger:
  T.MotionLedger{quad(101,101,102,103),4}
def motion_write(w:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,h:S.Handle<T.MotionSchema>,v:U32) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & T.Access<U32>:
  X.storage_set_main0(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,P.position_swap,w,h,v)
def motion_ledger_write(w:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,v:U32) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & Maybe<&2,U32>:
  X.storage_set_ledger0(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,P.motion_ledger_swap,w,v)
def motion_restore(w:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,h:S.Handle<T.MotionSchema>,v:U32) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>:
  X.storage_restore_main0(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,P.position_swap,w,h,v)
def motion_ledger_restore(w:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,v:U32) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>:
  X.storage_restore_ledger0(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,P.motion_ledger_swap,w,v)
def motion_ledger_observed(prefix:String,result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & Maybe<&2,T.LedgerView>) -> String:
  match result:
    case (S.World{namespace,next,_,_,_,_},Some{T.LedgerView{T.Four{a,b,c,d},epoch}}): prefix ++ ":ledger=" ++ U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d) ++ ":epoch=" ++ U32.show(epoch) ++ ":next=" ++ U32.show(next)
    case (_,None{}): "missingledger"
def motion_main_observed(result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & T.Access<T.PositionView>) -> String:
  match result:
    case (w,T.Found{T.PositionView{T.Four{a,b,c,d},frame}}): motion_ledger_observed(U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d) ++ ":meta=" ++ U32.show(frame),S.with_ledger(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.LedgerView,w,P.motion_ledger_get))
    case (_, _): "missingmain"
def motion_observe(handle:S.Handle<T.MotionSchema>,result:X.Finished<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Command<T.Position,T.Velocity,T.Selected>,S.Handle<T.MotionSchema>>) -> String:
  match result:
    case X.Reverted{w}: motion_main_observed(S.with_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.PositionView,w,handle,P.position_get))
    case X.Committed{_,_,_,_}: "badcommit"
def motion_exercise(+h:S.Handle<T.MotionSchema>,t:X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>) -> String:
  motion_observe(h,X.tx_finish_failure(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,motion_restore,motion_ledger_restore,X.tx_set_ledger0(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,motion_ledger_write,X.tx_set_main0(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,motion_write,X.tx_set_main0(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,motion_write,t,30),50),201)))
def motion_reserved(result:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & Maybe<&2,S.Handle<T.MotionSchema>>) -> String:
  match result:
    case (S.World{namespace,next,_,pending,ledger,mode},Some{S.Handle{+space,+id}}): motion_exercise(S.Handle{space,id},X.tx_begin(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,S.World{namespace,next,[S.Row{id,Some{T.Position{quad(20,21,22,23),7}},None{},None{},0,0}],pending,ledger,mode},S.Handle{space,id}))
    case (_,None{}): "reservationfailed"
def motion_created(result:T.Creation<S.Factory,S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>>) -> String:
  match result:
    case T.Created{factory,w}: motion_reserved(I.reserve_id(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,w))
    case T.CreateRejected{_}: "createfailed"
def motion() -> String:
  motion_created(I.create(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,motion_ledger,I.factory(),T.MotionOn{}))
def health_ledger(u:Unit) -> T.HealthLedger:
  T.HealthLedger{quad(101,101,102,103),4}
def health_write(w:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,h:S.Handle<T.HealthSchema>,v:U32) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & T.Access<U32>:
  X.storage_set_main0(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,P.vitals_swap,w,h,v)
def health_ledger_write(w:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,v:U32) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & Maybe<&2,U32>:
  X.storage_set_ledger0(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,P.health_ledger_swap,w,v)
def health_restore(w:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,h:S.Handle<T.HealthSchema>,v:U32) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>:
  X.storage_restore_main0(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,P.vitals_swap,w,h,v)
def health_ledger_restore(w:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,v:U32) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>:
  X.storage_restore_ledger0(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,P.health_ledger_swap,w,v)
def health_ledger_observed(prefix:String,result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & Maybe<&2,T.LedgerView>) -> String:
  match result:
    case (S.World{namespace,next,_,_,_,_},Some{T.LedgerView{T.Four{a,b,c,d},epoch}}): prefix ++ ":ledger=" ++ U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d) ++ ":epoch=" ++ U32.show(epoch) ++ ":next=" ++ U32.show(next)
    case (_,None{}): "missingledger"
def health_main_observed(result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & T.Access<T.VitalsView>) -> String:
  match result:
    case (w,T.Found{T.VitalsView{T.Four{a,b,c,d},reserve,class}}): health_ledger_observed(U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d) ++ ":meta=" ++ U32.show(reserve) ++ ":" ++ U32.show(class),S.with_ledger(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.LedgerView,w,P.health_ledger_get))
    case (_, _): "missingmain"
def health_observe(handle:S.Handle<T.HealthSchema>,result:X.Finished<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Command<T.Vitals,T.Armor,T.Tracked>,S.Handle<T.HealthSchema>>) -> String:
  match result:
    case X.Reverted{w}: health_main_observed(S.with_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.VitalsView,w,handle,P.vitals_get))
    case X.Committed{_,_,_,_}: "badcommit"
def health_exercise(+h:S.Handle<T.HealthSchema>,t:X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>) -> String:
  health_observe(h,X.tx_finish_failure(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,health_restore,health_ledger_restore,X.tx_set_ledger0(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,health_ledger_write,X.tx_set_main0(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,health_write,X.tx_set_main0(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,health_write,t,30),50),201)))
def health_reserved(result:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & Maybe<&2,S.Handle<T.HealthSchema>>) -> String:
  match result:
    case (S.World{namespace,next,_,pending,ledger,mode},Some{S.Handle{+space,+id}}): health_exercise(S.Handle{space,id},X.tx_begin(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,S.World{namespace,next,[S.Row{id,Some{T.Vitals{quad(20,21,22,23),9,2}},None{},None{},0,0}],pending,ledger,mode},S.Handle{space,id}))
    case (_,None{}): "reservationfailed"
def health_created(result:T.Creation<S.Factory,S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>>) -> String:
  match result:
    case T.Created{factory,w}: health_reserved(I.reserve_id(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,w))
    case T.CreateRejected{_}: "createfailed"
def health() -> String:
  health_created(I.create(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,health_ledger,I.factory(),T.HealthOn{}))

def main() -> String:
  motion() ++ "\n" ++ health()
