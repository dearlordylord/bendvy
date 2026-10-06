import Base
import full-functional.bend as F
import ../../src/ecs/component.bend as C
import ../../src/ecs/provider.bend as Pv
import ../../src/ecs/query.bend as Q
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as T
def bad(~H: Type,~get: H -> H & C.Access<U32>,~aux: H -> H & C.Access<U32>,~resource_get: H -> H & U32,left: H,right: H) -> H & H:
  (left,right)
def main() -> U32:
  0
