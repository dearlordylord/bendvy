import Base
import ../fixture.bend as F
import ./scenario.bend as Scenario
import /workspace/formal-proofs/bendvy/experiments/public-conditions/component-query-v1/schema.bend as Model
import /workspace/formal-proofs/bendvy/src/ecs/world-io.bend as WI

def created(~S:Data,value:WI.Creation<S,Array<U32>,F.Resources(~S),U32>) -> IO(String):
  match value:
    case WI.Created{world}:IO.pure(String,Scenario.run(~S,F.register(~S,F.before(~S,F.queued(~S,world)))))
    case _:IO.die(String,1,"checked reader attachment world creation failed")
def run(~S:Data) -> IO(String):IO.bind(WI.Creation<S,Array<U32>,F.Resources(~S),U32>,String,WI.create(~S,~Array<U32>,~F.Resources(~S),~U32,~F.empty(~S),F.resources(~S)),created(~S))
def printed(workshop:String,garden:String) -> IO(Unit):IO.print("Workshop\n" ++ workshop ++ "Garden\n" ++ garden)
def workshop(value:String) -> IO(Unit):IO.bind(String,Unit,run(~Model.Garden),garden=>printed(value,garden))
def main() -> IO(Unit):IO.bind(String,Unit,run(~Model.Workshop),workshop)
