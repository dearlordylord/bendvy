import Base
import ./query.bend as Q
import ./owners.bend as A

def bad(~P:Type,~U:Type,~get:P -> Unit -> P & String,~ag:U -> U & Maybe<&2,String>,p:P,u:U) -> Q.PrototypeOwnerResult<P,U,String>:
  Q.PrototypeOwnerResult{A.motion_set(p,1),u,"forged-write"}
