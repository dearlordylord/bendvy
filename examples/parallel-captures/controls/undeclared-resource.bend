import Base
import ../payloads.bend as P
import ../../../src/ecs/execution-access.bend as A

def write(~H:Type,~cap:A.ResourceWrite<H,P.Counter,String>,scope:H) -> H & String:
  A.resource_modify_field(~H,~P.Score,~String,cap)(P.update_score,scope)
