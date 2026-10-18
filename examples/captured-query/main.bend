import Base
import ./schema.bend as S
import ./scenario.bend as Scenario
import ../../src/ecs/world-io.bend as WI

def created(value:WI.Creation<S.Workshop,S.Store(~S.Workshop),Unit,Unit>) -> IO(Unit):
  match value:
    case WI.Created{world}:IO.print(Scenario.start(~S.Workshop,world))
    case _:IO.die(Unit,1,"World creation failed")
def main() -> IO(Unit):
  IO.bind(WI.Creation<S.Workshop,S.Store(~S.Workshop),Unit,Unit>,Unit,WI.create(~S.Workshop,~S.Store(~S.Workshop),~Unit,~Unit,~S.empty(~S.Workshop),Unit{}),created)
