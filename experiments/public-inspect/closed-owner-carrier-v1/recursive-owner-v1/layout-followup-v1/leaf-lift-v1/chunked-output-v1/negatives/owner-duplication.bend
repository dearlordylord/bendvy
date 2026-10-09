import Base
import ../stage/selection.bend as D
import ../stage/owner-carrier.bend as Carrier
import ../stage/schema-families.bend as F
import ../stage/core-v1/src/ecs/world.bend as W
def bad(~S:Data,~R:Type,owner:Carrier.InspectOwner<S,R>) -> Carrier.InspectOwner<S,R> & Carrier.InspectOwner<S,R>:
  (owner,owner)
