import Base
import ./events.bend as Events
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import ./geometry.bend as Geometry
import ./storage.bend as Storage
import ./schema.bend as Schema
import ./step.bend as Step

type SpawnPayload is Type:
  SpawnPayload{position: Array<U32>,velocity: Array<U32>,health: Array<U32>}
def replaced(~S: Data,result: C.Replacement<Step.World(~S),Array<U32>>) -> Step.World(~S):
  match result:
    case C.Replaced{world,_}: world
    case C.ReplaceRejected{world,_,_}: world
def insert_position(~S: Data,world: Step.World(~S),handle: W.Handle<S>,value: Array<U32>) -> Step.World(~S):
  replaced(~S,C.structural_replace(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Storage.PositionRest<S>,~Array<U32>,~Geometry.Cell,~Storage.PositionToken<S>,~Storage.take_position(~S),~Storage.put_position(~S),~Geometry.project,Schema.position(~S),world,handle,Some{value}))
def insert_velocity(~S: Data,world: Step.World(~S),handle: W.Handle<S>,value: Array<U32>) -> Step.World(~S):
  replaced(~S,C.structural_replace(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Storage.VelocityRest<S>,~Array<U32>,~Geometry.Cell,~Storage.VelocityToken<S>,~Storage.take_velocity(~S),~Storage.put_velocity(~S),~Geometry.project,Schema.velocity(~S),world,handle,Some{value}))
def insert_health(~S: Data,world: Step.World(~S),handle: W.Handle<S>,value: Array<U32>) -> Step.World(~S):
  replaced(~S,C.structural_replace(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Storage.HealthRest<S>,~Array<U32>,~Geometry.Cell,~Storage.HealthToken<S>,~Storage.take_health(~S),~Storage.put_health(~S),~Geometry.project,Schema.health(~S),world,handle,Some{value}))
def populate_parts(~S: Data,world: Step.World(~S),+handle: W.Handle<S>,payload: SpawnPayload) -> Step.World(~S):
  match payload:
    case SpawnPayload{position,velocity,health}:
      insert_health(~S,insert_velocity(~S,insert_position(~S,world,handle,position),handle,velocity),handle,health)
def populate(~S: Data,world: Step.World(~S),handle: W.Handle<S>,payload: SpawnPayload) -> Step.World(~S):
  populate_parts(~S,world,handle,payload)
def staged(~S: Data,observed: Step.Transaction(~S) & W.Reservation<S>) -> Step.World(~S) & W.Reservation<S>:
  match observed:
    case (T.Tx{world,_,commands,_},+reservation): (Cmd.enqueue(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,world,commands),reservation)
def spawn(~S: Data,world: Step.World(~S),payload: SpawnPayload) -> Step.World(~S) & W.Reservation<S>:
  staged(~S,Cmd.tx_spawn(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~SpawnPayload,~populate(~S),T.begin(~Step.World(~S),~Events.SimulationEvent,world),payload))
def cell(value: U32,sentinel: U32) -> Array<U32>: ANode{ALeaf{value},ALeaf{sentinel}}
def payload(position: U32,velocity: U32,health: U32,+sentinel: U32) -> SpawnPayload:
  SpawnPayload{cell(position,sentinel),cell(velocity,(sentinel + 1 : U32)),cell(health,(sentinel + 2 : U32))}
