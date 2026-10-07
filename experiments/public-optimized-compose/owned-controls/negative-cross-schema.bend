import Base
import ../owned-seam-control.bend as S
import ../refusal-control.bend as P
import ../../../src/ecs/owned-compose.bend as O
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/world.bend as W
type Other is Data:
  Other{}
def body(~H:Type,~caps:S.Ops<H>,args:Bool,row:H) -> H & (T.Outcome<Unit> & List<&2,U32>):
  S.body(~H,~caps,args,row)
def probe(world:W.World<Other,S.Store,Unit,Unit>) -> Q.Executed<W.World<Other,S.Store,Unit,Unit>,Q.Error<Unit>,List<&2,U32>>:
  O.each(~Other,~S.Store,~Unit,~Unit,~S.Bundle,~S.Row,~Bool,~Unit,~List<&2,U32>,~O.Plan{S.Ops{Cap.Read{S.get},Cap.Read{S.get}},Q.all(~P.Schema,~S.Store,~Unit,~Unit),S.enter,S.leave},~body,False{},world)
