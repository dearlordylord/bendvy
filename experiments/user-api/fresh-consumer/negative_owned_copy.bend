import Base
import ./arena.bend as Arena
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/component.bend as Cmp
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/provider.bend as Pv
import ../../../src/ecs/transaction.bend as T
def bad(+owner: Arena.Position) -> Arena.Position:
  owner
