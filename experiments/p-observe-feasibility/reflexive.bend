import Base
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T

# Elementary equality infrastructure, not an ECS correspondence theorem.
def reflexive(-world: R.World) -> {O.snapshot(world) == O.snapshot(world) : T.World}:
  {==}
