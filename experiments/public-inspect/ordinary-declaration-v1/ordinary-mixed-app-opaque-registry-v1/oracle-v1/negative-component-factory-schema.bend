import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/ordinary-mixed-app-opaque-registry-v1/ordinary.bend as Ordinary
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/ordinary-mixed-app-opaque-registry-v1/full-consumer.bend as Consumer
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/component.bend as Caller
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/schedule-app-observation-v1/component-fixture.bend as Fixture
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Projection
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-observable.bend as O
type Other is Data:
  Other{}
def wrong_schema() -> O.Declaration<Caller.A,Q.Frame<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32>,Fixture.read_ops(Q.Frame<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32>),I.Frame<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32>,Projection.Product<C.Access<U32>,Unit>>:
  Ordinary.component_query(~Caller.A,~Col.Column<Caller.A,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Projection.Product<C.Access<U32>,Unit>,~Consumer.component_declaration(~Other))
