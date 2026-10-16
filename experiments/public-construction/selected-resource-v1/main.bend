import Base
import ./fixture.bend as F
import ./setup.bend as Setup
import ./scenario.bend as Scenario
import /workspace/formal-proofs/bendvy/src/ecs/world-io.bend as WI

def empty(_:Unit) -> Array<U32>:ANode{ALeaf{700},ALeaf{701}}
def created(~S:Data,value:WI.Creation<S,Array<U32>,F.Resources(~S),Unit>) -> IO(String):
  match value:
    case WI.Created{world}:IO.pure(String,Scenario.run(~S,world))
    case _:IO.die(String,1,"selected resource World creation failed")
def run(~S:Data) -> IO(String):IO.bind(WI.Creation<S,Array<U32>,F.Resources(~S),Unit>,String,WI.create(~S,~Array<U32>,~F.Resources(~S),~Unit,~empty,Setup.resources(~S)),created(~S))
def printed(workshop:String,garden:String) -> IO(Unit):IO.print("Workshop\n" ++ workshop ++ "Garden\n" ++ garden)
def workshop(value:String) -> IO(Unit):IO.bind(String,Unit,run(~F.Garden),garden=>printed(value,garden))
def main() -> IO(Unit):IO.bind(String,Unit,run(~F.Workshop),workshop)
