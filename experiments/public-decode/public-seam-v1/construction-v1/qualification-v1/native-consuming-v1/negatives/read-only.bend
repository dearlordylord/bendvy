import Base
import ../../canonical-v1/source/fixture.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-validated-resource.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
# Actual resource write cannot be invoked through a read grant.
def body(~H:Type,~cap:Cap.Read<H,D.Raw>,input:Input.Owner,ctx:H) -> H & Resource.Output<Input.Owner>:
  Cap.owned_request(~H,~Input.Owner,~Resource.Output<Input.Owner>,~cap,ctx,input)
