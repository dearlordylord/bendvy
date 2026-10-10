import Base
import ../consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
def duplicate(app:C.Application()) -> C.Application() & C.Application():(app,app)
def main() -> List<&2,String>:C.main()
