import Base
import relation-commands.bend as A
import owned-world.bend as O
import ../../../src/ecs/world.bend as W

def bad(~S: Data,components: O.Components<S>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & U32:
  W.namespace(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,components)
