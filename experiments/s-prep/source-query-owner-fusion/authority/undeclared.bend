import Base
import ./query.bend as Q
import ./owners.bend as A

def bad(~P:Type,~U:Type,~get:P -> Unit -> P & String,~ag:U -> U & Maybe<&2,String>,p:P,u:U) -> Q.PrototypeOwnerResult<P,U,String>:
  Q.PrototypeOwnerResult{p,u,A.health_observe(p)}
