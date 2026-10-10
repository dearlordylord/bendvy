import Base
import ../consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
def duplicate(owner:Array<U32>) -> Array<U32> & Array<U32>:(owner,owner)
def main() -> List<&2,String>:C.main()
