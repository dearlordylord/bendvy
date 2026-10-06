import Base
import ./cache.bend as CC
import ./cached-payload.bend as CP
import ./types.bend as T
import ./schedule.bend as Q
import ./storage.bend as S

def MotionWorld() -> Type:
  S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>
def HealthWorld() -> Type:
  S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>
type Observation is Data:
  MainObserved{view: T.Access<T.MainView>}
  LedgerObserved{view: Maybe<&2,T.LedgerView>}
  ReservedObserved{view:T.Access<T.MainView>}
type BodyResult<-Tx: Type,-H: Data> is Type:
  BodyResult{transaction: Tx,outcome: T.Outcome,escaped: Maybe<&2,H>,observations: List<&2,Observation>}
def failed(mode: Q.Mode) -> T.Outcome:
  match mode:
    case Q.BFail{}: T.Failure{7}
    case Q.ObserveFail{}: T.Failure{7}
    case _: T.Success{}
def writes(mode: Q.Mode) -> Bool:
  match mode:
    case Q.BFail{}: True{}
    case Q.Retry{}: True{}
    case _: False{}
def quad(a:U32,b:U32,c:U32,d:U32) -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,[a:U32^2n],1,b),2,c),3,d)
def code(mode:Q.Mode) -> U32:
  match mode:
    case Q.BFail{}: 9
    case _: 2

def audit_result(-Tx:Type,-H:Data,+outcome:T.Outcome,+escaped:Maybe<&2,H>,+observations:List<&2,Observation>,owner:Tx) -> IO(BodyResult<Tx,H>):
  IO.pure(BodyResult<Tx,H>,BodyResult{owner,outcome,escaped,observations})
def audit(-Tx:Type,-H:Data,mode:Q.Mode,count:U32,escaped:Maybe<&2,H>,observations:List<&2,Observation>,owner:Tx,log:Tx -> String -> IO(Tx)) -> IO(BodyResult<Tx,H>):
  IO.bind(Tx,BodyResult<Tx,H>,log(owner,"B:attempt:" ++ U32.show(count)), t => audit_result(Tx,H,failed(mode),escaped,observations,t))

def motion_view(access:T.Access<T.PositionView>) -> T.Access<T.MainView>:
  match access:
    case T.Found{view}: T.Found{T.MotionMain{view}}
    case T.Mismatch{}: T.Mismatch{}
    case T.Missing{}: T.Missing{}
def motion_reserved(-Tx:Type,-H:Data,+mode:Q.Mode,count:U32,observations:List<&2,Observation>,flag:Tx -> T.Selected -> Tx,ping:Tx -> T.MotionPing -> Tx,log:Tx -> String -> IO(Tx),result:T.Reservation<Tx,H,CC.Cache<T.Position,T.PositionView>>) -> IO(BodyResult<Tx,H>):
  match result:
    case T.Reserved{owner,handle}: audit(Tx,H,mode,count,Some{handle},observations,ping(flag(owner,T.Selected{8}),T.MotionPing{code(mode)}),log)
    case T.ReserveRejected{owner,payload}: audit(Tx,H,mode,count,None{},observations,ping(flag(owner,T.Selected{8}),T.MotionPing{code(mode)}),log)
def motion_ledger(-Tx:Type,-H:Data,+mode:Q.Mode,count:U32,observations:List<&2,Observation>,spawn:Tx -> CC.Cache<T.Position,T.PositionView> -> T.Reservation<Tx,H,CC.Cache<T.Position,T.PositionView>>,flag:Tx -> T.Selected -> Tx,ping:Tx -> T.MotionPing -> Tx,log:Tx -> String -> IO(Tx),pair:Tx & Maybe<&2,T.LedgerView>) -> IO(BodyResult<Tx,H>):
  match pair:
    case (owner,view):
      motion_reserved(Tx,H,mode,count,List.append(&2,Observation,observations,[LedgerObserved{view}]),flag,ping,log,
        spawn(owner,CP.position_new(T.Position{quad(60,61,62,63),7})))
def motion_after(-Tx:Type,-H:Data,mode:Q.Mode,count:U32,observations:List<&2,Observation>,ledger:Tx -> T.MotionLedgerToken -> Tx & Maybe<&2,T.LedgerView>,set_ledger:Tx -> T.MotionLedgerToken -> U32 -> Tx,spawn:Tx -> CC.Cache<T.Position,T.PositionView> -> T.Reservation<Tx,H,CC.Cache<T.Position,T.PositionView>>,flag:Tx -> T.Selected -> Tx,ping:Tx -> T.MotionPing -> Tx,log:Tx -> String -> IO(Tx),pair:Tx & T.Access<T.PositionView>) -> IO(BodyResult<Tx,H>):
  match pair:
    case (owner,view): motion_ledger(Tx,H,mode,count,List.append(&2,Observation,observations,[MainObserved{motion_view(view)}]),spawn,flag,ping,log,ledger(set_ledger(owner,T.MotionLedgerToken{},201),T.MotionLedgerToken{}))
def motion_between(-Tx:Type,-H:Data,mode:Q.Mode,count:U32,observations:List<&2,Observation>,second:Tx -> T.PositionToken -> U32 -> Tx,after:Tx -> T.PositionToken -> Tx & T.Access<T.PositionView>,ledger:Tx -> T.MotionLedgerToken -> Tx & Maybe<&2,T.LedgerView>,set_ledger:Tx -> T.MotionLedgerToken -> U32 -> Tx,spawn:Tx -> CC.Cache<T.Position,T.PositionView> -> T.Reservation<Tx,H,CC.Cache<T.Position,T.PositionView>>,flag:Tx -> T.Selected -> Tx,ping:Tx -> T.MotionPing -> Tx,log:Tx -> String -> IO(Tx),pair:Tx & T.Access<T.PositionView>) -> IO(BodyResult<Tx,H>):
  match pair:
    case (owner,view): motion_after(Tx,H,mode,count,List.append(&2,Observation,observations,[MainObserved{motion_view(view)}]),ledger,set_ledger,spawn,flag,ping,log,after(second(owner,T.PositionToken{},50),T.PositionToken{}))
def motion_choose(-Tx:Type,-H:Data,write:Bool,mode:Q.Mode,count:U32,first:Tx -> T.PositionToken -> U32 -> Tx,between:Tx -> T.PositionToken -> Tx & T.Access<T.PositionView>,second:Tx -> T.PositionToken -> U32 -> Tx,after:Tx -> T.PositionToken -> Tx & T.Access<T.PositionView>,ledger:Tx -> T.MotionLedgerToken -> Tx & Maybe<&2,T.LedgerView>,set_ledger:Tx -> T.MotionLedgerToken -> U32 -> Tx,spawn:Tx -> CC.Cache<T.Position,T.PositionView> -> T.Reservation<Tx,H,CC.Cache<T.Position,T.PositionView>>,flag:Tx -> T.Selected -> Tx,ping:Tx -> T.MotionPing -> Tx,log:Tx -> String -> IO(Tx),owner:Tx,observations:List<&2,Observation>) -> IO(BodyResult<Tx,H>):
  match write:
    case False{}: IO.pure(BodyResult<Tx,H>,BodyResult{owner,failed(mode),None{},observations})
    case True{}: motion_between(Tx,H,mode,count,observations,second,after,ledger,set_ledger,spawn,flag,ping,log,between(first(owner,T.PositionToken{},30),T.PositionToken{}))
def motion_before(-Tx:Type,-H:Data,+mode:Q.Mode,count:U32,first:Tx -> T.PositionToken -> U32 -> Tx,between:Tx -> T.PositionToken -> Tx & T.Access<T.PositionView>,second:Tx -> T.PositionToken -> U32 -> Tx,after:Tx -> T.PositionToken -> Tx & T.Access<T.PositionView>,ledger:Tx -> T.MotionLedgerToken -> Tx & Maybe<&2,T.LedgerView>,set_ledger:Tx -> T.MotionLedgerToken -> U32 -> Tx,spawn:Tx -> CC.Cache<T.Position,T.PositionView> -> T.Reservation<Tx,H,CC.Cache<T.Position,T.PositionView>>,flag:Tx -> T.Selected -> Tx,ping:Tx -> T.MotionPing -> Tx,log:Tx -> String -> IO(Tx),pair:Tx & T.Access<T.PositionView>) -> IO(BodyResult<Tx,H>):
  match pair:
    case (owner,view): motion_choose(Tx,H,writes(mode),mode,count,first,between,second,after,ledger,set_ledger,spawn,flag,ping,log,owner,[MainObserved{motion_view(view)}])
def motion_b(-Tx:Type,-H:Data,mode:Q.Mode,count:U32,before:Tx -> T.PositionToken -> Tx & T.Access<T.PositionView>,first:Tx -> T.PositionToken -> U32 -> Tx,between:Tx -> T.PositionToken -> Tx & T.Access<T.PositionView>,second:Tx -> T.PositionToken -> U32 -> Tx,after:Tx -> T.PositionToken -> Tx & T.Access<T.PositionView>,ledger:Tx -> T.MotionLedgerToken -> Tx & Maybe<&2,T.LedgerView>,set_ledger:Tx -> T.MotionLedgerToken -> U32 -> Tx,spawn:Tx -> CC.Cache<T.Position,T.PositionView> -> T.Reservation<Tx,H,CC.Cache<T.Position,T.PositionView>>,flag:Tx -> T.Selected -> Tx,ping:Tx -> T.MotionPing -> Tx,log:Tx -> String -> IO(Tx),owner:Tx) -> IO(BodyResult<Tx,H>):
  motion_before(Tx,H,mode,count,first,between,second,after,ledger,set_ledger,spawn,flag,ping,log,before(owner,T.PositionToken{}))

def health_view(access:T.Access<T.VitalsView>) -> T.Access<T.MainView>:
  match access:
    case T.Found{view}: T.Found{T.HealthMain{view}}
    case T.Mismatch{}: T.Mismatch{}
    case T.Missing{}: T.Missing{}
def health_reserved(-Tx:Type,-H:Data,+mode:Q.Mode,count:U32,observations:List<&2,Observation>,flag:Tx -> T.Tracked -> Tx,ping:Tx -> T.HealthPing -> Tx,log:Tx -> String -> IO(Tx),result:T.Reservation<Tx,H,CC.Cache<T.Vitals,T.VitalsView>>) -> IO(BodyResult<Tx,H>):
  match result:
    case T.Reserved{owner,handle}: audit(Tx,H,mode,count,Some{handle},observations,ping(flag(owner,T.Tracked{8}),T.HealthPing{code(mode)}),log)
    case T.ReserveRejected{owner,payload}: audit(Tx,H,mode,count,None{},observations,ping(flag(owner,T.Tracked{8}),T.HealthPing{code(mode)}),log)
def health_ledger(-Tx:Type,-H:Data,+mode:Q.Mode,count:U32,observations:List<&2,Observation>,spawn:Tx -> CC.Cache<T.Vitals,T.VitalsView> -> T.Reservation<Tx,H,CC.Cache<T.Vitals,T.VitalsView>>,flag:Tx -> T.Tracked -> Tx,ping:Tx -> T.HealthPing -> Tx,log:Tx -> String -> IO(Tx),pair:Tx & Maybe<&2,T.LedgerView>) -> IO(BodyResult<Tx,H>):
  match pair:
    case (owner,view):
      health_reserved(Tx,H,mode,count,List.append(&2,Observation,observations,[LedgerObserved{view}]),flag,ping,log,
        spawn(owner,CP.vitals_new(T.Vitals{quad(60,61,62,63),9,2})))
def health_after(-Tx:Type,-H:Data,mode:Q.Mode,count:U32,observations:List<&2,Observation>,ledger:Tx -> T.HealthLedgerToken -> Tx & Maybe<&2,T.LedgerView>,set_ledger:Tx -> T.HealthLedgerToken -> U32 -> Tx,spawn:Tx -> CC.Cache<T.Vitals,T.VitalsView> -> T.Reservation<Tx,H,CC.Cache<T.Vitals,T.VitalsView>>,flag:Tx -> T.Tracked -> Tx,ping:Tx -> T.HealthPing -> Tx,log:Tx -> String -> IO(Tx),pair:Tx & T.Access<T.VitalsView>) -> IO(BodyResult<Tx,H>):
  match pair:
    case (owner,view): health_ledger(Tx,H,mode,count,List.append(&2,Observation,observations,[MainObserved{health_view(view)}]),spawn,flag,ping,log,ledger(set_ledger(owner,T.HealthLedgerToken{},201),T.HealthLedgerToken{}))
def health_between(-Tx:Type,-H:Data,mode:Q.Mode,count:U32,observations:List<&2,Observation>,second:Tx -> T.VitalsToken -> U32 -> Tx,after:Tx -> T.VitalsToken -> Tx & T.Access<T.VitalsView>,ledger:Tx -> T.HealthLedgerToken -> Tx & Maybe<&2,T.LedgerView>,set_ledger:Tx -> T.HealthLedgerToken -> U32 -> Tx,spawn:Tx -> CC.Cache<T.Vitals,T.VitalsView> -> T.Reservation<Tx,H,CC.Cache<T.Vitals,T.VitalsView>>,flag:Tx -> T.Tracked -> Tx,ping:Tx -> T.HealthPing -> Tx,log:Tx -> String -> IO(Tx),pair:Tx & T.Access<T.VitalsView>) -> IO(BodyResult<Tx,H>):
  match pair:
    case (owner,view): health_after(Tx,H,mode,count,List.append(&2,Observation,observations,[MainObserved{health_view(view)}]),ledger,set_ledger,spawn,flag,ping,log,after(second(owner,T.VitalsToken{},50),T.VitalsToken{}))
def health_choose(-Tx:Type,-H:Data,write:Bool,mode:Q.Mode,count:U32,first:Tx -> T.VitalsToken -> U32 -> Tx,between:Tx -> T.VitalsToken -> Tx & T.Access<T.VitalsView>,second:Tx -> T.VitalsToken -> U32 -> Tx,after:Tx -> T.VitalsToken -> Tx & T.Access<T.VitalsView>,ledger:Tx -> T.HealthLedgerToken -> Tx & Maybe<&2,T.LedgerView>,set_ledger:Tx -> T.HealthLedgerToken -> U32 -> Tx,spawn:Tx -> CC.Cache<T.Vitals,T.VitalsView> -> T.Reservation<Tx,H,CC.Cache<T.Vitals,T.VitalsView>>,flag:Tx -> T.Tracked -> Tx,ping:Tx -> T.HealthPing -> Tx,log:Tx -> String -> IO(Tx),owner:Tx,observations:List<&2,Observation>) -> IO(BodyResult<Tx,H>):
  match write:
    case False{}: IO.pure(BodyResult<Tx,H>,BodyResult{owner,failed(mode),None{},observations})
    case True{}: health_between(Tx,H,mode,count,observations,second,after,ledger,set_ledger,spawn,flag,ping,log,between(first(owner,T.VitalsToken{},30),T.VitalsToken{}))
def health_before(-Tx:Type,-H:Data,+mode:Q.Mode,count:U32,first:Tx -> T.VitalsToken -> U32 -> Tx,between:Tx -> T.VitalsToken -> Tx & T.Access<T.VitalsView>,second:Tx -> T.VitalsToken -> U32 -> Tx,after:Tx -> T.VitalsToken -> Tx & T.Access<T.VitalsView>,ledger:Tx -> T.HealthLedgerToken -> Tx & Maybe<&2,T.LedgerView>,set_ledger:Tx -> T.HealthLedgerToken -> U32 -> Tx,spawn:Tx -> CC.Cache<T.Vitals,T.VitalsView> -> T.Reservation<Tx,H,CC.Cache<T.Vitals,T.VitalsView>>,flag:Tx -> T.Tracked -> Tx,ping:Tx -> T.HealthPing -> Tx,log:Tx -> String -> IO(Tx),pair:Tx & T.Access<T.VitalsView>) -> IO(BodyResult<Tx,H>):
  match pair:
    case (owner,view): health_choose(Tx,H,writes(mode),mode,count,first,between,second,after,ledger,set_ledger,spawn,flag,ping,log,owner,[MainObserved{health_view(view)}])
def health_b(-Tx:Type,-H:Data,mode:Q.Mode,count:U32,before:Tx -> T.VitalsToken -> Tx & T.Access<T.VitalsView>,first:Tx -> T.VitalsToken -> U32 -> Tx,between:Tx -> T.VitalsToken -> Tx & T.Access<T.VitalsView>,second:Tx -> T.VitalsToken -> U32 -> Tx,after:Tx -> T.VitalsToken -> Tx & T.Access<T.VitalsView>,ledger:Tx -> T.HealthLedgerToken -> Tx & Maybe<&2,T.LedgerView>,set_ledger:Tx -> T.HealthLedgerToken -> U32 -> Tx,spawn:Tx -> CC.Cache<T.Vitals,T.VitalsView> -> T.Reservation<Tx,H,CC.Cache<T.Vitals,T.VitalsView>>,flag:Tx -> T.Tracked -> Tx,ping:Tx -> T.HealthPing -> Tx,log:Tx -> String -> IO(Tx),owner:Tx) -> IO(BodyResult<Tx,H>):
  health_before(Tx,H,mode,count,first,between,second,after,ledger,set_ledger,spawn,flag,ping,log,before(owner,T.VitalsToken{}))

# Closed A body: operations are supplied fresh over opaque Tx; selected handle
# is bound privately by trusted provisioning to the actual A entity.
def a_logged(-Tx:Type,-H:Data,handle:H,observations:List<&2,Observation>,owner:Tx) -> IO(BodyResult<Tx,H>):
  IO.pure(BodyResult<Tx,H>,BodyResult{owner,T.Success{},Some{handle},observations})
def motion_a_reserved(-Tx:Type,-H:Data,count:U32,+rejected:T.Outcome,observations:List<&2,Observation>,remove:Tx -> Tx,ping:Tx -> T.MotionPing -> Tx,log:Tx -> String -> IO(Tx),result:T.Reservation<Tx,H,CC.Cache<T.Position,T.PositionView>>) -> IO(BodyResult<Tx,H>):
  match result:
    case T.Reserved{owner,handle}: IO.bind(Tx,BodyResult<Tx,H>,log(ping(remove(owner),T.MotionPing{1}),"A:attempt:" ++ U32.show(count)),t => a_logged(Tx,H,handle,observations,t))
    case T.ReserveRejected{owner,_}: IO.pure(BodyResult<Tx,H>,BodyResult{owner,rejected,None{},observations})
def motion_a_ledger(-Tx:Type,-H:Data,count:U32,+rejected:T.Outcome,observations:List<&2,Observation>,spawn:Tx -> CC.Cache<T.Position,T.PositionView> -> T.Reservation<Tx,H,CC.Cache<T.Position,T.PositionView>>,remove:Tx -> Tx,ping:Tx -> T.MotionPing -> Tx,log:Tx -> String -> IO(Tx),pair:Tx & Maybe<&2,T.LedgerView>) -> IO(BodyResult<Tx,H>):
  match pair:
    case (owner,view): motion_a_reserved(Tx,H,count,rejected,List.append(&2,Observation,observations,[LedgerObserved{view}]),remove,ping,log,spawn(owner,CP.position_new(T.Position{quad(50,51,52,53),7})))
def motion_a_main(-Tx:Type,-H:Data,count:U32,+rejected:T.Outcome,ledger:Tx -> T.MotionLedgerToken -> Tx & Maybe<&2,T.LedgerView>,spawn:Tx -> CC.Cache<T.Position,T.PositionView> -> T.Reservation<Tx,H,CC.Cache<T.Position,T.PositionView>>,remove:Tx -> Tx,ping:Tx -> T.MotionPing -> Tx,log:Tx -> String -> IO(Tx),pair:Tx & T.Access<T.PositionView>) -> IO(BodyResult<Tx,H>):
  match pair:
    case (owner,view): motion_a_ledger(Tx,H,count,rejected,[MainObserved{motion_view(view)}],spawn,remove,ping,log,ledger(owner,T.MotionLedgerToken{}))
def motion_a(-Tx:Type,-H:Data,count:U32,+rejected:T.Outcome,set_main:Tx -> T.PositionToken -> U32 -> Tx,set_ledger:Tx -> T.MotionLedgerToken -> U32 -> Tx,read_main:Tx -> T.PositionToken -> Tx & T.Access<T.PositionView>,read_ledger:Tx -> T.MotionLedgerToken -> Tx & Maybe<&2,T.LedgerView>,spawn_flagged:Tx -> CC.Cache<T.Position,T.PositionView> -> T.Reservation<Tx,H,CC.Cache<T.Position,T.PositionView>>,remove:Tx -> Tx,ping:Tx -> T.MotionPing -> Tx,log:Tx -> String -> IO(Tx),owner:Tx) -> IO(BodyResult<Tx,H>):
  motion_a_main(Tx,H,count,rejected,read_ledger,spawn_flagged,remove,ping,log,read_main(set_ledger(set_main(owner,T.PositionToken{},11),T.MotionLedgerToken{},101),T.PositionToken{}))
def health_a_reserved(-Tx:Type,-H:Data,count:U32,+rejected:T.Outcome,observations:List<&2,Observation>,remove:Tx -> Tx,ping:Tx -> T.HealthPing -> Tx,log:Tx -> String -> IO(Tx),result:T.Reservation<Tx,H,CC.Cache<T.Vitals,T.VitalsView>>) -> IO(BodyResult<Tx,H>):
  match result:
    case T.Reserved{owner,handle}: IO.bind(Tx,BodyResult<Tx,H>,log(ping(remove(owner),T.HealthPing{1}),"A:attempt:" ++ U32.show(count)),t => a_logged(Tx,H,handle,observations,t))
    case T.ReserveRejected{owner,_}: IO.pure(BodyResult<Tx,H>,BodyResult{owner,rejected,None{},observations})
def health_a_ledger(-Tx:Type,-H:Data,count:U32,+rejected:T.Outcome,observations:List<&2,Observation>,spawn:Tx -> CC.Cache<T.Vitals,T.VitalsView> -> T.Reservation<Tx,H,CC.Cache<T.Vitals,T.VitalsView>>,remove:Tx -> Tx,ping:Tx -> T.HealthPing -> Tx,log:Tx -> String -> IO(Tx),pair:Tx & Maybe<&2,T.LedgerView>) -> IO(BodyResult<Tx,H>):
  match pair:
    case (owner,view): health_a_reserved(Tx,H,count,rejected,List.append(&2,Observation,observations,[LedgerObserved{view}]),remove,ping,log,spawn(owner,CP.vitals_new(T.Vitals{quad(50,51,52,53),9,2})))
def health_a_main(-Tx:Type,-H:Data,count:U32,+rejected:T.Outcome,ledger:Tx -> T.HealthLedgerToken -> Tx & Maybe<&2,T.LedgerView>,spawn:Tx -> CC.Cache<T.Vitals,T.VitalsView> -> T.Reservation<Tx,H,CC.Cache<T.Vitals,T.VitalsView>>,remove:Tx -> Tx,ping:Tx -> T.HealthPing -> Tx,log:Tx -> String -> IO(Tx),pair:Tx & T.Access<T.VitalsView>) -> IO(BodyResult<Tx,H>):
  match pair:
    case (owner,view): health_a_ledger(Tx,H,count,rejected,[MainObserved{health_view(view)}],spawn,remove,ping,log,ledger(owner,T.HealthLedgerToken{}))
def health_a(-Tx:Type,-H:Data,count:U32,+rejected:T.Outcome,set_main:Tx -> T.VitalsToken -> U32 -> Tx,set_ledger:Tx -> T.HealthLedgerToken -> U32 -> Tx,read_main:Tx -> T.VitalsToken -> Tx & T.Access<T.VitalsView>,read_ledger:Tx -> T.HealthLedgerToken -> Tx & Maybe<&2,T.LedgerView>,spawn_flagged:Tx -> CC.Cache<T.Vitals,T.VitalsView> -> T.Reservation<Tx,H,CC.Cache<T.Vitals,T.VitalsView>>,remove:Tx -> Tx,ping:Tx -> T.HealthPing -> Tx,log:Tx -> String -> IO(Tx),owner:Tx) -> IO(BodyResult<Tx,H>):
  health_a_main(Tx,H,count,rejected,read_ledger,spawn_flagged,remove,ping,log,read_main(set_ledger(set_main(owner,T.VitalsToken{},11),T.HealthLedgerToken{},101),T.VitalsToken{}))

def WBundleMotion() -> Type:
  S.Bundle<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>
def motion_seed(-Owner:Type,first:Owner -> String -> WBundleMotion() -> Owner,second:Owner -> String -> WBundleMotion() -> Owner,third:Owner -> String -> WBundleMotion() -> Owner,owner:Owner) -> Owner:
  third(second(first(owner,"a",S.Bundle{Some{CP.position_new(T.Position{quad(10,11,12,13),7})},Some{T.Velocity{quad(1,2,3,4),True{}}},Some{T.Selected{8}}}),"b",S.Bundle{Some{CP.position_new(T.Position{quad(20,21,22,23),7})},None{},None{}}),"c",S.Bundle{None{},Some{T.Velocity{quad(1,2,3,4),True{}}},Some{T.Selected{8}}})
def motion_seed_beta(-Owner:Type,reserve:Owner -> String -> WBundleMotion() -> Owner,owner:Owner) -> Owner:
  reserve(owner,"z",S.Bundle{Some{CP.position_new(T.Position{quad(90,91,92,93),7})},None{},Some{T.Selected{8}}})
def motion_spawn_s(-Owner:Type,reserve:Owner -> String -> WBundleMotion() -> Owner,owner:Owner) -> Owner:
  reserve(owner,"s",S.Bundle{Some{CP.position_new(T.Position{quad(70,71,72,73),7})},None{},None{}})

def WBundleHealth() -> Type:
  S.Bundle<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>
def health_seed(-Owner:Type,first:Owner -> String -> WBundleHealth() -> Owner,second:Owner -> String -> WBundleHealth() -> Owner,third:Owner -> String -> WBundleHealth() -> Owner,owner:Owner) -> Owner:
  third(second(first(owner,"a",S.Bundle{Some{CP.vitals_new(T.Vitals{quad(10,11,12,13),9,2})},Some{T.Armor{quad(1,2,3,4),3}},Some{T.Tracked{8}}}),"b",S.Bundle{Some{CP.vitals_new(T.Vitals{quad(20,21,22,23),9,2})},None{},None{}}),"c",S.Bundle{None{},Some{T.Armor{quad(1,2,3,4),3}},Some{T.Tracked{8}}})
def health_seed_beta(-Owner:Type,reserve:Owner -> String -> WBundleHealth() -> Owner,owner:Owner) -> Owner:
  reserve(owner,"z",S.Bundle{Some{CP.vitals_new(T.Vitals{quad(90,91,92,93),9,2})},None{},Some{T.Tracked{8}}})
def health_spawn_s(-Owner:Type,reserve:Owner -> String -> WBundleHealth() -> Owner,owner:Owner) -> Owner:
  reserve(owner,"s",S.Bundle{Some{CP.vitals_new(T.Vitals{quad(70,71,72,73),9,2})},None{},None{}})
