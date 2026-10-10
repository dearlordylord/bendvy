import Base
import consumer.bend as C
import frontend.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def rejected(~H:Type,~cap:Cap.ValueRead<H,M.CurrentView<C.SchemaA,C.FlowKey,C.Value>>,input:M.QueueInput<C.Value>,owner:H) -> H:Cap.value_set(~H,~M.QueueInput<C.Value>,~M.CurrentView<C.SchemaA,C.FlowKey,C.Value>,~cap,owner,input)
