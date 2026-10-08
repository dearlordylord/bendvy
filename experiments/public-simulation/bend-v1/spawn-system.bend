import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import ./step.bend as Step
import ./storage.bend as Storage
import ./events.bend as Events
import ./spawn.bend as Spawn

type SpawnError is Data: SpawnFixtureError{}
def third(~S: Data,reservations: List<&2,W.Reservation<S>>,observed: Step.World(~S) & W.Reservation<S>) -> Sys.Outcome<Step.World(~S),SpawnError,List<&2,W.Reservation<S>>>:
  match observed:
    case (world,reservation): Sys.Succeeded{world,List.reverse(&2,W.Reservation<S>,reservation <> reservations)}
def second(~S: Data,reservations: List<&2,W.Reservation<S>>,observed: Step.World(~S) & W.Reservation<S>) -> Sys.Outcome<Step.World(~S),SpawnError,List<&2,W.Reservation<S>>>:
  match observed:
    case (world,reservation): third(~S,reservation <> reservations,Spawn.spawn(~S,world,Spawn.payload(0,1,1,300)))
def first(~S: Data,observed: Step.World(~S) & W.Reservation<S>) -> Sys.Outcome<Step.World(~S),SpawnError,List<&2,W.Reservation<S>>>:
  match observed:
    case (world,reservation): second(~S,[reservation],Spawn.spawn(~S,world,Spawn.payload(0,2,1,200)))
# Fixed comparator inputs; all reservation outcomes remain observable.
# The registered system queues commands; activation requires the explicit barrier.
def runner(~S: Data,world: Step.World(~S),args: Unit) -> Sys.Outcome<Step.World(~S),SpawnError,List<&2,W.Reservation<S>>>:
  first(~S,Spawn.spawn(~S,world,Spawn.payload(0,1,2,100)))
def Registry(~S: Data) -> Type:
  Sys.Registry<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,Unit,SpawnError,List<&2,W.Reservation<S>>,runner(~S)>
def register(~S: Data,world: Step.World(~S)) -> Sys.RegistrationResult<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,Unit,SpawnError,List<&2,W.Reservation<S>>,runner(~S)>:
  Sys.register(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Unit,~SpawnError,~List<&2,W.Reservation<S>>,~runner(~S),world,"Simulation/Spawn",["command:spawn"])
def run(~S: Data,registry: Registry(~S),world: Step.World(~S)) -> Sys.RunResult<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,Unit,SpawnError,List<&2,W.Reservation<S>>,runner(~S)>:
  Sys.run_tracked(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Unit,~SpawnError,~List<&2,W.Reservation<S>>,~runner(~S),registry,world,Unit{})
