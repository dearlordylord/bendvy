import Base
import ./owners.bend as A

def returned(-P:Type,-U:Type,u:U,result:P & String) -> P & (U & String):
  match result:
    case (p,text): (p,(u,text))
def bad(~P:Type,~U:Type,~get:P -> Unit -> P & String,~ag:U -> U & Maybe<&2,String>,p:P,u:U) -> P & (U & String):
  returned(P,U,u,A.health_observe(p))
