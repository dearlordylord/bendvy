# Trusted service provisioning: callback receives only fresh operations over opaque Tx.
import Base
import ./types.bend as T
import ./storage.bend as S
import ./transaction.bend as X
import ./transaction-dispatch-adapters.bend as A
import ./systems.bend as U
import ./schedule.bend as Q
import ./dispatcher.bend as D

type Wrapped<Tx:Type> is Type:
  Wrapped{transaction:Tx,audit:D.Audit}
type ServiceResult<W:Type,H:Data> is Type:
  ServiceResult{result:A.RunResult<W,H>,audit:D.Audit}
def logged(-Tx:Type,pair:Tx & D.Audit) -> Wrapped<Tx>:
  match pair:
    case (transaction,audit): Wrapped{transaction,audit}
def log(-Tx:Type,owner:Wrapped<Tx>,text:String) -> IO(Wrapped<Tx>):
  match owner:
    case Wrapped{transaction,audit}: IO.bind(D.Audit,Wrapped<Tx>,D.audit_log(audit,text), a => IO.pure(Wrapped<Tx>,Wrapped{transaction,a}))
def motion_read_main_pair(audit:D.Audit,pair:X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & T.Access<T.PositionView>) -> Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>> & T.Access<T.PositionView>:
  match pair:
    case (transaction,value): (Wrapped{transaction,audit},value)
def motion_read_main(owner:Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,token:T.PositionToken) -> Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>> & T.Access<T.PositionView>:
  match owner:
    case Wrapped{transaction,audit}: motion_read_main_pair(audit,A.motion_read_main(transaction,token))
def motion_read_ledger_pair(audit:D.Audit,pair:X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>> & Maybe<&2,T.LedgerView>) -> Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>> & Maybe<&2,T.LedgerView>:
  match pair:
    case (transaction,value): (Wrapped{transaction,audit},value)
def motion_read_ledger(owner:Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,token:T.MotionLedgerToken) -> Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>> & Maybe<&2,T.LedgerView>:
  match owner:
    case Wrapped{transaction,audit}: motion_read_ledger_pair(audit,A.motion_read_ledger(transaction,token))
def motion_set_main0(owner:Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,token:T.PositionToken,value:U32) -> Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>:
  match owner:
    case Wrapped{transaction,audit}: Wrapped{A.motion_set_main0(transaction,token,value),audit}
def motion_set_ledger0(owner:Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,token:T.MotionLedgerToken,value:U32) -> Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>:
  match owner:
    case Wrapped{transaction,audit}: Wrapped{A.motion_set_ledger0(transaction,token,value),audit}
def motion_insert_flag(owner:Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,token:T.Selected) -> Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>:
  match owner:
    case Wrapped{transaction,audit}: Wrapped{A.motion_insert_flag(transaction,token),audit}
def motion_emit(owner:Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,token:T.MotionPing) -> Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>:
  match owner:
    case Wrapped{transaction,audit}: Wrapped{A.motion_emit(transaction,token),audit}
def motion_remove_flag(owner:Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>) -> Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>:
  match owner:
    case Wrapped{transaction,audit}: Wrapped{A.motion_remove_flag(transaction),audit}
def motion_spawn_main_result(audit:D.Audit,result:T.Reservation<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,S.Handle<T.MotionSchema>,T.Position>) -> T.Reservation<Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,S.Handle<T.MotionSchema>,T.Position>:
  match result:
    case T.Reserved{transaction,handle}: T.Reserved{Wrapped{transaction,audit},handle}
    case T.ReserveRejected{transaction,payload}: T.ReserveRejected{Wrapped{transaction,audit},payload}
def motion_spawn_main(owner:Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,payload:T.Position) -> T.Reservation<Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,S.Handle<T.MotionSchema>,T.Position>:
  match owner:
    case Wrapped{transaction,audit}: motion_spawn_main_result(audit,A.motion_spawn_main(transaction,payload))
def motion_spawn_flagged_result(audit:D.Audit,result:T.Reservation<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,S.Handle<T.MotionSchema>,T.Position>) -> T.Reservation<Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,S.Handle<T.MotionSchema>,T.Position>:
  match result:
    case T.Reserved{transaction,handle}: T.Reserved{Wrapped{transaction,audit},handle}
    case T.ReserveRejected{transaction,payload}: T.ReserveRejected{Wrapped{transaction,audit},payload}
def motion_spawn_flagged(owner:Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,payload:T.Position) -> T.Reservation<Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,S.Handle<T.MotionSchema>,T.Position>:
  match owner:
    case Wrapped{transaction,audit}: motion_spawn_flagged_result(audit,A.motion_spawn_flagged(transaction,payload))
def motion_log(owner:Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,text:String) -> IO(Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>):
  log(X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,owner,text)
def motion_finished(tick:U32,result:U.BodyResult<Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,S.Handle<T.MotionSchema>>) -> IO(ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>>):
  match result:
    case U.BodyResult{Wrapped{transaction,audit},outcome,escaped,observations}: IO.pure(ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>>,ServiceResult{A.motion_finished(U.BodyResult{transaction,outcome,escaped,observations},tick),audit})
def motion_a(count:U32,rejected:T.Outcome,tick:U32,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,selected:S.Handle<T.MotionSchema>,audit:D.Audit) -> IO(ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>>):
  IO.bind(U.BodyResult<Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,S.Handle<T.MotionSchema>>,ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>>,U.motion_a(Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,S.Handle<T.MotionSchema>,count,rejected,motion_set_main0,motion_set_ledger0,motion_read_main,motion_read_ledger,motion_spawn_flagged,motion_remove_flag,motion_emit,motion_log,Wrapped{X.tx_begin(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,world,selected),audit}), r => motion_finished(tick,r))
def motion_b(mode:Q.Mode,count:U32,tick:U32,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,selected:S.Handle<T.MotionSchema>,audit:D.Audit) -> IO(ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>>):
  IO.bind(U.BodyResult<Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,S.Handle<T.MotionSchema>>,ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>>,U.motion_b(Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,S.Handle<T.MotionSchema>,mode,count,motion_read_main,motion_set_main0,motion_read_main,motion_set_main0,motion_read_main,motion_read_ledger,motion_set_ledger0,motion_spawn_main,motion_insert_flag,motion_emit,motion_log,Wrapped{X.tx_begin(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,world,selected),audit}), r => motion_finished(tick,r))
def health_read_main_pair(audit:D.Audit,pair:X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & T.Access<T.VitalsView>) -> Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>> & T.Access<T.VitalsView>:
  match pair:
    case (transaction,value): (Wrapped{transaction,audit},value)
def health_read_main(owner:Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,token:T.VitalsToken) -> Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>> & T.Access<T.VitalsView>:
  match owner:
    case Wrapped{transaction,audit}: health_read_main_pair(audit,A.health_read_main(transaction,token))
def health_read_ledger_pair(audit:D.Audit,pair:X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>> & Maybe<&2,T.LedgerView>) -> Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>> & Maybe<&2,T.LedgerView>:
  match pair:
    case (transaction,value): (Wrapped{transaction,audit},value)
def health_read_ledger(owner:Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,token:T.HealthLedgerToken) -> Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>> & Maybe<&2,T.LedgerView>:
  match owner:
    case Wrapped{transaction,audit}: health_read_ledger_pair(audit,A.health_read_ledger(transaction,token))
def health_set_main0(owner:Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,token:T.VitalsToken,value:U32) -> Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>:
  match owner:
    case Wrapped{transaction,audit}: Wrapped{A.health_set_main0(transaction,token,value),audit}
def health_set_ledger0(owner:Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,token:T.HealthLedgerToken,value:U32) -> Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>:
  match owner:
    case Wrapped{transaction,audit}: Wrapped{A.health_set_ledger0(transaction,token,value),audit}
def health_insert_flag(owner:Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,token:T.Tracked) -> Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>:
  match owner:
    case Wrapped{transaction,audit}: Wrapped{A.health_insert_flag(transaction,token),audit}
def health_emit(owner:Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,token:T.HealthPing) -> Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>:
  match owner:
    case Wrapped{transaction,audit}: Wrapped{A.health_emit(transaction,token),audit}
def health_remove_flag(owner:Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>) -> Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>:
  match owner:
    case Wrapped{transaction,audit}: Wrapped{A.health_remove_flag(transaction),audit}
def health_spawn_main_result(audit:D.Audit,result:T.Reservation<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,S.Handle<T.HealthSchema>,T.Vitals>) -> T.Reservation<Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,S.Handle<T.HealthSchema>,T.Vitals>:
  match result:
    case T.Reserved{transaction,handle}: T.Reserved{Wrapped{transaction,audit},handle}
    case T.ReserveRejected{transaction,payload}: T.ReserveRejected{Wrapped{transaction,audit},payload}
def health_spawn_main(owner:Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,payload:T.Vitals) -> T.Reservation<Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,S.Handle<T.HealthSchema>,T.Vitals>:
  match owner:
    case Wrapped{transaction,audit}: health_spawn_main_result(audit,A.health_spawn_main(transaction,payload))
def health_spawn_flagged_result(audit:D.Audit,result:T.Reservation<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,S.Handle<T.HealthSchema>,T.Vitals>) -> T.Reservation<Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,S.Handle<T.HealthSchema>,T.Vitals>:
  match result:
    case T.Reserved{transaction,handle}: T.Reserved{Wrapped{transaction,audit},handle}
    case T.ReserveRejected{transaction,payload}: T.ReserveRejected{Wrapped{transaction,audit},payload}
def health_spawn_flagged(owner:Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,payload:T.Vitals) -> T.Reservation<Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,S.Handle<T.HealthSchema>,T.Vitals>:
  match owner:
    case Wrapped{transaction,audit}: health_spawn_flagged_result(audit,A.health_spawn_flagged(transaction,payload))
def health_log(owner:Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,text:String) -> IO(Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>):
  log(X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,owner,text)
def health_finished(tick:U32,result:U.BodyResult<Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,S.Handle<T.HealthSchema>>) -> IO(ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>>):
  match result:
    case U.BodyResult{Wrapped{transaction,audit},outcome,escaped,observations}: IO.pure(ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>>,ServiceResult{A.health_finished(U.BodyResult{transaction,outcome,escaped,observations},tick),audit})
def health_a(count:U32,rejected:T.Outcome,tick:U32,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,selected:S.Handle<T.HealthSchema>,audit:D.Audit) -> IO(ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>>):
  IO.bind(U.BodyResult<Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,S.Handle<T.HealthSchema>>,ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>>,U.health_a(Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,S.Handle<T.HealthSchema>,count,rejected,health_set_main0,health_set_ledger0,health_read_main,health_read_ledger,health_spawn_flagged,health_remove_flag,health_emit,health_log,Wrapped{X.tx_begin(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,world,selected),audit}), r => health_finished(tick,r))
def health_b(mode:Q.Mode,count:U32,tick:U32,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,selected:S.Handle<T.HealthSchema>,audit:D.Audit) -> IO(ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>>):
  IO.bind(U.BodyResult<Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,S.Handle<T.HealthSchema>>,ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>>,U.health_b(Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,S.Handle<T.HealthSchema>,mode,count,health_read_main,health_set_main0,health_read_main,health_set_main0,health_read_main,health_read_ledger,health_set_ledger0,health_spawn_main,health_insert_flag,health_emit,health_log,Wrapped{X.tx_begin(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,world,selected),audit}), r => health_finished(tick,r))
