import Base
import ../materialization.bend as Material
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.bend as Input
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/input-codec-v1/business.bend as Business
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/decode-fallible-constructed-requests.bend as Constructed
# Actual raw provider grant cannot be substituted for opaque-H gameplay authority.
def invalid(~S:Data,~H:Type,input:Constructed.Input<S,Input.Input>,ctx:H) -> H & Constructed.Output<S,Input.Input,Business.Owner,Business.Error>:
  Cap.owned_request(~H,~Constructed.Input<S,Input.Input>,~Constructed.Output<S,Input.Input,Business.Owner,Business.Error>,~Material.grants(~S),ctx,input)
