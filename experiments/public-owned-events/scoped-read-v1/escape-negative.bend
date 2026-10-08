import Base
import read.bend as Read
import controls.bend as Controls
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

def escape(~H:Type,~read:Cap.Request<H,U32,U32>,owner:H) -> H & Cap.Request<H,U32,U32>:
  (owner,read)
def reached(owner:Controls.Payload) -> Controls.Payload & Cap.Request<Controls.Payload,U32,U32>:
  Read.provide(~Controls.Payload,~Cap.Request<Controls.Payload,U32,U32>,~Controls.at,~escape,owner)
