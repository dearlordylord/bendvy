import Base
import ./capability.bend as Public
import ./application.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input
type Schema is Data: Schema{}
type OtherSchema is Data: OtherSchema{}
def body(-H:Type,cap:Cap.OwnedRequest<H,Public.Input<Schema,Input.Owner>,Public.Output<Schema,Input.Owner,App.Output<Schema>>>,owner:Input.Owner,ctx:H) -> H & App.Output<Schema>:
  App.resource(~Schema,ctx,owner,D.Number{7})
