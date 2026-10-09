import Base
import ../stage/selection.bend as D
import ../stage/owner-carrier.bend as Carrier
import ../stage/schema-families.bend as F
import ../stage/core-v1/src/ecs/world.bend as W
import ../stage/runtime-named-declarations.bend as N
import ../stage/traversal.bend as T
import ../stage/query.bend as Q
import ../stage/core-v1/src/ecs/inspector.bend as I
def bad() -> Q.ReadQuery<I.Frame<F.Garden,F.Store<F.Garden>,Unit,U32>,F.Garden,N.ValueEmpty>:
  Carrier.inspect_grant(~F.Garden,~Unit,~N.ValueEmpty,~N.inspect_empty(~F.Workshop,~Unit),~T.inspect_world(~F.Garden,~F.Store<F.Garden>,~Unit,~U32))
