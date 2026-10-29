import Base
import ./execution-reservation-task.bend as T
import ./execution-reservation-authority.bend as Authority

# Private framework protocol. No fuel, namespace minting, or completion recursion.
type Frame<-S:Data,-Permit:Data,-R:Type> is Type:
  Frame{issuer:T.Issuer<S>,task:T.Task<S,Permit,R>}
  SerialFrame{issuer:T.Issuer<S>,task:T.Task<S,Permit,R>}
type Terminal<-S:Data,-R:Type> is Type:
  Terminal{issuer:T.Issuer<S>,value:R}
# Base Result is only a one-field transport envelope: Fail means another round.
def Round(-S:Data,-Permit:Data,-R:Type) -> Type:
  Result<&1,&1,Frame<S,Permit,R>,Terminal<S,R>>
def initial(-S:Data,-Permit:Data,-R:Type,policy:T.Policy,issuer:T.Issuer<S>,task:T.Task<S,Permit,R>) -> Frame<S,Permit,R>:
  match policy:
    case T.Parallel{}:Frame{issuer,task}
    case T.Serial{}:SerialFrame{issuer,task}
def pack_policy(-S:Data,-Permit:Data,-R:Type,policy:T.Policy,result:T.Issuer<S> & T.Task<S,Permit,R>) -> Round(S,Permit,R):
  match result:
    case (issuer,T.TDone{value}):Done{Terminal{issuer,value}}
    case (issuer,task):Fail{initial(S,Permit,R,policy,issuer,task)}
def pack(-S:Data,-Permit:Data,-R:Type,result:T.Issuer<S> & T.Task<S,Permit,R>) -> Round(S,Permit,R):
  pack_policy(S,Permit,R,T.Parallel{},result)
def step_policy(~S:Data,-R:Type,+policy:T.Policy,issuer:T.Issuer<S>,task:T.Task<S,Authority.Permit,R>) -> Round(S,Authority.Permit,R):
  pack_policy(S,Authority.Permit,R,policy,T.service_generic_mode(S,Authority.Permit,R,policy,T.advance_mode(S,Authority.Permit,R,policy,task),T.Direct{{==}},issuer))
def framework_step_generic(~S:Data,-R:Type,frame:Frame<S,Authority.Permit,R>) -> Round(S,Authority.Permit,R):
  match frame:
    case Frame{issuer,task}:step_policy(~S,R,T.Parallel{},issuer,task)
    case SerialFrame{issuer,task}:step_policy(~S,R,T.Serial{},issuer,task)
