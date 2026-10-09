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
def wrong(owner:S.Owner<Caller.A,Sys.Registry<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,S.observable_runner(~Caller.A,~Col.Column<Caller.A,Caller.Payload>,~Array<U32>,~U32,~Good.ops,~Unit,~Unit,~Unit,~C.Access<U32>,~Good.read(~Caller.A),~Good.body)>>) -> S.Owner<Caller.A,Sys.Registry<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,S.observable_runner(~Caller.A,~Col.Column<Caller.A,Caller.Payload>,~Array<U32>,~U32,~Good.ops,~Unit,~Unit,~Unit,~C.Access<U32>,~Good.read(~Caller.A),~Good.body)>> & S.Owner<Caller.A,Sys.Registry<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,S.observable_runner(~Caller.A,~Col.Column<Caller.A,Caller.Payload>,~Array<U32>,~U32,~Good.ops,~Unit,~Unit,~Unit,~C.Access<U32>,~Good.read(~Caller.A),~Good.body)>>:
  (owner,owner)
