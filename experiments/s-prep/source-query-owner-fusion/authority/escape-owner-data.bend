import Base
import ./query.bend as Q

def bad(~P:Type,~U:Type,p:P,u:U) -> Q.PrototypeOwnerResult<P,U,Unit>:
  Q.PrototypeOwnerResult{p,u,p}
