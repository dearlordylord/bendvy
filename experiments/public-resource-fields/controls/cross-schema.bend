import Base
import ../provider.bend as P
import ../operations.bend as O
import ../schema-a.bend as A
import ../schema-b.bend as Other
def attempt(~H:Type,~cap:P.Write<A.A,O.Counter,A.first(),H,U32>,owner:H) -> H:
  P.set(~Other.Other,~O.Counter,~Other.first(),~H,~U32,~cap,owner,O.counter(1,2,3,4))
