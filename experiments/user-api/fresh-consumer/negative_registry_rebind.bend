import Base
import ./arena.bend as Arena
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/component.bend as Cmp
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/provider.bend as Pv
import ../../../src/ecs/transaction.bend as T
def alternate(world: W.World<Arena.Arena,Arena.Store,U32,Arena.Hit>,args: Unit) -> Sys.Outcome<W.World<Arena.Arena,Arena.Store,U32,Arena.Hit>,Pv.Error<Arena.Fault>,Unit>:
  Sys.Succeeded{world,Unit{}}
def bad(world: W.World<Arena.Arena,Arena.Store,U32,Arena.Hit>,registry: Sys.Registry<Arena.Arena,Arena.Store,U32,Arena.Hit,Unit,Pv.Error<Arena.Fault>,Unit,Arena.move_runner>) -> Sys.RunResult<Arena.Arena,Arena.Store,U32,Arena.Hit,Unit,Pv.Error<Arena.Fault>,Unit,alternate>:
  Sys.run(~Arena.Arena,~Arena.Store,~U32,~Arena.Hit,~Unit,~Pv.Error<Arena.Fault>,~Unit,~alternate,registry,world,Unit{})
