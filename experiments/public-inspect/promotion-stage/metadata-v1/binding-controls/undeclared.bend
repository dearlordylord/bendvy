import Base
import ../binding-fixtures/workshop.bend as W
import ../../../../../src/ecs/capabilities.bend as Cap
# Exact actual fixed Ops cannot be promoted into a fourth resource read grant.
type ExtraReads<-H:Type> is Type:
  ExtraReads{bonus:Cap.ValueRead<H,List<&2,U32>>,bonusAlias:Cap.ValueRead<H,List<&2,U32>>,score:Cap.ValueRead<H,List<&2,U32>>,undeclared:Cap.ValueRead<H,List<&2,U32>>}
def bad(~H:Type,actual:W.Reads<H>) -> ExtraReads<H>:
  actual
