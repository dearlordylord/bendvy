import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
def forbidden(~H:Type,~E:Data,~observe:H -> H & Ev.Reading<E>,owner:H) -> H & Ev.Reading<E>:Ev.all(~H,~E,~observe,Unit{},owner)
def main() -> U32:0
