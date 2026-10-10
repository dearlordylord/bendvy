import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H

# One-use reconstruction retains every actual phase entry and the other owners.
# Closed World continuations implement only the existing commit/requeue recipes.
# This adapter does not run, flush, publish or roll back a handler itself.
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Owners:Type,
  restore:List<&1,H.Entry<S,C,R,E,V,runner>> -> Owners,
  success:W.World<S,C,R,E> -> W.World<S,C,R,E>,
  failure:W.World<S,C,R,E> -> W.World<S,C,R,E>,
  result:H.PhaseResult<S,C,R,E,V,runner>) -> Owners & Sys.Outcome<W.World<S,C,R,E>,String,Unit>:
  match result:
    case H.Complete{entries,world}:(restore(entries),Sys.Succeeded{success(world),Unit{}})
    case H.Failed{entries,world,error}:(restore(entries),Sys.Failed{failure(world),error})
