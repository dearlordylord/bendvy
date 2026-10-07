import Base
import ../optional-resource.bend as Slot
import ../../consumer.bend as Model
def bad(slot:Slot.Slot<Model.Resource>) -> Slot.Slot<Model.Resource> & Slot.Slot<Model.Resource>:
  (slot,slot)
