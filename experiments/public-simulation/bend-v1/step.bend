import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/resource.bend as R
import ./events.bend as Events
import ./storage.bend as Storage
import ./geometry.bend as Geometry

def World(~S: Data) -> Type: W.World<S,Storage.Store<S>,Array<U32>,Events.SimulationEvent>
def Transaction(~S: Data) -> Type: T.Tx<World(~S),Events.SimulationEvent>
# This prefix joins the movement traversal's transaction before it commits.
# The resource inverse owns the old Array; failure must roll back this prefix
# together with all component writes, without publishing staged events.
def advanced(~S: Data,observed: Transaction(~S) & Geometry.Cell) -> Transaction(~S):
  match observed:
    case (tx,Geometry.Cell{value,sentinel}):
      R.tx_replace(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,tx,ANode{ALeaf{(value + 1 : U32)},ALeaf{sentinel}})
def begin(~S: Data,world: World(~S)) -> Transaction(~S):
  advanced(~S,R.tx_get(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Geometry.Cell,~Geometry.project,T.begin(~World(~S),~Events.SimulationEvent,world)))
