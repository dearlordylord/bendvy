import Base
import ./schema.bend as Schema
import ./registration.bend as Registration
import ./application.bend as Application
import ../../src/ecs/execution-composer-schema.bend as Setup
import ../../src/ecs/world.bend as W

def created(result:Setup.Initialized<Schema.Schema,Schema.components(),Schema.resources(),Unit>) -> IO(Unit):
  match result:
    case Setup.SchemaCreated{_,world}:Application.start(Registration.attach(world))
    case _:IO.die(Unit,1,"health world creation refused")
def main() -> IO(Unit):created(Schema.create(W.factory()))
