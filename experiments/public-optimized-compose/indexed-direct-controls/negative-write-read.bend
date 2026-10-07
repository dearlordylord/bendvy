import Base
import ../owned-seam-control.bend as S
import ../refusal-control.bend as P
import ../../../src/ecs/owned-compose.bend as O
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/world.bend as W
def body(~H:Type,~caps:S.Ops<H>,args:Bool,row:H) -> H & (T.Outcome<Unit> & List<&2,U32>):
  (Cap.set(~H,~P.Payload,~P.View,~S.first(~H,caps),row,P.Payload{ANode{ALeaf{9},ALeaf{9}}}),(T.Success{},[]))

def probe(world:S.World()) -> Q.Executed<S.World(),Q.Error<Unit>,List<&2,U32>>:
  O.each_fields(~P.Schema,~S.Store,~Unit,~Unit,~S.Bundle,~S.Row,~Bool,~Unit,~List<&2,U32>,~S.Ops{Cap.Read{S.get},Cap.Read{S.get}},~Q.all(~P.Schema,~S.Store,~Unit,~Unit),~S.enter,~S.leave,~body,False{},world)
