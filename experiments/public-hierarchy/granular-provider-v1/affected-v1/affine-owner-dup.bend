import Base
import ../consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/hierarchy-traversal-provider.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def bad(-F:Type,caps:H.Read<F,C.Alpha>,owner:F,target:W.Handle<C.Alpha>) -> (F & Maybe<&2,W.Handle<C.Alpha>>) & F:
  (H.root(F,C.Alpha,caps,owner,target),owner)
