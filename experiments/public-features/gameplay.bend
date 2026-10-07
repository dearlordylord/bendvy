import Base
import provider.bend as P
import ../../src/ecs/component.bend as C
import ../../src/ecs/capabilities.bend as Cap
def observe(-H:Type,cap:Cap.Read<H,U32>,ctx:H) -> H & C.Access<U32>:
  P.read(H,U32,cap,ctx)
def action(-H:Type,cap:Cap.Action<H>,ctx:H) -> H:
  P.action(H,cap,ctx)
