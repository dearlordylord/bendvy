import Base
import ../consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/hierarchy-provider.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-reorder.bend as R
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
def bad(-F:Type,caps:H.Read<F,C.Alpha>,owner:F,args:R.Args<C.Alpha>) -> F & A.QueueStatus:
  R.body(~C.Alpha,F,caps,args,owner)
