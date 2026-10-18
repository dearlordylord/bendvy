import Base
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as T

def bad(~H: Type,~read: Cap.Read<H,U32>,world: W.World<Unit,Unit,Unit,U32>,ctx: H) -> H:
  Q.Frame{T.begin(~W.World<Unit,Unit,Unit,U32>,~U32,world),W.Handle{1,1},None{},0}
def main() -> U32:
  0
