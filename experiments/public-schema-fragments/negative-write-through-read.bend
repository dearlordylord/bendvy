import Base
import ../../src/ecs/capabilities.bend as Cap

def invalid(~H: Type,~read: Cap.ValueRead<H,U32>,ctx: H) -> H:
  Cap.value_set(~H,~U32,~U32,~read,ctx,0)
