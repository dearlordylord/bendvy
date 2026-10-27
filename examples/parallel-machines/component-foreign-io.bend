import Base
import ./component-probe.bend as Probe
import ./component-foreign.bend as Core
import ./declarations.bend as D
import ../../src/ecs/world-io.bend as WorldIO

def second_created(~S:Data,target:Probe.World(~S),result:WorldIO.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match result:
    case WorldIO.Created{foreign}:Core.run(~S,target,foreign)
    case WorldIO.Refused{_}:"ERROR:second-create"
def first_created(~S:Data,result:WorldIO.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> IO(String):
  match result:
    case WorldIO.Created{target}:IO.bind(WorldIO.Creation<S,D.Store(~S),D.Resources(~S),Unit>,String,WorldIO.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Probe.empty(~S),Probe.resources(~S)),result => IO.pure(String,second_created(~S,target,result)))
    case WorldIO.Refused{_}:IO.pure(String,"ERROR:first-create")
def run(~S:Data) -> IO(String):
  IO.bind(WorldIO.Creation<S,D.Store(~S),D.Resources(~S),Unit>,String,WorldIO.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Probe.empty(~S),Probe.resources(~S)),first_created(~S))
def main() -> IO(Unit):IO.bind(String,Unit,run(~Core.Schema),IO.print)
