import Base
import ./notice-positive-core.bend as Core
import ../parallel-query/declarations.bend as D
import ../../src/ecs/execution-lifecycle-administration.bend as Admin
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/world-io.bend as WorldIO

def created(~S:Data,result:WorldIO.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match result:
    case WorldIO.Created{world}:Core.registered(~S,Admin.register_removed(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.layout(),~Core.route(),~{==},~{==},world,Notice.Retained{}))
    case WorldIO.Refused{_}:"creation-refused"
def run(~S:Data) -> IO(String):
  IO.bind(WorldIO.Creation<S,D.Store(~S),D.Resources(~S),Unit>,String,WorldIO.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),D.resource(~S)),world => IO.pure(String,created(~S,world)))
def main() -> IO(Unit):
  IO.bind(String,Unit,run(~Core.First),first => IO.bind(String,Unit,run(~Core.Second),second => IO.print("First=" ++ first ++ "\nSecond=" ++ second)))
