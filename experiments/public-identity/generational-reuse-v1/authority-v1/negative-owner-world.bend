import Base
import ../fixture.bend as F

def duplicate(world:F.World(~F.Workshop)) -> F.World(~F.Workshop) & F.World(~F.Workshop):
  (world,world)
