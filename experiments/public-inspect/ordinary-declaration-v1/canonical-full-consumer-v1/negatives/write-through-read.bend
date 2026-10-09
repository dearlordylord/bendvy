import Base
import ../../../../../src/ecs/inspector-query.bend as Q
import ../../../../../src/ecs/inspector-query-projection.bend as D
import ../stage/owner-carrier.bend as Carrier
import ../stage/schema-families.bend as F
import ../../../../../src/ecs/world.bend as W
def bad(~H:Type,~cap:Q.ComposedReadQuery<H,F.Workshop,Unit>,owner:H) -> W.World<F.Workshop,F.Store<F.Workshop>,U32,U32> & U32:
  W.replace_resource(~F.Workshop,~F.Store<F.Workshop>,~U32,~U32,owner,99)
