import Base
import ./scheduled.bend as Scheduled
import ./declarations.bend as D
import ./initialize.bend as Init
import ../../src/ecs/world-io.bend as WorldIO

type First is Data:
  First{}
type Second is Data:
  Second{}
def created(~S:Data,result:WorldIO.Creation<S,D.Store(~S),Scheduled.Resources(~S),Unit>) -> String:
  match result:
    case WorldIO.Created{world}:Scheduled.initialized(~S,Init.setup(~S,world))
    case WorldIO.Refused{_}:"ERROR:namespace-allocation"
def run(~S:Data) -> IO(String):
  IO.bind(WorldIO.Creation<S,D.Store(~S),Scheduled.Resources(~S),Unit>,String,WorldIO.create(~S,~D.Store(~S),~Scheduled.Resources(~S),~Unit,~Scheduled.empty(~S),Scheduled.resources(~S)),result => IO.pure(String,created(~S,result)))
def second(first:String,result:String) -> IO(Unit):IO.print("first{" ++ first ++ "}|second{" ++ result ++ "}")
def first(result:String) -> IO(Unit):IO.bind(String,Unit,run(~Second),second(result))
def main() -> IO(Unit):IO.bind(String,Unit,run(~First),first)
