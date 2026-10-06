import Base
import full-functional.bend as F
import ../../src/ecs/component.bend as C
import ../../src/ecs/column.bend as Col
import ../../src/ecs/provider.bend as Pv
import ../../src/ecs/query.bend as Q
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as T

type Foreign is Data:
  Foreign{}
type ForeignStore is Type:
  ForeignStore{column: Col.Column<Foreign,F.Cell>}
def take(store: ForeignStore) -> Unit & Col.Column<Foreign,F.Cell>:
  match store:
    case ForeignStore{column}: (Unit{},column)
def put(rest: Unit,column: Col.Column<Foreign,F.Cell>) -> ForeignStore:
  ForeignStore{column}
def bad(world: W.World<Foreign,ForeignStore,F.Res,F.GameEvent>) -> W.World<Foreign,ForeignStore,F.Res,F.GameEvent> & C.Access<U32>:
  C.get(~Foreign,~ForeignStore,~F.Res,~F.GameEvent,~Unit,~F.Cell,~U32,~F.Token,~take,~put,~F.project,F.family(),world,W.Handle{1,1})
def main() -> U32:
  0
