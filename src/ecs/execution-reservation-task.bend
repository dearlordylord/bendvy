import Base
import ./entity-allocator.bend as A
import ./world.bend as W

type Granted is Data:
  Granted{}

type Task<-S:Data,-Permit:Data,-R:Type> is Type:
  TDone{value:R}
  TRun{step:Unit -> Task<S,Permit,R>}
  TNeed{permit:Permit,resume:W.Reservation<S> -> Task<S,Permit,R>}
  TBind{-A:Type,task:Task<S,Permit,A>,next:A -> Task<S,Permit,R>}
  TFork{-L:Type,-T:Type,left:Task<S,Permit,L>,right:Task<S,Permit,T>,join:L -> T -> Task<S,Permit,R>}
  TMapPermit{-Inner:Data,-Context:Data,-convert:Context -> Inner -> Permit,context:Context,task:Task<S,Inner,R>}
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

def advance(-S:Data,-Permit:Data,-R:Type,task:Task<S,Permit,R>) -> Task<S,Permit,R>:
  match task:
    case TRun{step}:step(Unit{})
    case TBind{A,task,next}:TBind{A,advance(S,Permit,A,task),next}
    case TFork{L,T,left,right,join}:
      l r = advance(S,Permit,L,left) advance(S,Permit,T,right)
      TFork{L,T,l,r,join}
    case TNeed{permit,resume}:TNeed{permit,resume}
    case TMapPermit{Inner,Context,convert,context,task}:TMapPermit{Inner,Context,convert,context,advance(S,Inner,R,task)}
    case TDone{value}:TDone{value}

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
type ContextPair<-Outer:Data,-Inner:Data> is Data:
  ContextPair{outer:Outer,inner:Inner}
def mapped_authorized(~Inner:Data,~Permit:Data,~Outer:Data,~Map:Data,~convert:Map -> Inner -> Permit,~authorized:Outer -> Permit -> U32 -> List<&2,U32> -> Bool,context:ContextPair<Outer,Map>,permit:Inner,namespace:U32,ids:List<&2,U32>) -> Bool:
  match context:
    case ContextPair{outer,inner}:authorized(outer,convert(inner,permit),namespace,ids)
def service_mapped(~S:Data,~Inner:Data,~Permit:Data,~R:Type,~Context:Data,~convert:Context -> Inner -> Permit,context:Context,result:Issuer<S> & Task<S,Inner,R>) -> Issuer<S> & Task<S,Permit,R>:
  match result:
    case (issuer,TDone{value}):(issuer,TDone{value})
    case (issuer,task):(issuer,TMapPermit{Inner,Context,convert,context,task})
def service_request(~S:Data,~Permit:Data,~R:Type,~Context:Data,~authorized:Context -> Permit -> U32 -> List<&2,U32> -> Bool,context:Context,permit:Permit,resume:W.Reservation<S> -> Task<S,Permit,R>,issuer:Issuer<S>) -> Issuer<S> & Task<S,Permit,R>:
  match issuer:
    case Issuer{+namespace,allocator,+allowlist}:service_allowed(S,Permit,R,resume,Issuer{namespace,allocator,allowlist},authorized(context,permit,namespace,allowlist))
def service(~S:Data,~Permit:Data,~R:Type,~Context:Data,~authorized:Context -> Permit -> U32 -> List<&2,U32> -> Bool,task:Task<S,Permit,R>,+context:Context,issuer:Issuer<S>) -> Issuer<S> & Task<S,Permit,R>:
  match task:
    case TNeed{permit,resume}:service_request(~S,~Permit,~R,~Context,~authorized,context,permit,resume,issuer)
    case TBind{A,task,next}:service_bind(S,Permit,A,R,next,service(~S,~Permit,~A,~Context,~authorized,task,context,issuer))
    case TFork{L,T,left,right,join}:service_left(S,Permit,L,T,R,root => service(~S,~Permit,~T,~Context,~authorized,right,context,root),join,service(~S,~Permit,~L,~Context,~authorized,left,context,issuer))
    case TMapPermit{Inner,Map,convert,+inner,task}:service_mapped(~S,~Inner,~Permit,~R,~Map,~convert,inner,service(~S,~Inner,~R,~ContextPair<Context,Map>,~mapped_authorized(~Inner,~Permit,~Context,~Map,~convert,~authorized),task,ContextPair{context,inner},issuer))
    case TRun{step}:(issuer,TRun{step})
    case TDone{value}:(issuer,TDone{value})

# Persistent wrapper keeps future callbacks under the same conversion. There
# is no recursive traversal of a computed callback result and no copied closure.
def map_permit(~S:Data,~P:Data,~Q:Data,~R:Type,~Context:Data,~convert:Context -> P -> Q,context:Context,task:Task<S,P,R>) -> Task<S,Q,R>:
  TMapPermit{P,Context,convert,context,task}
