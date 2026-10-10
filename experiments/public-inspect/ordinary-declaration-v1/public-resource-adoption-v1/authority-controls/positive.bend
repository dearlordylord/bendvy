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
def independent_schema(world:W.World<Other,Col.Column<Other,Unit>,C.Counter,U32>) -> String:
  C.start(~Other,world)
def read_declaration() -> P.Declaration<C.A,C.Counter,T.Tx<W.World<C.A,Col.Column<C.A,Unit>,C.Counter,U32>,U32>,Cap.ValueRead<T.Tx<W.World<C.A,Col.Column<C.A,Unit>,C.Counter,U32>,U32>,U32>>:
  P.read(~C.A,~Col.Column<C.A,Unit>,~C.Counter,~U32,~U32,~C.view,Schema.resource(~C.A,~C.Counter,"Counter"))
