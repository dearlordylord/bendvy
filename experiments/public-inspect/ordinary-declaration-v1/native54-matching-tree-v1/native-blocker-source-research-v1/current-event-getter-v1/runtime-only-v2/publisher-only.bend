import Base
import ./event-getter.bend as Getter
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/ordinary-composed-debug-v1/registered-mixed-readers-v1/affected-v1/normal/state.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/ordinary-composed-debug-v1/registered-mixed-readers-v1/affected-v1/normal/event-setup.bend as Events
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/ordinary-composed-debug-v1/registered-mixed-readers-v1/affected-v1/normal/physical.bend as Physical
import /workspace/formal-proofs/bendvy/experiments/public-inspect/ordinary-declaration-v1/ordinary-composed-debug-v1/registered-mixed-readers-v1/affected-v1/normal/operations.bend as Operations
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/event-stream.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-family.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import /workspace/formal-proofs/bendvy/src/ecs/event-notice-runtime.bend as Mixed
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
# Existing generated provision selectors; no Reader or caller-authored value projector.
def unused_family_take() -> Events.Metadata() -> Events.Metadata() & Leaf.Stream<F.S,F.UnusedEvent>:Provision.right_take(~F.S,~F.UnusedEvent,~Events.PairMetadata(),~Leaf.Stream<F.S,F.UnusedEvent>,~Provision.selected_leaf(~F.S,~F.UnusedEvent))
def unused_family_put() -> Events.Metadata() -> Leaf.Stream<F.S,F.UnusedEvent> -> Events.Metadata():Provision.right_put(~F.S,~F.UnusedEvent,~Events.PairMetadata(),~Leaf.Stream<F.S,F.UnusedEvent>,~Provision.replaced_leaf(~F.S,~F.UnusedEvent))
def take_unused(state:Events.State()) -> Events.State() & Leaf.Stream<F.S,F.UnusedEvent>:Mixed.take(~F.S,~F.UnusedEvent,~Events.Events(),~Events.Metadata(),~Array<U32>,~unused_family_take(),state)
def put_unused(state:Events.State(),stream:Leaf.Stream<F.S,F.UnusedEvent>) -> Events.State():Mixed.put(~F.S,~F.UnusedEvent,~Events.Events(),~Events.Metadata(),~Array<U32>,~unused_family_put(),state,stream)
type Observation is Data:Observation{factory:U32,first:Maybe<&2,List<&2,F.FirstEvent>>,again:Maybe<&2,List<&2,F.FirstEvent>>,unused:Maybe<&2,List<&2,F.UnusedEvent>>,physical:Physical.View}
type State is Type:State{factory:U32,runtime:Events.Runtime(),observations:List<&2,Observation>}
type Returned is Type:
  Ready{runtime:Events.Runtime(),observations:List<&2,Observation>}
  Refused{creation:W.Creation<F.S,F.Store(),F.Resources(),F.Events()>}
def captured(+factory:U32,before:List<&2,Observation>,first:Maybe<&2,List<&2,F.FirstEvent>>,again:Maybe<&2,List<&2,F.FirstEvent>>,unused:Maybe<&2,List<&2,F.UnusedEvent>>,returned:Events.Runtime() & Physical.View) -> State:
  match returned:
    case (runtime,physical):State{factory,runtime,List.append(&2,Observation,before,[Observation{factory,first,again,unused,physical}])}
def unused_read(factory:U32,before:List<&2,Observation>,first:Maybe<&2,List<&2,F.FirstEvent>>,again:Maybe<&2,List<&2,F.FirstEvent>>,returned:Events.Runtime() & Maybe<&2,List<&2,F.UnusedEvent>>) -> State:
  match returned:
    case (runtime,unused):captured(factory,before,first,again,unused,Physical.runtime(runtime))
def again_read(factory:U32,before:List<&2,Observation>,first:Maybe<&2,List<&2,F.FirstEvent>>,returned:Events.Runtime() & Maybe<&2,List<&2,F.FirstEvent>>) -> State:
  match returned:
    case (runtime,again):unused_read(factory,before,first,again,Getter.values(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.UnusedEvent,~Events.State(),~take_unused,~put_unused,Event.read(~F.S,~F.UnusedEvent,Event.domain(~F.S,~F.UnusedEvent,"Source.UnusedEvent")),runtime))
def first_read(factory:U32,before:List<&2,Observation>,returned:Events.Runtime() & Maybe<&2,List<&2,F.FirstEvent>>) -> State:
  match returned:
    case (runtime,first):again_read(factory,before,first,Getter.values(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.FirstEvent,~Events.State(),~Events.take_first,~Events.put_first,Event.read(~F.S,~F.FirstEvent,Event.domain(~F.S,~F.FirstEvent,"Signal")),runtime))
def checkpoint(state:State) -> State:
  match state:
    case State{factory,runtime,before}:first_read(factory,before,Getter.values(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.FirstEvent,~Events.State(),~Events.take_first,~Events.put_first,Event.read(~F.S,~F.FirstEvent,Event.domain(~F.S,~F.FirstEvent,"Signal")),runtime))
def publish_returned(factory:U32,before:List<&2,Observation>,+tick:Nat,returned:F.World() & Events.State()) -> State:
  match returned:
    case (world,family):State{factory,Route.Runtime{world,family,tick},before}
def publish(state:State) -> State:
  match state:
    case State{factory,Route.Runtime{world,family,+tick},before}:publish_returned(factory,before,1n+tick,Events.synchronize(Operations.publish_before(world),family,1n+tick))
def finished(state:State) -> Returned:
  match state:
    case State{_,runtime,observations}:Ready{runtime,observations}
def created(creation:W.Creation<F.S,F.Store(),F.Resources(),F.Events()>) -> Returned:
  match creation:
    case W.Created{W.Factory{factory},world}:finished(checkpoint(publish(checkpoint(State{factory,Events.setup(world,ANode{ALeaf{31},ALeaf{32}}),[]}))))
    case creation:Refused{creation}
def run() -> Returned:created(W.create(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.empty,W.factory(),ANode{ALeaf{81},ALeaf{82}}))
