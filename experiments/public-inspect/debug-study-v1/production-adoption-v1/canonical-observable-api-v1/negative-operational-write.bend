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
import ../../../../../src/ecs/transaction.bend as Tx
import ../../../../../src/ecs/system.bend as Sys
import ./positive.bend as Good
def wrong() -> Cap.Write<Q.Frame<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32>,Caller.Payload,U32>:
  N.grant(~Caller.A,~Q.Frame<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32>,~Cap.Read<Q.Frame<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32>,U32>,O.operational(~Caller.A,~Q.Frame<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32>,~Cap.Read<Q.Frame<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32>,U32>,~I.Frame<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32>,~C.Access<U32>,Good.read(~Caller.A)))
