import Base
import consumer-expanded.bend as C
import queue.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def rejected(frame:Tx.Tx<W.World<C.SchemaB,Array<Array<U32>>,C.Resources<C.SchemaB>,String>,String>) -> Tx.Tx<W.World<C.SchemaB,Array<Array<U32>>,C.Resources<C.SchemaB>,String>,String>:Q.next_declared(~C.SchemaB,~C.FlowKey,~C.Value,~W.World<C.SchemaB,Array<Array<U32>>,C.Resources<C.SchemaB>,String>,~String,~C.take(~C.SchemaB),~C.put(~C.SchemaB),~C.same,C.family(~C.SchemaA),frame,M.Set{C.Value{C.Play{},21},True{}})
