import Base
import fixture.bend as F
import scenario.bend as Scenario
import /workspace/formal-proofs/bendvy/src/ecs/world-io.bend as WI
def empty(_:Unit) -> Unit:Unit{}
def created(~S:Data,value:WI.Creation<S,Unit,F.Resources(~S),Unit>) -> IO(String):
  match value:
    case WI.Created{world}:IO.pure(String,Scenario.start(~S,F.register(~S,False{},world)))
    case _:IO.die(String,1,"interop world creation failed")
def one(~S:Data) -> IO(String):IO.bind(WI.Creation<S,Unit,F.Resources(~S),Unit>,String,WI.create(~S,~Unit,~F.Resources(~S),~Unit,~empty,F.resources(~S)),created(~S))
def printed(a:String,b:String) -> IO(Unit):IO.print("Workshop\n" ++ a ++ "Garden\n" ++ b)
def workshop(a:String) -> IO(Unit):IO.bind(String,Unit,one(~F.Garden),b=>printed(a,b))
def main() -> IO(Unit):IO.bind(String,Unit,one(~F.Workshop),workshop)
