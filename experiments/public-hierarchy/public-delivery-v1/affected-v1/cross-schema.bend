import Base
import ../consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/hierarchy-provider.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def bad(-F:Type,caps:H.Read<F,C.Alpha>,owner:F,target:W.Handle<C.Alpha>) -> F & Maybe<&2,H.Frame<C.Alpha>>:
  H.read(F,C.Beta,caps,owner,target)
