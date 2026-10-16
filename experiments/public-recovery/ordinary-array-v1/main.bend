import Base
import ./fixture.bend as F
import ./scenario.bend as Scenario
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/world-io.bend as WI
type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
def empty(value:Unit) -> Unit:value
def foreign(~S:Data,world:W.World<S,Unit,Array<Array<U32>>,Unit>,created:WI.Creation<S,Unit,Array<Array<U32>>,Unit>) -> IO(String):
  match created:
    case WI.Created{other}:IO.pure(String,Scenario.start(~S,world,other))
    case _:IO.die(String,1,"foreign creation failed")
def first(~S:Data,created:WI.Creation<S,Unit,Array<Array<U32>>,Unit>) -> IO(String):
  match created:
    case WI.Created{world}:IO.bind(WI.Creation<S,Unit,Array<Array<U32>>,Unit>,String,WI.create(~S,~Unit,~Array<Array<U32>>,~Unit,~empty,F.array(900)),value => foreign(~S,world,value))
    case _:IO.die(String,1,"creation failed")
def run(~S:Data) -> IO(String):
  IO.bind(WI.Creation<S,Unit,Array<Array<U32>>,Unit>,String,WI.create(~S,~Unit,~Array<Array<U32>>,~Unit,~empty,F.array(10)),first(~S))
def printed(a:String,b:String) -> IO(Unit):IO.print("Workshop\n" ++ a ++ "Garden\n" ++ b)
def workshop(a:String) -> IO(Unit):IO.bind(String,Unit,run(~Garden),b => printed(a,b))
def main() -> IO(Unit):IO.bind(String,Unit,run(~Workshop),workshop)
