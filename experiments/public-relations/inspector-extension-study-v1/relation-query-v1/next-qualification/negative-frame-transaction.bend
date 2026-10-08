import Base
import ../fixture-schema.bend as D
import ../core-v1/src/ecs/world.bend as W
import ../core-v1/src/ecs/inspector.bend as I
import ../core-v1/src/ecs/transaction.bend as X

def transaction_from_read(frame:I.Frame<D.Workshop,Unit,Unit,D.FixtureEvent>) -> X.Tx<W.World<D.Workshop,Unit,Unit,D.FixtureEvent>,D.FixtureEvent>:
  frame
