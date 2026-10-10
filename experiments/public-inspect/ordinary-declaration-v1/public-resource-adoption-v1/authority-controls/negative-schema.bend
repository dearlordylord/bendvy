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
def foreign(identity:Schema.Resource<Other,C.Counter>) -> P.Declaration<C.A,C.Counter,T.Tx<W.World<C.A,Col.Column<C.A,Unit>,C.Counter,U32>,U32>,C.ops(T.Tx<W.World<C.A,Col.Column<C.A,Unit>,C.Counter,U32>,U32>)>:
  P.write(~C.A,~Col.Column<C.A,Unit>,~C.Counter,~U32,~U32,~C.view,identity)
