import Base
import local-fixture.bend as F
import local-driver.bend as Driver
import ../../../src/ecs/world-io.bend as WI

def empty(value:Unit) -> Unit:value
def created(value:WI.Creation<F.S,Unit,U32,Unit>) -> IO(Unit):
  match value:
    case WI.Created{world}:IO.print(Driver.start(world))
    case _:IO.die(Unit,1,"world creation refused")
def main() -> IO(Unit):
  IO.bind(WI.Creation<F.S,Unit,U32,Unit>,Unit,WI.create(~F.S,~Unit,~U32,~Unit,~empty,10),created)
