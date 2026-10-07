import Base
import provider.bend as P
import ../../src/ecs/capabilities.bend as Cap
def bad(-H:Type,cap:Cap.Read<H,U32>,ctx:H) -> H:
  P.write(H,U32,U32,cap,ctx,9)
