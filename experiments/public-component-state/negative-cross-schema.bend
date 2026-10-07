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

def main(world: W.World<S.SchemaA,S.Store<S.SchemaA>,Unit,Unit>) -> Compose.Executed<W.World<S.SchemaB,S.Store<S.SchemaB>,Unit,Unit>,Compose.Error<G.Error>,String>:
  Q.each(~S.SchemaB,world,G.Advance{})
