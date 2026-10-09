import Base
import ../../../../../src/ecs/inspector-query.bend as Q
import ../../../../../src/ecs/inspector-query-projection.bend as D
import ../stage/owner-carrier.bend as Carrier
import ../stage/schema-families.bend as F
import ../../../../../src/ecs/world.bend as W
def bad(~H:Type,~S:Data,cap:Q.ComposedReadQuery<H,S,Unit>,owner:H,target:W.Handle<S>) -> H & Bool:
  D.matches_field(~H,~S,~Unit,cap)(owner,target)
