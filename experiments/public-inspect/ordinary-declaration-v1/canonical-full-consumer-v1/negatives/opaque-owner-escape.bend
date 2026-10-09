import Base
import ../../../../../src/ecs/inspector-query.bend as Q
import ../../../../../src/ecs/inspector-query-projection.bend as D
import ../stage/owner-carrier.bend as Carrier
import ../stage/schema-families.bend as F
import ../../../../../src/ecs/world.bend as W
def bad(~H:Type,~cap:Q.ComposedReadQuery<H,F.Workshop,Unit>,owner:H) -> Carrier.InspectOwner<F.Workshop,F.Store<F.Workshop>,Unit,U32>:
  owner
