import Base
import state.bend as V
import schema.bend as S
import query.bend as Q
import gameplay.bend as G
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/component.bend as C
import ../../src/ecs/compose.bend as Compose
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/world.bend as W

def observed(~H: Type,pair: H & C.Access<S.NeighborView>) -> H & (T.Outcome<G.Error> & String):
  (owner,_) = pair
  (owner,(T.Success{},"bad"))
def bad(~H: Type,~ops: G.Ops<H>,action: G.Action,owner: H) -> H & (T.Outcome<G.Error> & String):
  observed(~H,Cap.get(~H,~S.Neighbor,~S.NeighborView,~G.phase(~H,ops),owner))
def main(world: W.World<S.SchemaA,S.Store<S.SchemaA>,Unit,Unit>) -> Compose.Executed<W.World<S.SchemaA,S.Store<S.SchemaA>,Unit,Unit>,Compose.Error<G.Error>,String>:
  Compose.each(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,~G.Caps,~G.Action,~G.Error,~String,~Q.plan(~S.SchemaA),~bad,G.Advance{},world)
