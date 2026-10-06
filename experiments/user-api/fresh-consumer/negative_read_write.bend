import Base
import ./arena.bend as Arena
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/component.bend as Cmp
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/provider.bend as Pv
import ../../../src/ecs/transaction.bend as T
def bad(~H: Type,~aux: H -> H & Cmp.Access<U32>,ctx: H) -> H & T.Outcome<Arena.Fault>:
  Arena.move_values(~H,~aux,1,Cmp.Found{0},Cmp.Found{2},ctx)
