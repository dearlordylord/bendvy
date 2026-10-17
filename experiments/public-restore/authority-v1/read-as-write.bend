import Base
import ../../../src/ecs/capabilities.bend as C
def wrong(~H:Type,cap:C.Read<H,U32>) -> C.Write<H,Array<U32>,U32>:cap
