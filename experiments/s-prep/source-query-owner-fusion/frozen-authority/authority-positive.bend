import Base
import ./owners.bend as A

def returned(-P:Type,-U:Type,result:(P & String) & (U & Maybe<&2,String>)) -> P & (U & String):
  match result:
    case ((p,text),(u,_)): (p,(u,text))
def control(~P:Type,~U:Type,~get:P -> Unit -> P & String,~ag:U -> U & Maybe<&2,String>,p:P,u:U) -> P & (U & String):
  returned(P,U,(get(p,Unit{}),ag(u)))
