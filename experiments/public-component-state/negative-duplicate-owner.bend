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

def duplicate(~H: Type,owner: H) -> H & H:
  (owner,owner)
def duplicated(~H: Type,pair: H & H) -> H & (T.Outcome<G.Error> & String):
  (owner,_) = pair
  (owner,(T.Success{},"bad"))
def bad(~H: Type,~ops: G.Ops<H>,action: G.Action,owner: H) -> H & (T.Outcome<G.Error> & String):
  duplicated(~H,duplicate(~H,owner))
def main(world: W.World<S.SchemaA,S.Store<S.SchemaA>,Unit,Unit>) -> Compose.Executed<W.World<S.SchemaA,S.Store<S.SchemaA>,Unit,Unit>,Compose.Error<G.Error>,String>:
  Compose.each(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,~G.Caps,~G.Action,~G.Error,~String,~Q.plan(~S.SchemaA),~bad,G.Advance{},world)
