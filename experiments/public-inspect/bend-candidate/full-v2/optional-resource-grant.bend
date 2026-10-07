import Base
import optional-resource.bend as Slot
import ../inspect.bend as I
import ../../../../src/ecs/capabilities.bend as Cap

# Absence projects as None; arbitrary affine resource payloads never cross H.
def inspect(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~Payload:Type,~V:Data,~take:R -> Rest & Slot.Slot<Payload>,~put:Rest -> Slot.Slot<Payload> -> R,~project:Payload -> Payload & V) -> Cap.ValueRead<I.Frame<S,Store,R,E>,Maybe<&2,V>>:
  I.read_resource(~S,~Store,~R,~E,~Maybe<&2,V>,~(resources => Slot.read(~R,~Rest,~Payload,~V,~take,~put,~project,resources)))
