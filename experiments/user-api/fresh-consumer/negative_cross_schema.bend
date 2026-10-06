import Base
import ./arena.bend as Arena
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/component.bend as Cmp
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/provider.bend as Pv
import ../../../src/ecs/transaction.bend as T
type Other is Data:
  Other{}
def bad(world: W.World<Arena.Arena,Arena.Store,U32,Arena.Hit>,handle: W.Handle<Other>) -> W.World<Arena.Arena,Arena.Store,U32,Arena.Hit>:
  Arena.write_Health(world,handle,10)
