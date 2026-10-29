import Base
import ./prepared-foreign-core.bend as Core
import ../parallel-query/commands-core.bend as Commands
import ../parallel-query/declarations.bend as D
import ../../src/ecs/world-io.bend as WorldIO
import ../../src/ecs/owner-product.bend as Product

def second_created(~S:Data,world:Core.Runtime(~S),result:WorldIO.Creation<S,Commands.Store(~S),Commands.Resources(~S),Unit>) -> String:
  match result:
    case WorldIO.Created{foreign}:Core.run(~S,world,foreign)
    case WorldIO.Refused{_}:"ERROR: foreign creation"
def first_created(~S:Data,result:WorldIO.Creation<S,Commands.Store(~S),Commands.Resources(~S),Unit>) -> IO(String):
  match result:
    case WorldIO.Created{world}:IO.bind(WorldIO.Creation<S,Commands.Store(~S),Commands.Resources(~S),Unit>,String,WorldIO.create(~S,~Commands.Store(~S),~Commands.Resources(~S),~Unit,~Commands.empty(~S),Product.Owner{D.resource(~S),Unit{}}),foreign => IO.pure(String,second_created(~S,world,foreign)))
    case WorldIO.Refused{_}:IO.pure(String,"ERROR: original creation")
def run(~S:Data) -> IO(String):
  IO.bind(WorldIO.Creation<S,Commands.Store(~S),Commands.Resources(~S),Unit>,String,WorldIO.create(~S,~Commands.Store(~S),~Commands.Resources(~S),~Unit,~Commands.empty(~S),Product.Owner{D.resource(~S),Unit{}}),first_created(~S))
def main() -> IO(Unit):
  IO.bind(String,Unit,run(~Core.First),first => IO.bind(String,Unit,run(~Core.Second),second => IO.print("First=" ++ first ++ "\nSecond=" ++ second)))
