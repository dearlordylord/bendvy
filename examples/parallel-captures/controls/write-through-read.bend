import Base
import ../payloads.bend as P
import ../../../src/ecs/execution-access.bend as A

def write(~H:Type,~cap:A.ResourceRead<H,String>,scope:H) -> H & String:
  A.resource_modify_field(~H,~P.Counter,~String,cap)(P.update_counter,scope)
