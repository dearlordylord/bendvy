import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

def bad(~H:Type,~cap:Cap.ValueRead<H,U32>,owner:H) -> H:
  Cap.value_set(~H,~U32,~U32,~cap,owner,0)
