import Base
import ../../../../src/ecs/column.bend as Col
import ../reader-query-context-v1/fixture.bend as F
import ./scenario.bend as Scenario
import ../../../../src/ecs/world-io.bend as WI
import ../../../../src/ecs/owned-event-log.bend as Log

def created(~S:Data,~mode:Bool,value:WI.Creation<S,Col.Column<S,Array<U32>>,Log.Log<Array<U32>>,Nat>) -> IO(String):
  match value:
    case WI.Created{world}:IO.pure(String,Scenario.run_mode(~S,~mode,F.setup(~S,world)))
    case _:IO.die(String,1,"query-reader World creation failed")
def empty(~S:Data,ignored:Unit) -> Col.Column<S,Array<U32>>:F.empty(~S)
def run_mode(~S:Data,~mode:Bool) -> IO(String):IO.bind(WI.Creation<S,Col.Column<S,Array<U32>>,Log.Log<Array<U32>>,Nat>,String,WI.create(~S,~Col.Column<S,Array<U32>>,~Log.Log<Array<U32>>,~Nat,~empty(~S),F.resources()),created(~S,~mode))
