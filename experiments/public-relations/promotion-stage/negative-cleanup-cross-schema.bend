import Base
import ../../../src/ecs/relation-commands.bend as A
import owned-world.bend as O
import cleanup-owned.bend as C
import ../../../src/ecs/world.bend as W
def invalid(-H:Type,caps:C.Writable<H,O.Workshop>,handle:W.Handle<O.Other>,owner:H) -> H & A.QueueStatus:
  C.body(~O.Workshop,H,caps,handle,owner)
