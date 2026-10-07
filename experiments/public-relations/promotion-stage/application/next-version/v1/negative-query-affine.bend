import Base
import ../../../../../../src/ecs/relation-query.bend as RQ
import ../../../../../../src/ecs/relation-types.bend as G
import ../../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../../src/ecs/world.bend as W
import owned-world.bend as O
def bad(-H:Type,owner:H) -> H & H:
  (owner,owner)
