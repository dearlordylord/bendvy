import Base
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/event-stream.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/event-publication.bend as Publication
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-family.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/event-family-runtime.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import state.bend as Source

def PairEvents() -> Data:Publication.Publication<Source.FirstEvent,Source.SecondEvent>
def Events() -> Data:Publication.Publication<PairEvents(),Source.UnusedEvent>
def PairDomains() -> Data:C.Domains<Event.Domain<Source.Other,Source.FirstEvent>,Event.Domain<Source.Other,Source.SecondEvent>>
def Domains() -> Data:C.Domains<PairDomains(),Event.Domain<Source.Other,Source.UnusedEvent>>
def PairMetadata() -> Type:Product.Owner<Leaf.Stream<Source.Other,Source.FirstEvent>,Leaf.Stream<Source.Other,Source.SecondEvent>>
def Metadata() -> Type:Product.Owner<PairMetadata(),Leaf.Stream<Source.Other,Source.UnusedEvent>>
def make_pair() -> PairDomains() -> Nat -> PairMetadata():C.node_make(~Event.Domain<Source.Other,Source.FirstEvent>,~Event.Domain<Source.Other,Source.SecondEvent>,~Leaf.Stream<Source.Other,Source.FirstEvent>,~Leaf.Stream<Source.Other,Source.SecondEvent>,~C.leaf_make(~Source.Other,~Source.FirstEvent),~C.leaf_make(~Source.Other,~Source.SecondEvent))
def sync_pair() -> PairMetadata() -> Nat -> List<&2,PairEvents()> -> PairMetadata():C.node_sync(~Source.FirstEvent,~Source.SecondEvent,~Leaf.Stream<Source.Other,Source.FirstEvent>,~Leaf.Stream<Source.Other,Source.SecondEvent>,~C.leaf_sync(~Source.Other,~Source.FirstEvent),~C.leaf_sync(~Source.Other,~Source.SecondEvent))
def frame_pair() -> PairMetadata() -> Nat -> PairMetadata():C.node_frame(~Leaf.Stream<Source.Other,Source.FirstEvent>,~Leaf.Stream<Source.Other,Source.SecondEvent>,~C.leaf_frame(~Source.Other,~Source.FirstEvent),~C.leaf_frame(~Source.Other,~Source.SecondEvent))
def retain_pair() -> PairMetadata() -> Nat -> List<&2,PairEvents()> -> PairMetadata() & List<&2,PairEvents()>:C.pair_retain(~Source.FirstEvent,~Source.SecondEvent,~Leaf.Stream<Source.Other,Source.FirstEvent>,~Leaf.Stream<Source.Other,Source.SecondEvent>,~C.leaf_retain(~Source.Other,~Source.FirstEvent),~C.leaf_retain(~Source.Other,~Source.SecondEvent))
def inventory_pair() -> PairMetadata() -> PairMetadata() & List<&2,String>:C.pair_inventory(~Leaf.Stream<Source.Other,Source.FirstEvent>,~Leaf.Stream<Source.Other,Source.SecondEvent>,~C.leaf_inventory(~Source.Other,~Source.FirstEvent),~C.leaf_inventory(~Source.Other,~Source.SecondEvent))
def make() -> Domains() -> Nat -> Metadata():C.node_make(~PairDomains(),~Event.Domain<Source.Other,Source.UnusedEvent>,~PairMetadata(),~Leaf.Stream<Source.Other,Source.UnusedEvent>,~make_pair(),~C.leaf_make(~Source.Other,~Source.UnusedEvent))
def sync() -> Metadata() -> Nat -> List<&2,Events()> -> Metadata():C.node_sync(~PairEvents(),~Source.UnusedEvent,~PairMetadata(),~Leaf.Stream<Source.Other,Source.UnusedEvent>,~sync_pair(),~C.leaf_sync(~Source.Other,~Source.UnusedEvent))
def frame() -> Metadata() -> Nat -> Metadata():C.node_frame(~PairMetadata(),~Leaf.Stream<Source.Other,Source.UnusedEvent>,~frame_pair(),~C.leaf_frame(~Source.Other,~Source.UnusedEvent))
def retain() -> Metadata() -> Nat -> List<&2,Events()> -> Metadata() & List<&2,Events()>:C.pair_retain(~PairEvents(),~Source.UnusedEvent,~PairMetadata(),~Leaf.Stream<Source.Other,Source.UnusedEvent>,~retain_pair(),~C.leaf_retain(~Source.Other,~Source.UnusedEvent))
def inventory() -> Metadata() -> Metadata() & List<&2,String>:C.pair_inventory(~PairMetadata(),~Leaf.Stream<Source.Other,Source.UnusedEvent>,~inventory_pair(),~C.leaf_inventory(~Source.Other,~Source.UnusedEvent))
def PairProvision() -> Data:C.Provision<Source.Other,PairEvents(),PairDomains(),PairMetadata(),make_pair(),sync_pair(),frame_pair(),retain_pair(),inventory_pair()>
def Provision() -> Data:C.Provision<Source.Other,Events(),Domains(),Metadata(),make(),sync(),frame(),retain(),inventory()>
def pair_provision() -> PairProvision():C.branch(~Source.Other,~Source.FirstEvent,~Source.SecondEvent,~Event.Domain<Source.Other,Source.FirstEvent>,~Event.Domain<Source.Other,Source.SecondEvent>,~Leaf.Stream<Source.Other,Source.FirstEvent>,~Leaf.Stream<Source.Other,Source.SecondEvent>,~C.leaf_make(~Source.Other,~Source.FirstEvent),~C.leaf_make(~Source.Other,~Source.SecondEvent),~C.leaf_sync(~Source.Other,~Source.FirstEvent),~C.leaf_sync(~Source.Other,~Source.SecondEvent),~C.leaf_frame(~Source.Other,~Source.FirstEvent),~C.leaf_frame(~Source.Other,~Source.SecondEvent),~C.leaf_retain(~Source.Other,~Source.FirstEvent),~C.leaf_retain(~Source.Other,~Source.SecondEvent),~C.leaf_inventory(~Source.Other,~Source.FirstEvent),~C.leaf_inventory(~Source.Other,~Source.SecondEvent),C.leaf(~Source.Other,~Source.FirstEvent,Event.domain(~Source.Other,~Source.FirstEvent,"Signal")),C.leaf(~Source.Other,~Source.SecondEvent,Event.domain(~Source.Other,~Source.SecondEvent,"Signal")))
def provision() -> Provision():C.branch(~Source.Other,~PairEvents(),~Source.UnusedEvent,~PairDomains(),~Event.Domain<Source.Other,Source.UnusedEvent>,~PairMetadata(),~Leaf.Stream<Source.Other,Source.UnusedEvent>,~make_pair(),~C.leaf_make(~Source.Other,~Source.UnusedEvent),~sync_pair(),~C.leaf_sync(~Source.Other,~Source.UnusedEvent),~frame_pair(),~C.leaf_frame(~Source.Other,~Source.UnusedEvent),~retain_pair(),~C.leaf_retain(~Source.Other,~Source.UnusedEvent),~inventory_pair(),~C.leaf_inventory(~Source.Other,~Source.UnusedEvent),pair_provision(),C.leaf(~Source.Other,~Source.UnusedEvent,Event.domain(~Source.Other,~Source.UnusedEvent,"Source.UnusedEvent")))
def State() -> Type:Tree.State<Events(),Metadata(),Array<U32>>
def World() -> Type:W.World<Source.Other,Source.Store,Source.Resources,Events()>
def Runtime() -> Type:Route.Runtime<Source.Other,Source.Store,Source.Resources,Events(),State()>
def setup(world:World(),owners:Array<U32>) -> Runtime():Tree.setup(~Source.Other,~Source.Store,~Source.Resources,~Events(),~Domains(),~Metadata(),~Array<U32>,~make(),~sync(),~frame(),~retain(),~inventory(),world,provision(),owners,2n)
