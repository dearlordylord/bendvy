import Base
import ../fixture.bend as F
import ../../../../src/ecs/world.bend as W

def access(-H:Type,owner:H) -> H & List<&2,W.Handle<F.Workshop>>:
  W.handles(~F.Workshop,~F.Store<F.Workshop>,~Array<U32>,~F.Notice<F.Workshop>,owner)
