import Base
import ../basic-world-statefree-v1/schema.bend as F
import ../basic-world-statefree-v1/factory.bend as Factory
def wrong(owner:F.Owned(~Factory.Workshop)) -> F.Owned(~Factory.Garden):owner
