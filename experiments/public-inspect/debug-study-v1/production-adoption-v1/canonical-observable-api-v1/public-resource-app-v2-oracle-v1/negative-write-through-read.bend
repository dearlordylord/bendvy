import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/observable-resource.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-system.bend as P
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/fixture.bend as C
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
type Other is Data:
  Other{}
def upgrade_read() -> P.Declaration<C.A,C.Counter,T.Tx<W.World<C.A,Col.Column<C.A,Unit>,C.Counter,U32>,U32>,Cap.ValueWrite<T.Tx<W.World<C.A,Col.Column<C.A,Unit>,C.Counter,U32>,U32>,C.Counter,U32>>:
  D.ordinary(~C.A,~Col.Column<C.A,Unit>,~C.Counter,~U32,~D.write_ops(~C.Counter,~U32),~U32,D.read(~C.A,~Col.Column<C.A,Unit>,~C.Counter,~U32,~U32,~C.view,~U32.show,Schema.resource(~C.A,~C.Counter,"Counter")))
