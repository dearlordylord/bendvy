import Base
import ./inspection-provision-v2.bend as Inspection
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
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
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
    case (runtime,again):unused_read(factory,before,first,again,Cap.value_read_field(~Events.Runtime(),~Maybe<&2,List<&2,F.UnusedEvent>>,Inspection.unused(Events.provision()))(runtime))
def first_read(factory:U32,before:List<&2,Observation>,returned:Events.Runtime() & Maybe<&2,List<&2,F.FirstEvent>>) -> State:
  match returned:
    case (runtime,first):again_read(factory,before,first,Cap.value_read_field(~Events.Runtime(),~Maybe<&2,List<&2,F.FirstEvent>>,Inspection.first(Events.provision()))(runtime))
def checkpoint(state:State) -> State:
  match state:
    case State{factory,runtime,before}:first_read(factory,before,Cap.value_read_field(~Events.Runtime(),~Maybe<&2,List<&2,F.FirstEvent>>,Inspection.first(Events.provision()))(runtime))
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
