import Base
import ./execution-reservation-task.bend as T
import ./execution-reservation-authority.bend as Authority

# Private framework protocol. No fuel, namespace minting, or completion recursion.
type Frame<-S:Data,-Permit:Data,-R:Type> is Type:
  Frame{issuer:T.Issuer<S>,task:T.Task<S,Permit,R>}
type Terminal<-S:Data,-R:Type> is Type:
  Terminal{issuer:T.Issuer<S>,value:R}
# Base Result is only a one-field transport envelope: Fail means another round.
def Round(-S:Data,-Permit:Data,-R:Type) -> Type:
  Result<&1,&1,Frame<S,Permit,R>,Terminal<S,R>>
def pack(-S:Data,-Permit:Data,-R:Type,result:T.Issuer<S> & T.Task<S,Permit,R>) -> Round(S,Permit,R):
  match result:
    case (issuer,T.TDone{value}):Done{Terminal{issuer,value}}
    case (issuer,task):Fail{Frame{issuer,task}}
def framework_step_generic(~S:Data,-R:Type,frame:Frame<S,Authority.Permit,R>) -> Round(S,Authority.Permit,R):
  match frame:
    case Frame{issuer,task}:pack(S,Authority.Permit,R,T.service_generic(S,Authority.Permit,R,T.advance(S,Authority.Permit,R,task),T.Direct{{==}},issuer))
