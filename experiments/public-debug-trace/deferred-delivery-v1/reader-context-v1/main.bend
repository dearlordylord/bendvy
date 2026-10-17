import Base
import ./fixture.bend as F
import ./scenario.bend as Scenario
import ../../../../src/ecs/world-io.bend as WI
import ../../../../src/ecs/owned-event-log.bend as Log

def created(~S:Data,value:WI.Creation<S,Unit,Log.Log<Array<U32>>,Nat>) -> IO(String):
  match value:
    case WI.Created{world}:IO.pure(String,Scenario.run(~S,F.setup(~S,world)))
    case _:IO.die(String,1,"reader World creation failed")
def empty(~S:Data,ignored:Unit) -> Unit:F.empty(~S)
def run(~S:Data) -> IO(String):IO.bind(WI.Creation<S,Unit,Log.Log<Array<U32>>,Nat>,String,WI.create(~S,~Unit,~Log.Log<Array<U32>>,~Nat,~empty(~S),F.resources()),created(~S))
def printed(value:String) -> IO(Unit):IO.print(value)
def main() -> IO(Unit):IO.bind(String,Unit,run(~F.Workshop),printed)
