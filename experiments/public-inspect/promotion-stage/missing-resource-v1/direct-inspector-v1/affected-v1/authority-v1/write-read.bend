import Base
import ../../host.bend as Host
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def refused(~H:Type,~caps:Host.InspectorOps(H),owner:H) -> H:
  Cap.value_set(~H,~Array<U32>,~List<&2,U32>,~Cap.second(~Host.Ops(H),~Host.CounterOps(H),caps),owner,ALeaf{0})
