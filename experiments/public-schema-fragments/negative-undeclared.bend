import Base
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/world.bend as W

def invalid(~H: Type,~read: Cap.ValueRead<H,U32>,ctx: H) -> H & U32:
  W.namespace(~Unit,~Unit,~Unit,~Unit,ctx)
