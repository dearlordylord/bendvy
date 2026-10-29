import Base
import ../declarations.bend as D
import ../../../src/ecs/execution-machine-access.bend as Machine

type First is Data:
  First{}
type Second is Data:
  Second{}
def forbidden(~H:Type,cap:Machine.Write<First,D.Key,D.Mode,H>) -> Machine.Write<Second,D.Key,D.Mode,H>:cap
