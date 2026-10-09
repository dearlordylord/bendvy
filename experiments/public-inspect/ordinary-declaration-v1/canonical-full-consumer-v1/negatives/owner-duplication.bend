import Base
import ../../../../../src/ecs/inspector-query-projection.bend as D
import ../stage/owner-carrier.bend as Carrier
import ../stage/schema-families.bend as F
import ../../../../../src/ecs/world.bend as W
def bad(~S:Data,~Store:Type,~R:Type,~E:Data,owner:Carrier.InspectOwner<S,Store,R,E>) -> Carrier.InspectOwner<S,Store,R,E> & Carrier.InspectOwner<S,Store,R,E>:
  (owner,owner)
