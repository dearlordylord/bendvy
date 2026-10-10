import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import ../consumer-public.bend as Consumer
def escape(~H:Type,~observe:H -> H & Ev.Reading<U32>,ops:Ev.ReadAccess<H,U32,observe>,owner:H) -> Consumer.Host:owner
def main() -> Unit:Unit{}
