import Base
import ./caller.bend as Caller
import ./ordinary-binding.bend as B
import ./ordinary-inspector-declaration.bend as D
import ../../../src/ecs/inspector.bend as I
import ../../../src/ecs/inspector-query.bend as Q
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/inspector-query-projection.bend as Rows
import ../../../src/ecs/ordinary-query-declaration.bend as Normal
def wrong(owner:I.Frame<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32>) -> (I.Frame<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32> & (List<&2,Rows.Row<Caller.A,U32>> & List<&2,Normal.Clause<Caller.A>>)) & I.Frame<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32>:
  (Caller.inspector_read(~Caller.A,owner),owner)
def main() -> Unit:
  Unit{}
