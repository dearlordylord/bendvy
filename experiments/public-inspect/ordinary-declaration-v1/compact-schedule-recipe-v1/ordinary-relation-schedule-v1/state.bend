import Base
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def Components(~S:Data) -> Type:
  Unit
type Resources<S:Data> is Type:
  Resources{cells:Array<U32>}
def World(~S:Data) -> Type:
  W.World<S,A.Store<S,Unit>,Resources<S>,A.Notice<S,U32>>
