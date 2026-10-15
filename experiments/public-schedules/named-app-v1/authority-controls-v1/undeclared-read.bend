import Base
import ./common.bend as C
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/world.bend as W
# Undeclared raw resource access cannot consume the body's opaque H as World.
def wrong(~H:Type,~caps:C.Ops(H),ctx:H) -> W.World<C.Workshop,C.Cell,C.Cell,Unit> & U32:
  W.observe_resource(~C.Workshop,~C.Cell,~C.Cell,~Unit,~U32,~C.project,ctx)
