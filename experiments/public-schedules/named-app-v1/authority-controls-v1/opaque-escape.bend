import Base
import ./common.bend as C
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/world.bend as W
# Opaque H cannot be returned as a concrete World owner.
def wrong(~H:Type,~caps:C.Ops(H),ctx:H) -> W.World<C.Workshop,C.Cell,C.Cell,Unit>:
  ctx
