import Base
import ../../graph-runtime-v1/fixture.bend as F
import ../../basic-world-statefree-v1/factory.bend as Factory
def wrong(owner:F.Owned(~Factory.Workshop)) -> F.Owned(~Factory.Garden):owner
