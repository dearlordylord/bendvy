import Base
import ../fixture.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-fallible-constructed-resource.bend as Resource
import ./business.bend as Business
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
def body(~H:Type,~cap:Cap.Read<H,D.Raw>,input:Input.Input,ctx:H) -> H & Resource.Output<Input.Input,Input.Owner,Business.Error>:
  Cap.owned_request(~H,~Input.Input,~Resource.Output<Input.Input,Input.Owner,Business.Error>,~cap,ctx,input)
