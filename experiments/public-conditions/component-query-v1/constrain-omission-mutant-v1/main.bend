import Base
import ./fixture.bend as F
import /tmp/bendvy-component-query-check/experiments/public-conditions/component-query-v1/schema.bend as Model
import ./scenario.bend as Scenario
import /workspace/formal-proofs/bendvy/src/ecs/world-io.bend as WI

def created(~S:Data,value:WI.Creation<S,Model.Store(~S),F.Resources(~S),Unit>) -> IO(String):
  match value:
    case WI.Created{world}:IO.pure(String,Scenario.run(~S,F.register(~S,world)))
    case _:IO.die(String,1,"component-query Check world creation failed")
def run(~S:Data) -> IO(String):IO.bind(WI.Creation<S,Model.Store(~S),F.Resources(~S),Unit>,String,WI.create(~S,~Model.Store(~S),~F.Resources(~S),~Unit,~Model.empty(~S),F.resources(~S)),created(~S))
def printed(a:String,b:String) -> IO(Unit):IO.print("Workshop\n" ++ a ++ "Garden\n" ++ b)
def workshop(a:String) -> IO(Unit):IO.bind(String,Unit,run(~Model.Garden),b=>printed(a,b))
def main() -> IO(Unit):IO.bind(String,Unit,run(~Model.Workshop),workshop)
