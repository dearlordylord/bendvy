import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import ../consumer-public.bend as Consumer
import ../types-other.bend as Types
import ../types.bend as Normal
def cross(value:Event.Domain<Types.OtherSchema,U32>) -> Event.Domain<Normal.Schema,U32>:value
def main() -> Unit:Unit{}
