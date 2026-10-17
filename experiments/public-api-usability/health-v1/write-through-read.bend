import Base
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/world.bend as W
import ../../../examples/scheduled-health/schema.bend as S
import ../../../examples/scheduled-health/components.bend as D
def denied(~H:Type,~grant:Cap.Read<H,D.Health>,owner:H,value:D.Health) -> H:
  Cap.set(~H,~D.Health,~D.Health,~grant,owner,value)
