import Base
import ../public-v1/state.bend as F
import ../public-v1/event-setup.bend as Events
import ../public-v1/reader-bindings.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-reader.bend as Reader
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
def duplicate(owner:B.FirstOwner()) -> B.FirstOwner() & B.FirstOwner():(owner,owner)
def main() -> Unit:Unit{}
