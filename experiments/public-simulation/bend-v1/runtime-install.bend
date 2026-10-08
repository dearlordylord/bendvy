import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as ER
import ./step.bend as Step
import ./systems.bend as Systems
import ./gameplay.bend as Game
import ./events.bend as Events
import ./runtime-gameplay.bend as Runtime

type Owners<-S: Data> is Type:
  Installed{movement: Systems.MovementRegistry(~S),damage: Systems.DamageRegistry(~S)}
  MovementRefused{}
  DamageRefused{movement: Systems.MovementRegistry(~S)}
def extracted(~S: Data,result: Game.Installed<S>) -> Step.World(~S) & Owners<S>:
  match result:
    case Game.GameplayInstalled{Game.Gameplay{world,movement,damage}}: (world,Installed{movement,damage})
    case Game.GameplayMovementRefused{world}: (world,MovementRefused{})
    case Game.GameplayDamageRefused{world,movement}: (world,DamageRefused{movement})
def returned(~S: Data,namespace: U32,batches: List<&2,ER.Batch<Events.SimulationEvent>>,positions: List<&2,ER.Position>,nextReader: U32,tick: Nat,frameStart: Nat,boundary: Nat,capacity: Nat,dropped: Nat,observed: Step.World(~S) & Owners<S>) -> Runtime.Runtime(~S) & Owners<S>:
  match observed:
    case (world,owners): (ER.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},owners)
# Registration changes World registry metadata, but is not an event execution.
def install(~S: Data,runtime: Runtime.Runtime(~S)) -> Runtime.Runtime(~S) & Owners<S>:
  match runtime:
    case ER.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped}: returned(~S,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,extracted(~S,Game.install(~S,world)))
