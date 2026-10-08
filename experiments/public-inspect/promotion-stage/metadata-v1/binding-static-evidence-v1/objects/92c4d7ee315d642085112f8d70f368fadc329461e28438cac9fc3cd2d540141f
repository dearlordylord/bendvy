import Base
import ../binding-fixtures/workshop.bend as W
import ../../../bend-candidate/consumer.bend as A
import ../../../../../src/ecs/capabilities.bend as Cap
def bad(~H:Type,actual:W.Reads<H>) -> Cap.ValueWrite<H,A.Resource,List<&2,U32>>:
  match actual:
    case W.Reads{_,_,score}:score
