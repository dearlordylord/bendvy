import Base
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as Cmp

type Payload is Type:
  Payload{owned: Array<U32>,scalar: U32}

def bad(~H: Type,~read: Cap.Read<H,U32>,ctx: H,value: Payload) -> H:
  Cap.set(~H,~Payload,~U32,~read,ctx,value)
def main() -> U32:
  0
