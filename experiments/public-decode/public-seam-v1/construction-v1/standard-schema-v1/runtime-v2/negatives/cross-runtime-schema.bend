import Base
import ../materialization.bend as Material
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.bend as Input
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/input-codec-v1/business.bend as Business
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/decode-fallible-constructed-requests.bend as Constructed
# Actual declaration-derived First grant cannot provision Second provider.
def invalid() -> Cap.OwnedRequest<Material.Owner(~Input.Second),Constructed.Input<Input.Second,Input.Input>,Constructed.Output<Input.Second,Input.Input,Business.Owner,Business.Error>>:
  Material.grants(~Input.First)
