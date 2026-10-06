import Base
import ./query.bend as Q
import ./owners.bend as A

def returned(-P:Type,-U:Type,result:(P & String) & (U & Maybe<&2,String>)) -> Q.PrototypeOwnerResult<P,U,String>:
  match result:
    case ((p,text),(u,_)): Q.PrototypeOwnerResult{p,u,text}
def control(~P:Type,~U:Type,~get:P -> Unit -> P & String,~ag:U -> U & Maybe<&2,String>,p:P,u:U) -> Q.PrototypeOwnerResult<P,U,String>:
  returned(P,U,(get(p,Unit{}),ag(u)))
