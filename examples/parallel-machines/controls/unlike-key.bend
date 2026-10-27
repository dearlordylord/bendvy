import Base
import ../declarations.bend as D
import ../../../src/ecs/execution-machine-access.bend as Machine

type OtherKey is Data:
  OtherKey{}
def forbidden(~S:Data,~H:Type,cap:Machine.Write<S,D.Key,D.Mode,H>) -> Machine.Write<S,OtherKey,D.Mode,H>:cap
