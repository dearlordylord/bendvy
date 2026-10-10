import Base
import consumer-expanded.bend as C
import queue.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def rejected(world:W.World<C.SchemaB,Array<Array<U32>>,C.Resources<C.SchemaB>,String>) -> W.World<C.SchemaB,Array<Array<U32>>,C.Resources<C.SchemaB>,String> & W.World<C.SchemaB,Array<Array<U32>>,C.Resources<C.SchemaB>,String>:(world,world)
