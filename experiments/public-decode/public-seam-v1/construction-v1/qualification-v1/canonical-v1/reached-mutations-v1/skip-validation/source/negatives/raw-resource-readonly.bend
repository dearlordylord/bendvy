import Base
import ../fixture.bend as Input
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/reached-mutations-v1/skip-validation/core/decode-constructed-resource.bend as Constructed
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
# Constructed resource is still a write, not a read callback.
def body(~H:Type,~cap:Cap.Read<H,D.Raw>,input:Input.Input,ctx:H) -> H & Constructed.Output<Input.Input,Input.Owner>:
  Cap.owned_request(~H,~Input.Input,~Constructed.Output<Input.Input,Input.Owner>,~cap,ctx,input)
