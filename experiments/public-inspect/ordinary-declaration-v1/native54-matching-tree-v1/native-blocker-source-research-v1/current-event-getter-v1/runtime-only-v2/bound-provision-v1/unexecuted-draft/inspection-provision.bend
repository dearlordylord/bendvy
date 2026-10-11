import Base
import ./event-binding.bend as Binding
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
def unused_family_take() -> Events.Metadata() -> Events.Metadata() & Leaf.Stream<F.S,F.UnusedEvent>:Provision.right_take(~F.S,~F.UnusedEvent,~Events.PairMetadata(),~Leaf.Stream<F.S,F.UnusedEvent>,~Provision.selected_leaf(~F.S,~F.UnusedEvent))
def unused_family_put() -> Events.Metadata() -> Leaf.Stream<F.S,F.UnusedEvent> -> Events.Metadata():Provision.right_put(~F.S,~F.UnusedEvent,~Events.PairMetadata(),~Leaf.Stream<F.S,F.UnusedEvent>,~Provision.replaced_leaf(~F.S,~F.UnusedEvent))
def take_unused(state:Events.State()) -> Events.State() & Leaf.Stream<F.S,F.UnusedEvent>:Mixed.take(~F.S,~F.UnusedEvent,~Events.Events(),~Events.Metadata(),~Array<U32>,~unused_family_take(),state)
def put_unused(state:Events.State(),stream:Leaf.Stream<F.S,F.UnusedEvent>) -> Events.State():Mixed.put(~F.S,~F.UnusedEvent,~Events.Events(),~Events.Metadata(),~Array<U32>,~unused_family_put(),state,stream)
def first() -> Cap.ValueRead<Events.Runtime(),Maybe<&2,List<&2,F.FirstEvent>>>:Binding.bind(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.FirstEvent,~Events.State(),~Events.take_first,~Events.put_first,Event.read(~F.S,~F.FirstEvent,Event.domain(~F.S,~F.FirstEvent,"Signal")),Provision.Selection{})
def unused() -> Cap.ValueRead<Events.Runtime(),Maybe<&2,List<&2,F.UnusedEvent>>>:Binding.bind(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.UnusedEvent,~Events.State(),~take_unused,~put_unused,Event.read(~F.S,~F.UnusedEvent,Event.domain(~F.S,~F.UnusedEvent,"Source.UnusedEvent")),Provision.Selection{})
