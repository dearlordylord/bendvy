import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def wrong(~H:Type,~V:Data,~cap:Cap.ValueRead<H,V>,owner:H,value:V) -> H:
  Cap.value_set(~H,~V,~V,~cap,owner,value)
