import Base
import ../consumer.bend as C
import ../../../owners.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/relation-cleanup.bend as Cleanup
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def clear_resource(resource:Array<U32>,_:W.Handle<C.Alpha>) -> Array<U32> & List<&2,A.Notice<C.Alpha,U32>>:
  (resource,[])
def bad(world:W.World<C.Alpha,A.Store<C.Alpha,O.Components<C.Alpha>>,Array<U32>,A.Notice<C.Alpha,U32>>,handle:W.Handle<C.Alpha>) -> Cleanup.CleanupResult<C.Alpha,O.Components<C.Alpha>,Array<U32>,U32>:
  Cleanup.automatic(~C.Alpha,~O.Components<C.Alpha>,~Array<U32>,~U32,~clear_resource,~C.despawn_notice(~C.Alpha),world,handle,[C.parent(~C.Alpha),C.link(~C.Alpha)])
