import Base
import world-adapter.bend as A
import owned-world.bend as O
import providers.bend as P
import cleanup-owned.bend as C
import ../../src/ecs/world.bend as W
def invalid(-H:Type,caps:P.ReadOnly<H,O.Workshop>,handle:W.Handle<O.Workshop>,owner:H) -> H & A.QueueStatus:
  C.body(~O.Workshop,H,caps,handle,owner)
