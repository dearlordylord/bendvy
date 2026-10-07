import Base
import ../optional-resource.bend as Slot
import ../resource-workshop.bend as A
import ../../consumer.bend as Model
import ../../inspect.bend as I
import ../../../../../src/ecs/capabilities.bend as Cap
def bad(~H:Type,~caps:A.Reads<H>,ctx:H) -> H:
  Cap.value_set(~H,~A.Resources,~Maybe<&2,List<&2,U32>>,~A.score(~H,caps),ctx,A.Resources{Slot.Absent{},Array.new(U32,2n,99)})
