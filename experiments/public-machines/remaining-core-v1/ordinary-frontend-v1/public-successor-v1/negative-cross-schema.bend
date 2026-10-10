import Base
import consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-operations.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def rejected(~H:Type,~ops:C.Ops<C.SchemaA,H>,input:M.QueueInput<C.Value>,owner:H) -> H & Unit:C.body(~C.SchemaB,~H,~ops,input,owner)
