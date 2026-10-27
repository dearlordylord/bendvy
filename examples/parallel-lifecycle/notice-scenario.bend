import Base
import ./notice-scenario-core.bend as Core
import ../parallel-query/declarations.bend as D
import ../../src/ecs/world-io.bend as WorldIO
import ../../src/ecs/execution-query.bend as Query
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/owner-product.bend as Product

def created(result:WorldIO.Creation<Core.First,Core.Store(~Core.First),Core.Resources(~Core.First),Unit>) -> String:
  match result:
    case WorldIO.Created{world}:Core.admitted(~Core.First,~Query.Parallel{},Settings.defaults(),True{},world)
    case WorldIO.Refused{_}:"creation-refused"
def main() -> IO(Unit):
  IO.bind(WorldIO.Creation<Core.First,Core.Store(~Core.First),Core.Resources(~Core.First),Unit>,Unit,WorldIO.create(~Core.First,~Core.Store(~Core.First),~Core.Resources(~Core.First),~Unit,~Core.empty(~Core.First),Product.Owner{D.resource(~Core.First),Unit{}}),world => IO.print("First=" ++ created(world)))
