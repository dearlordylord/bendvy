import Base
import ../../src/ecs/state.bend as A
import state.bend as V
import schema.bend as S
import query.bend as Q
import gameplay.bend as G
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/component.bend as C
import ../../src/ecs/compose.bend as Compose
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/world.bend as W

def read_cap(~H: Type,~ops: G.Ops<H>) -> Cap.Read<H,V.Phase>:
  Cap.Read{Cap.write_read_field(~H,~V.Phase,~V.Phase,G.phase(~H,ops))}
def observed(~H: Type,pair: H & A.Outcome<V.Phase,W.WorldError>) -> H & (T.Outcome<G.Error> & String):
  (owner,_) = pair
  (owner,(T.Success{},"bad"))
def bad(~H: Type,~ops: G.Ops<H>,action: G.Action,owner: H) -> H & (T.Outcome<G.Error> & String):
  observed(~H,A.compare_set(~H,~V.Phase,~W.WorldError,~V.phase_equal,~read_cap(~H,~ops),~read_cap(~H,~ops),owner,V.Ready{},V.Windup{}))
def main(world: W.World<S.SchemaA,S.Store<S.SchemaA>,Unit,Unit>) -> Compose.Executed<W.World<S.SchemaA,S.Store<S.SchemaA>,Unit,Unit>,Compose.Error<G.Error>,String>:
  Compose.each(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,~G.Caps,~G.Action,~G.Error,~String,~Q.plan(~S.SchemaA),~bad,G.Advance{},world)
