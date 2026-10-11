import Base
import ../public-v1/state.bend as F
import ../public-v1/event-setup.bend as Events
import ../public-v1/reader-bindings.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-reader.bend as Reader
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
def duplicate(owner:B.FirstOwner()) -> Route.Reader<F.S,F.FirstEvent,Events.State(),Events.take_first,Events.put_first> & Route.Reader<F.S,F.FirstEvent,Events.State(),Events.take_first,Events.put_first>:
  match owner:
    case Reader.Owner{_,reader,_}:(reader,reader)
def main() -> Unit:Unit{}
