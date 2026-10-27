import Base
import ./execution-reservation-task.bend as T

# Private framework protocol. No fuel, namespace minting, or completion recursion.
type Frame<-S:Data,-R:Type> is Type:
  Frame{issuer:T.Issuer<S>,task:T.Task<S,R>}
type Terminal<-S:Data,-R:Type> is Type:
  Terminal{issuer:T.Issuer<S>,value:R}
# Base Result is only a one-field transport envelope: Fail means another round.
def Round(-S:Data,-R:Type) -> Type:
  Result<&1,&1,Frame<S,R>,Terminal<S,R>>
def pack(-S:Data,-R:Type,result:T.Issuer<S> & T.Task<S,R>) -> Round(S,R):
  match result:
    case (issuer,T.TDone{value}):Done{Terminal{issuer,value}}
    case (issuer,task):Fail{Frame{issuer,task}}
def framework_step(-S:Data,-R:Type,frame:Frame<S,R>) -> Round(S,R):
  match frame:
    case Frame{issuer,task}:pack(S,R,T.service(S,R,T.advance(S,R,task),issuer))
