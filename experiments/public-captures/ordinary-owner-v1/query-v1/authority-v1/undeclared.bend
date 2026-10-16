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
def positive(world:W.World<First,Col.Column<First,U32>,Unit,Unit>,capture:P.Pack) -> O.Registration<W.World<First,Col.Column<First,U32>,Unit,Unit>,F.Owned(First),P.Pack>:
  O.define(~First,~Col.Column<First,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~D.with_component(~First,~U32,~Col.Column<First,U32>,~Unit,~Unit,~Unit,~U32,~F.Token,~F.identity(~First),~F.view,~F.take(~First),~F.put(~First)),~F.body,world,"query",capture)
