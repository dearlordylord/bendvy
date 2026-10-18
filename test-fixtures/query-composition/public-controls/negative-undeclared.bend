import Base
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/compose.bend as Q

def bad(~H: Type,~read: Cap.Read<H,U32>,ctx: H) -> H:
  Q.resource_set(~Unit,~Unit,~Unit,~U32,ctx,Unit{})
def main() -> U32:
  0
