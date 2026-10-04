# Trusted service provisioning: callback receives only fresh operations over opaque Tx.
import Base
import ./types.bend as T
import ./storage.bend as S
import ./transaction.bend as X
import ./transaction-dispatch-adapters.bend as A
import ./systems.bend as U
import ./schedule.bend as Q
import ./dispatcher.bend as D
import ./observations.bend as O
import ./payload.bend as P
import ./query.bend as J

type Wrapped<Tx:Type> is Type:
  Wrapped{transaction:Tx,audit:D.Audit}
type ServiceResult<W:Type,H:Data,V:Data,AV:Data,F:Data> is Type:
  ServiceResult{result:A.RunResult<W,H>,audit:D.Audit,reservation:Maybe<&2,O.BundleView<V,AV,F>>}
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
# Derive the reservation observation from actual retained staged command owners.
def motion_find_match(equal:Bool,bundle:O.BundleView<T.PositionView,T.VelocityView,T.Selected>,fallback:Maybe<&2,O.BundleView<T.PositionView,T.VelocityView,T.Selected>>) -> Maybe<&2,O.BundleView<T.PositionView,T.VelocityView,T.Selected>>:
  match equal:
    case True{}: Some{bundle}
    case False{}: fallback
def motion_find_spawn(+target:U32,values:List<&2,O.PendingView<T.PositionView,T.VelocityView,T.Selected>>) -> Maybe<&2,O.BundleView<T.PositionView,T.VelocityView,T.Selected>>:
  match values:
    case []: None{}
    case Con{value,tail}:
      match value:
        case O.SpawnView{id,bundle}:
          motion_find_match(U32.is_eq(target,id),bundle,motion_find_spawn(target,tail))
        case _: motion_find_spawn(target,tail)
def motion_find_namespace(equal:Bool,id:U32,values:List<&2,O.PendingView<T.PositionView,T.VelocityView,T.Selected>>) -> Maybe<&2,O.BundleView<T.PositionView,T.VelocityView,T.Selected>>:
  match equal:
    case True{}: motion_find_spawn(id,values)
    case False{}: None{}
def motion_lookup_read(-Main:Type,-Aux:Type,aux:Aux,result:Main & T.PositionView) -> Main & (Aux & T.MainView):
  match result:
    case (main,value): (main,(aux,T.MotionMain{value}))
def motion_lookup_client(-Main:Type,-Aux:Type,get:Main -> T.PositionToken -> Main & T.PositionView,aux_get:Aux -> Aux & Maybe<&2,T.VelocityView>,handle:S.Handle<T.MotionSchema>,flag:Maybe<&2,T.Selected>,main:Main,aux:Aux) -> Main & (Aux & T.MainView):
  motion_lookup_read(Main,Aux,aux,get(main,T.PositionToken{}))
def motion_complete(tick:U32,audit:D.Audit,reservation:Maybe<&2,O.BundleView<T.PositionView,T.VelocityView,T.Selected>>,result:U.BodyResult<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,S.Handle<T.MotionSchema>>) -> IO(ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>):
  IO.pure(ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>,ServiceResult{A.motion_finished(result,tick),audit,reservation})
def motion_looked(tick:U32,audit:D.Audit,reservation:Maybe<&2,O.BundleView<T.PositionView,T.VelocityView,T.Selected>>,selected:S.Handle<T.MotionSchema>,undo:List<&2,X.Inverse<S.Handle<T.MotionSchema>>>,commands:List<S.Command<T.Position,T.Velocity,T.Selected>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.MotionSchema>>,outcome:T.Outcome,escaped:Maybe<&2,S.Handle<T.MotionSchema>>,observations:List<&2,U.Observation>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & T.Access<T.MainView>) -> IO(ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>):
  match pair:
    case (world,view): motion_complete(tick,audit,reservation,U.BodyResult{X.Tx{world,selected,undo,commands,pings,marks},outcome,escaped,List.append(&2,U.Observation,observations,[U.ReservedObserved{view}])})
def motion_lookup_decide(tick:U32,lookup:Bool,+worldnamespace:U32,audit:D.Audit,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,selected:S.Handle<T.MotionSchema>,undo:List<&2,X.Inverse<S.Handle<T.MotionSchema>>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.MotionSchema>>,outcome:T.Outcome,+namespace:U32,+id:U32,observations:List<&2,U.Observation>,commands:List<S.Command<T.Position,T.Velocity,T.Selected>>,values:List<&2,O.PendingView<T.PositionView,T.VelocityView,T.Selected>>) -> IO(ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>):
  match lookup:
    case False{}: motion_complete(tick,audit,motion_find_namespace(U32.is_eq(worldnamespace,namespace),id,values),U.BodyResult{X.Tx{world,selected,undo,commands,pings,marks},outcome,Some{S.Handle{namespace,id}},observations})
    case True{}: motion_looked(tick,audit,motion_find_namespace(U32.is_eq(worldnamespace,namespace),id,values),selected,undo,commands,pings,marks,outcome,Some{S.Handle{namespace,id}},observations,J.lookup(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.PositionToken,T.PositionView,T.VelocityView,T.MainView,T.MotionLedger,T.MotionMode,P.position_get,P.velocity_get,motion_lookup_client,J.Required{},world,S.Handle{namespace,id}))
def motion_inspected_values(tick:U32,lookup:Bool,+worldnamespace:U32,audit:D.Audit,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,selected:S.Handle<T.MotionSchema>,undo:List<&2,X.Inverse<S.Handle<T.MotionSchema>>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.MotionSchema>>,outcome:T.Outcome,escaped:Maybe<&2,S.Handle<T.MotionSchema>>,observations:List<&2,U.Observation>,commands:List<S.Command<T.Position,T.Velocity,T.Selected>>,values:List<&2,O.PendingView<T.PositionView,T.VelocityView,T.Selected>>) -> IO(ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>):
  match escaped:
    case None{}: motion_complete(tick,audit,None{},U.BodyResult{X.Tx{world,selected,undo,commands,pings,marks},outcome,None{},observations})
    case Some{handle}:
      match handle:
        case S.Handle{+namespace,+id}:
          motion_lookup_decide(tick,lookup,worldnamespace,audit,world,selected,undo,pings,marks,outcome,namespace,id,observations,commands,values)
def motion_inspected_world(tick:U32,lookup:Bool,audit:D.Audit,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,selected:S.Handle<T.MotionSchema>,undo:List<&2,X.Inverse<S.Handle<T.MotionSchema>>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.MotionSchema>>,outcome:T.Outcome,escaped:Maybe<&2,S.Handle<T.MotionSchema>>,observations:List<&2,U.Observation>,commands:List<S.Command<T.Position,T.Velocity,T.Selected>>,values:List<&2,O.PendingView<T.PositionView,T.VelocityView,T.Selected>>) -> IO(ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>):
  match world:
    case S.World{+namespace,next,rows,pending,ledger,mode}: motion_inspected_values(tick,lookup,namespace,audit,S.World{namespace,next,rows,pending,ledger,mode},selected,undo,pings,marks,outcome,escaped,observations,commands,values)
def motion_inspected(tick:U32,lookup:Bool,audit:D.Audit,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,selected:S.Handle<T.MotionSchema>,undo:List<&2,X.Inverse<S.Handle<T.MotionSchema>>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.MotionSchema>>,outcome:T.Outcome,escaped:Maybe<&2,S.Handle<T.MotionSchema>>,observations:List<&2,U.Observation>,pair:List<S.Command<T.Position,T.Velocity,T.Selected>> & List<&2,O.PendingView<T.PositionView,T.VelocityView,T.Selected>>) -> IO(ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>):
  match pair:
    case (commands,values): motion_inspected_world(tick,lookup,audit,world,selected,undo,pings,marks,outcome,escaped,observations,commands,values)

def motion_finished(tick:U32,lookup:Bool,result:U.BodyResult<Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,S.Handle<T.MotionSchema>>) -> IO(ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>):
  match result:
    case U.BodyResult{Wrapped{X.Tx{world,selected,undo,commands,pings,marks},audit},outcome,escaped,observations}: motion_inspected(tick,lookup,audit,world,selected,undo,pings,marks,outcome,escaped,observations,O.commands(T.Position,T.Velocity,T.Selected,T.PositionView,T.VelocityView,P.position_get,P.velocity_get,commands))

def motion_a(count:U32,rejected:T.Outcome,tick:U32,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,selected:S.Handle<T.MotionSchema>,audit:D.Audit) -> IO(ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>):
  IO.bind(U.BodyResult<Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,S.Handle<T.MotionSchema>>,ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>,U.motion_a(Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,S.Handle<T.MotionSchema>,count,rejected,motion_set_main0,motion_set_ledger0,motion_read_main,motion_read_ledger,motion_spawn_flagged,motion_remove_flag,motion_emit,motion_log,Wrapped{X.tx_begin(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,world,selected),audit}), r => motion_finished(tick,False{},r))
def motion_b(mode:Q.Mode,count:U32,tick:U32,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,selected:S.Handle<T.MotionSchema>,audit:D.Audit) -> IO(ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>):
  IO.bind(U.BodyResult<Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,S.Handle<T.MotionSchema>>,ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>,U.motion_b(Wrapped<X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>>,S.Handle<T.MotionSchema>,mode,count,motion_read_main,motion_set_main0,motion_read_main,motion_set_main0,motion_read_main,motion_read_ledger,motion_set_ledger0,motion_spawn_main,motion_insert_flag,motion_emit,motion_log,Wrapped{X.tx_begin(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,world,selected),audit}), r => motion_finished(tick,True{},r))
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
# Derive the reservation observation from actual retained staged command owners.
def health_find_match(equal:Bool,bundle:O.BundleView<T.VitalsView,T.ArmorView,T.Tracked>,fallback:Maybe<&2,O.BundleView<T.VitalsView,T.ArmorView,T.Tracked>>) -> Maybe<&2,O.BundleView<T.VitalsView,T.ArmorView,T.Tracked>>:
  match equal:
    case True{}: Some{bundle}
    case False{}: fallback
def health_find_spawn(+target:U32,values:List<&2,O.PendingView<T.VitalsView,T.ArmorView,T.Tracked>>) -> Maybe<&2,O.BundleView<T.VitalsView,T.ArmorView,T.Tracked>>:
  match values:
    case []: None{}
    case Con{value,tail}:
      match value:
        case O.SpawnView{id,bundle}:
          health_find_match(U32.is_eq(target,id),bundle,health_find_spawn(target,tail))
        case _: health_find_spawn(target,tail)
def health_find_namespace(equal:Bool,id:U32,values:List<&2,O.PendingView<T.VitalsView,T.ArmorView,T.Tracked>>) -> Maybe<&2,O.BundleView<T.VitalsView,T.ArmorView,T.Tracked>>:
  match equal:
    case True{}: health_find_spawn(id,values)
    case False{}: None{}
def health_lookup_read(-Main:Type,-Aux:Type,aux:Aux,result:Main & T.VitalsView) -> Main & (Aux & T.MainView):
  match result:
    case (main,value): (main,(aux,T.HealthMain{value}))
def health_lookup_client(-Main:Type,-Aux:Type,get:Main -> T.VitalsToken -> Main & T.VitalsView,aux_get:Aux -> Aux & Maybe<&2,T.ArmorView>,handle:S.Handle<T.HealthSchema>,flag:Maybe<&2,T.Tracked>,main:Main,aux:Aux) -> Main & (Aux & T.MainView):
  health_lookup_read(Main,Aux,aux,get(main,T.VitalsToken{}))
def health_complete(tick:U32,audit:D.Audit,reservation:Maybe<&2,O.BundleView<T.VitalsView,T.ArmorView,T.Tracked>>,result:U.BodyResult<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,S.Handle<T.HealthSchema>>) -> IO(ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>):
  IO.pure(ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>,ServiceResult{A.health_finished(result,tick),audit,reservation})
def health_looked(tick:U32,audit:D.Audit,reservation:Maybe<&2,O.BundleView<T.VitalsView,T.ArmorView,T.Tracked>>,selected:S.Handle<T.HealthSchema>,undo:List<&2,X.Inverse<S.Handle<T.HealthSchema>>>,commands:List<S.Command<T.Vitals,T.Armor,T.Tracked>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.HealthSchema>>,outcome:T.Outcome,escaped:Maybe<&2,S.Handle<T.HealthSchema>>,observations:List<&2,U.Observation>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & T.Access<T.MainView>) -> IO(ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>):
  match pair:
    case (world,view): health_complete(tick,audit,reservation,U.BodyResult{X.Tx{world,selected,undo,commands,pings,marks},outcome,escaped,List.append(&2,U.Observation,observations,[U.ReservedObserved{view}])})
def health_lookup_decide(tick:U32,lookup:Bool,+worldnamespace:U32,audit:D.Audit,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,selected:S.Handle<T.HealthSchema>,undo:List<&2,X.Inverse<S.Handle<T.HealthSchema>>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.HealthSchema>>,outcome:T.Outcome,+namespace:U32,+id:U32,observations:List<&2,U.Observation>,commands:List<S.Command<T.Vitals,T.Armor,T.Tracked>>,values:List<&2,O.PendingView<T.VitalsView,T.ArmorView,T.Tracked>>) -> IO(ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>):
  match lookup:
    case False{}: health_complete(tick,audit,health_find_namespace(U32.is_eq(worldnamespace,namespace),id,values),U.BodyResult{X.Tx{world,selected,undo,commands,pings,marks},outcome,Some{S.Handle{namespace,id}},observations})
    case True{}: health_looked(tick,audit,health_find_namespace(U32.is_eq(worldnamespace,namespace),id,values),selected,undo,commands,pings,marks,outcome,Some{S.Handle{namespace,id}},observations,J.lookup(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.VitalsToken,T.VitalsView,T.ArmorView,T.MainView,T.HealthLedger,T.HealthMode,P.vitals_get,P.armor_get,health_lookup_client,J.Required{},world,S.Handle{namespace,id}))
def health_inspected_values(tick:U32,lookup:Bool,+worldnamespace:U32,audit:D.Audit,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,selected:S.Handle<T.HealthSchema>,undo:List<&2,X.Inverse<S.Handle<T.HealthSchema>>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.HealthSchema>>,outcome:T.Outcome,escaped:Maybe<&2,S.Handle<T.HealthSchema>>,observations:List<&2,U.Observation>,commands:List<S.Command<T.Vitals,T.Armor,T.Tracked>>,values:List<&2,O.PendingView<T.VitalsView,T.ArmorView,T.Tracked>>) -> IO(ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>):
  match escaped:
    case None{}: health_complete(tick,audit,None{},U.BodyResult{X.Tx{world,selected,undo,commands,pings,marks},outcome,None{},observations})
    case Some{handle}:
      match handle:
        case S.Handle{+namespace,+id}:
          health_lookup_decide(tick,lookup,worldnamespace,audit,world,selected,undo,pings,marks,outcome,namespace,id,observations,commands,values)
def health_inspected_world(tick:U32,lookup:Bool,audit:D.Audit,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,selected:S.Handle<T.HealthSchema>,undo:List<&2,X.Inverse<S.Handle<T.HealthSchema>>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.HealthSchema>>,outcome:T.Outcome,escaped:Maybe<&2,S.Handle<T.HealthSchema>>,observations:List<&2,U.Observation>,commands:List<S.Command<T.Vitals,T.Armor,T.Tracked>>,values:List<&2,O.PendingView<T.VitalsView,T.ArmorView,T.Tracked>>) -> IO(ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>):
  match world:
    case S.World{+namespace,next,rows,pending,ledger,mode}: health_inspected_values(tick,lookup,namespace,audit,S.World{namespace,next,rows,pending,ledger,mode},selected,undo,pings,marks,outcome,escaped,observations,commands,values)
def health_inspected(tick:U32,lookup:Bool,audit:D.Audit,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,selected:S.Handle<T.HealthSchema>,undo:List<&2,X.Inverse<S.Handle<T.HealthSchema>>>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.HealthSchema>>,outcome:T.Outcome,escaped:Maybe<&2,S.Handle<T.HealthSchema>>,observations:List<&2,U.Observation>,pair:List<S.Command<T.Vitals,T.Armor,T.Tracked>> & List<&2,O.PendingView<T.VitalsView,T.ArmorView,T.Tracked>>) -> IO(ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>):
  match pair:
    case (commands,values): health_inspected_world(tick,lookup,audit,world,selected,undo,pings,marks,outcome,escaped,observations,commands,values)

def health_finished(tick:U32,lookup:Bool,result:U.BodyResult<Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,S.Handle<T.HealthSchema>>) -> IO(ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>):
  match result:
    case U.BodyResult{Wrapped{X.Tx{world,selected,undo,commands,pings,marks},audit},outcome,escaped,observations}: health_inspected(tick,lookup,audit,world,selected,undo,pings,marks,outcome,escaped,observations,O.commands(T.Vitals,T.Armor,T.Tracked,T.VitalsView,T.ArmorView,P.vitals_get,P.armor_get,commands))

def health_a(count:U32,rejected:T.Outcome,tick:U32,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,selected:S.Handle<T.HealthSchema>,audit:D.Audit) -> IO(ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>):
  IO.bind(U.BodyResult<Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,S.Handle<T.HealthSchema>>,ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>,U.health_a(Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,S.Handle<T.HealthSchema>,count,rejected,health_set_main0,health_set_ledger0,health_read_main,health_read_ledger,health_spawn_flagged,health_remove_flag,health_emit,health_log,Wrapped{X.tx_begin(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,world,selected),audit}), r => health_finished(tick,False{},r))
def health_b(mode:Q.Mode,count:U32,tick:U32,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,selected:S.Handle<T.HealthSchema>,audit:D.Audit) -> IO(ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>):
  IO.bind(U.BodyResult<Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,S.Handle<T.HealthSchema>>,ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>,U.health_b(Wrapped<X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>>,S.Handle<T.HealthSchema>,mode,count,health_read_main,health_set_main0,health_read_main,health_set_main0,health_read_main,health_read_ledger,health_set_ledger0,health_spawn_main,health_insert_flag,health_emit,health_log,Wrapped{X.tx_begin(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,world,selected),audit}), r => health_finished(tick,True{},r))
