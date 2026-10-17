import Base
import schema.bend as S
import ../fixture.bend as F
import ../../../../src/ecs/column.bend as Col

def duplicate(column:Col.Column<F.Workshop,S.Payload>) -> Col.Column<F.Workshop,S.Payload> & Col.Column<F.Workshop,S.Payload>:
  (column,column)
