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
import ./fixture-1.bend as Source
import /workspace/formal-proofs/bendvy/src/ecs/event-notice-runtime.bend as Mixed
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as Notice

def PairEvents() -> Data:Publication.Publication<Source.FirstEvent,Source.SecondEvent>
def Events() -> Data:Publication.Publication<PairEvents(),Source.UnusedEvent>
def PairDomains() -> Data:C.Domains<Event.Domain<Source.S,Source.FirstEvent>,Event.Domain<Source.S,Source.SecondEvent>>
def Domains() -> Data:C.Domains<PairDomains(),Event.Domain<Source.S,Source.UnusedEvent>>
def PairMetadata() -> Type:Product.Owner<Leaf.Stream<Source.S,Source.FirstEvent>,Leaf.Stream<Source.S,Source.SecondEvent>>
def Metadata() -> Type:Product.Owner<PairMetadata(),Leaf.Stream<Source.S,Source.UnusedEvent>>
def make_pair() -> PairDomains() -> Nat -> PairMetadata():C.node_make(~Event.Domain<Source.S,Source.FirstEvent>,~Event.Domain<Source.S,Source.SecondEvent>,~Leaf.Stream<Source.S,Source.FirstEvent>,~Leaf.Stream<Source.S,Source.SecondEvent>,~C.leaf_make(~Source.S,~Source.FirstEvent),~C.leaf_make(~Source.S,~Source.SecondEvent))
def sync_pair() -> PairMetadata() -> Nat -> List<&2,PairEvents()> -> PairMetadata():C.node_sync(~Source.FirstEvent,~Source.SecondEvent,~Leaf.Stream<Source.S,Source.FirstEvent>,~Leaf.Stream<Source.S,Source.SecondEvent>,~C.leaf_sync(~Source.S,~Source.FirstEvent),~C.leaf_sync(~Source.S,~Source.SecondEvent))
def frame_pair() -> PairMetadata() -> Nat -> PairMetadata():C.node_frame(~Leaf.Stream<Source.S,Source.FirstEvent>,~Leaf.Stream<Source.S,Source.SecondEvent>,~C.leaf_frame(~Source.S,~Source.FirstEvent),~C.leaf_frame(~Source.S,~Source.SecondEvent))
def retain_pair() -> PairMetadata() -> Nat -> List<&2,PairEvents()> -> PairMetadata() & List<&2,PairEvents()>:C.pair_retain(~Source.FirstEvent,~Source.SecondEvent,~Leaf.Stream<Source.S,Source.FirstEvent>,~Leaf.Stream<Source.S,Source.SecondEvent>,~C.leaf_retain(~Source.S,~Source.FirstEvent),~C.leaf_retain(~Source.S,~Source.SecondEvent))
def inventory_pair() -> PairMetadata() -> PairMetadata() & List<&2,String>:C.pair_inventory(~Leaf.Stream<Source.S,Source.FirstEvent>,~Leaf.Stream<Source.S,Source.SecondEvent>,~C.leaf_inventory(~Source.S,~Source.FirstEvent),~C.leaf_inventory(~Source.S,~Source.SecondEvent))
def make() -> Domains() -> Nat -> Metadata():C.node_make(~PairDomains(),~Event.Domain<Source.S,Source.UnusedEvent>,~PairMetadata(),~Leaf.Stream<Source.S,Source.UnusedEvent>,~make_pair(),~C.leaf_make(~Source.S,~Source.UnusedEvent))
def sync() -> Metadata() -> Nat -> List<&2,Events()> -> Metadata():C.node_sync(~PairEvents(),~Source.UnusedEvent,~PairMetadata(),~Leaf.Stream<Source.S,Source.UnusedEvent>,~sync_pair(),~C.leaf_sync(~Source.S,~Source.UnusedEvent))
def frame() -> Metadata() -> Nat -> Metadata():C.node_frame(~PairMetadata(),~Leaf.Stream<Source.S,Source.UnusedEvent>,~frame_pair(),~C.leaf_frame(~Source.S,~Source.UnusedEvent))
def retain() -> Metadata() -> Nat -> List<&2,Events()> -> Metadata() & List<&2,Events()>:C.pair_retain(~PairEvents(),~Source.UnusedEvent,~PairMetadata(),~Leaf.Stream<Source.S,Source.UnusedEvent>,~retain_pair(),~C.leaf_retain(~Source.S,~Source.UnusedEvent))
def inventory() -> Metadata() -> Metadata() & List<&2,String>:C.pair_inventory(~PairMetadata(),~Leaf.Stream<Source.S,Source.UnusedEvent>,~inventory_pair(),~C.leaf_inventory(~Source.S,~Source.UnusedEvent))
def PairProvision() -> Data:C.Provision<Source.S,PairEvents(),PairDomains(),PairMetadata(),make_pair(),sync_pair(),frame_pair(),retain_pair(),inventory_pair()>
def Provision() -> Data:C.Provision<Source.S,Events(),Domains(),Metadata(),make(),sync(),frame(),retain(),inventory()>
def pair_provision() -> PairProvision():C.branch(~Source.S,~Source.FirstEvent,~Source.SecondEvent,~Event.Domain<Source.S,Source.FirstEvent>,~Event.Domain<Source.S,Source.SecondEvent>,~Leaf.Stream<Source.S,Source.FirstEvent>,~Leaf.Stream<Source.S,Source.SecondEvent>,~C.leaf_make(~Source.S,~Source.FirstEvent),~C.leaf_make(~Source.S,~Source.SecondEvent),~C.leaf_sync(~Source.S,~Source.FirstEvent),~C.leaf_sync(~Source.S,~Source.SecondEvent),~C.leaf_frame(~Source.S,~Source.FirstEvent),~C.leaf_frame(~Source.S,~Source.SecondEvent),~C.leaf_retain(~Source.S,~Source.FirstEvent),~C.leaf_retain(~Source.S,~Source.SecondEvent),~C.leaf_inventory(~Source.S,~Source.FirstEvent),~C.leaf_inventory(~Source.S,~Source.SecondEvent),C.leaf(~Source.S,~Source.FirstEvent,Event.domain(~Source.S,~Source.FirstEvent,"Signal")),C.leaf(~Source.S,~Source.SecondEvent,Event.domain(~Source.S,~Source.SecondEvent,"Signal")))
def provision() -> Provision():C.branch(~Source.S,~PairEvents(),~Source.UnusedEvent,~PairDomains(),~Event.Domain<Source.S,Source.UnusedEvent>,~PairMetadata(),~Leaf.Stream<Source.S,Source.UnusedEvent>,~make_pair(),~C.leaf_make(~Source.S,~Source.UnusedEvent),~sync_pair(),~C.leaf_sync(~Source.S,~Source.UnusedEvent),~frame_pair(),~C.leaf_frame(~Source.S,~Source.UnusedEvent),~retain_pair(),~C.leaf_retain(~Source.S,~Source.UnusedEvent),~inventory_pair(),~C.leaf_inventory(~Source.S,~Source.UnusedEvent),pair_provision(),C.leaf(~Source.S,~Source.UnusedEvent,Event.domain(~Source.S,~Source.UnusedEvent,"Source.UnusedEvent")))
def State() -> Type:Mixed.State<Source.S,Events(),Metadata(),Array<U32>>
def World() -> Type:W.World<Source.S,Source.Store(),Source.Resources(),Notice.Notice<Source.S,Events()>>
def Runtime() -> Type:Route.Runtime<Source.S,Source.Store(),Source.Resources(),Notice.Notice<Source.S,Events()>,State()>
def setup_provision(world:World(),owners:Array<U32>,value:Provision()) -> Runtime():
  match value:
    case C.Provision{domains}:Mixed.start(~Source.S,~Source.Store(),~Source.Resources(),~Events(),~Metadata(),~Array<U32>,world,make()(domains,2n),owners)
def setup(world:World(),owners:Array<U32>) -> Runtime():setup_provision(world,owners,provision())

# Operational generated tree paths reused by registration and real reader execution.
def first_family_take() -> Metadata() -> Metadata() & Leaf.Stream<Source.S,Source.FirstEvent>:C.left_take(~Source.S,~Source.FirstEvent,~PairMetadata(),~Leaf.Stream<Source.S,Source.UnusedEvent>,~C.left_take(~Source.S,~Source.FirstEvent,~Leaf.Stream<Source.S,Source.FirstEvent>,~Leaf.Stream<Source.S,Source.SecondEvent>,~C.selected_leaf(~Source.S,~Source.FirstEvent)))
def first_family_put() -> Metadata() -> Leaf.Stream<Source.S,Source.FirstEvent> -> Metadata():C.left_put(~Source.S,~Source.FirstEvent,~PairMetadata(),~Leaf.Stream<Source.S,Source.UnusedEvent>,~C.left_put(~Source.S,~Source.FirstEvent,~Leaf.Stream<Source.S,Source.FirstEvent>,~Leaf.Stream<Source.S,Source.SecondEvent>,~C.replaced_leaf(~Source.S,~Source.FirstEvent)))
def second_family_take() -> Metadata() -> Metadata() & Leaf.Stream<Source.S,Source.SecondEvent>:C.left_take(~Source.S,~Source.SecondEvent,~PairMetadata(),~Leaf.Stream<Source.S,Source.UnusedEvent>,~C.right_take(~Source.S,~Source.SecondEvent,~Leaf.Stream<Source.S,Source.FirstEvent>,~Leaf.Stream<Source.S,Source.SecondEvent>,~C.selected_leaf(~Source.S,~Source.SecondEvent)))
def second_family_put() -> Metadata() -> Leaf.Stream<Source.S,Source.SecondEvent> -> Metadata():C.left_put(~Source.S,~Source.SecondEvent,~PairMetadata(),~Leaf.Stream<Source.S,Source.UnusedEvent>,~C.right_put(~Source.S,~Source.SecondEvent,~Leaf.Stream<Source.S,Source.FirstEvent>,~Leaf.Stream<Source.S,Source.SecondEvent>,~C.replaced_leaf(~Source.S,~Source.SecondEvent)))
def take_first(state:State()) -> State() & Leaf.Stream<Source.S,Source.FirstEvent>:Mixed.take(~Source.S,~Source.FirstEvent,~Events(),~Metadata(),~Array<U32>,~first_family_take(),state)
def put_first(state:State(),stream:Leaf.Stream<Source.S,Source.FirstEvent>) -> State():Mixed.put(~Source.S,~Source.FirstEvent,~Events(),~Metadata(),~Array<U32>,~first_family_put(),state,stream)
def take_second(state:State()) -> State() & Leaf.Stream<Source.S,Source.SecondEvent>:Mixed.take(~Source.S,~Source.SecondEvent,~Events(),~Metadata(),~Array<U32>,~second_family_take(),state)
def put_second(state:State(),stream:Leaf.Stream<Source.S,Source.SecondEvent>) -> State():Mixed.put(~Source.S,~Source.SecondEvent,~Events(),~Metadata(),~Array<U32>,~second_family_put(),state,stream)
def synchronize(world:World(),state:State(),tick:Nat) -> World() & State():Mixed.synchronize(~Source.S,~Source.Store(),~Source.Resources(),~Events(),~Metadata(),~Array<U32>,~sync(),world,state,tick)
