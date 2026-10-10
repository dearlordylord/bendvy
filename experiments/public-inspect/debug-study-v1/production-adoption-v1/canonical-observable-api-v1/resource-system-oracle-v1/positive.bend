import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-system-v1/provider.bend as P
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-system-v1/consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
type Other is Data:
  Other{}
def independent_schema(world:W.World<Other,Col.Column<Other,Unit>,C.Counter,U32>) -> String:
  C.start(~Other,world)
def read_declaration() -> P.Declaration<C.A,C.Counter,T.Tx<W.World<C.A,Col.Column<C.A,Unit>,C.Counter,U32>,U32>,Cap.ValueRead<T.Tx<W.World<C.A,Col.Column<C.A,Unit>,C.Counter,U32>,U32>,U32>>:
  P.read(~C.A,~Col.Column<C.A,Unit>,~C.Counter,~U32,~U32,~C.view,Schema.resource(~C.A,~C.Counter,"Counter"))
