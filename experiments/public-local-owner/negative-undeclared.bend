import Base
import ./schema.bend as S
import ../../src/ecs/local.bend as L

# An abstract provider owner is not a concrete cell for another access route.
def undeclared(-H: Type,ops: L.Ops<H,S.Owner,List<&2,U32>>,owner: H) -> H & Unit:
  (L.replace_cell(~S.Owner,owner,S.owned(9,9,9,9)),Unit{})
