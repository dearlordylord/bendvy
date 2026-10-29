import Base
import ../../src/ecs/chunk-column.bend as C
import ./query.bend as F
def duplicate(+column:C.Column<F.First,F.Output>) -> C.Column<F.First,F.Output> & C.Column<F.First,F.Output>:
  (column,column)
