import Base
import ../../../../../src/ecs/inspector-query-projection.bend as D
import ../stage/owner-carrier.bend as Carrier
import ../stage/schema-families.bend as F
import ../../../../../src/ecs/world.bend as W
import ../stage/runtime-named-declarations.bend as N
import ../../../../../src/ecs/inspector-query-world.bend as T
import ../../../../../src/ecs/inspector-query.bend as Q
import ../../../../../src/ecs/inspector.bend as I
def bad() -> Q.ComposedReadQuery<I.Frame<F.Garden,F.Store<F.Garden>,Unit,U32>,F.Garden,N.ValueEmpty>:
  Carrier.inspect_grant(~F.Garden,~F.Store<F.Garden>,~Unit,~U32,~N.ValueEmpty,~N.inspect_empty(~F.Workshop,~Unit),~T.inspect_world(~F.Garden,~F.Store<F.Garden>,~Unit,~U32))
