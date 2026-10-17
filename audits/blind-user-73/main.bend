import Base
import ../../src/ecs/world-io.bend as WI
import ../../src/ecs/ordinary-service-declaration.bend as SD
import ./consumer.bend as Game

def created(result:WI.Creation<Game.Game,Game.Store,Game.Resources,Unit>) -> List<&2,List<&2,U32>>:
  match result:
    case WI.Refused{_}:[[994]]
    case WI.Created{world}:Game.start(world)
def show_row(xs:List<&2,U32>) -> String:
  match xs:
    case []:""
    case x <> xs:String.concat([U32.show(x)," ",show_row(xs)])
def print_rows(rows:List<&2,List<&2,U32>>) -> IO(Unit):
  match rows:
    case []:IO.pure(Unit,Unit{})
    case row <> rest:IO.bind(Unit,Unit,IO.print(show_row(row)),_=>print_rows(rest))
def main() -> IO(Unit):
  IO.bind(WI.Creation<Game.Game,Game.Store,Game.Resources,Unit>,Unit,WI.create(~Game.Game,~Game.Store,~Game.Resources,~Unit,~Game.empty,SD.Ready{0}),result=>print_rows(created(result)))
