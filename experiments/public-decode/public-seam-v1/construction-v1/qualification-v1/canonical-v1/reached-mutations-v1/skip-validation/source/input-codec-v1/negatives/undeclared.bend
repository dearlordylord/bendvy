import Base
import ../../fixture.bend as Input
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/reached-mutations-v1/skip-validation/core/decode-construction.bend as Constructor
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
# A read-only provisioned body has no construction capability.
def body(~H:Type,~cap:Cap.Read<H,D.Raw>,input:Input.Input,ctx:H) -> H & Build.Construction<Input.Input,Input.Owner,D.Error>:
  Cap.owned_request(~H,~Input.Input,~Build.Construction<Input.Input,Input.Owner,D.Error>,~cap,ctx,input)
