import Base
import ../stage/selection.bend as D
import ../stage/owner-carrier.bend as Carrier
import ../stage/schema-families.bend as F
import ../../../../../src/ecs/world.bend as W
def bad(~H:Type,~S:Data,cap:D.Read<H,S,Unit>,owner:H,target:W.Handle<S>) -> H & Bool:
  D.matches_field(~H,~S,~Unit,cap)(owner,target)
