import Base
import ./events.bend as Events
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import ./storage.bend as Storage
import ./step.bend as Step
import ./spawn.bend as Spawn
import ./application.bend as Application

# Exact initial inputs from the frozen TS simulation comparator: seed0,
# velocities1/2/1, health2/1/1. This is a fixture, not a public spawn policy.
type Prepared<-S: Data> is Type:
  SimulationPrepared{factory: W.Factory,world: Step.World(~S),reservations: List<&2,W.Reservation<S>>}
  SimulationCreateRefused{factory: W.Factory,resource: Array<U32>}
def final_spawn(~S: Data,factory: W.Factory,reservations: List<&2,W.Reservation<S>>,observed: Step.World(~S) & W.Reservation<S>) -> Prepared<S>:
  match observed:
    case (world,reservation): SimulationPrepared{factory,world,List.reverse(&2,W.Reservation<S>,reservation <> reservations)}
def second_spawn(~S: Data,factory: W.Factory,reservations: List<&2,W.Reservation<S>>,observed: Step.World(~S) & W.Reservation<S>) -> Prepared<S>:
  match observed:
    case (world,reservation): final_spawn(~S,factory,reservation <> reservations,Spawn.spawn(~S,world,Spawn.payload(0,1,1,300)))
def first_spawn(~S: Data,factory: W.Factory,observed: Step.World(~S) & W.Reservation<S>) -> Prepared<S>:
  match observed:
    case (world,reservation): second_spawn(~S,factory,[reservation],Spawn.spawn(~S,world,Spawn.payload(0,2,1,200)))
def created(~S: Data,result: W.Creation<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>) -> Prepared<S>:
  match result:
    case W.Created{factory,world}: first_spawn(~S,factory,Spawn.spawn(~S,world,Spawn.payload(0,1,2,100)))
    case W.CreateRejected{factory,resource}: SimulationCreateRefused{factory,resource}
def prepare(~S: Data,factory: W.Factory) -> Prepared<S>:
  created(~S,Application.create(~S,factory))
