import Base
import ../retained-workshop.bend as A
import ../../consumer.bend as Model
import ../../../../../src/ecs/capabilities.bend as Cap

def bad(~H:Type,~caps:A.Reads<H>,ctx:H) -> H:
  Cap.value_set(~H,~Model.Resource,~List<&2,U32>,~A.score_cap(~H,caps),ctx,Model.Resource{Array.new(U32,2n,99)})
