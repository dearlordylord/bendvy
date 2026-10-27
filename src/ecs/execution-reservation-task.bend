import Base
import ./entity-allocator.bend as A
import ./world.bend as W

type Task<-S:Data,-R:Type> is Type:
  TDone{value:R}
  TRun{step:Unit -> Task<S,R>}
  TNeed{resume:W.Reservation<S> -> Task<S,R>}
  TBind{-A:Type,task:Task<S,A>,next:A -> Task<S,R>}
  TFork{-L:Type,-T:Type,left:Task<S,L>,right:Task<S,T>,join:L -> T -> Task<S,R>}
type Issuer<-S:Data> is Type:
  Issuer{namespace:U32,allocator:A.Allocator}
def bind(-S:Data,-R:Type,-T:Type,task:Task<S,R>,next:R -> Task<S,T>) -> Task<S,T>:
  TBind{R,task,next}

def pending_answer(-S:Data,+namespace:U32,key:W.Handle<S>,result:A.Allocator & Bool) -> Issuer<S> & W.Reservation<S>:
  match result:
    case (allocator,True{}):(Issuer{namespace,allocator},W.Reserved{key})
    case (allocator,False{}):(Issuer{namespace,allocator},W.ReservationRejected{W.MissingEntity{}})
def answer(-S:Data,+namespace:U32,result:A.Allocator & A.Reservation) -> Issuer<S> & W.Reservation<S>:
  match result:
    case (allocator,A.Exhausted{}):(Issuer{namespace,allocator},W.ReservationRejected{W.CapacityExceeded{}})
    case (allocator,A.Reserved{+key}):pending_answer(S,namespace,W.Handle{namespace,key},A.set(allocator,key,A.Pending{}))

def reserve(-S:Data,issuer:Issuer<S>) -> Issuer<S> & W.Reservation<S>:
  match issuer:
    case Issuer{namespace,allocator}:answer(S,namespace,A.reserve(allocator))

def advance(-S:Data,-R:Type,task:Task<S,R>) -> Task<S,R>:
  match task:
    case TRun{step}:step(Unit{})
    case TBind{A,task,next}:TBind{A,advance(S,A,task),next}
    case TFork{L,T,left,right,join}:
      l r = advance(S,L,left) advance(S,T,right)
      TFork{L,T,l,r,join}
    case TNeed{resume}:TNeed{resume}
    case TDone{value}:TDone{value}

def service_answer(-S:Data,-R:Type,resume:W.Reservation<S> -> Task<S,R>,result:Issuer<S> & W.Reservation<S>) -> Issuer<S> & Task<S,R>:
  match result:
    case (issuer,answer):(issuer,TRun{_ => resume(answer)})
def service_bind(-S:Data,-A:Type,-R:Type,next:A -> Task<S,R>,result:Issuer<S> & Task<S,A>) -> Issuer<S> & Task<S,R>:
  match result:
    case (issuer,TDone{value}):(issuer,TRun{_ => next(value)})
    case (issuer,task):(issuer,TBind{A,task,next})
def service_join(-S:Data,-L:Type,-T:Type,-R:Type,left:Task<S,L>,join:L -> T -> Task<S,R>,result:Issuer<S> & Task<S,T>) -> Issuer<S> & Task<S,R>:
  match left result:
    case TDone{left}, (issuer,TDone{right}):(issuer,TRun{_ => join(left,right)})
    case left, (issuer,right):(issuer,TFork{L,T,left,right,join})
def service_left(-S:Data,-L:Type,-T:Type,-R:Type,serviceRight:Issuer<S> -> Issuer<S> & Task<S,T>,join:L -> T -> Task<S,R>,result:Issuer<S> & Task<S,L>) -> Issuer<S> & Task<S,R>:
  match result:
    case (issuer,left):service_join(S,L,T,R,left,join,serviceRight(issuer))
def service(-S:Data,-R:Type,task:Task<S,R>,issuer:Issuer<S>) -> Issuer<S> & Task<S,R>:
  match task:
    case TNeed{resume}:service_answer(S,R,resume,reserve(S,issuer))
    case TBind{A,task,next}:service_bind(S,A,R,next,service(S,A,task,issuer))
    case TFork{L,T,left,right,join}:service_left(S,L,T,R,root => service(S,T,right,root),join,service(S,L,left,issuer))
    case TRun{step}:(issuer,TRun{step})
    case TDone{value}:(issuer,TDone{value})
