import Base
import ../../core-v1/src/ecs/world.bend as W
import ../../fixture-schema.bend as D
import ../../core-v1/src/ecs/relation-commands.bend as A

# The read-only Check body receives opaque H; it cannot treat it as World.
def legal(~H:Type,owner:W.World<D.Workshop,A.Store<D.Workshop,D.Components<D.Workshop>>,D.Resources,A.Notice<D.Workshop,D.FixtureEvent>>,target:W.Handle<D.Workshop>) -> W.World<D.Workshop,A.Store<D.Workshop,D.Components<D.Workshop>>,D.Resources,A.Notice<D.Workshop,D.FixtureEvent>> & W.Status:
  W.activate(~D.Workshop,~A.Store<D.Workshop,D.Components<D.Workshop>>,~D.Resources,~A.Notice<D.Workshop,D.FixtureEvent>,owner,target)
def main() -> Nat:
  0n
