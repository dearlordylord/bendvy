import Base
import ../../host.bend as Host
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def positive(~H:Type,~caps:Host.InspectorOps(H),owner:H) -> H & Result<&2,&2,Unit,Host.Output()>:
  Host.inspector_body(~H,~caps,Unit{},owner)
