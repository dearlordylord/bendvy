import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/fixture.bend as Input
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/source/input-codec-v1/business.bend as Business
import /workspace/formal-proofs/bendvy/src/ecs/decode-fallible-constructed-requests.bend as Constructed
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
# No write/construction grant can be manufactured from a read-only grant.
def body(~S:Data,~H:Type,~cap:Cap.Read<H,D.Raw>,input:Constructed.Input<S,Input.Input>,ctx:H) -> H & Constructed.Output<S,Input.Input,Business.Owner,Business.Error>:
  Cap.owned_request(~H,~Constructed.Input<S,Input.Input>,~Constructed.Output<S,Input.Input,Business.Owner,Business.Error>,~cap,ctx,input)
