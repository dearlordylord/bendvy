import Base
import ../fixture.bend as F
import ../../payload.bend as P
import ../../../../../src/ecs/ordinary-capture-query.bend as O
import ../../../../../src/ecs/ordinary-query-declaration.bend as D
import ../../../../../src/ecs/compose.bend as Q
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/column.bend as Col
import ../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../src/ecs/transaction.bend as T
type First is Data:
  First{}
type Other is Data:
  Other{}
def escaped(~H:Type,~caps:F.Ops(H),capture:P.Pack,args:F.Args,owner:H) -> W.World<First,Col.Column<First,U32>,Unit,Unit>:
  owner
