import Base
import ../../host.bend as Host
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def refused(~H:Type,~caps:Host.InspectorOps(H),owner:H) -> H & Bool:
  Cap.value_read(~H,~Bool,~Cap.second(~Host.Ops(H),~Host.CounterOps(H),caps),owner)
