import Base
import consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-operations.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def rejected(~H:Type,~caps:Unit,input:M.QueueInput<C.Value>,owner:H) -> H:F.set(~C.SchemaA,~C.FlowKey,~C.Value,~Array<Array<U32>>,~C.Resources<C.SchemaA>,~String,~C.take_resource(~C.SchemaA),~C.put_resource(~C.SchemaA),~C.same,~C.declaration(~C.SchemaA),owner,input)
