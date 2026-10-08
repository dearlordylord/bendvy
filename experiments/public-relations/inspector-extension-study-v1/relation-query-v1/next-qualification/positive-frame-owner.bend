import Base
import ../fixture-schema.bend as D
import ../core-v1/src/ecs/inspector.bend as I

def owner_return(frame:I.Frame<D.Workshop,Unit,Unit,D.FixtureEvent>) -> I.Frame<D.Workshop,Unit,Unit,D.FixtureEvent>:
  frame
