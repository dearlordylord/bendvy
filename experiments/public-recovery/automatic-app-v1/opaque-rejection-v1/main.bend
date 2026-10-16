import Base
import ../fixture.bend as F
import ./scenario.bend as Scenario
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/world-io.bend as WI

type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
def empty(~S:Data,value:Unit) -> F.Store(~S):Col.empty(~S,~Array<Array<U32>>)
def created(~S:Data,value:WI.Creation<S,F.Store(~S),F.Resources(),Unit>) -> IO(String):
  match value:
    case WI.Created{world}:IO.pure(String,Scenario.start(~S,world))
    case _:IO.die(String,1,"automatic recovery app world creation failed")
def run(~S:Data) -> IO(String):
  IO.bind(WI.Creation<S,F.Store(~S),F.Resources(),Unit>,String,WI.create(~S,~F.Store(~S),~F.Resources(),~Unit,~empty(~S),F.resources(20)),created(~S))
def printed(a:String,b:String) -> IO(Unit):IO.print("Workshop\n" ++ a ++ "Garden\n" ++ b)
def workshop(a:String) -> IO(Unit):IO.bind(String,Unit,run(~Garden),b => printed(a,b))
def main() -> IO(Unit):IO.bind(String,Unit,run(~Workshop),workshop)
