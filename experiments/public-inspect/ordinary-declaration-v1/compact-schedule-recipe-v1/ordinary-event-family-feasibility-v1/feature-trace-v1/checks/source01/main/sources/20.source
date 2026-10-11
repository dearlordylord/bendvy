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
import types.bend as Source

type Unused is Data:Unused{code:U32}
def PairEvents() -> Data:Publication.Publication<Source.First,Source.Second>
def Events() -> Data:Publication.Publication<PairEvents(),Unused>
def PairDomains() -> Data:C.Domains<Event.Domain<Source.Schema,Source.First>,Event.Domain<Source.Schema,Source.Second>>
def Domains() -> Data:C.Domains<PairDomains(),Event.Domain<Source.Schema,Unused>>
def PairMetadata() -> Type:Product.Owner<Leaf.Stream<Source.Schema,Source.First>,Leaf.Stream<Source.Schema,Source.Second>>
def Metadata() -> Type:Product.Owner<PairMetadata(),Leaf.Stream<Source.Schema,Unused>>
def make_pair() -> PairDomains() -> Nat -> PairMetadata():C.node_make(~Event.Domain<Source.Schema,Source.First>,~Event.Domain<Source.Schema,Source.Second>,~Leaf.Stream<Source.Schema,Source.First>,~Leaf.Stream<Source.Schema,Source.Second>,~C.leaf_make(~Source.Schema,~Source.First),~C.leaf_make(~Source.Schema,~Source.Second))
def sync_pair() -> PairMetadata() -> Nat -> List<&2,PairEvents()> -> PairMetadata():C.node_sync(~Source.First,~Source.Second,~Leaf.Stream<Source.Schema,Source.First>,~Leaf.Stream<Source.Schema,Source.Second>,~C.leaf_sync(~Source.Schema,~Source.First),~C.leaf_sync(~Source.Schema,~Source.Second))
def frame_pair() -> PairMetadata() -> Nat -> PairMetadata():C.node_frame(~Leaf.Stream<Source.Schema,Source.First>,~Leaf.Stream<Source.Schema,Source.Second>,~C.leaf_frame(~Source.Schema,~Source.First),~C.leaf_frame(~Source.Schema,~Source.Second))
def retain_pair() -> PairMetadata() -> Nat -> List<&2,PairEvents()> -> PairMetadata() & List<&2,PairEvents()>:C.pair_retain(~Source.First,~Source.Second,~Leaf.Stream<Source.Schema,Source.First>,~Leaf.Stream<Source.Schema,Source.Second>,~C.leaf_retain(~Source.Schema,~Source.First),~C.leaf_retain(~Source.Schema,~Source.Second))
def inventory_pair() -> PairMetadata() -> PairMetadata() & List<&2,String>:C.pair_inventory(~Leaf.Stream<Source.Schema,Source.First>,~Leaf.Stream<Source.Schema,Source.Second>,~C.leaf_inventory(~Source.Schema,~Source.First),~C.leaf_inventory(~Source.Schema,~Source.Second))
def make() -> Domains() -> Nat -> Metadata():C.node_make(~PairDomains(),~Event.Domain<Source.Schema,Unused>,~PairMetadata(),~Leaf.Stream<Source.Schema,Unused>,~make_pair(),~C.leaf_make(~Source.Schema,~Unused))
def sync() -> Metadata() -> Nat -> List<&2,Events()> -> Metadata():C.node_sync(~PairEvents(),~Unused,~PairMetadata(),~Leaf.Stream<Source.Schema,Unused>,~sync_pair(),~C.leaf_sync(~Source.Schema,~Unused))
def frame() -> Metadata() -> Nat -> Metadata():C.node_frame(~PairMetadata(),~Leaf.Stream<Source.Schema,Unused>,~frame_pair(),~C.leaf_frame(~Source.Schema,~Unused))
def retain() -> Metadata() -> Nat -> List<&2,Events()> -> Metadata() & List<&2,Events()>:C.pair_retain(~PairEvents(),~Unused,~PairMetadata(),~Leaf.Stream<Source.Schema,Unused>,~retain_pair(),~C.leaf_retain(~Source.Schema,~Unused))
def inventory() -> Metadata() -> Metadata() & List<&2,String>:C.pair_inventory(~PairMetadata(),~Leaf.Stream<Source.Schema,Unused>,~inventory_pair(),~C.leaf_inventory(~Source.Schema,~Unused))
def PairProvision() -> Data:C.Provision<Source.Schema,PairEvents(),PairDomains(),PairMetadata(),make_pair(),sync_pair(),frame_pair(),retain_pair(),inventory_pair()>
def Provision() -> Data:C.Provision<Source.Schema,Events(),Domains(),Metadata(),make(),sync(),frame(),retain(),inventory()>
def pair_provision() -> PairProvision():C.branch(~Source.Schema,~Source.First,~Source.Second,~Event.Domain<Source.Schema,Source.First>,~Event.Domain<Source.Schema,Source.Second>,~Leaf.Stream<Source.Schema,Source.First>,~Leaf.Stream<Source.Schema,Source.Second>,~C.leaf_make(~Source.Schema,~Source.First),~C.leaf_make(~Source.Schema,~Source.Second),~C.leaf_sync(~Source.Schema,~Source.First),~C.leaf_sync(~Source.Schema,~Source.Second),~C.leaf_frame(~Source.Schema,~Source.First),~C.leaf_frame(~Source.Schema,~Source.Second),~C.leaf_retain(~Source.Schema,~Source.First),~C.leaf_retain(~Source.Schema,~Source.Second),~C.leaf_inventory(~Source.Schema,~Source.First),~C.leaf_inventory(~Source.Schema,~Source.Second),C.leaf(~Source.Schema,~Source.First,Event.domain(~Source.Schema,~Source.First,"First")),C.leaf(~Source.Schema,~Source.Second,Event.domain(~Source.Schema,~Source.Second,"Second")))
def provision() -> Provision():C.branch(~Source.Schema,~PairEvents(),~Unused,~PairDomains(),~Event.Domain<Source.Schema,Unused>,~PairMetadata(),~Leaf.Stream<Source.Schema,Unused>,~make_pair(),~C.leaf_make(~Source.Schema,~Unused),~sync_pair(),~C.leaf_sync(~Source.Schema,~Unused),~frame_pair(),~C.leaf_frame(~Source.Schema,~Unused),~retain_pair(),~C.leaf_retain(~Source.Schema,~Unused),~inventory_pair(),~C.leaf_inventory(~Source.Schema,~Unused),pair_provision(),C.leaf(~Source.Schema,~Unused,Event.domain(~Source.Schema,~Unused,"Unused")))
def State() -> Type:Tree.State<Events(),Metadata(),Array<U32>>
def World() -> Type:W.World<Source.Schema,Array<U32>,Array<U32>,Events()>
def Runtime() -> Type:Route.Runtime<Source.Schema,Array<U32>,Array<U32>,Events(),State()>
def setup(world:World(),owners:Array<U32>) -> Runtime():Tree.setup(~Source.Schema,~Array<U32>,~Array<U32>,~Events(),~Domains(),~Metadata(),~Array<U32>,~make(),~sync(),~frame(),~retain(),~inventory(),world,provision(),owners,65536n)
def first_family_take() -> Metadata() -> Metadata() & Leaf.Stream<Source.Schema,Source.First>:C.left_take(~Source.Schema,~Source.First,~PairMetadata(),~Leaf.Stream<Source.Schema,Unused>,~C.left_take(~Source.Schema,~Source.First,~Leaf.Stream<Source.Schema,Source.First>,~Leaf.Stream<Source.Schema,Source.Second>,~C.selected_leaf(~Source.Schema,~Source.First)))
def first_family_put() -> Metadata() -> Leaf.Stream<Source.Schema,Source.First> -> Metadata():C.left_put(~Source.Schema,~Source.First,~PairMetadata(),~Leaf.Stream<Source.Schema,Unused>,~C.left_put(~Source.Schema,~Source.First,~Leaf.Stream<Source.Schema,Source.First>,~Leaf.Stream<Source.Schema,Source.Second>,~C.replaced_leaf(~Source.Schema,~Source.First)))
def take_first(state:State()) -> State() & Leaf.Stream<Source.Schema,Source.First>:Tree.take(~Source.Schema,~Source.First,~Events(),~Metadata(),~Array<U32>,~first_family_take(),state)
def put_first(state:State(),stream:Leaf.Stream<Source.Schema,Source.First>) -> State():Tree.put(~Source.Schema,~Source.First,~Events(),~Metadata(),~Array<U32>,~first_family_put(),state,stream)
def inject_first() -> Source.First -> Events():C.inject_left(~Source.First,~PairEvents(),~Unused,~C.inject_left(~Source.First,~Source.First,~Source.Second,~C.inject_leaf(~Source.First)))
def emit_first(tx:Tx.Tx<World(),Events()>,event:Source.First) -> Tx.Tx<World(),Events()>:Tx.emit(~World(),~Events(),tx,inject_first()(event))
def second_family_take() -> Metadata() -> Metadata() & Leaf.Stream<Source.Schema,Source.Second>:C.left_take(~Source.Schema,~Source.Second,~PairMetadata(),~Leaf.Stream<Source.Schema,Unused>,~C.right_take(~Source.Schema,~Source.Second,~Leaf.Stream<Source.Schema,Source.First>,~Leaf.Stream<Source.Schema,Source.Second>,~C.selected_leaf(~Source.Schema,~Source.Second)))
def second_family_put() -> Metadata() -> Leaf.Stream<Source.Schema,Source.Second> -> Metadata():C.left_put(~Source.Schema,~Source.Second,~PairMetadata(),~Leaf.Stream<Source.Schema,Unused>,~C.right_put(~Source.Schema,~Source.Second,~Leaf.Stream<Source.Schema,Source.First>,~Leaf.Stream<Source.Schema,Source.Second>,~C.replaced_leaf(~Source.Schema,~Source.Second)))
def take_second(state:State()) -> State() & Leaf.Stream<Source.Schema,Source.Second>:Tree.take(~Source.Schema,~Source.Second,~Events(),~Metadata(),~Array<U32>,~second_family_take(),state)
def put_second(state:State(),stream:Leaf.Stream<Source.Schema,Source.Second>) -> State():Tree.put(~Source.Schema,~Source.Second,~Events(),~Metadata(),~Array<U32>,~second_family_put(),state,stream)
def inject_second() -> Source.Second -> Events():C.inject_left(~Source.Second,~PairEvents(),~Unused,~C.inject_right(~Source.Second,~Source.First,~Source.Second,~C.inject_leaf(~Source.Second)))
def emit_second(tx:Tx.Tx<World(),Events()>,event:Source.Second) -> Tx.Tx<World(),Events()>:Tx.emit(~World(),~Events(),tx,inject_second()(event))
def synchronize(world:World(),state:State(),tick:Nat) -> World() & State():Tree.synchronize(~Source.Schema,~Array<U32>,~Array<U32>,~Events(),~Metadata(),~Array<U32>,~sync(),world,state,tick)
def next_frame(runtime:Runtime()) -> Runtime():Tree.frame(~Source.Schema,~Array<U32>,~Array<U32>,~Events(),~Metadata(),~Array<U32>,~frame(),~retain(),runtime)
def inspect(enabled:Bool,runtime:Runtime()) -> Runtime() & Maybe<&2,List<&2,String>>:Tree.inventory_enabled(~Source.Schema,~Array<U32>,~Array<U32>,~Events(),~Metadata(),~Array<U32>,~inventory(),enabled,runtime)
def staged(world:World()) -> Tx.Tx<World(),Events()>:emit_first(emit_second(emit_first(Tx.begin(~World(),~Events(),world),Source.First{7}),Source.Second{True{}}),Source.First{8})
def enqueue_loop(commands:List<&1,World() -> World()>,world:World()) -> World():
  match commands:
    case []:world
    case command <> rest:enqueue_loop(rest,command(world))
def enqueue(world:World(),commands:List<&1,World() -> World()>) -> World():enqueue_loop(commands,world)
def publish(world:World(),events:List<&2,Events()>) -> World():W.event_publish(~Source.Schema,~Array<U32>,~Array<U32>,~Events(),world,events)

def second_domain_returned(first:Event.Domain<Source.Schema,Source.First>,returned:State() & Leaf.Stream<Source.Schema,Source.Second>) -> State() & PairDomains():
  match returned:
    case (state,stream):(state,C.Domains{first,Leaf.domain(~Source.Schema,~Source.Second,stream)})
def first_domain_returned(returned:State() & Leaf.Stream<Source.Schema,Source.First>) -> State() & PairDomains():
  match returned:
    case (state,stream):second_domain_returned(Leaf.domain(~Source.Schema,~Source.First,stream),take_second(state))
def publisher_domains(state:State()) -> State() & PairDomains():first_domain_returned(take_first(state))
def publisher_access(domains:PairDomains()) -> List<&2,String>:
  match domains:
    case C.Domains{first,second}:[Event.access(~Source.Schema,~Source.First,Event.write(~Source.Schema,~Source.First,first)),Event.access(~Source.Schema,~Source.Second,Event.write(~Source.Schema,~Source.Second,second))]
def staged_declared(world:World(),domains:PairDomains()) -> Tx.Tx<World(),Events()>:
  match domains:
    case C.Domains{+first,second}:
      Ev.emit(~Tx.Tx<World(),Events()>,~Source.First,~emit_first,Event.write_grant(~Source.Schema,~Source.First,~Tx.Tx<World(),Events()>,~emit_first,first),Ev.emit(~Tx.Tx<World(),Events()>,~Source.Second,~emit_second,Event.write_grant(~Source.Schema,~Source.Second,~Tx.Tx<World(),Events()>,~emit_second,second),Ev.emit(~Tx.Tx<World(),Events()>,~Source.First,~emit_first,Event.write_grant(~Source.Schema,~Source.First,~Tx.Tx<World(),Events()>,~emit_first,first),Tx.begin(~World(),~Events(),world),Source.First{7}),Source.Second{True{}}),Source.First{8})
