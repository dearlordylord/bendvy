import Base
import recipe-app.bend as A
import ../../src/ecs/capabilities.bend as Cap
def bad(-H:Type,cap:Cap.Read<H,U32>,ctx:H) -> String:
  A.owner_text(ctx)
