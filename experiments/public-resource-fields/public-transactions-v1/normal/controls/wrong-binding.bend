import Base
import ../../../../../src/ecs/ordinary-resource-field-system.bend as P
import ../operations.bend as O
import ../schema-a.bend as A
import ../schema-b.bend as Other
import ../../../../../src/ecs/column.bend as Col
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/transaction.bend as T
def attempt() -> P.Declaration<A.A,T.Tx<W.World<A.A,Col.Column<A.A,Unit>,A.Resources(),U32>,U32>,P.Write<A.A,O.Counter,A.first(),T.Tx<W.World<A.A,Col.Column<A.A,Unit>,A.Resources(),U32>,U32>,U32>>:
  P.write(~A.A,~Col.Column<A.A,Unit>,~A.Resources(),~U32,~O.Counter,~Unit & O.Counter,~U32,~A.first_lens(),~A.first(),~A.second_binding(),~O.view)
