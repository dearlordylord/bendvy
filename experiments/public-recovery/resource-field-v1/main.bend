import Base
import ./fixture.bend as F
import ./scenario.bend as Scenario
import /workspace/formal-proofs/bendvy/src/ecs/world-io.bend as WI

type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
def empty(value:Unit) -> Unit:value
def created(~S:Data,value:WI.Creation<S,Unit,F.Resources(),Unit>) -> IO(String):
  match value:
    case WI.Created{world}:IO.pure(String,Scenario.start(~S,world))
    case _:IO.die(String,1,"resource-field world creation failed")
def run(~S:Data) -> IO(String):
  IO.bind(WI.Creation<S,Unit,F.Resources(),Unit>,String,WI.create(~S,~Unit,~F.Resources(),~Unit,~empty,F.resources(10)),created(~S))
def printed(a:String,b:String) -> IO(Unit):IO.print("Workshop\n" ++ a ++ "Garden\n" ++ b)
def workshop(a:String) -> IO(Unit):IO.bind(String,Unit,run(~Garden),b => printed(a,b))
def main() -> IO(Unit):IO.bind(String,Unit,run(~Workshop),workshop)
