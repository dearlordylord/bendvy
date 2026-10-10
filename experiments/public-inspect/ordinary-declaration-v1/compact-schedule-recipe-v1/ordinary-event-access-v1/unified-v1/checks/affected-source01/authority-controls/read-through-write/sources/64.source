import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-event-declaration.bend as Event
import ../consumer-public.bend as Consumer
def read(~H:Type,~publish:H -> U32 -> H,~observe:H -> H & Ev.Reading<U32>,ops:Ev.WriteAccess<H,U32,publish>,owner:H) -> H & Ev.Reading<U32>:Ev.all(~H,~U32,~observe,ops,owner)
def main() -> Unit:Unit{}
