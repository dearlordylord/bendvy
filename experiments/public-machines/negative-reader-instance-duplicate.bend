import Base
import provider.bend as P
import readers.bend as R
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys

def misuse(~run: W.World<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,Unit> -> R.Input -> Sys.Outcome<W.World<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,Unit>,R.Failure,R.Delivery>,owner: R.Instance<P.SchemaA,run>) -> R.Instance<P.SchemaA,run> & R.Instance<P.SchemaA,run>:
  (owner,owner)
