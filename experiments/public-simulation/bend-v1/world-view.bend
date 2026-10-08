import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import ./storage.bend as Storage
import ./step.bend as Step
import ./events.bend as Events
import ./owner-view.bend as Owner
import ./store-view.bend as StoreView

def entity(~S: Data,+id: U32,world: Step.World(~S)) -> Step.World(~S) & StoreView.EntityCells:
  W.with_store(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~StoreView.EntityCells,(store => StoreView.entity(~S,id,store)),world)
def resource(~S: Data,world: Step.World(~S)) -> Step.World(~S) & Owner.FullCell:
  W.observe_resource(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~Owner.FullCell,~Owner.view,world)

type Allocation is Data: Allocation{nextId: U32,highWater: U32}
def allocation(~S: Data,world: Step.World(~S)) -> Step.World(~S) & Allocation:
  match world:
    case W.World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}:
      (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},Allocation{nextId,highWater})
def allocated_known(~S: Data,observed: Step.World(~S) & Allocation) -> Step.World(~S) & List<&2,StoreView.EntityCells>:
  match observed:
    case (world,Allocation{_,highWater}): W.with_store(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,~List<&2,StoreView.EntityCells>,(store => StoreView.allocated(~S,U32.to_nat(highWater),1,store)),world)
def allocated(~S: Data,world: Step.World(~S)) -> Step.World(~S) & List<&2,StoreView.EntityCells>:
  allocated_known(~S,allocation(~S,world))
