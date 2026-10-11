import Base
import ./event-getter.bend as Getter
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-family.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/event-stream.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
# Bind existing generated selection and the same ordinary declaration once.
def bind(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,declaration:Event.Declaration<S,E>,_:Provision.Selection<S,E,F,take,put>) -> Cap.ValueRead<Route.Runtime<S,C,R,P,F>,Maybe<&2,List<&2,E>>>:
  Getter.read(~S,~C,~R,~P,~E,~F,~take,~put,declaration)
