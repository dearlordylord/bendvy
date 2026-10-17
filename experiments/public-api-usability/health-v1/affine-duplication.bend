import Base
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/world.bend as W
import ../../../examples/scheduled-health/schema.bend as S
import ../../../examples/scheduled-health/components.bend as D
def denied(~H:Type,owner:H) -> H & H:(owner,owner)
