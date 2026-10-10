import Base
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

type Components<S:Data> is Type:
  Components{cells:Array<U32>}
type Resources<S:Data> is Type:
  Resources{cells:Array<U32>}
def World(~S:Data) -> Type:
  W.World<S,A.Store<S,Components<S>>,Resources<S>,A.Notice<S,U32>>
