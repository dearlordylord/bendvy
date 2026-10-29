import Base
import ./schema.bend as S
import ./scenario.bend as Scenario
import ../../src/ecs/execution-composer-schema.bend as Setup
import ./app.bend as A

def created(result:Setup.Initialized<S.Workshop,S.components(),S.resources(),Unit>) -> IO(Unit):
  match result:
    case Setup.SchemaCreated{_,world}:Scenario.defined(A.define(S.seed(~S.Workshop,world)))
    case _:IO.die(Unit,1,"world creation refused")
def main() -> IO(Unit):created(S.create())
