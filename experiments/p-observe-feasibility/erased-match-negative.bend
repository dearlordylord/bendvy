import Base
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T

def forbidden(-world: R.World) -> {O.snapshot(world) == O.snapshot(world) : T.World}:
  match world:
    case R.World{id,next,rows,pending}: {==}
