import Base
import ./entity-allocator.bend as A
import ./world.bend as W
import ./execution-reservation-authority.bend as Authority

type Policy is Data:
  Parallel{}
  Serial{}

type Granted is Data:
  Granted{}

type Task<-S:Data,-Permit:Data,-R:Type> is Type:
  TDone{value:R}
  TRun{step:Unit -> Task<S,Permit,R>}
  TNeed{permit:Permit,resume:W.Reservation<S> -> Task<S,Permit,R>}
  TBind{-A:Type,task:Task<S,Permit,A>,next:A -> Task<S,Permit,R>}
  TFork{-L:Type,-T:Type,left:Task<S,Permit,L>,right:Task<S,Permit,T>,join:L -> T -> Task<S,Permit,R>}
  TQualify{same:{Permit == Authority.Permit : Data},context:Authority.Context,task:Task<S,Granted,R>}
type Issuer<-S:Data> is Type:
  Issuer{namespace:U32,allocator:A.Allocator,authorized:List<&2,U32>}
def bind(-S:Data,-Permit:Data,-R:Type,-T:Type,task:Task<S,Permit,R>,next:R -> Task<S,Permit,T>) -> Task<S,Permit,T>:
  TBind{R,task,next}

def pending_answer(-S:Data,+namespace:U32,authorized:List<&2,U32>,key:W.Handle<S>,result:A.Allocator & Bool) -> Issuer<S> & W.Reservation<S>:
  match result:
    case (allocator,True{}):(Issuer{namespace,allocator,authorized},W.Reserved{key})
    case (allocator,False{}):(Issuer{namespace,allocator,authorized},W.ReservationRejected{W.MissingEntity{}})
def answer(-S:Data,+namespace:U32,authorized:List<&2,U32>,result:A.Allocator & A.Reservation) -> Issuer<S> & W.Reservation<S>:
  match result:
    case (allocator,A.Exhausted{}):(Issuer{namespace,allocator,authorized},W.ReservationRejected{W.CapacityExceeded{}})
    case (allocator,A.Reserved{+key}):pending_answer(S,namespace,authorized,W.Handle{namespace,key},A.set(allocator,key,A.Pending{}))

def reserve(-S:Data,issuer:Issuer<S>) -> Issuer<S> & W.Reservation<S>:
  match issuer:
    case Issuer{namespace,allocator,authorized}:answer(S,namespace,authorized,A.reserve(allocator))

# Serial interpretation transfers each existing branch into the normal bind
# continuation. It does not enter the right branch before the left returns.
def lower_fork(-S:Data,-Permit:Data,-L:Type,-T:Type,-R:Type,left:Task<S,Permit,L>,right:Task<S,Permit,T>,join:L -> T -> Task<S,Permit,R>) -> Task<S,Permit,R>:
  TBind{L,left,l => TBind{T,right,r => join(l,r)}}
def advance_mode(-S:Data,-Permit:Data,-R:Type,+policy:Policy,task:Task<S,Permit,R>) -> Task<S,Permit,R>:
  match policy task:
    case policy TRun{step}:step(Unit{})
    case policy TBind{A,task,next}:TBind{A,advance_mode(S,Permit,A,policy,task),next}
    case Serial{} TFork{L,T,left,right,join}:lower_fork(S,Permit,L,T,R,left,right,join)
    case Parallel{} TFork{L,T,left,right,join}:
      l r = advance_mode(S,Permit,L,Parallel{},left) advance_mode(S,Permit,T,Parallel{},right)
      TFork{L,T,l,r,join}
    case policy TNeed{permit,resume}:TNeed{permit,resume}
    case policy TQualify{same,context,task}:TQualify{same,context,advance_mode(S,Granted,R,policy,task)}
    case policy TDone{value}:TDone{value}
def advance(-S:Data,-Permit:Data,-R:Type,task:Task<S,Permit,R>) -> Task<S,Permit,R>:
  advance_mode(S,Permit,R,Parallel{},task)

def service_answer(-S:Data,-Permit:Data,-R:Type,resume:W.Reservation<S> -> Task<S,Permit,R>,result:Issuer<S> & W.Reservation<S>) -> Issuer<S> & Task<S,Permit,R>:
  match result:
    case (issuer,answer):(issuer,TRun{_ => resume(answer)})
def service_bind(-S:Data,-Permit:Data,-A:Type,-R:Type,next:A -> Task<S,Permit,R>,result:Issuer<S> & Task<S,Permit,A>) -> Issuer<S> & Task<S,Permit,R>:
  match result:
    case (issuer,TDone{value}):(issuer,TRun{_ => next(value)})
    case (issuer,task):(issuer,TBind{A,task,next})
def service_join(-S:Data,-Permit:Data,-L:Type,-T:Type,-R:Type,left:Task<S,Permit,L>,join:L -> T -> Task<S,Permit,R>,result:Issuer<S> & Task<S,Permit,T>) -> Issuer<S> & Task<S,Permit,R>:
  match left result:
    case TDone{left}, (issuer,TDone{right}):(issuer,TRun{_ => join(left,right)})
    case left, (issuer,right):(issuer,TFork{L,T,left,right,join})
def service_left(-S:Data,-Permit:Data,-L:Type,-T:Type,-R:Type,serviceRight:Issuer<S> -> Issuer<S> & Task<S,Permit,T>,join:L -> T -> Task<S,Permit,R>,result:Issuer<S> & Task<S,Permit,L>) -> Issuer<S> & Task<S,Permit,R>:
  match result:
    case (issuer,left):service_join(S,Permit,L,T,R,left,join,serviceRight(issuer))
# The framework specializes authorized to its concrete declaration-bound check.
# A denied request keeps the same actual issuer and does not call reserve.
def service_allowed(-S:Data,-Permit:Data,-R:Type,resume:W.Reservation<S> -> Task<S,Permit,R>,issuer:Issuer<S>,allowed:Bool) -> Issuer<S> & Task<S,Permit,R>:
  match allowed:
    case False{}:service_answer(S,Permit,R,resume,(issuer,W.ReservationRejected{W.ReservationUnauthorized{}}))
    case True{}:service_answer(S,Permit,R,resume,reserve(S,issuer))
# Closed authorization modes retain reusable provenance, never a function owner.
type Authorization<-Permit:Data> is Data:
  Direct{same:{Permit == Authority.Permit : Data}}
  GrantedAccess{same:{Permit == Granted : Data},context:Authority.Context}
def runtime_permit(-Permit:Data,same:{Permit == Authority.Permit : Data},permit:Permit) -> Authority.Permit:
  %same : _
  permit
def allowed(-Permit:Data,access:Authorization<Permit>,permit:Permit,namespace:U32,ids:List<&2,U32>) -> Bool:
  match access:
    case Direct{same}:Authority.authorized(runtime_permit(Permit,same,permit),namespace,ids)
    case GrantedAccess{_,context}:Authority.authorized(Authority.qualified(context),namespace,ids)
def service_request_generic(-S:Data,-Permit:Data,-R:Type,access:Authorization<Permit>,permit:Permit,resume:W.Reservation<S> -> Task<S,Permit,R>,issuer:Issuer<S>) -> Issuer<S> & Task<S,Permit,R>:
  match issuer:
    case Issuer{+namespace,allocator,+allowlist}:service_allowed(S,Permit,R,resume,Issuer{namespace,allocator,allowlist},allowed(Permit,access,permit,namespace,allowlist))
def service_qualified(-S:Data,-Permit:Data,-R:Type,same:{Permit == Authority.Permit : Data},context:Authority.Context,result:Issuer<S> & Task<S,Granted,R>) -> Issuer<S> & Task<S,Permit,R>:
  match result:
    case (issuer,TDone{value}):(issuer,TDone{value})
    case (issuer,task):(issuer,TQualify{same,context,task})
# A TRun may yield a fresh fork in the same frame round. Apply the same
# serial lowering here before either branch can issue a reservation request.
def service_generic_mode(-S:Data,-Permit:Data,-R:Type,+policy:Policy,task:Task<S,Permit,R>,+access:Authorization<Permit>,issuer:Issuer<S>) -> Issuer<S> & Task<S,Permit,R>:
  match policy task:
    case policy TNeed{permit,resume}:service_request_generic(S,Permit,R,access,permit,resume,issuer)
    case policy TBind{A,task,next}:service_bind(S,Permit,A,R,next,service_generic_mode(S,Permit,A,policy,task,access,issuer))
    case Serial{} TFork{L,T,left,right,join}:(issuer,lower_fork(S,Permit,L,T,R,left,right,join))
    case Parallel{} TFork{L,T,left,right,join}:service_left(S,Permit,L,T,R,root => service_generic_mode(S,Permit,T,Parallel{},right,access,root),join,service_generic_mode(S,Permit,L,Parallel{},left,access,issuer))
    case policy TQualify{same,+context,task}:service_qualified(S,Permit,R,same,context,service_generic_mode(S,Granted,R,policy,task,GrantedAccess{{==},context},issuer))
    case policy TRun{step}:(issuer,TRun{step})
    case policy TDone{value}:(issuer,TDone{value})
def service_generic(-S:Data,-Permit:Data,-R:Type,task:Task<S,Permit,R>,access:Authorization<Permit>,issuer:Issuer<S>) -> Issuer<S> & Task<S,Permit,R>:
  service_generic_mode(S,Permit,R,Parallel{},task,access,issuer)
# The trusted prepared leaf supplies the actual namespace, id and closed grant.
# The persistent wrapper also covers future bind/fork/request continuations.
def qualify(-S:Data,-R:Type,context:Authority.Context,task:Task<S,Granted,R>) -> Task<S,Authority.Permit,R>:
  TQualify{{==},context,task}
