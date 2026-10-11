import Base
import ../consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/hierarchy-traversal-provider.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/experiments/public-hierarchy/public-delivery-v1/owners.bend as O
def bad(-F:Type,caps:H.Read<F,C.Alpha>,owner:F) -> W.World<C.Alpha,A.Store<C.Alpha,O.Components<C.Alpha>>,Array<U32>,A.Notice<C.Alpha,U32>>:
  owner
