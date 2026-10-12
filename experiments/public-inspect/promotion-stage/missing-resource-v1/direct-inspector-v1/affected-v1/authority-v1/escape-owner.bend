import Base
import ../../host.bend as Host
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def refused(~H:Type,~caps:Host.InspectorOps(H),owner:H) -> Result<&2,&2,Unit,Host.Output()>:
  Done{owner}
