import Base
import full-functional.bend as F
import ../../src/ecs/component.bend as C
import ../../src/ecs/provider.bend as Pv
import ../../src/ecs/query.bend as Q
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as T
def bad(~H: Type,~get: H -> H & C.Access<U32>,~aux: H -> H & C.Access<U32>,~resource_get: H -> H & U32,ctx: H) -> H:
  Pv.Frame{T.begin(~F.World(),~F.GameEvent,F.initial()),W.Handle{1,1},"cell","cell",None{}}
def main() -> U32:
  0
