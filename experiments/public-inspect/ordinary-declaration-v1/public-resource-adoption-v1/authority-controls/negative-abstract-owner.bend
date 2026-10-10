import Base
import ../../../../../src/ecs/ordinary-resource-system.bend as P
import ../consumer.bend as C
import ../../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../../src/ecs/ordinary-query-declaration.bend as Query
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/column.bend as Col
import ../../../../../src/ecs/transaction.bend as T
import ../../../../../src/ecs/capabilities.bend as Cap
type Other is Data:
  Other{}
def recover_world(~H:Type,~caps:C.ops(H),owner:H) -> W.World<C.A,Col.Column<C.A,Unit>,C.Counter,U32>:
  owner
