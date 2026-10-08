import Base
import ../binding-fixtures/workshop.bend as D
import ../adoption-positive-workshop.bend as P
import ../../../bend-candidate/consumer.bend as A
import ../../../../../src/ecs/inspector-definition.bend as G
import ../../../../../src/ecs/capabilities.bend as Cap
def bad(~H:Type,actual:Cap.ValueRead<H,List<&2,U32>>) -> Cap.ValueWrite<H,A.Resource,List<&2,U32>>:
  actual
