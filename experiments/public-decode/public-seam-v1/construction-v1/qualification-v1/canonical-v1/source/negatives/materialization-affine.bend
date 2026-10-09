import Base
import ../fixture.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-constructed-requests.bend as Constructed
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
# Registered delivery cannot duplicate the arbitrary input owner.
def body(~S:Data,~H:Type,~cap:Cap.OwnedRequest<H,Constructed.Input<S,Input.Input>,Constructed.Output<S,Input.Input,Input.Owner>>,input:Constructed.Input<S,Input.Input>,ctx:H) -> Constructed.Input<S,Input.Input> & (H & Constructed.Output<S,Input.Input,Input.Owner>):
  (input,Cap.owned_request(~H,~Constructed.Input<S,Input.Input>,~Constructed.Output<S,Input.Input,Input.Owner>,~cap,ctx,input))
