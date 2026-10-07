import Base
import ../../../../src/ecs/relation-query.bend as RQ
import ../../../../src/ecs/relation-types.bend as G
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/world.bend as W
import owned-world.bend as O
def bad(~S:Data,-H:Type,caps:Cap.ValueRead<H,RQ.Row<S,List<&2,U32>>>,owner:H) -> U32:
  match owner:
    case W.World{ns,_,_,_,_,_,_,_,_,_,_,_,_}: ns
