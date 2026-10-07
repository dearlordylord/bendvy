import Base
import ../../../../../../../src/ecs/relation-query.bend as RQ
import ../../../../../../../src/ecs/relation-types.bend as G
import ../../../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../../../src/ecs/world.bend as W
import owned-world.bend as O
def bad(~S:Data,-H:Type,caps:Cap.ValueRead<H,RQ.Row<S,List<&2,U32>>>,owner:H) -> H & RQ.Row<S,List<&2,U32>>:
  Cap.value_read(~H,~RQ.Row<S,List<&2,U32>>,~relation_read,owner)
