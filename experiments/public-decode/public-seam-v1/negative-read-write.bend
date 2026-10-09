import Base
import ./capability.bend as Public
import ./application.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input
type Schema is Data: Schema{}
type OtherSchema is Data: OtherSchema{}
def body(-H:Type,cap:Cap.ValueRead<H,D.Raw>,input:Public.Input<Schema,Input.Owner>,ctx:H) -> H & Public.Output<Schema,Input.Owner,App.Output<Schema>>:
  Public.gameplay(~Schema,~Input.Owner,~App.Output<Schema>,H,cap,input,ctx)
