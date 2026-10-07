import Base
import runtime-context.bend as X
import ../../src/ecs/capabilities.bend as Cap
def bad(-H:Type,cap:Cap.Action<H>,ctx:H) -> H:
  X.traced(ctx,"unauthorized")
