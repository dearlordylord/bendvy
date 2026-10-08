import Base
import ./events.bend as Events
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import ./storage.bend as Storage
import ./step.bend as Step
import ./spawn.bend as Spawn
import ./movement.bend as Movement
import ./damage.bend as Damage

# Preserve the factory for the independently bound second nominal schema.
def create(~S: Data,factory: W.Factory) -> W.Creation<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>:
  W.create(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Storage.empty(~S),factory,Spawn.cell(0,900))
def flush(~S: Data,world: Step.World(~S)) -> Step.World(~S):
  W.barrier(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,world)
