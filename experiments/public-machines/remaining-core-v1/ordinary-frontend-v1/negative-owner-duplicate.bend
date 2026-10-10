import Base
import consumer.bend as C
import frontend.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def rejected(~H:Type,owner:H) -> H & H:(owner,owner)
