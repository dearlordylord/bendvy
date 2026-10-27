import Base
import ./declarations.bend as D
import ./payloads.bend as P
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-command-publication.bend as Publication
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product

def Resources(~S:Data) -> Type:Product.Owner<D.Resources(~S),Unit>
def World(~S:Data) -> Type:W.World<S,D.Store(~S),Resources(~S),Unit>
def SeedReceipt(~S:Data) -> Type:Buffer.Receipt<S,P.PeerActor<S,D.Mode>,Removed.Removed(D.component_layout(~S))>
type Allocation<-S:Data> is Type:
  AllocationReady{world:World(~S),handle:W.Handle<S>}
  Refused{world:World(~S),receipt:Maybe<&1,SeedReceipt(~S)>}
def seeded(~S:Data,+handle:W.Handle<S>,result:World(~S) & SeedReceipt(~S)) -> Allocation<S>:
  match result:
    case (world,Buffer.Applied{_,None{}}):AllocationReady{world,handle}
    case (world,receipt):Refused{world,Some{receipt}}
def seed_clocked(~S:Data,+handle:W.Handle<S>,result:World(~S) & Tick.Tick) -> Allocation<S>:
  match result:
    case (world,tick):seeded(~S,handle,Publication.family(~S,~Resources(~S),~Unit,~D.component_layout(~S),~Layout.InRight{Layout.AtLeaf{}},world,handle,Some{P.PeerActor{ALeaf{"peer-affine"},D.Waiting{}}},tick))
def activated(~S:Data,handle:W.Handle<S>,result:World(~S) & W.Status) -> Allocation<S>:
  match result:
    case (world,W.Accepted{}):seed_clocked(~S,handle,W.write_clock(~S,~D.Store(~S),~Resources(~S),~Unit,world))
    case (world,W.Rejected{_}):Refused{world,None{}}
def reserved(~S:Data,result:World(~S) & W.Reservation<S>) -> Allocation<S>:
  match result:
    case (world,W.Reserved{+handle}):activated(~S,handle,W.activate(~S,~D.Store(~S),~Resources(~S),~Unit,world,handle))
    case (world,W.ReservationRejected{_}):Refused{world,None{}}
def allocate(~S:Data,world:World(~S)) -> Allocation<S>:
  reserved(~S,W.reserve_id(~S,~D.Store(~S),~Resources(~S),~Unit,world))
