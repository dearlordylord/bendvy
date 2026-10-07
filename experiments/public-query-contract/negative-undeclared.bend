import Base
import ../../src/ecs/query-contract.bend as QC
import ../../examples/query-composition/schema.bend as S
import ../../examples/query-composition/gameplay.bend as G

def bad(~H: Type,~caps: G.WorkOps(H),ctx: H) -> S.World():
  ctx
