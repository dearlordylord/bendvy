import Base
import ./caller.bend as Caller
import ./ordinary-binding.bend as B
import ./ordinary-inspector-declaration.bend as D
import ../../../src/ecs/inspector.bend as I
import ../../../src/ecs/inspector-query.bend as Q
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/capabilities.bend as Cap
def wrong() -> Cap.Write<I.Frame<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32>,Caller.Payload,U32>:
  D.query(~Caller.A,~I.Frame<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32>,~U32,D.read(~Caller.A,~Col.Column<Caller.A,Caller.Payload>,~Unit,~Caller.Payload,~U32,~Caller.Token,~Caller.take(~Caller.A),~Caller.put(~Caller.A),~Caller.view,~Array<U32>,~U32,~Caller.binding(~Caller.A)))
def main() -> Unit:
  Unit{}
