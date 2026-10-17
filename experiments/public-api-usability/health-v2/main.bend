import Base
import ../../../src/ecs/ordinary-service-declaration.bend as Service
import ../../../src/ecs/column.bend as Col
import ../../../examples/scheduled-health/components.bend as D
import schema.bend as S
import driver.bend as App
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/world-io.bend as WI
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/transaction.bend as T

def third(result:S.Spawned) -> String:
  match result:
    case S.Spawned{world,handle}:App.start(world,handle)
    case _:"ERROR: spawn sentinel"
def second(result:S.Spawned) -> String:
  match result:
    case S.Spawned{world,_}:third(S.spawn(world,D.EntitySeed{D.Health{30.0},None{}}))
    case _:"ERROR: spawn second"
def first(result:S.Spawned) -> String:
  match result:
    case S.Spawned{world,_}:second(S.spawn(world,D.EntitySeed{D.Health{20.0},Some{D.HealthDecay{0.25}}}))
    case _:"ERROR: spawn first"
def created(result:WI.Creation<S.Schema,S.Store,S.Resources,Unit>) -> IO(Unit):
  match result:
    case WI.Created{world}:IO.print(first(S.spawn(world,D.EntitySeed{D.Health{10.0},Some{D.HealthDecay{0.5}}})))
    case _:IO.die(Unit,1,"world creation refused")
def main() -> IO(Unit):
  IO.bind(WI.Creation<S.Schema,S.Store,S.Resources,Unit>,Unit,WI.create(~S.Schema,~S.Store,~S.Resources,~Unit,~S.empty,S.Resources{Service.Ready{Array.new(U32,0n,0)}}),created)
