import Base
import ../../../ordinary-declaration-v1/caller.bend as Caller
import ../../../../../src/ecs/ordinary-query-observable.bend as O
import ../../../../../src/ecs/inspector.bend as I
import ../../../../../src/ecs/compose.bend as Q
import ../../../../../src/ecs/inspector-query.bend as IQ
import ../../../../../src/ecs/component.bend as C
import ../../../../../src/ecs/column.bend as Col
import ../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../src/ecs/inspector-query-projection.bend as P
import ../../../../../src/ecs/ordinary-query-declaration.bend as N
import ../../../../../src/ecs/ordinary-system.bend as S
import ../../../../../src/ecs/world.bend as W
import ./positive.bend as Good
def wrong() -> Cap.Write<I.Frame<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32>,Caller.Payload,U32>:
  Good.inspect(~Caller.A)
def main() -> Unit:
  Unit{}
