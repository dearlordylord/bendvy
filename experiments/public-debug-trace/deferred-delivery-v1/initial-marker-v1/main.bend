import Base
import ./fixture.bend as F
import ../selector-handlers-v1/fixture.bend as BaseF
import ./scenario.bend as Scenario
import ../../../../src/ecs/world-io.bend as WI

def created(~S:Data,value:WI.Creation<S,Unit,BaseF.Resources(~S),Unit>) -> IO(String):
  match value:
    case WI.Created{world}:IO.pure(String,Scenario.run(~S,F.setup(~S,world)))
    case _:IO.die(String,1,"initializer World creation failed")
def run(~S:Data) -> IO(String):IO.bind(WI.Creation<S,Unit,BaseF.Resources(~S),Unit>,String,WI.create(~S,~Unit,~BaseF.Resources(~S),~Unit,~BaseF.empty(~S),BaseF.resources(~S)),created(~S))
def printed(value:String) -> IO(Unit):IO.print(value)
def main() -> IO(Unit):IO.bind(String,Unit,run(~F.Workshop),printed)
