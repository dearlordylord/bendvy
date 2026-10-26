import Base
import ./execution-state.bend as State
import ./capabilities.bend as Cap

type Declaration<-S:Data,-C:Type,-R:Type,-Ops:Type -> Type> is Type:
  Declaration{caps:Ops(State.Scope<S,C,R>),access:List<&2,String>}
def access(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type,value:Declaration<S,C,R,Ops>) -> List<&2,String>:
  match value:
    case Declaration{_,access}:access
def grants(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type,value:Declaration<S,C,R,Ops>) -> Ops(State.Scope<S,C,R>):
  match value:
    case Declaration{caps,_}:caps
def Combined(~L:Type -> Type,~R:Type -> Type,H:Type) -> Type:
  Cap.Bundle<L(H),R(H)>
def paired(~S:Data,~C:Type,~R:Type,~L:Type -> Type,~Right:Type -> Type,left:Declaration<S,C,R,L>,right:Declaration<S,C,R,Right>) -> Declaration<S,C,R,Combined(~L,~Right)>:
  match left right:
    case Declaration{lc,la} Declaration{rc,ra}:Declaration{Cap.Bundle{lc,rc},List.append(&2,String,la,ra)}
