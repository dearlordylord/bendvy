import Base
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T

def inspect(-snapshot: T.World) -> {snapshot == snapshot : T.World}:
  match snapshot:
    case T.World{id,next,rows,pending}: {==}
def forbidden(-world: R.World) -> {O.snapshot(world) == O.snapshot(world) : T.World}:
  inspect(O.snapshot(world))
