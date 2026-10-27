import Base
import ./execution-reservation-task.bend as T

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
def authorize_unit(~Permit:Data,~authorized:Permit -> U32 -> List<&2,U32> -> Bool,context:Unit,permit:Permit,namespace:U32,ids:List<&2,U32>) -> Bool:
  authorized(permit,namespace,ids)
def framework_step(~S:Data,~Permit:Data,~R:Type,~authorized:Permit -> U32 -> List<&2,U32> -> Bool,frame:Frame<S,Permit,R>) -> Round(S,Permit,R):
  match frame:
    case Frame{issuer,task}:pack(S,Permit,R,T.service(~S,~Permit,~R,~Unit,~authorize_unit(~Permit,~authorized),T.advance(S,Permit,R,task),Unit{},issuer))
