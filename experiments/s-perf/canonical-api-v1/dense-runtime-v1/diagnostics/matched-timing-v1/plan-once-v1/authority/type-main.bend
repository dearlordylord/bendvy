import Base
import type-schema.bend as S
import type-driver.bend as Driver
import ../../../../../../../../src/ecs/world-io.bend as WI
import ../../../../../../../../src/ecs/world.bend as W

def initial_text(result:S.World() & (W.Handle<S.Schema> & String)) -> IO(Unit):
  match result:
    case (world,(handle,before)):IO.print(Driver.start(world,handle,before))

def started(result:S.Spawned) -> IO(Unit):
  match result:
    case S.Spawned{world,handle}:
      ready = S.barrier(world)
      initial_text(S.read_text(ready,handle))
    case _:IO.die(Unit,1,"entity reservation refused")

def created(result:WI.Creation<S.Schema,S.Store,S.Resources,Unit>) -> IO(Unit):
  match result:
    case WI.Created{world}:started(S.spawn(world,S.cells(3,4)))
    case _:IO.die(Unit,1,"world creation refused")

def main() -> IO(Unit):
  IO.bind(WI.Creation<S.Schema,S.Store,S.Resources,Unit>,Unit,WI.create(~S.Schema,~S.Store,~S.Resources,~Unit,~S.empty,S.Resources{}),created)
