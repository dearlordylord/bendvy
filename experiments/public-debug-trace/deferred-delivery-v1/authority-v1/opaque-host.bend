import Base
import ./opaque-registration.bend as Control
import ../reader-query-context-v1/fixture.bend as F
import ../../../../src/ecs/world-io.bend as WI
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/owned-event-log.bend as Log

def empty(~S:Data,_:Unit) -> Col.Column<S,Array<U32>>:F.empty(~S)
def created(~S:Data,value:WI.Creation<S,Col.Column<S,Array<U32>>,Log.Log<Array<U32>>,Nat>) -> IO(String):
  match value:
    case WI.Created{world}:IO.pure(String,Control.run(~S,world))
    case _:IO.die(String,1,"opaque admission World creation failed")
def run(~S:Data) -> IO(String):IO.bind(WI.Creation<S,Col.Column<S,Array<U32>>,Log.Log<Array<U32>>,Nat>,String,WI.create(~S,~Col.Column<S,Array<U32>>,~Log.Log<Array<U32>>,~Nat,~empty(~S),F.resources()),created(~S))
def printed(value:String) -> IO(Unit):IO.print(value)
def main() -> IO(Unit):IO.bind(String,Unit,run(~F.Workshop),printed)
