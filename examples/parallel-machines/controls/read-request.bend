import Base
import ../declarations.bend as D
import ../../../src/ecs/execution-machine-access.bend as Machine
import ../../../src/ecs/machine.bend as M

def forbidden(~S:Data,~H:Type,cap:Machine.Read<S,D.Key,D.Mode,H>) -> M.QueueInput<D.Mode> -> H -> H & Unit:
  Machine.request_field(~S,~D.Key,~D.Mode,~H,cap)
