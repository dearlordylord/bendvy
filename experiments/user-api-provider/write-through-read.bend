import Base
import full-functional.bend as F
import ../../src/ecs/component.bend as C
import ../../src/ecs/provider.bend as Pv
import ../../src/ecs/query.bend as Q
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as T
def bad(~H: Type,~get: H -> H & C.Access<U32>,~aux: H -> H & C.Access<U32>,~resource_get: H -> H & U32,ctx: H) -> H:
  Pv.set(~F.Game,~F.Store,~F.Res,~F.GameEvent,~Unit,~F.Cell,~U32,~F.Token,~F.take,~F.put,~F.project,ctx,F.Cell{[9 : U32^1n],9})
def main() -> U32:
  0
