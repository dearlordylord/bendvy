import Base
import ../../fixture.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-construction.bend as Constructor
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
# Actual abstract-H gameplay body cannot retain and consume the same raw owner.
def body(~H:Type,~cap:Cap.OwnedRequest<H,Input.Input,Build.Construction<Input.Input,Input.Owner,D.Error>>,input:Input.Input,ctx:H) -> Input.Input & (H & Build.Construction<Input.Input,Input.Owner,D.Error>):
  (input,Cap.owned_request(~H,~Input.Input,~Build.Construction<Input.Input,Input.Owner,D.Error>,~cap,ctx,input))
