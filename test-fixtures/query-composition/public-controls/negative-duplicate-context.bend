import Base
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as Cmp

type Payload is Type:
  Payload{owned: Array<U32>,scalar: U32}

def bad(~H: Type,~read: Cap.Read<H,U32>,ctx: H) -> (H & Cmp.Access<U32>) & (H & Cmp.Access<U32>):
  (Cap.read(~H,~U32,~read,ctx),Cap.read(~H,~U32,~read,ctx))
def main() -> U32:
  0
