import Base
import ./query.bend as Q
import ./owners.bend as A

def bad(~P:Type,~U:Type,p:P,u:U) -> Q.PrototypeOwnerResult<P,U,Unit>:
  match p:
    case A.Motion{items,scalar}: Q.PrototypeOwnerResult{A.Motion{items,scalar},u,Unit{}}
