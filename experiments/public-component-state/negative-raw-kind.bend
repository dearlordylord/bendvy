import Base
import ../../src/ecs/state.bend as A
import error-decoders.bend as Decode
import ../public-decode/typed.bend as D
import state.bend as V
import schema.bend as S
import query.bend as Q
import gameplay.bend as G
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/component.bend as C
import ../../src/ecs/compose.bend as Compose
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/world.bend as W

def bad(~H: Type,~ops: G.Ops<H>,action: G.Action,owner: H) -> H & (T.Outcome<G.Error> & String):
  G.phase_raw_done(~H,A.set_raw_result(~H,~V.Phase,~String,~D.Error,~W.WorldError,~Decode.phase,~G.phase_raw_cap(~H,ops),owner,9))
def main(world: W.World<S.SchemaA,S.Store<S.SchemaA>,Unit,Unit>) -> Compose.Executed<W.World<S.SchemaA,S.Store<S.SchemaA>,Unit,Unit>,Compose.Error<G.Error>,String>:
  Compose.each(~S.SchemaA,~S.Store<S.SchemaA>,~Unit,~Unit,~G.Caps,~G.Action,~G.Error,~String,~Q.plan(~S.SchemaA),~bad,G.Advance{},world)
