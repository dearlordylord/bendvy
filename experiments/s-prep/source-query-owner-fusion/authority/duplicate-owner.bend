import Base
import ./query.bend as Q

def bad(~P:Type,p:P) -> Q.PrototypeOwnerResult<P,P,Unit>:
  Q.PrototypeOwnerResult{p,p,Unit{}}
