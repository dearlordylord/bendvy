import Base
import ../fixture.bend as Input
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/reached-mutations-v1/partial-write/core/decode-fallible-constructed-requests.bend as Request
import ./business.bend as Business
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def body(~S:Data,~H:Type,~cap:Cap.OwnedRequest<H,Request.Input<S,Input.Input>,Request.Output<S,Input.Input,Input.Owner,Business.Error>>,input:Request.Input<S,Input.Input>,ctx:H) -> Request.Input<S,Input.Input> & (H & Request.Output<S,Input.Input,Input.Owner,Business.Error>):
  (input,Cap.owned_request(~H,~Request.Input<S,Input.Input>,~Request.Output<S,Input.Input,Input.Owner,Business.Error>,~cap,ctx,input))
