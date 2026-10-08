import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as ER
import ./events.bend as Events
import ./step.bend as Step
import ./storage.bend as Storage
import ./checkpoint.bend as Checkpoint
import ./runtime-gameplay.bend as Game

type Snapshot is Data:
  Snapshot{world: Checkpoint.Snapshot,namespace: U32,batches: List<&2,ER.Batch<Events.SimulationEvent>>,positions: List<&2,ER.Position>,nextReader: U32,tick: Nat,frameStart: Nat,boundary: Nat,capacity: Nat,droppedThrough: Nat}
def returned(~S: Data,+namespace: U32,+batches: List<&2,ER.Batch<Events.SimulationEvent>>,+positions: List<&2,ER.Position>,+nextReader: U32,+tick: Nat,+frameStart: Nat,+boundary: Nat,+capacity: Nat,+dropped: Nat,observed: Step.World(~S) & Checkpoint.Snapshot) -> Game.Runtime(~S) & Snapshot:
  match observed:
    case (world,snapshot): (ER.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},Snapshot{snapshot,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped})
# Observation does not use ER.with_world: that operation advances event time.
# Every retained runtime metadata field is returned unchanged and observed.
def observe(~S: Data,label: String,runtime: Game.Runtime(~S)) -> Game.Runtime(~S) & Snapshot:
  match runtime:
    case ER.Runtime{world,+namespace,+batches,+positions,+nextReader,+tick,+frameStart,+boundary,+capacity,+dropped}: returned(~S,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped,Checkpoint.observe(~S,label,world))
