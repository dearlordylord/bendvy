import Base
import ../binding-fixtures/workshop.bend as D
import ../adoption-positive-workshop.bend as P
import ../../../bend-candidate/consumer.bend as A
import ../../../../../src/ecs/inspector-definition.bend as G
import ../../../../../src/ecs/capabilities.bend as Cap
type ExtraReads<-H:Type> is Type:
  ExtraReads{bonus:Cap.ValueRead<H,List<&2,U32>>,bonusAlias:Cap.ValueRead<H,List<&2,U32>>,score:Cap.ValueRead<H,List<&2,U32>>,undeclared:Cap.ValueRead<H,List<&2,U32>>}
def bad(~H:Type,actual:D.Reads<H>) -> ExtraReads<H>:
  actual
