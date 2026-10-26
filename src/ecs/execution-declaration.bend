import Base
import ./execution-state.bend as State
import ./capabilities.bend as Cap

type Mode is Data:
  Exclusive{}
  SharedView{}
type Permission is Data:
  ReadOnly{}
  Writable{}
type Access is Data:
  Access{key:String,mode:Mode,permission:Permission}
def keys(accesses:List<&2,Access>) -> List<&2,String>:
  match accesses:
    case []:[]
    case Access{key,_,_} <> rest:key <> keys(rest)

type Declaration<-S:Data,-C:Type,-R:Type,-Ops:Type -> Type> is Type:
  Declaration{caps:Ops(State.Scope<S,C,R>),access:List<&2,Access>}
def access(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type,value:Declaration<S,C,R,Ops>) -> List<&2,String>:
  match value:
    case Declaration{_,access}:keys(access)
def grants(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type,value:Declaration<S,C,R,Ops>) -> Ops(State.Scope<S,C,R>):
  match value:
    case Declaration{caps,_}:caps
def Combined(~L:Type -> Type,~R:Type -> Type,H:Type) -> Type:
  Cap.Bundle<L(H),R(H)>
def paired(~S:Data,~C:Type,~R:Type,~L:Type -> Type,~Right:Type -> Type,left:Declaration<S,C,R,L>,right:Declaration<S,C,R,Right>) -> Declaration<S,C,R,Combined(~L,~Right)>:
  match left right:
    case Declaration{lc,la} Declaration{rc,ra}:Declaration{Cap.Bundle{lc,rc},List.append(&2,Access,la,ra)}

def requirements(~S:Data,~C:Type,~R:Type,~Ops:Type -> Type,value:Declaration<S,C,R,Ops>) -> List<&2,Access>:
  match value:
    case Declaration{_,access}:access
