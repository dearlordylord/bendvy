import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as ER
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import ./step.bend as Step
import ./storage.bend as Storage
import ./events.bend as Events
import ./spawn-system.bend as Spawn
import ./runtime-gameplay.bend as Game

type Registered<-S: Data> is Type:
  Registered{registry: Spawn.Registry(~S)}
  RegistrationRefused{}
def extracted(~S: Data,result: Sys.RegistrationResult<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent,Unit,Spawn.SpawnError,List<&2,W.Reservation<S>>,Spawn.runner(~S)>) -> Step.World(~S) & Registered<S>:
  match result:
    case Sys.Registered{world,registry}: (world,Registered{registry})
    case Sys.RegistrationFailed{world}: (world,RegistrationRefused{})
def returned(~S: Data,namespace: U32,batches: List<&2,ER.Batch<Events.SimulationEvent>>,positions: List<&2,ER.Position>,nextReader: U32,tick: Nat,frameStart: Nat,boundary: Nat,capacity: Nat,dropped: Nat,observed: Step.World(~S) & Registered<S>) -> Game.Runtime(~S) & Registered<S>:
  match observed:
    case (world,registered): (ER.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},registered)
def register(~S: Data,runtime: Game.Runtime(~S)) -> Game.Runtime(~S) & Registered<S>:
  match runtime:
    case ER.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped}: returned(~S,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,extracted(~S,Spawn.register(~S,world)))
