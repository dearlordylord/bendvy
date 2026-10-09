import Base
import ../../fixture.bend as Input
import ../business.bend as Business
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/reached-mutations-v1/skip-input-validation/core/decode-fallible-constructed-requests.bend as Constructed
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
# Actual opaque-H text-to-coordinate request may not duplicate its owner.
def body(~S:Data,~H:Type,~cap:Cap.OwnedRequest<H,Constructed.Input<S,Input.Input>,Constructed.Output<S,Input.Input,Business.Owner,Business.Error>>,input:Constructed.Input<S,Input.Input>,ctx:H) -> Constructed.Input<S,Input.Input> & (H & Constructed.Output<S,Input.Input,Business.Owner,Business.Error>):
  (input,Cap.owned_request(~H,~Constructed.Input<S,Input.Input>,~Constructed.Output<S,Input.Input,Business.Owner,Business.Error>,~cap,ctx,input))
