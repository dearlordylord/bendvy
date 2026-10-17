import Base
import ../fixture.bend as F
import ../../../../src/ecs/world.bend as W

def recover(-H:Type,owner:H) -> W.World<F.Workshop,F.Store<F.Workshop>,Array<U32>,F.Notice<F.Workshop>>:
  owner
