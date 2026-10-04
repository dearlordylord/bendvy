import Base
import ./types.bend as T
import ./runtime.bend as R
import ./owned-spec.bend as O

def erased_proposition(-world: R.World) -> Type:
  {O.snapshot(world) == O.snapshot(world) : T.World}
def forward(world: R.World) -> R.World:
  world
