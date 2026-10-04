import Base
import ./types.bend as T
import ./systems.bend as U
import ./schedule.bend as K

def main_first(view:T.MainView) -> U32:
  match view:
    case T.MotionMain{T.PositionView{T.Four{a,_,_,_},_}}: a
    case T.HealthMain{T.VitalsView{T.Four{a,_,_,_},_,_}}: a
def read_initial(-Tx:Type,-H:Data,next:Tx -> U32 -> IO(U.BodyResult<Tx,H>),pair:Tx & T.Access<T.MainView>) -> IO(U.BodyResult<Tx,H>):
  match pair:
    case (owner,T.Found{view}): next(owner,main_first(view))
    case (owner,view): IO.pure(U.BodyResult<Tx,H>,U.BodyResult{owner,T.Failure{8},None{},[U.MainObserved{view}]})
def observe_main(-Tx:Type,-H:Data,next:Tx -> List<&2,U.Observation> -> IO(U.BodyResult<Tx,H>),observations:List<&2,U.Observation>,pair:Tx & T.Access<T.MainView>) -> IO(U.BodyResult<Tx,H>):
  match pair:
    case (owner,view): next(owner,List.append(&2,U.Observation,observations,[U.MainObserved{view}]))
def read_ledger(-Tx:Type,-H:Data,next:Tx -> U32 -> IO(U.BodyResult<Tx,H>),observations:List<&2,U.Observation>,pair:Tx & Maybe<&2,T.LedgerView>) -> IO(U.BodyResult<Tx,H>):
  match pair:
    case (owner,Some{T.LedgerView{T.Four{a,_,_,_},_}}): next(owner,a)
    case (owner,None{}): IO.pure(U.BodyResult<Tx,H>,U.BodyResult{owner,T.Failure{9},None{},observations})
def observe_ledger(-Tx:Type,-H:Data,next:Tx -> List<&2,U.Observation> -> IO(U.BodyResult<Tx,H>),observations:List<&2,U.Observation>,pair:Tx & Maybe<&2,T.LedgerView>) -> IO(U.BodyResult<Tx,H>):
  match pair:
    case (owner,view): next(owner,List.append(&2,U.Observation,observations,[U.LedgerObserved{view}]))
def audited(-Tx:Type,-H:Data,outcome:T.Outcome,handle:Maybe<&2,H>,observations:List<&2,U.Observation>,owner:Tx) -> IO(U.BodyResult<Tx,H>):
  IO.pure(U.BodyResult<Tx,H>,U.BodyResult{owner,outcome,handle,observations})
def reserved(-Tx:Type,-H:Data,-Payload:Type,outcome:T.Outcome,observations:List<&2,U.Observation>,publish:Tx -> Tx,log:Tx -> IO(Tx),reservation:T.Reservation<Tx,H,Payload>) -> IO(U.BodyResult<Tx,H>):
  match reservation:
    case T.Reserved{owner,handle}: IO.bind(Tx,U.BodyResult<Tx,H>,log(publish(owner)),t => audited(Tx,H,outcome,Some{handle},observations,t))
    case T.ReserveRejected{owner,payload}: IO.bind(Tx,U.BodyResult<Tx,H>,log(publish(owner)),t => audited(Tx,H,outcome,None{},observations,t))
def second(-Tx:Type,-H:Data,twice:Bool,+x:U32,write:Tx -> U32 -> Tx,read:Tx -> Tx & T.Access<T.MainView>,next:Tx -> List<&2,U.Observation> -> IO(U.BodyResult<Tx,H>),observations:List<&2,U.Observation>,owner:Tx) -> IO(U.BodyResult<Tx,H>):
  match twice:
    case False{}: next(owner,observations)
    case True{}: observe_main(Tx,H,next,observations,read(write(owner,U32.add(x,30))))
def amount(twice:Bool) -> U32:
  match twice:
    case False{}: 1
    case True{}: 10
def ledger_amount(twice:Bool) -> U32:
  match twice:
    case False{}: 1
    case True{}: 100
def dynamic(-Tx:Type,-H:Data,-Payload:Type,+twice:Bool,outcome:T.Outcome,
  before:Tx -> Tx & T.Access<T.MainView>,first:Tx -> U32 -> Tx,between:Tx -> Tx & T.Access<T.MainView>,second_write:Tx -> U32 -> Tx,after:Tx -> Tx & T.Access<T.MainView>,
  ledger_before:Tx -> Tx & Maybe<&2,T.LedgerView>,set_ledger:Tx -> U32 -> Tx,ledger_after:Tx -> Tx & Maybe<&2,T.LedgerView>,spawn:Tx -> Payload -> T.Reservation<Tx,H,Payload>,payload:Payload,publish:Tx -> Tx,log:Tx -> IO(Tx),owner:Tx) -> IO(U.BodyResult<Tx,H>):
  read_initial(Tx,H,t => +x =>
    observe_main(Tx,H,t => +observations =>
      second(Tx,H,twice,x,second_write,after,t => +observations =>
        read_ledger(Tx,H,t => old =>
          observe_ledger(Tx,H,t => +observations =>
            reserved(Tx,H,Payload,outcome,observations,publish,log,spawn(t,payload)),
            observations,ledger_after(set_ledger(t,U32.add(old,ledger_amount(twice))))),
          observations,ledger_before(t)),
        observations,t),
      [],between(first(t,U32.add(x,amount(twice))))),
    before(owner))
def motion_read_done(-Tx:Type,pair:Tx & T.Access<T.PositionView>) -> Tx & T.Access<T.MainView>:
  match pair:
    case (owner,view): (owner,U.motion_view(view))
def motion_read(-Tx:Type,read:Tx -> T.PositionToken -> Tx & T.Access<T.PositionView>,owner:Tx) -> Tx & T.Access<T.MainView>:
  motion_read_done(Tx,read(owner,T.PositionToken{}))
def health_read_done(-Tx:Type,pair:Tx & T.Access<T.VitalsView>) -> Tx & T.Access<T.MainView>:
  match pair:
    case (owner,view): (owner,U.health_view(view))
def health_read(-Tx:Type,read:Tx -> T.VitalsToken -> Tx & T.Access<T.VitalsView>,owner:Tx) -> Tx & T.Access<T.MainView>:
  health_read_done(Tx,read(owner,T.VitalsToken{}))
def payload_second(twice:Bool) -> U32:
  match twice:
    case False{}: 20
    case True{}: 200
def payload_third(twice:Bool) -> U32:
  match twice:
    case False{}: 30
    case True{}: 300
def payload_fourth(twice:Bool) -> U32:
  match twice:
    case False{}: 40
    case True{}: 400

def b_number(twice:Bool) -> U32:
  match twice:
    case False{}: 0
    case True{}: 1
def who(twice:Bool) -> String:
  match twice:
    case False{}: "A"
    case True{}: "B"

def motion_body(-Tx:Type,-H:Data,+twice:Bool,+iteration:U32,count:U32,outcome:T.Outcome,
  before:Tx -> T.PositionToken -> Tx & T.Access<T.PositionView>,first:Tx -> T.PositionToken -> U32 -> Tx,between:Tx -> T.PositionToken -> Tx & T.Access<T.PositionView>,second_write:Tx -> T.PositionToken -> U32 -> Tx,after:Tx -> T.PositionToken -> Tx & T.Access<T.PositionView>,
  ledger_before:Tx -> T.MotionLedgerToken -> Tx & Maybe<&2,T.LedgerView>,set_ledger:Tx -> T.MotionLedgerToken -> U32 -> Tx,ledger_after:Tx -> T.MotionLedgerToken -> Tx & Maybe<&2,T.LedgerView>,spawn:Tx -> T.Position -> T.Reservation<Tx,H,T.Position>,ping:Tx -> T.MotionPing -> Tx,log:Tx -> String -> IO(Tx),owner:Tx) -> IO(U.BodyResult<Tx,H>):
  dynamic(Tx,H,T.Position,twice,outcome,
    t => motion_read(Tx,before,t),t => v => first(t,T.PositionToken{},v),t => motion_read(Tx,between,t),t => v => second_write(t,T.PositionToken{},v),t => motion_read(Tx,after,t),
    t => ledger_before(t,T.MotionLedgerToken{}),t => v => set_ledger(t,T.MotionLedgerToken{},v),t => ledger_after(t,T.MotionLedgerToken{}),spawn,
    T.Position{U.quad(iteration,payload_second(twice),payload_third(twice),payload_fourth(twice)),7},
    t => ping(t,T.MotionPing{U32.add(U32.mul(iteration,2),b_number(twice))}),
    t => log(t,"{\"who\":\"" ++ who(twice) ++ "\",\"iteration\":" ++ U32.show(iteration) ++ ",\"capture\":" ++ U32.show(count) ++ "}"),owner)

def health_body(-Tx:Type,-H:Data,+twice:Bool,+iteration:U32,count:U32,outcome:T.Outcome,
  before:Tx -> T.VitalsToken -> Tx & T.Access<T.VitalsView>,first:Tx -> T.VitalsToken -> U32 -> Tx,between:Tx -> T.VitalsToken -> Tx & T.Access<T.VitalsView>,second_write:Tx -> T.VitalsToken -> U32 -> Tx,after:Tx -> T.VitalsToken -> Tx & T.Access<T.VitalsView>,
  ledger_before:Tx -> T.HealthLedgerToken -> Tx & Maybe<&2,T.LedgerView>,set_ledger:Tx -> T.HealthLedgerToken -> U32 -> Tx,ledger_after:Tx -> T.HealthLedgerToken -> Tx & Maybe<&2,T.LedgerView>,spawn:Tx -> T.Vitals -> T.Reservation<Tx,H,T.Vitals>,ping:Tx -> T.HealthPing -> Tx,log:Tx -> String -> IO(Tx),owner:Tx) -> IO(U.BodyResult<Tx,H>):
  dynamic(Tx,H,T.Vitals,twice,outcome,
    t => health_read(Tx,before,t),t => v => first(t,T.VitalsToken{},v),t => health_read(Tx,between,t),t => v => second_write(t,T.VitalsToken{},v),t => health_read(Tx,after,t),
    t => ledger_before(t,T.HealthLedgerToken{}),t => v => set_ledger(t,T.HealthLedgerToken{},v),t => ledger_after(t,T.HealthLedgerToken{}),spawn,
    T.Vitals{U.quad(iteration,payload_second(twice),payload_third(twice),payload_fourth(twice)),9,2},
    t => ping(t,T.HealthPing{U32.add(U32.mul(iteration,2),b_number(twice))}),
    t => log(t,"{\"who\":\"" ++ who(twice) ++ "\",\"iteration\":" ++ U32.show(iteration) ++ ",\"capture\":" ++ U32.show(count) ++ "}"),owner)
