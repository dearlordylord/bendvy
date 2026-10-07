import Base
import ../workshop/schema.bend as S
import ../../../src/ecs/captured-column.bend as K
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/lifecycle.bend as L

def consume(restore:K.Slot<S.Stock> -> Col.Column<S.Schema,S.Stock>) -> Col.Column<S.Schema,S.Stock>:
  restore(K.Slot{Some{S.Stock{3,ALeaf{7},1n}},L.Stamp{5,9},False{}})
