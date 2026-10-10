import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
def forbidden(~H:Type,~E:Data,~observe:H -> H & Ev.Reading<E>,~publish:H -> E -> H,grant:Ev.ReadAccess<H,E,observe>,owner:H,event:E) -> H:Ev.emit(~H,~E,~publish,grant,owner,event)
def main() -> U32:0
