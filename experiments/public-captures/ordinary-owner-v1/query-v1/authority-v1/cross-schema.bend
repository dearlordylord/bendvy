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
def cross_schema(owner:F.Owned(First),world:W.World<Other,Col.Column<Other,U32>,Unit,Unit>,args:F.Args) -> O.Run<W.World<First,Col.Column<First,U32>,Unit,Unit>,F.Owned(First),F.Args,Q.Error<F.Error>,U32>:
  F.run(~First,owner,world,args)
