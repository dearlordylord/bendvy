import Base
import ../workshop/schema.bend as S
import ../../../src/ecs/captured-column.bend as K
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/lifecycle.bend as L

# A captured restorer cannot restore two independently supplied affine owners.
def duplicate(restore:K.Slot<S.Stock> -> Col.Column<S.Schema,S.Stock>) -> Col.Column<S.Schema,S.Stock> & Col.Column<S.Schema,S.Stock>:
  (restore(K.Slot{Some{S.Stock{3,ALeaf{7},1n}},L.Stamp{5,9},False{}}),restore(K.Slot{Some{S.Stock{11,ALeaf{19},1n}},L.Stamp{5,9},False{}}))
