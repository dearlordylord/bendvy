import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-inspector-event.bend as Binding
import ./fixture-1.bend as F
import ./fixture-2.bend as Events
import ./fixture-7.bend as Physical
import ./fixture-5.bend as Operations
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/event-stream.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-family.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import /workspace/formal-proofs/bendvy/src/ecs/event-notice-runtime.bend as Mixed
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def domains(value:Events.Provision()) -> Events.Domains():
  match value:
    case Provision.Provision{domains}:domains
def first_domain(value:Events.Domains()) -> Event.Domain<F.S,F.FirstEvent>:
  match value:
    case Provision.Domains{Provision.Domains{first,_},_}:first
def unused_domain(value:Events.Domains()) -> Event.Domain<F.S,F.UnusedEvent>:
  match value:
    case Provision.Domains{_,unused}:unused
def first(value:Events.Provision()) -> Cap.ValueRead<Events.Runtime(),Maybe<&2,List<&2,F.FirstEvent>>>:Binding.bind(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.FirstEvent,~Events.State(),~Mixed.take(~F.S,~F.FirstEvent,~Events.Events(),~Events.Metadata(),~Array<U32>,~Events.first_family_take()),~Mixed.put(~F.S,~F.FirstEvent,~Events.Events(),~Events.Metadata(),~Array<U32>,~Events.first_family_put()),Event.read(~F.S,~F.FirstEvent,first_domain(domains(value))),Binding.lift_notice(~F.S,~F.FirstEvent,~Events.Events(),~Events.Metadata(),~Array<U32>,~Events.first_family_take(),~Events.first_family_put(),Provision.select_left(~F.S,~F.FirstEvent,~Events.PairMetadata(),~Leaf.Stream<F.S,F.UnusedEvent>,~Provision.left_take(~F.S,~F.FirstEvent,~Leaf.Stream<F.S,F.FirstEvent>,~Leaf.Stream<F.S,F.SecondEvent>,~Provision.selected_leaf(~F.S,~F.FirstEvent)),~Provision.left_put(~F.S,~F.FirstEvent,~Leaf.Stream<F.S,F.FirstEvent>,~Leaf.Stream<F.S,F.SecondEvent>,~Provision.replaced_leaf(~F.S,~F.FirstEvent)),Provision.select_left(~F.S,~F.FirstEvent,~Leaf.Stream<F.S,F.FirstEvent>,~Leaf.Stream<F.S,F.SecondEvent>,~Provision.selected_leaf(~F.S,~F.FirstEvent),~Provision.replaced_leaf(~F.S,~F.FirstEvent),Provision.select_leaf(~F.S,~F.FirstEvent)))))
def unused(value:Events.Provision()) -> Cap.ValueRead<Events.Runtime(),Maybe<&2,List<&2,F.UnusedEvent>>>:Binding.bind(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.UnusedEvent,~Events.State(),~Mixed.take(~F.S,~F.UnusedEvent,~Events.Events(),~Events.Metadata(),~Array<U32>,~Provision.right_take(~F.S,~F.UnusedEvent,~Events.PairMetadata(),~Leaf.Stream<F.S,F.UnusedEvent>,~Provision.selected_leaf(~F.S,~F.UnusedEvent))),~Mixed.put(~F.S,~F.UnusedEvent,~Events.Events(),~Events.Metadata(),~Array<U32>,~Provision.right_put(~F.S,~F.UnusedEvent,~Events.PairMetadata(),~Leaf.Stream<F.S,F.UnusedEvent>,~Provision.replaced_leaf(~F.S,~F.UnusedEvent))),Event.read(~F.S,~F.UnusedEvent,unused_domain(domains(value))),Binding.lift_notice(~F.S,~F.UnusedEvent,~Events.Events(),~Events.Metadata(),~Array<U32>,~Provision.right_take(~F.S,~F.UnusedEvent,~Events.PairMetadata(),~Leaf.Stream<F.S,F.UnusedEvent>,~Provision.selected_leaf(~F.S,~F.UnusedEvent)),~Provision.right_put(~F.S,~F.UnusedEvent,~Events.PairMetadata(),~Leaf.Stream<F.S,F.UnusedEvent>,~Provision.replaced_leaf(~F.S,~F.UnusedEvent)),Provision.select_right(~F.S,~F.UnusedEvent,~Events.PairMetadata(),~Leaf.Stream<F.S,F.UnusedEvent>,~Provision.selected_leaf(~F.S,~F.UnusedEvent),~Provision.replaced_leaf(~F.S,~F.UnusedEvent),Provision.select_leaf(~F.S,~F.UnusedEvent))))
