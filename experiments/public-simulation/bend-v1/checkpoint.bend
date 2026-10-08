import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import ./step.bend as Step
import ./storage.bend as Storage
import ./events.bend as Events
import ./owner-view.bend as Owner
import ./store-view.bend as StoreView
import ./world-view.bend as View

type Snapshot is Data:
  Snapshot{label: String,allocation: View.Allocation,resource: Owner.FullCell,cells: List<&2,StoreView.EntityCells>,events: List<&2,Events.SimulationEvent>,pending: U32,clock: U32,live: List<&2,U32>}
def ids(~S: Data,handles: List<&2,W.Handle<S>>) -> List<&2,U32>:
  match handles:
    case []: []
    case W.Handle{_,id} <> rest: id <> ids(~S,rest)
def live_known(~S: Data,label: String,allocation: View.Allocation,resource: Owner.FullCell,cells: List<&2,StoreView.EntityCells>,events: List<&2,Events.SimulationEvent>,pending: U32,clock: U32,observed: Step.World(~S) & List<&2,W.Handle<S>>) -> Step.World(~S) & Snapshot:
  match observed:
    case (world,handles): (world,Snapshot{label,allocation,resource,cells,events,pending,clock,ids(~S,handles)})
def clock_known(~S: Data,label: String,allocation: View.Allocation,resource: Owner.FullCell,cells: List<&2,StoreView.EntityCells>,events: List<&2,Events.SimulationEvent>,pending: U32,observed: Step.World(~S) & U32) -> Step.World(~S) & Snapshot:
  match observed:
    case (world,clock): live_known(~S,label,allocation,resource,cells,events,pending,clock,W.handles(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,world))
def pending_known(~S: Data,label: String,allocation: View.Allocation,resource: Owner.FullCell,cells: List<&2,StoreView.EntityCells>,events: List<&2,Events.SimulationEvent>,observed: Step.World(~S) & U32) -> Step.World(~S) & Snapshot:
  match observed:
    case (world,pending): clock_known(~S,label,allocation,resource,cells,events,pending,W.clock(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,world))
def events_known(~S: Data,label: String,allocation: View.Allocation,resource: Owner.FullCell,cells: List<&2,StoreView.EntityCells>,observed: Step.World(~S) & List<&2,Events.SimulationEvent>) -> Step.World(~S) & Snapshot:
  match observed:
    case (world,events): pending_known(~S,label,allocation,resource,cells,events,W.pending_count(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,world))
def cells_known(~S: Data,label: String,allocation: View.Allocation,resource: Owner.FullCell,observed: Step.World(~S) & List<&2,StoreView.EntityCells>) -> Step.World(~S) & Snapshot:
  match observed:
    case (world,cells): events_known(~S,label,allocation,resource,cells,W.events_view(~S,~Storage.Store<S>,~Array<U32>,~Events.SimulationEvent,world))
def resource_known(~S: Data,label: String,allocation: View.Allocation,observed: Step.World(~S) & Owner.FullCell) -> Step.World(~S) & Snapshot:
  match observed:
    case (world,resource): cells_known(~S,label,allocation,resource,View.allocated(~S,world))
def allocation_known(~S: Data,label: String,observed: Step.World(~S) & View.Allocation) -> Step.World(~S) & Snapshot:
  match observed:
    case (world,allocation): resource_known(~S,label,allocation,View.resource(~S,world))
def observe(~S: Data,label: String,world: Step.World(~S)) -> Step.World(~S) & Snapshot:
  allocation_known(~S,label,View.allocation(~S,world))
