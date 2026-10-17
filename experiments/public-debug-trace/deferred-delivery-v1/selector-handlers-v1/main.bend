import Base
import ./fixture.bend as F
import ./scenario.bend as Scenario
import ../../../../src/ecs/world-io.bend as WI

def created(~S:Data,value:WI.Creation<S,Unit,F.Resources(~S),Unit>) -> IO(String):
  match value:
    case WI.Created{world}:IO.pure(String,Scenario.run(~S,F.setup(~S,world)))
    case _:IO.die(String,1,"selector World creation failed")
def run(~S:Data) -> IO(String):IO.bind(WI.Creation<S,Unit,F.Resources(~S),Unit>,String,WI.create(~S,~Unit,~F.Resources(~S),~Unit,~F.empty(~S),F.resources(~S)),created(~S))
def printed(value:String) -> IO(Unit):IO.print(value)
def main() -> IO(Unit):IO.bind(String,Unit,run(~F.Workshop),printed)
