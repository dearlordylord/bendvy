import Base
import ../../../src/ecs/column.bend as Col
import ../refusal-control.bend as P
def duplicate(column:Col.Column<P.Schema,P.Payload>) -> Col.Column<P.Schema,P.Payload> & Col.Column<P.Schema,P.Payload>:
  (column,column)
def main() -> IO(Unit):
  IO.print("unreachable")
