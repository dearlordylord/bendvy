import Base
import ../basic-world-statefree-v1/schema.bend as F
import ../basic-world-statefree-v1/factory.bend as Factory
def wrong(~H:Type,owner:H) -> F.Owned(~Factory.Workshop):owner
